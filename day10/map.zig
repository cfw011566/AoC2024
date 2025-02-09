/// map.zig
const std = @import("std");
const Allocator = std.mem.Allocator;

const Direction = enum(u8) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
};

pub const Status = enum(u8) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
    player = 14,
    obstacle = 15,
};

allocator: Allocator,
rows: usize,
columns: usize,
cells: [][]usize,

const Self = @This();

pub fn init(allocator: Allocator, content: []const u8) !Self {
    var map = std.ArrayList([]usize).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    while (lines.next()) |line| {
        const row = try allocator.alloc(usize, line.len);
        @memset(row, 0);
        for (0..line.len) |column| {
            row[column] = line[column] - '0';
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

pub fn print(self: Self) void {
    for (0..self.rows) |i| {
        for (0..self.columns) |j| {
            std.debug.print("{d}", .{self.cells[i][j]});
        }
        std.debug.print("\n", .{});
    }
    return;
}
