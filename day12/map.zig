/// map.zig
const std = @import("std");
const Allocator = std.mem.Allocator;
const Garden = @import("garden.zig");

allocator: Allocator,
rows: usize,
columns: usize,
cells: [][]Garden,

const Self = @This();

pub fn init(allocator: Allocator, content: []const u8) !Self {
    var map = std.ArrayList([]Garden).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    while (lines.next()) |line| {
        const row = try allocator.alloc(Garden, line.len);
        for (0..line.len) |i| {
            row[i].plant = line[i];
            row[i].region_id = null;
            row[i].perimeters = 0;
        }
        try map.append(row);
        rows += 1;
    }
    const columns = map.items[0].len;

    return Self{ .allocator = allocator, .rows = rows, .columns = columns, .cells = try map.toOwnedSlice() };
}

pub fn deinit(self: Self) void {
    for (0..self.rows) |i| {
        self.allocator.free(self.cells[i]);
    }
    self.allocator.free(self.cells);
    return;
}

pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    if (fmt.len != 0) {
        std.fmt.invalidFmtError(fmt, self);
    }
    try writer.print("rows = {d}, columns = {d}\n", .{ self.rows, self.columns });
    for (0..self.rows) |i| {
        for (0..self.columns) |j| {
            try writer.print("{}", .{self.cells[i][j]});
        }
        if (i != self.columns - 1) {
            try writer.print("\n", .{});
        }
    }
    return;
}
