// ===========================================================================
// 02_records.zig  --  Records and memory management in Zig
// CCS 238 Final Project: Forth (1970) vs. Zig (2016)
// Run:  zig run 02_records.zig
//
// Topics exercised: Names, bindings, scope & lifetime (stack vs. static vs.
// heap memory), record handling, allocator-based leak detection.
//
// Zig's rule: no hidden allocations.  Any function that needs heap memory
// takes an `Allocator` parameter, so the CALLER decides where memory comes
// from (a general-purpose heap, a buffer on the stack, an arena, ...).
// ===========================================================================

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

// ---------------------------------------------------------------------------
// Static data.  A container-level `const` initialised with a literal is
// evaluated at compile time and stored in the executable's read-only data.
// `[_]u32{...}` is an array whose length (_) is inferred from the literal.
// ---------------------------------------------------------------------------
const cutoffs = [_]u32{ 90, 80, 70, 60, 0 };

fn letter(score: u32) u8 {
    // A multi-object for loop walks two arrays of equal length in lock-step.
    for (cutoffs, "ABCDF") |cutoff, grade| {
        if (score >= cutoff) return grade;
    }
    unreachable; // the 0 cutoff always matches; in safe builds this would panic
}

// ---------------------------------------------------------------------------
// A record type.  Fields have names and types checked by the compiler.
// `[]const u8` is a SLICE: a pointer plus a length, so a string always knows
// its own size (no separate length cell as in the Forth version).
// ---------------------------------------------------------------------------
const Student = struct {
    name: []const u8,
    score: u32,
};

const Roster = struct {
    // std.ArrayList is a growable array.  It does NOT store an allocator;
    // every method that may allocate or free takes one explicitly.
    students: std.ArrayList(Student) = .empty,

    fn add(self: *Roster, gpa: Allocator, name: []const u8, score: u32) Allocator.Error!void {
        const owned = try gpa.dupe(u8, name); // heap copy of the name
        // errdefer runs ONLY if this function later returns an error, so a
        // failed append cannot leak the name we just copied.
        errdefer gpa.free(owned);
        try self.students.append(gpa, .{ .name = owned, .score = score });
    }

    fn remove(self: *Roster, gpa: Allocator, name: []const u8) bool {
        for (self.students.items, 0..) |s, i| {
            if (std.mem.eql(u8, s.name, name)) {
                gpa.free(s.name); // free the name we own ...
                _ = self.students.orderedRemove(i); // ... then drop the record
                return true;
            }
        }
        return false;
    }

    fn deinit(self: *Roster, gpa: Allocator) void {
        for (self.students.items) |s| gpa.free(s.name);
        self.students.deinit(gpa);
    }

    // `?*const Student` is an OPTIONAL pointer: either a pointer or null.
    // The type system, not a convention like "0 = none", marks absence.
    fn best(self: *const Roster) ?*const Student {
        var top: ?*const Student = null;
        for (self.students.items) |*s| { // |*s| captures a pointer to each item
            if (top == null or s.score > top.?.score) top = s; // .? unwraps
        }
        return top;
    }

    fn print(self: *const Roster, w: *Io.Writer) Io.Writer.Error!void {
        var total: u32 = 0;
        for (self.students.items) |s| {
            try w.print("  {s:<12}{d:>3}  {c}\n", .{ s.name, s.score, letter(s.score) });
            total += s.score;
        }
        const count = self.students.items.len;
        // Conversions are explicit: @floatFromInt turns an integer into the
        // float type the result location asks for (f64 here).
        const avg: f64 = @as(f64, @floatFromInt(total)) / @as(f64, @floatFromInt(count));
        const top = self.best().?;
        try w.print("  count: {d} average: {d:.2}  best: {s} ({d})\n", .{ count, avg, top.name, top.score });
    }
};

const names = [_][]const u8{ "Ana", "Ben", "Carla", "Dan", "Eve" };
const scores = [_]u32{ 92, 78, 85, 64, 99 };

// The same function works with ANY allocator; it cannot tell (and does not
// care) whether the memory is on the heap or inside a stack buffer.
fn buildRoster(gpa: Allocator, roster: *Roster) Allocator.Error!void {
    for (names, scores) |n, s| try roster.add(gpa, n, s);
}

pub fn main(init: std.process.Init) !void {
    var out_buf: [2048]u8 = undefined;
    var out_file: Io.File.Writer = .init(.stdout(), init.io, &out_buf);
    const w = &out_file.interface;
    defer w.flush() catch {};

    // --- 1. Heap memory through a leak-checking allocator -----------------
    try w.print("=== Heap records: DebugAllocator ===\n", .{});
    {
        // DebugAllocator records every allocation; deinit() reports leaks.
        var debug_alloc: std.heap.DebugAllocator(.{}) = .init;
        const gpa = debug_alloc.allocator();

        var roster: Roster = .{};
        try buildRoster(gpa, &roster);
        try roster.print(w);

        try w.print("\nRemoving Dan ...\n", .{});
        _ = roster.remove(gpa, "Dan");
        try roster.print(w);

        roster.deinit(gpa);
        // @tagName turns the enum result (.ok or .leak) into a string.
        try w.print("\nleak check after deinit: {s}\n\n", .{@tagName(debug_alloc.deinit())});
    } // block scope: debug_alloc and roster cease to exist here

    // --- 2. Same code, memory taken from a buffer on main's stack ---------
    try w.print("=== Same records, FixedBufferAllocator on the stack ===\n", .{});
    {
        var stack_bytes: [512]u8 = undefined; // lives in this stack frame
        var fba: std.heap.FixedBufferAllocator = .init(&stack_bytes);
        var roster: Roster = .{};
        try buildRoster(fba.allocator(), &roster);
        try roster.print(w);
        try w.print("  bytes of the 512-byte stack buffer in use: {d}\n", .{fba.end_index});
        // No deinit needed: the buffer disappears with the stack frame.
    }

    // --- 3. Running out of memory is an ordinary, catchable error ----------
    try w.print("\n=== Too small a buffer: error.OutOfMemory is a value ===\n", .{});
    {
        var tiny: [160]u8 = undefined; // too small for all five records
        var fba: std.heap.FixedBufferAllocator = .init(&tiny);
        var roster: Roster = .{};
        // `catch |err|` handles the error instead of propagating it with try.
        buildRoster(fba.allocator(), &roster) catch |err| {
            try w.print("  buildRoster failed with error.{s} after {d} record(s)\n", .{ @errorName(err), roster.students.items.len });
        };
    }

    // --- 4. A deliberate leak, detected by the allocator --------------------
    try w.print("\n=== A deliberate leak: allocate and forget ===\n", .{});
    {
        var debug_alloc: std.heap.DebugAllocator(.{}) = .init;
        const gpa = debug_alloc.allocator();
        _ = try gpa.alloc(u8, 64); // result discarded: the block is unreachable
        try w.flush(); // flush stdout so the allocator's stderr report follows
        try w.print("  leak check: {s}  <- reported by the allocator itself (details on stderr)\n", .{@tagName(debug_alloc.deinit())});
    }
}
