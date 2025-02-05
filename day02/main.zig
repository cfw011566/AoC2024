const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var timer = try std.time.Timer.start();
    const part1 = try puzzle1(input);
    std.debug.print("{}\n", .{timer.lap()});
    std.debug.print("part1 = {d}\n", .{part1});
    timer.reset();
    const part2 = try puzzle2(allocator, input, false);
    std.debug.print("{}\n", .{timer.lap()});
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    try std.testing.expectEqual(2, puzzle1(example));
}

fn puzzle1(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');

    var count: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var level = try std.fmt.parseInt(isize, it.next().?, 10);
        var level1 = level;
        level = try std.fmt.parseInt(isize, it.next().?, 10);
        var level2 = level;
        var diff = level2 - level1;
        if ((diff == 0) or (@abs(diff) > 3)) continue;
        var safe = true;
        while (it.next()) |level_text| {
            level = try std.fmt.parseInt(isize, level_text, 10);
            level1 = level2;
            level2 = level;
            const diff1 = level2 - level1;
            if ((diff1 == 0) or (@abs(diff1) > 3)) {
                safe = false;
                break;
            }
            if (std.math.sign(diff) != std.math.sign(diff1)) {
                safe = false;
                break;
            }
            diff = diff1;
        }
        if (safe) {
            count += 1;
        }
    }
    return count;
}

fn is_safe(levels: []isize) bool {
    var diff = levels[1] - levels[0];
    if ((diff == 0) or (@abs(diff) > 3)) return false;
    for (2..levels.len) |i| {
        const diff1 = levels[i] - levels[i - 1];
        if ((diff1 == 0) or (@abs(diff1) > 3)) {
            return false;
        }
        if (std.math.sign(diff) != std.math.sign(diff1)) {
            return false;
        }
        diff = diff1;
    }
    return true;
}

fn puzzle2(allocator: std.mem.Allocator, puzzle: []const u8, debug: bool) !usize {
    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');

    var levels = std.ArrayList(isize).init(allocator);
    defer levels.deinit();

    var count: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) break;

        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while (it.next()) |level_text| {
            const level = try std.fmt.parseInt(isize, level_text, 10);
            try levels.append(level);
        }
        if (debug) {
            std.debug.print("line = {s}\n", .{line});
        }

        const len = levels.items.len;
        const levels_minus_one = try allocator.alloc(isize, len - 1);
        defer allocator.free(levels_minus_one);
        for (0..len) |skip| {
            var j: usize = 0;
            for (0..len) |i| {
                if (i != skip) {
                    levels_minus_one[j] = levels.items[i];
                    j += 1;
                }
            }
            if (debug) {
                std.debug.print("{any}\n", .{levels_minus_one});
            }
            if (is_safe(levels_minus_one)) {
                count += 1;
                break;
            }
        }
        levels.clearRetainingCapacity();
    }
    return count;
}

test "puzzle 2" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(4, puzzle2(allocator, example, true));
}
