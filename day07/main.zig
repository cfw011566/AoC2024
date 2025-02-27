const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var time_0 = std.time.microTimestamp();
    const part1 = try puzzle1(allocator, input);
    var time_1 = std.time.microTimestamp();
    std.debug.print("part1 = {d}\n", .{part1});
    std.debug.print("time = {d} micro seconds\n", .{time_1 - time_0});

    time_0 = std.time.milliTimestamp();
    const part2 = try puzzle2(allocator, input);
    time_1 = std.time.milliTimestamp();
    std.debug.print("part2 = {d}\n", .{part2});
    std.debug.print("time = {d} milli seconds\n", .{time_1 - time_0});
}

test "puzzle1" {
    const allocator = std.testing.allocator;
    const time_0 = std.time.nanoTimestamp();
    const result = try puzzle1(allocator, example);
    const time_1 = std.time.nanoTimestamp();
    try std.testing.expectEqual(3749, result);

    const time_diff = time_1 - time_0;
    std.debug.print("time = {d}\n", .{time_diff});

    const time_diff_str = try std.fmt.allocPrint(allocator, "time diff in nano seconds = {}", .{time_diff});
    defer allocator.free(time_diff_str);

    std.debug.print("{s}\n", .{time_diff_str});
}

test "puzzle2" {
    const allocator = std.testing.allocator;
    const result = try puzzle2(allocator, example);
    try std.testing.expectEqual(11387, result);
}

fn check_two_ops(value_check: usize, numbers: []const usize) bool {
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

fn check_three_ops(value_check: usize, numbers: []const usize) bool {
    const ops = numbers.len - 1;
    const bits = ops * 2;
    const max = @as(usize, 1) << @intCast(bits);
    for (0..max) |op| {
        // std.debug.print("{b} ", .{op});
        var mask: usize = 0b11;
        var mask1: usize = 0b01;
        var mask2: usize = 0b10;
        var res: usize = numbers[0];
        var skip = false;
        for (1..ops + 1) |i| {
            if ((op & mask) == 0) {
                res += numbers[i];
            } else if ((op & mask) == mask1) {
                res *= numbers[i];
            } else if ((op & mask) == mask2) {
                var num = numbers[i];
                while (num > 0) {
                    res *= 10;
                    num /= 10;
                }
                res += numbers[i];
            } else {
                skip = true;
                break;
            }
            if (res > value_check) {
                skip = true;
                break;
            }
            // std.debug.print("{d} ", .{res});
            mask <<= 2;
            mask1 <<= 2;
            mask2 <<= 2;
        }
        // std.debug.print("\n", .{});
        if (!skip and value_check == res) return true;
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
        if (check_two_ops(first, numbers.items)) {
            sum += first;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});
    return sum;
}

fn puzzle2(allocator: std.mem.Allocator, content: []const u8) !u64 {
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
        if (check_three_ops(first, numbers.items)) {
            sum += first;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});
    return sum;
}
