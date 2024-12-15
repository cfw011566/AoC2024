const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    try std.testing.expectEqual(161, puzzle1(example));
    const part1 = try puzzle1(input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(48, puzzle2(example));
    const part2 = try puzzle2(input);
    std.debug.print("part2 = {d}\n", .{part2});
}

fn is_valid(inst: []const u8, p_num_1: *usize, p_num_2: *usize) !bool {
    const len = inst.len;
    const comma_pos = std.mem.indexOfScalar(u8, inst, ',') orelse return false;
    const num1 = inst[0..comma_pos];
    const num2 = inst[comma_pos + 1 .. len];
    if (num1.len == 0 or num1.len > 3) return false;
    if (num2.len == 0 or num2.len > 3) return false;
    for (num1) |ch| {
        if (ch < '0' or ch > '9') return false;
    }
    for (num2) |ch| {
        if (ch < '0' or ch > '9') return false;
    }
    p_num_1.* = try std.fmt.parseInt(usize, num1, 10);
    p_num_2.* = try std.fmt.parseInt(usize, num2, 10);
    return true;
}

fn parsing(inst: []const u8) usize {
    var number_1: usize = undefined;
    var number_2: usize = undefined;
    if (is_valid(inst, &number_1, &number_2)) |valid| {
        if (valid) {
            // std.debug.print("{d}: {d},{d}\n", .{ count, number_1, number_2 });
            return number_1 * number_2;
        } else {
            // std.debug.print("false {d} {d}-{d}: {s}\n", .{ count, i, j, mul_inst });
        }
    } else |_| {
        // std.debug.print("error {d} {d}-{d}: {s}\n", .{ count, i, j, mul_inst });
    }
    return 0;
}

fn puzzle1(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');
    var sum: usize = 0;
    while (lines.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        var i: usize = 0;
        while (i < line.len - 8) {
            const tok = line[i .. i + 4];
            if (std.mem.eql(u8, tok, "mul(")) {
                i += 4;
                var j = i;
                while (j - i < 8 and j < line.len) {
                    if (line[j] == ')') {
                        const mul_inst = line[i..j];
                        // std.debug.print("{d}-{d}: {s}\n", .{ i, j, mul_inst });
                        sum += parsing(mul_inst);
                        break;
                    }
                    j += 1;
                }
            } else {
                i += 1;
            }
        }
    }
    return sum;
}

fn puzzle2(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, puzzle, '\n');
    var sum: usize = 0;
    var enable: bool = true;
    while (lines.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        var i: usize = 0;
        while (i < line.len - 8) {
            const dont = line[i .. i + 7];
            const do = line[i .. i + 4];
            if (std.mem.eql(u8, dont, "don't()")) {
                enable = false;
            }
            if (std.mem.eql(u8, do, "do()")) {
                enable = true;
            }
            const tok = line[i .. i + 4];
            if (enable and std.mem.eql(u8, tok, "mul(")) {
                i += 4;
                var j = i;
                while (j - i < 8 and j < line.len) {
                    if (line[j] == ')') {
                        const mul_inst = line[i..j];
                        // std.debug.print("{d}-{d}: {s}\n", .{ i, j, mul_inst });
                        sum += parsing(mul_inst);
                        break;
                    }
                    j += 1;
                }
            } else {
                i += 1;
            }
        }
    }
    return sum;
}
