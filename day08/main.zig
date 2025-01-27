const std = @import("std");
const Map = @import("map.zig");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});

    // const part2 = try puzzle2(allocator, input);
    // std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle1" {
    const allocator = std.testing.allocator;
    const result = try puzzle1(allocator, example);
    try std.testing.expectEqual(14, result);
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    var map = try Map.init(allocator, content);
    defer map.deinit();

    const count = map.solve();

    map.print();

    return count;
}
