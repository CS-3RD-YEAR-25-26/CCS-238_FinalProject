// ===========================================================================
// 04_rpn_errors.zig  --  A reverse-Polish calculator with error handling
// CCS 238 Final Project: Forth (1970) vs. Zig (2016)
// Run:  zig run 04_rpn_errors.zig
//
// Topics exercised: Exception handling (error sets, error unions, try,
// catch, exhaustive switch), Syntax & semantics (explicit division
// rounding), an explicit stack data structure.
//
// Zig has no built-in operand stack, so the calculator declares one -- a
// generic fixed-capacity stack whose storage sits in the caller's frame.
// ===========================================================================

const std = @import("std");
const Io = std.Io;

// ---------------------------------------------------------------------------
// An ERROR SET is a type: a named set of error values.  Errors are values,
// not exceptions -- they travel through ordinary return values.
// ---------------------------------------------------------------------------
const EvalError = error{
    StackUnderflow,
    StackOverflow,
    DivisionByZero,
    UnknownToken,
    Overflow,
    MalformedExpression,
};

// A generic stack: a function that takes a type and a size at compile time
// and returns a new struct type (compare 03_compile_time_crc32.zig).
fn Stack(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined, // storage is INSIDE the struct value
        len: usize = 0,

        const Self = @This(); // the anonymous struct type being defined

        fn push(self: *Self, value: T) error{StackOverflow}!void {
            if (self.len == capacity) return error.StackOverflow;
            self.items[self.len] = value;
            self.len += 1;
        }

        fn pop(self: *Self) error{StackUnderflow}!T {
            if (self.len == 0) return error.StackUnderflow;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

fn evaluate(expr: []const u8) EvalError!i64 {
    // The whole stack (8 x i64 + a length) is a local variable: it lives in
    // evaluate's stack frame and vanishes when the function returns.
    var stack: Stack(i64, 8) = .{};

    // tokenizeScalar yields the pieces between spaces, skipping empty ones.
    var tokens = std.mem.tokenizeScalar(u8, expr, ' ');
    while (tokens.next()) |tok| {
        if (tok.len == 1 and std.mem.indexOfScalar(u8, "+-*/", tok[0]) != null) {
            // `try` propagates StackUnderflow out of evaluate.  The compiler
            // checks that StackUnderflow is a member of EvalError.
            const b = try stack.pop();
            const a = try stack.pop();
            // `switch` on u8 must cover every value: `else` is required.
            const result = switch (tok[0]) {
                // std.math.add/sub/mul return error.Overflow instead of
                // wrapping silently (contrast with Forth's + and *).
                '+' => try std.math.add(i64, a, b),
                '-' => try std.math.sub(i64, a, b),
                '*' => try std.math.mul(i64, a, b),
                // Plain `/` is rejected for signed integers: the programmer
                // must CHOOSE truncating or flooring division.  divTrunc
                // also returns error.DivisionByZero for b == 0.
                '/' => try std.math.divTrunc(i64, a, b),
                else => unreachable, // excluded by the indexOfScalar test
            };
            try stack.push(result);
        } else {
            // `catch` converts parseInt's own errors into ours.
            const n = std.fmt.parseInt(i64, tok, 10) catch return error.UnknownToken;
            try stack.push(n);
        }
    }
    if (stack.len != 1) return error.MalformedExpression;
    return stack.items[0];
}

// An exhaustive switch over the error set: if a new error were added to
// EvalError and not handled here, the program would not compile.
fn describe(err: EvalError) []const u8 {
    return switch (err) {
        error.StackUnderflow => "stack underflow",
        error.StackOverflow => "stack overflow",
        error.DivisionByZero => "division by zero",
        error.UnknownToken => "unknown token",
        error.Overflow => "integer overflow",
        error.MalformedExpression => "malformed expression (not exactly 1 result)",
    };
}

fn rpn(w: *Io.Writer, expr: []const u8) Io.Writer.Error!void {
    try w.print("\"{s}\" => ", .{expr});
    if (evaluate(expr)) |value| {
        try w.print("{d}\n", .{value});
    } else |err| {
        try w.print("error: {s}\n", .{describe(err)});
    }
}

pub fn main(init: std.process.Init) !void {
    var out_buf: [2048]u8 = undefined;
    var out_file: Io.File.Writer = .init(.stdout(), init.io, &out_buf);
    const w = &out_file.interface;
    defer w.flush() catch {};

    try w.print("=== RPN calculator: Zig error unions ===\n", .{});
    try rpn(w, "3 4 + 2 *");
    try rpn(w, "5 1 2 + 4 * + 3 -");
    try rpn(w, "0 7 - 2 /"); // -7 / 2: truncating division gives -3
    try rpn(w, "1 +");
    try rpn(w, "10 0 /");
    try rpn(w, "2 x *");
    try rpn(w, "2 3 4");
    try rpn(w, "1 2 3 4 5 6 7 8 9");
    try rpn(w, "9223372036854775807 1 +"); // max i64 + 1: detected
    try rpn(w, "");
}
