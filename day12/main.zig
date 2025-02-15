const std = @import("std");

const Map = @import("map.zig");
const Position = @import("position.zig");

const example = @embedFile("example.txt");
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
    return;
}

test "puzzle 1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(1930, puzzle1(allocator, example));
}

const offsets = [_]Position{
    Position{ .row = -1, .column = 0 }, // up
    Position{ .row = 0, .column = 1 }, // right
    Position{ .row = 1, .column = 0 }, // down
    Position{ .row = 0, .column = -1 }, // left
};

fn puzzle1(allocator: std.mem.Allocator, content: []const u8) !usize {
    const map = try Map.init(allocator, content);
    defer map.deinit();

    const L = std.DoublyLinkedList(Position);
    var region_cells = L{};
    var total_regions: usize = 0;
    var sum: usize = 0;
    for (0..map.rows) |row| {
        for (0..map.columns) |col| {
            if (map.cells[row][col].region_id == null) {
                var area: usize = 0;
                var perimiter: usize = 0;
                map.cells[row][col].region_id = total_regions;
                defer total_regions += 1;

                var p1 = try allocator.create(L.Node);
                p1.data = Position{ .row = @intCast(row), .column = @intCast(col) };
                region_cells.append(p1);
                while (region_cells.popFirst()) |p| {
                    defer allocator.destroy(p);
                    // std.debug.print("len = {d} {}\n", .{ region_cells.len, p.data });
                    const pos = p.data;
                    const pos_row = pos.row;
                    const pos_col = pos.column;
                    const p_cell = &(map.cells[@intCast(pos_row)][@intCast(pos_col)]);

                    for (offsets) |offset| {
                        const r = pos_row + offset.row;
                        const c = pos_col + offset.column;
                        if (r < 0 or r >= map.rows or c < 0 or c >= map.columns) {
                            p_cell.perimeters += 1;
                        } else {
                            const p_neighbor = &(map.cells[@intCast(r)][@intCast(c)]);
                            if (p_cell.plant != p_neighbor.plant) {
                                p_cell.perimeters += 1;
                            } else {
                                if (p_neighbor.region_id == null) {
                                    p_neighbor.region_id = p_cell.region_id;
                                    // std.debug.print("add {d},{d}\n", .{ r, c });
                                    var p2 = try allocator.create(L.Node);
                                    p2.data = Position{ .row = r, .column = c };
                                    region_cells.append(p2);
                                }
                            }
                        }
                    }
                    area += 1;
                    perimiter += p_cell.perimeters;
                }
                sum += area * perimiter;
            }
        }
    }

    // std.debug.print("{}\n", .{map});

    return sum;
}
