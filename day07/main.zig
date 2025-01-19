const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
}

test "puzzle1" {
    const allocator = std.testing.allocator;
    const result = try puzzle1(allocator, example);
    try std.testing.expectEqual(result, 3749);
}

fn check(value_check: usize, numbers: []const usize) bool {
    const bits = numbers.len - 1;
    const max = @as(usize, 1) << @intCast(bits);
    for (0..max) |op| {
        var mask: usize = 1;
        var res = numbers[0];
        for (1..bits + 1) |i| {
            if ((op & mask) == 0) {
                res += numbers[i];
            } else {
                res *= numbers[i];
            }
            // std.debug.print("{d} ", .{res});
            mask <<= 1;
        }
        // std.debug.print("\n", .{});
        if (value_check == res) return true;
    }
    return false;
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var sum: usize = 0;
    while (lines.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, " :");
        const first = try std.fmt.parseInt(usize, it.next().?, 10);
        // std.debug.print("{d}:", .{first});
        var numbers = std.ArrayList(usize).init(allocator);
        defer numbers.deinit();
        while (it.next()) |token| {
            const value = try std.fmt.parseInt(usize, token, 10);
            try numbers.append(value);
            // std.debug.print(" {d}", .{value});
        }
        // std.debug.print("\n", .{});
        if (check(first, numbers.items)) {
            sum += first;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});
    return sum;
}
