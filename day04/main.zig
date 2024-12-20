const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(18, puzzle1(allocator, example));
    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(9, puzzle2(allocator, example));
    const part2 = try puzzle2(allocator, input);
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(18, puzzle1(allocator, example));
}

const Offset = struct {
    row: isize,
    column: isize,
};

const offsets = [_]Offset{
    Offset{ .row = -1, .column = 0 },
    Offset{ .row = -1, .column = 1 },
    Offset{ .row = 0, .column = 1 },
    Offset{ .row = 1, .column = 1 },
    Offset{ .row = 1, .column = 0 },
    Offset{ .row = 1, .column = -1 },
    Offset{ .row = 0, .column = -1 },
    Offset{ .row = -1, .column = -1 },
};

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |line| {
        try lines.append(line);
    }

    const puzzle = try lines.toOwnedSlice();
    defer allocator.free(puzzle);

    // print_puzzle(puzzle);

    const rows = puzzle.len;
    const columns = puzzle[0].len;

    // std.debug.print("{d}x{d}\n", .{ rows, columns });

    var count: usize = 0;
    for (0..rows) |row| {
        for (0..columns) |column| {
            for (offsets) |offset| {
                const r3 = @as(isize, @intCast(row)) + 3 * offset.row;
                const c3 = @as(isize, @intCast(column)) + 3 * offset.column;
                if (r3 < 0 or r3 >= rows or c3 < 0 or c3 >= columns) {
                    continue;
                }
                var chars = [_]u8{ 0, 0, 0, 0 };
                for (0..4) |i| {
                    var r: isize = @intCast(row);
                    r += @as(isize, @intCast(i)) * offset.row;
                    var c: isize = @intCast(column);
                    c += @as(isize, @intCast(i)) * offset.column;
                    chars[i] = puzzle[@intCast(r)][@intCast(c)];
                }
                if (std.mem.eql(u8, &chars, "XMAS")) {
                    count += 1;
                }
            }
        }
    }

    return count;
}

fn print_puzzle(puzzle: [][]const u8) void {
    for (puzzle) |line| {
        std.debug.print("{s}\n", .{line});
    }
    return;
}

fn puzzle2(allocator: std.mem.Allocator, content: []const u8) !usize {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |line| {
        try lines.append(line);
    }

    const puzzle = try lines.toOwnedSlice();
    defer allocator.free(puzzle);

    // print_puzzle(puzzle);

    const rows = puzzle.len;
    const columns = puzzle[0].len;

    // std.debug.print("{d}x{d}\n", .{ rows, columns });

    var count: usize = 0;
    for (1..rows - 1) |row| {
        for (1..columns - 1) |column| {
            if (puzzle[row][column] == 'A') {
                const left_top = puzzle[row - 1][column - 1];
                const right_bottom = puzzle[row + 1][column + 1];
                const right_top = puzzle[row - 1][column + 1];
                const left_bottom = puzzle[row + 1][column - 1];
                const str1 = (left_top == 'S' and right_bottom == 'M') or (left_top == 'M' and right_bottom == 'S');
                const str2 = (right_top == 'S' and left_bottom == 'M') or (right_top == 'M' and left_bottom == 'S');
                if (str1 and str2) {
                    count += 1;
                }
            }
        }
    }

    return count;
}
