// map.zi
const std = @import("std");
const Allocator = std.mem.Allocator;

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
player: Offset,

const Self = @This();

pub fn init(allocator: Allocator, content: []const u8) !Self {
    var map = std.ArrayList([]usize).init(allocator);
    var player: Offset = undefined;
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    while (lines.next()) |line| {
        const row = try allocator.alloc(usize, line.len);
        @memset(row, 0);
        for (0..line.len) |column| {
            if (line[column] == '#') {
                row[column] = 1 << @intFromEnum(Status.obstacle);
            }
            if (line[column] == '^') {
                row[column] = 1 << @intFromEnum(Status.player);
                player.row = @intCast(rows);
                player.column = @intCast(column);
            }
        }
        try map.append(row);
        rows += 1;
    }
    const columns = map.items[0].len;
    // std.debug.print("player = {d} {d}\n", .{ player.row, player.column });

    return Self{ .allocator = allocator, .rows = rows, .columns = columns, .cells = try map.toOwnedSlice(), .player = player };
}

pub fn deinit(self: Self) void {
    for (0..self.rows) |i| {
        self.allocator.free(self.cells[i]);
    }
    self.allocator.free(self.cells);
    return;
}

pub fn clone(self: Self, allocator: Allocator) !Self {
    var cells = try allocator.alloc([]usize, self.rows);
    for (0..self.rows) |row| {
        cells[row] = try allocator.alloc(usize, self.columns);
        for (0..self.columns) |column| {
            cells[row][column] = self.cells[row][column];
        }
    }

    return Self{ .allocator = allocator, .rows = self.rows, .columns = self.columns, .cells = cells, .player = self.player };
}

pub fn solve(self: Self) ?usize {
    var count: usize = 1;
    var direction: usize = 0;
    const max = self.cells.len;
    var player = Offset{ .row = self.player.row, .column = self.player.column };
    while (true) {
        const offset = offsets[direction];
        const r: isize = player.row + offset.row;
        const c: isize = player.column + offset.column;
        if (r < 0 or r >= max or c < 0 or c >= max) {
            // out of map
            return count;
        }
        if (self.cells[@intCast(r)][@intCast(c)] >= 1 << @intFromEnum(Status.obstacle)) {
            // turn right 90 degree
            direction += 1;
            direction %= 4;
        } else {
            const mask = @as(usize, 1) << @intCast(direction);
            if ((self.cells[@intCast(r)][@intCast(c)] & mask) != 0) {
                // same direction again, it is looping
                return null;
            }
            player.row = r;
            player.column = c;
            if (self.cells[@intCast(r)][@intCast(c)] == 0) {
                count += 1;
            }
            self.cells[@intCast(r)][@intCast(c)] |= mask;
        }
    }
}
