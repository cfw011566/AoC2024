const std = @import("std");
const Map = @import("map.zig");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const scores = try puzzle1(allocator, input);
    std.debug.print("puzzle 1 = {d}\n", .{scores});

    return;
}

test "puzzle 1" {
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(36, try puzzle1(allocator, example));
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

fn trailheads(map: Map, row: usize, col: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    var path = std.ArrayList(Offset).init(allocator);
    defer path.deinit();

    var r: isize = @intCast(row);
    var c: isize = @intCast(col);
    try path.append(Offset{ .row = r, .column = c });
    var index: usize = 0;
    while (index < path.items.len) {
        r = path.items[index].row;
        c = path.items[index].column;
        const height: usize = map.cells[@intCast(r)][@intCast(c)];
        for (offsets) |offset| {
            const rr = r + offset.row;
            const cc = c + offset.column;
            if (rr >= 0 and rr < map.rows and cc >= 0 and cc < map.columns) {
                const h = map.cells[@intCast(rr)][@intCast(cc)];
                if (h == height + 1) {
                    // std.debug.print("{d},{d}({d}) -> {d},{d}({d})\n", .{ r, c, height, rr, cc, h });
                    try path.append(Offset{ .row = rr, .column = cc });
                }
            }
        }
        index += 1;
    }
    var count: usize = 0;
    const len = path.items.len;
    // find unique postion of 9
    var i = len - 1;
    while (i >= 0) : (i -= 1) {
        const r1: usize = @intCast(path.items[i].row);
        const c1: usize = @intCast(path.items[i].column);
        if (map.cells[r1][c1] == 9) {
            var found = false;
            var j = len - 1;
            while (j > i) : (j -= 1) {
                if (path.items[i].row == path.items[j].row and path.items[i].column == path.items[j].column) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                count += 1;
            }
        } else {
            break;
        }
    }

    return count;
}

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    const map = try Map.init(allocator, content);
    defer map.deinit();

    // map.print();

    var sum: usize = 0;
    for (0..map.rows) |row| {
        for (0..map.columns) |col| {
            if (map.cells[row][col] == 0) {
                const scores = try trailheads(map, row, col);
                std.debug.print("{d} ", .{scores});
                sum += scores;
            }
        }
    }
    std.debug.print("\n", .{});

    return sum;
}
