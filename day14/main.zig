const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const part1 = try puzzle1(input, 101, 103, 100);
    var seconds: f64 = @floatFromInt(timer.lap());
    seconds /= 1e9;
    std.debug.print("puzzle 1 = {d} in {d:.6} seconds\n", .{ part1, seconds });
    return;
}

test "puzzle" {
    try std.testing.expectEqual(12, puzzle1(example, 11, 7, 100));
}

pub fn puzzle1(content: []const u8, width: usize, height: usize, seconds: usize) !usize {
    const steps: isize = @intCast(seconds);
    const half_width = width / 2;
    const half_height = height / 2;
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var zones = [_]usize{ 0, 0, 0, 0 };
    while (lines.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, "pv=, ");
        var px: isize = undefined;
        var py: isize = undefined;
        var vx: isize = undefined;
        var vy: isize = undefined;
        var count: usize = 0;
        while (it.next()) |text| {
            const value = try std.fmt.parseInt(isize, text, 10);
            if (count == 0) {
                px = value;
                count = 1;
            } else if (count == 1) {
                py = value;
                count = 2;
            } else if (count == 2) {
                count = 3;
                vx = value;
            } else if (count == 3) {
                vy = value;
            }
        }
        // std.debug.print("{},{} {},{}", .{ px, py, vx, vy });
        px += vx * steps;
        py += vy * steps;
        const x: usize = @intCast(@mod(px, @as(isize, @intCast(width))));
        const y: usize = @intCast(@mod(py, @as(isize, @intCast(height))));
        // std.debug.print(" -> {},{} {},{}\n", .{ px, py, x, y });
        if (x < half_width and y < half_height) {
            zones[0] += 1;
        } else if (x > half_width and y < half_height) {
            zones[1] += 1;
        } else if (x < half_width and y > half_height) {
            zones[2] += 1;
        } else if (x > half_width and y > half_height) {
            zones[3] += 1;
        }
    }
    std.debug.print("{any}\n", .{zones});

    return zones[0] * zones[1] * zones[2] * zones[3];
}
