const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    const part1 = puzzle1(std.mem.trim(u8, input, " \n"));
    std.debug.print("part1 = {d}\n", .{part1});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const part2 = try puzzle2(allocator, std.mem.trim(u8, input, " \n"));
    std.debug.print("part2 = {d}\n", .{part2});
}

test "puzzle 1" {
    try std.testing.expectEqual(puzzle1(std.mem.trim(u8, example, " \n")), 1928);
}

fn puzzle1(content: []const u8) usize {
    var begin: usize = 0;
    var end: usize = content.len - 1;
    var is_file: bool = true;
    var position: usize = 0;

    std.debug.print("{d} {d}\n", .{ begin, end });
    var file_id: usize = 0;
    var last_file_id: usize = content.len / 2;
    std.debug.print("{d} {d}\n", .{ file_id, last_file_id });

    var checksum: usize = 0;
    var end_left: isize = 0;
    while (begin <= end) {
        if (is_file) {
            const begin_count = content[begin] - '0';
            for (0..begin_count) |_| {
                std.debug.print("{d}", .{file_id});
                checksum += file_id * position;
                position += 1;
                if (begin == end and begin_count > end_left) {
                    break;
                }
            }
            file_id += 1;
        } else {
            var begin_count: isize = content[begin] - '0';
            var end_count: isize = if (end_left == 0) content[end] - '0' else end_left;
            while (begin_count > 0) {
                std.debug.print("{d}", .{last_file_id});
                checksum += last_file_id * position;
                position += 1;
                begin_count -= 1;
                end_count -= 1;
                if (end_count <= 0) {
                    if (begin == end) {
                        break;
                    }
                    end -= 2;
                    last_file_id -= 1;
                    end_count = content[end] - '0';
                }
            }
            end_left = end_count;
        }
        begin += 1;
        is_file = !is_file;
    }
    std.debug.print("\n{d}\n", .{checksum});
    return checksum;
}

test "puzzle 2" {
    const allocator = std.testing.allocator;
    const part2 = try puzzle2(allocator, std.mem.trim(u8, example, " \n"));
    try std.testing.expectEqual(part2, 2858);
}

fn puzzle2(allocator: std.mem.Allocator, content: []const u8) !usize {
    var file_id: usize = 0;
    const last_file_id: usize = content.len / 2;

    var file_system = try allocator.alloc(?usize, content.len * 9);
    defer allocator.free(file_system);

    var file_indexes = try allocator.alloc(usize, last_file_id + 1);
    defer allocator.free(file_indexes);
    var file_counts = try allocator.alloc(usize, last_file_id + 1);
    defer allocator.free(file_counts);
    var free_indexes = try allocator.alloc(usize, last_file_id);
    defer allocator.free(free_indexes);
    var free_counts = try allocator.alloc(usize, last_file_id);
    defer allocator.free(free_counts);

    var position: usize = 0;
    for (content, 0..) |ch, i| {
        const count: usize = ch - '0';
        if (i % 2 == 0) {
            file_indexes[file_id] = position;
            file_counts[file_id] = count;
            for (0..count) |_| {
                file_system[position] = file_id;
                position += 1;
            }
        } else {
            free_indexes[file_id] = position;
            free_counts[file_id] = count;
            for (0..count) |_| {
                file_system[position] = null;
                position += 1;
            }
            file_id += 1;
        }
    }
    //print_file_system(file_system[0..position]);
    //for (0..last_file_id) |i| {
    //    std.debug.print("{d} : {d}\n", .{ free_indexes[i], free_counts[i] });
    //}
    //std.debug.print("\n", .{});
    //for (0..last_file_id + 1) |i| {
    //    std.debug.print("{d} : {d}\n", .{ file_indexes[i], file_counts[i] });
    //}

    //const reverse = try allocator.alloc(u8, content.len);
    //defer allocator.free(reverse);
    //@memcpy(reverse, content);
    //std.mem.reverse(u8, reverse);

    std.mem.reverse(usize, file_indexes);
    std.mem.reverse(usize, file_counts);
    for (file_counts, 0..) |count, ii| {
        for (0..free_counts.len) |c| {
            const free_count = free_counts[c];
            if (count <= free_count) {
                const free_index = free_indexes[c];
                const file_index = file_indexes[ii];
                for (0..count) |j| {
                    file_system[free_index + j] = last_file_id - ii;
                    file_system[file_index + j] = null;
                }
                free_indexes[c] += count;
                free_counts[c] -= count;
                break;
            }
        }
        //print_file_system(file_system[0..position]);
    }
    var checksum: usize = 0;
    for (0..position) |i| {
        if (file_system[i]) |id| {
            checksum += i * id;
        }
    }
    std.debug.print("checksum = {d}\n", .{checksum});

    return checksum;
}

fn print_file_system(system: []?usize) void {
    for (system) |i| {
        if (i) |id| {
            std.debug.print("{d}", .{id});
        } else {
            std.debug.print(".", .{});
        }
    }
    std.debug.print("\n", .{});
}
