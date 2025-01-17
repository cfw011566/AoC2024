const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");
const Map = @import("map.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(41, puzzle1(allocator, example));
    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(6, puzzle2(allocator, example));
    const part2 = try puzzle2(allocator, input);
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(41, puzzle1(allocator, example));
}

test "puzzle 2" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(6, puzzle2(allocator, example));
}

fn print_puzzle(puzzle: [][]usize) void {
    for (0..puzzle.len) |i| {
        std.debug.print("{x:4}\n", .{puzzle[i]});
    }
    std.debug.print("\n", .{});
    return;
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var map = try Map.init(allocator, content);
    defer map.deinit();
    return map.solve() orelse 0;
}

fn puzzle2(allocator: std.mem.Allocator, content: []const u8) !usize {
    var map = try Map.init(allocator, content);
    defer map.deinit();

    var solution = try map.clone(allocator);
    defer solution.deinit();

    _ = solution.solve() orelse 0;

    // print_puzzle(solution.cells);

    var loop_count: usize = 0;
    for (0..solution.rows) |r| {
        for (0..solution.columns) |c| {
            const cell = solution.cells[r][c];
            const is_obstacle = (cell & (1 << @intFromEnum(Map.Status.obstacle)) != 0);
            const is_player_pos = (cell & (1 << @intFromEnum(Map.Status.player)) != 0);
            if (is_obstacle == false and is_player_pos == false and cell != 0) {
                // std.debug.print("r = {d} c = {d} cell = {x}\n", .{ r, c, cell });
                var new_map = try map.clone(allocator);
                defer new_map.deinit();
                new_map.cells[r][c] = 1 << @intFromEnum(Map.Status.obstacle);
                if (new_map.solve() == null) {
                    loop_count += 1;
                    // print_puzzle(new_map.cells);
                }
            }
        }
    }

    return loop_count;
}
