// ===========================================================================
// 03_compile_time_crc32.zig  --  Compile-time execution in Zig
// CCS 238 Final Project: Forth (1970) vs. Zig (2016)
// Run:  zig run 03_compile_time_crc32.zig
//
// Topic exercised: Language implementation -- running code while the
// program is being compiled.  Problem: CRC-32 checksums using a 256-entry
// lookup table that is computed before the program runs.
//
// Key idea: Zig has a strict boundary between compile time and run time,
// and the keyword `comptime` moves ordinary Zig code across it.  The same
// language (no separate macro or template language) is used on both sides:
//   1. a comptime-evaluated initializer               (table construction)
//   2. a function that takes a comptime polynomial and RETURNS A TYPE
//                                                     (a "CRC type" maker)
//   3. `inline for` -- loop unrolling by the compiler
//   4. `comptime` expression                          (precomputed constant)
// plus @compileError for a compile-time self-test.
// ===========================================================================

const std = @import("std");
const Io = std.Io;

// One bit-step of the reflected CRC algorithm.  Plain function: callable at
// both compile time and run time.
fn crcBit(poly: u32, c: u32) u32 {
    return if (c & 1 != 0) (c >> 1) ^ poly else c >> 1;
}

// 3. `inline for` over a comptime-known range is unrolled by the compiler:
//    the generated code contains eight crcBit steps and no loop counter.
fn crcEntry(byte: u8, poly: u32) u32 {
    var c: u32 = byte;
    inline for (0..8) |_| c = crcBit(poly, c);
    return c;
}

// ---------------------------------------------------------------------------
// 2. A function from a comptime value to a TYPE.  Types are first-class
//    values at compile time, so "generics" are just functions.  Each distinct
//    polynomial produces a distinct struct type with its own table.
// ---------------------------------------------------------------------------
fn Crc(comptime poly: u32) type {
    // Compile-time validation: a CRC generator must include the x^0 term,
    // which is bit 31 in reflected form.  Violations stop the BUILD.
    if (poly & 0x8000_0000 == 0) @compileError("reflected CRC polynomial must have bit 31 set");

    return struct {
        // 1. A container-level constant is evaluated at compile time.  The
        //    labelled block `blk: { ... break :blk value; }` computes the
        //    table; the finished array is embedded in the executable.
        pub const table: [256]u32 = blk: {
            // The compiler limits comptime loops to catch infinite ones;
            // 256 entries x 8 steps needs a higher quota than the default.
            @setEvalBranchQuota(10_000);
            var t: [256]u32 = undefined;
            for (&t, 0..) |*entry, i| entry.* = crcEntry(@intCast(i), poly);
            break :blk t;
        };

        // Run-time (or compile-time!) checksum of a byte slice.
        pub fn checksum(bytes: []const u8) u32 {
            var crc: u32 = 0xFFFF_FFFF;
            for (bytes) |b| crc = table[(crc ^ b) & 0xFF] ^ (crc >> 8);
            return crc ^ 0xFFFF_FFFF;
        }
    };
}

// Instantiating the "generic" twice creates two types and two tables.
const Crc32 = Crc(0xEDB8_8320); // IEEE 802.3 / zip / PNG
const Crc32C = Crc(0x82F6_3B78); // Castagnoli (iSCSI, ext4)
// Uncomment the next line and the BUILD fails with our @compileError message.
// (Zig analyses declarations lazily: the comptime block forces Crc(1) to be
// instantiated; an unused `const Broken = Crc(1);` alone would be skipped.)
// const Broken = Crc(0x0000_0001); comptime { _ = Broken; }

// ---------------------------------------------------------------------------
// A compile-time self-test.  Everything at container level is evaluated by
// the compiler, so this block runs during the BUILD: if the table were
// wrong, compilation fails and no executable is produced at all.
// ---------------------------------------------------------------------------
comptime {
    if (Crc32.checksum("123456789") != 0xCBF4_3926) @compileError("CRC-32 self-test failed");
}

fn printCrcs(w: *Io.Writer, text: []const u8) Io.Writer.Error!void {
    try w.print("\"{s}\"\n", .{text});
    // {X:0>8} = uppercase hex, padded with '0' to width 8.
    try w.print("    crc32  = {X:0>8}\n", .{Crc32.checksum(text)});
    try w.print("    crc32c = {X:0>8}\n", .{Crc32C.checksum(text)});
}

pub fn main(init: std.process.Init) !void {
    var out_buf: [2048]u8 = undefined;
    var out_file: Io.File.Writer = .init(.stdout(), init.io, &out_buf);
    const w = &out_file.interface;
    defer w.flush() catch {};

    // 4. Inside a function, code runs at RUN time unless the `comptime`
    //    keyword forces the compiler to evaluate it.  Only the resulting
    //    number is stored in the executable.
    const check_value = comptime Crc32.checksum("123456789");

    try w.print("=== CRC tables built at compile time ===\n", .{});
    try w.print("check value computed during compilation: {X:0>8}\n", .{check_value});
    try w.print("crc32 table[1] = {X:0>8}\n", .{Crc32.table[1]});
    // @typeName shows that each instantiation is a distinct type.
    try w.print("distinct types: {s} / {s}\n\n", .{ @typeName(Crc32), @typeName(Crc32C) });

    try printCrcs(w, "123456789");
    try printCrcs(w, "The quick brown fox jumps over the lazy dog");
    try printCrcs(w, "Forth vs. Zig");
    try printCrcs(w, "");
}
