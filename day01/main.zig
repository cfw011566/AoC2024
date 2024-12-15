const std = @import("std");

const example = @embedFile("example.txt");
//const example2 = @embedFile("example2.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(puzzle1(allocator, example), 11);
    const part1 = try puzzle1(allocator, input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(puzzle2(example), 31);
    const part2 = try puzzle2(input);
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(puzzle1(allocator, example), 11);
}

test "puzzle 2" {
    try std.testing.expectEqual(puzzle2(example), 31);
}

fn puzzle1(allocator: std.mem.Allocator, puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');

    var first_list = std.ArrayList(usize).init(allocator);
    var second_list = std.ArrayList(usize).init(allocator);
    defer {
        first_list.deinit();
        second_list.deinit();
    }

    while (lines.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, " ");
        const first_number = try std.fmt.parseInt(usize, it.next().?, 10);
        const second_number = try std.fmt.parseInt(usize, it.next().?, 10);
        // std.debug.print("{d} {d}\n", .{ first_number, second_number });
        try first_list.append(first_number);
        try second_list.append(second_number);
    }
    std.mem.sort(usize, first_list.items, {}, std.sort.asc(usize));
    std.mem.sort(usize, second_list.items, {}, std.sort.asc(usize));
    // std.debug.print("first list = {any}\n", .{first_list});
    // std.debug.print("second list = {any}\n", .{second_list});
    var sum: usize = 0;
    for (0..first_list.items.len) |i| {
        const first: isize = @intCast(first_list.items[i]);
        const second: isize = @intCast(second_list.items[i]);
        sum += @abs(first - second);
    }
    return sum;
}

fn puzzle2(puzzle: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var first_list = std.ArrayList(usize).init(allocator);
    var second_list = std.ArrayList(usize).init(allocator);
    defer {
        first_list.deinit();
        second_list.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');
    while (lines.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, " ");
        const first_number = try std.fmt.parseInt(usize, it.next().?, 10);
        const second_number = try std.fmt.parseInt(usize, it.next().?, 10);
        // std.debug.print("{d} {d}\n", .{ first_number, second_number });
        try first_list.append(first_number);
        try second_list.append(second_number);
    }
    std.mem.sort(usize, first_list.items, {}, std.sort.asc(usize));
    std.mem.sort(usize, second_list.items, {}, std.sort.asc(usize));
    // std.debug.print("first list = {any}\n", .{first_list});
    // std.debug.print("second list = {any}\n", .{second_list});
    const first_items = first_list.items;
    const second_items = second_list.items;
    const list_len = first_items.len;
    var sum: usize = 0;
    var i: usize = 0;
    var j: usize = 0;
    while ((i < list_len) and (j < list_len)) {
        if (first_items[i] < second_items[j]) {
            i += 1;
        } else if (first_items[i] > second_items[j]) {
            j += 1;
        } else if (first_items[i] == second_items[j]) {
            const number = first_items[i];
            var i_next = i + 1;
            var j_next = j + 1;
            while ((i_next < list_len) and (first_items[i_next] == number)) {
                i_next += 1;
            }
            while ((j_next < list_len) and (second_items[j_next] == number)) {
                j_next += 1;
            }
            // std.debug.print("number = {d}\n", .{number});
            // std.debug.print("i = {d} j = {d}\n", .{ i, j });
            // std.debug.print("i_next {d} j_next = {d}\n", .{ i_next, j_next });
            sum += number * (i_next - i) * (j_next - j);
            i = i_next;
            j = j_next;
        }
    }
    return sum;
}
