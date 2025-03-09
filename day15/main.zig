const std = @import("std");
const Map = @import("Map.zig").Map;
const Direction = @import("Map.zig").Direction;

const small_example = @embedFile("small.txt");
const large_example = @embedFile("large.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var timer = try std.time.Timer.start();
    const part1 = try puzzle1(allocator, input);
    var seconds: f64 = @floatFromInt(timer.lap());
    seconds /= 1e9;
    std.debug.print("puzzle 1 = {d} in {d:.6} seconds\n", .{ part1, seconds });

    //timer.reset();
    //const part2 = try puzzle2(allocator, input);
    //seconds = @floatFromInt(timer.lap());
    //seconds /= 1e9;

    return;
}

test "small" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(2028, puzzle1(allocator, small_example));
}

test "large" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(10092, puzzle1(allocator, large_example));
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, content, '\n');

    var map_data = std.ArrayList([]const u8).init(allocator);
    defer map_data.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) break;
        try map_data.append(line);
    }
    var map = try Map.init(allocator, map_data.items);
    defer map.deinit();
    //std.debug.print("{c}\n", .{map});

    while (lines.next()) |line| {
        for (line) |ch| {
            // std.debug.print("{c}\n", .{ch});
            const direction = switch (ch) {
                '^' => Direction.up,
                '>' => Direction.right,
                'v' => Direction.down,
                '<' => Direction.left,
                else => Direction.none,
            };
            map.move(direction);
            // std.debug.print("{c}", .{map});
            // std.debug.print("robot at ({},{})\n", .{ map.robot.row, map.robot.column });
        }
    }
    // std.debug.print("\n", .{});

    var sum: isize = 0;
    var it = map.iterator();
    while (it.next()) |pos| {
        // std.debug.print("({},{})\n", .{ pos.row, pos.column });
        sum += pos.row * 100 + pos.column;
    }
    // std.debug.print("map\n{c}\nsum={}\n", .{ map, sum });

    return @intCast(sum);
}
