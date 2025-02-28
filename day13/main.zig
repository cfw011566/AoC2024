const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const part1 = try puzzle1(input);
    var seconds: f64 = @floatFromInt(timer.lap());
    seconds /= 1e9;
    std.debug.print("puzzle 1 = {d} in {d:.6} seconds\n", .{ part1, seconds });
    return;
}

const Position = struct {
    x: usize,
    y: usize,

    const Self = @This();
    pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) {
            std.fmt.invalidFmtError(fmt, self);
        }
        try writer.print("({d},{d})", .{ self.x, self.y });
    }
};

const Machine = struct {
    button_a: Position,
    button_b: Position,
    prize: Position,

    const Self = @This();
    pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) {
            std.fmt.invalidFmtError(fmt, self);
        }
        try writer.print("A = {}, B = {}, P = {}", .{ self.button_a, self.button_b, self.prize });
    }
};

test "puzzle1" {
    try std.testing.expectEqual(480, puzzle1(example));
}

fn puzzle1(content: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, content, '\n');
    var parts: usize = 0;
    var machine: Machine = undefined;
    var tokens: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            // std.debug.print("{}\n", .{machine});
            const button_a = machine.button_a;
            const button_b = machine.button_b;
            const prize = machine.prize;
            const ax: isize = @intCast(button_a.x);
            const ay: isize = @intCast(button_a.y);
            const bx: isize = @intCast(button_b.x);
            const by: isize = @intCast(button_b.y);
            const px: isize = @intCast(prize.x);
            const py: isize = @intCast(prize.y);
            const divisor = ax * by - ay * bx;
            const divident_a = px * by - py * bx;
            const divident_b = ax * py - ay * px;
            // std.debug.print("{} {} {}\n", .{ divident_a, divident_b, divisor });
            if ((divisor * divident_a > 0) and (divisor * divident_b > 0)) {
                const rem_a = @rem(divident_a, divisor);
                const rem_b = @rem(divident_a, divisor);
                if (rem_a == 0 and rem_b == 0) {
                    const token_a: usize = @intCast(@divExact(divident_a, divisor));
                    const token_b: usize = @intCast(@divExact(divident_b, divisor));
                    // std.debug.print("token : {} {}\n", .{ token_a, token_b });
                    tokens += token_a * 3 + token_b;
                }
            }
            continue;
        }
        // std.debug.print("{d} {s}\n", .{ parts, line });
        var it = std.mem.tokenizeAny(u8, line, " :,+=ABXY");
        if (parts == 0) {
            _ = it.next();
            if (it.next()) |x_text| {
                machine.button_a.x = try std.fmt.parseInt(usize, x_text, 10);
            }
            if (it.next()) |y_text| {
                machine.button_a.y = try std.fmt.parseInt(usize, y_text, 10);
            }
            parts = 1;
        } else if (parts == 1) {
            _ = it.next();
            if (it.next()) |x_text| {
                machine.button_b.x = try std.fmt.parseInt(usize, x_text, 10);
            }
            if (it.next()) |y_text| {
                machine.button_b.y = try std.fmt.parseInt(usize, y_text, 10);
            }
            parts = 2;
        } else if (parts == 2) {
            _ = it.next();
            if (it.next()) |x_text| {
                machine.prize.x = try std.fmt.parseInt(usize, x_text, 10);
            }
            if (it.next()) |y_text| {
                machine.prize.y = try std.fmt.parseInt(usize, y_text, 10);
            }
            parts = 0;
        } else {
            parts = 0;
        }
    }

    return tokens;
}
