const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(41, puzzle1(allocator, example));
    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
    // try std.testing.expectEqual(6, puzzle2(allocator, example));
    // const part2 = try puzzle2(allocator, input);
    // std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(41, puzzle1(allocator, example));
}

const Offset = struct {
    row: isize,
    column: isize,
};

const offsets = [_]Offset{
    Offset{ .row = -1, .column = 0 },
    Offset{ .row = 0, .column = 1 },
    Offset{ .row = 1, .column = 0 },
    Offset{ .row = 0, .column = -1 },
};

const Direction = enum(u8) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
};

fn print_puzzle(puzzle: [][]usize) void {
    for (0..puzzle.len) |i| {
        std.debug.print("{any}\n", .{puzzle[i]});
    }
    return;
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var map = std.ArrayList([]usize).init(allocator);
    defer {
        for (0..map.items.len) |i| {
            allocator.free(map.items[i]);
        }
        map.deinit();
    }

    var player: Offset = undefined;

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    while (lines.next()) |line| {
        const row = try allocator.alloc(usize, line.len);
        @memset(row, 0);
        for (0..line.len) |column| {
            if (line[column] == '#') {
                row[column] = 255;
            }
            if (line[column] == '^') {
                row[column] = 1;
                player.row = @intCast(rows);
                player.column = @intCast(column);
            }
        }
        try map.append(row);
        rows += 1;
    }
    // std.debug.print("player = {d} {d}\n", .{ player.row, player.column });

    // const puzzle = try map.toOwnedSlice();
    // defer allocator.free(puzzle);

    // print_puzzle(map.items);

    var count: usize = 1;
    var direction: usize = 0;
    const max = map.items.len;
    while (true) {
        const offset = offsets[direction];
        const r: isize = player.row + offset.row;
        const c: isize = player.column + offset.column;
        if (r < 0 or r >= max or c < 0 or c >= max) {
            break;
        }
        if (map.items[@intCast(r)][@intCast(c)] == 255) {
            // turn right 90 degree
            direction += 1;
            direction %= 4;
        } else {
            player.row = r;
            player.column = c;
            if (map.items[@intCast(r)][@intCast(c)] == 0) {
                map.items[@intCast(r)][@intCast(c)] = 1;
                count += 1;
            }
        }
    }

    return count;
}
