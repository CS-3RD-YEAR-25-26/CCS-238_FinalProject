// ===========================================================================
// 01_recursion.zig  --  Recursion and parameter passing in Zig
// CCS 238 Final Project: Forth (1970) vs. Zig (2016)
// Run:  zig run 01_recursion.zig
//
// Topics exercised: Subprograms & parameter passing (explicit, typed
// parameters), Syntax & semantics, checked integer arithmetic.
// ===========================================================================

// @import is a builtin (all builtins start with '@') evaluated at compile
// time; it returns the standard library as an ordinary struct value.
const std = @import("std");
const Io = std.Io;

// ---------------------------------------------------------------------------
// 1. Factorial.  The parameter has a name and a type (u64 = unsigned 64-bit).
//    The return type `error{Overflow}!u64` is an ERROR UNION: the function
//    returns either a u64 or the error value error.Overflow.  The caller is
//    forced by the compiler to handle that possibility.
// ---------------------------------------------------------------------------
fn factorial(n: u64) error{Overflow}!u64 {
    if (n < 2) return 1;
    // `try` unwraps the error union: on error it returns the error to OUR
    // caller immediately, otherwise it yields the u64 value.
    const rest = try factorial(n - 1);
    // std.math.mul detects overflow and returns error.Overflow instead of
    // wrapping.  (A plain `n * rest` would also be checked: in Debug and
    // ReleaseSafe builds an overflowing `*` panics rather than wrap.)
    return std.math.mul(u64, n, rest);
}

// ---------------------------------------------------------------------------
// 2. Towers of Hanoi.  Every argument is passed by value and referred to by
//    name.  `moves` is a POINTER (*u32): the callee updates the caller's
//    counter explicitly through `moves.*` -- no global variable needed.
//    `w` is the output writer, also passed explicitly (Zig has no hidden
//    global stdout; I/O is a capability you hand to a function).
// ---------------------------------------------------------------------------
fn hanoi(w: *Io.Writer, n: u32, from: u8, to: u8, via: u8, moves: *u32) Io.Writer.Error!void {
    if (n == 0) return;
    try hanoi(w, n - 1, from, via, to, moves);
    try w.print("  move disk {d} from peg {c} to peg {c}\n", .{ n, from, to });
    moves.* += 1; // `.*` dereferences the pointer
    try hanoi(w, n - 1, via, to, from, moves);
}

// ---------------------------------------------------------------------------
// main receives a std.process.Init bundle from the runtime.  It carries the
// Io implementation (`init.io`) that every I/O call must be given.
// The `!void` return type means main may fail with any error (inferred set).
// ---------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    // A 1 KiB output buffer that lives on main's stack frame.  `undefined`
    // means "do not initialise": Zig makes uninitialised memory explicit.
    var out_buf: [1024]u8 = undefined;
    var out_file: Io.File.Writer = .init(.stdout(), init.io, &out_buf);
    const w = &out_file.interface;
    // `defer` schedules a statement to run when the scope exits, so the
    // buffered output is flushed no matter how main returns.
    defer w.flush() catch {};

    try w.print("=== Factorial (recursive) ===\n", .{});
    try w.print("n    n! (u64 with checked multiplication)\n", .{});
    // `for (0..22) |i|` iterates over a range, capturing each value as i.
    for (0..22) |i| {
        try w.print("{d:>2}  ", .{i});
        // if/else on an error union: the first capture is the value,
        // `else |err|` captures the error.  Overflow is reported, not hidden.
        if (factorial(i)) |value| {
            try w.print("{d}\n", .{value});
        } else |err| {
            try w.print("error.{s}\n", .{@errorName(err)});
        }
    }

    try w.print("\n=== Towers of Hanoi, 3 disks ===\n", .{});
    var moves: u32 = 0; // `var` = mutable; `const` = immutable binding
    try hanoi(w, 3, 'A', 'C', 'B', &moves); // &moves takes its address
    try w.print("total moves: {d}\n", .{moves});
}
