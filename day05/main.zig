const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(143, puzzle1(allocator, example));
    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(123, puzzle2(allocator, example));
    const part2 = try puzzle2(allocator, input);
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(143, puzzle1(allocator, example));
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var seq_matrix = try allocator.alloc([]usize, 100);
    for (0..100) |i| {
        seq_matrix[i] = try allocator.alloc(usize, 100);
        @memset(seq_matrix[i], 0);
    }
    defer {
        for (0..100) |i| {
            allocator.free(seq_matrix[i]);
        }
        allocator.free(seq_matrix);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');

    // get sequence matrix
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(usize, it.next().?, 10);
        const second = try std.fmt.parseInt(usize, it.next().?, 10);
        // std.debug.print("{d}|{d}\n", .{ first, second });
        seq_matrix[first][second] = 1;
    }

    // get testing lines
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, ',');
        var pages = std.ArrayList(usize).init(allocator);
        defer pages.deinit();
        while (it.next()) |token| {
            const page = try std.fmt.parseInt(usize, token, 10);
            try pages.append(page);
        }
        const items = pages.items;
        const len = items.len;
        var pass: bool = true;
        for (0..len - 1) |i| {
            for (i..len) |j| {
                if (seq_matrix[items[j]][items[i]] == 1) {
                    pass = false;
                    break;
                }
            }
        }
        if (pass) {
            // std.debug.print("{any}\n", .{items});
            const middle = len / 2;
            const page = items[middle];
            sum += page;
        }
    }

    return sum;
}

fn puzzle2(allocator: std.mem.Allocator, content: []const u8) !usize {
    var seq_matrix = try allocator.alloc([]usize, 100);
    for (0..100) |i| {
        seq_matrix[i] = try allocator.alloc(usize, 100);
        @memset(seq_matrix[i], 0);
    }
    defer {
        for (0..100) |i| {
            allocator.free(seq_matrix[i]);
        }
        allocator.free(seq_matrix);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');

    // get sequence matrix
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(usize, it.next().?, 10);
        const second = try std.fmt.parseInt(usize, it.next().?, 10);
        // std.debug.print("{d}|{d}\n", .{ first, second });
        seq_matrix[first][second] = 1;
    }

    // get testing lines
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, ',');
        var pages = std.ArrayList(usize).init(allocator);
        defer pages.deinit();
        while (it.next()) |token| {
            const page = try std.fmt.parseInt(usize, token, 10);
            try pages.append(page);
        }
        var items = pages.items;
        const len = items.len;
        var pass: bool = true;
        for (0..len - 1) |i| {
            for (i..len) |j| {
                if (seq_matrix[items[j]][items[i]] == 1) {
                    pass = false;
                    const temp = items[j];
                    items[j] = items[i];
                    items[i] = temp;
                }
            }
        }
        if (!pass) {
            // std.debug.print("{any}\n", .{items});
            const middle = len / 2;
            const page = items[middle];
            sum += page;
        }
    }

    return sum;
}
