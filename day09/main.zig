const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    const part1 = puzzle1(std.mem.trim(u8, input, " \n"));
    std.debug.print("part1 = {d}\n", .{part1});
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
