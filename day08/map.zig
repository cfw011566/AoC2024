const std = @import("std");
const Allocator = std.mem.Allocator;

const Position = struct {
    row: isize,
    column: isize,
};

pub const EntityMask = enum(u8) {
    Antenna = 0,
    Antinode = 1,
};

allocator: Allocator,
rows: usize,
columns: usize,
cells: [][]usize,
antenna: [128]?std.ArrayList(Position),

const Self = @This();

pub fn init(allocator: Allocator, content: []const u8) !Self {
    var map = std.ArrayList([]usize).init(allocator);
    defer map.deinit();

    var antenna = [_]?std.ArrayList(Position){null} ** 128;

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    while (lines.next()) |line| {
        const row_line = try allocator.alloc(usize, line.len);
        @memset(row_line, 0);
        for (0..row_line.len) |col| {
            if (std.ascii.isAlphanumeric(line[col])) {
                // std.debug.print("{c} ({d},{d})\n", .{ line[col], rows, col });
                row_line[col] = 1 << @intFromEnum(EntityMask.Antenna);
                const char = line[col];
                if (antenna[char]) |*list| {
                    const position = Position{ .row = @intCast(rows), .column = @intCast(col) };
                    try list.*.append(position);
                } else {
                    var list = std.ArrayList(Position).init(allocator);
                    const position = Position{ .row = @intCast(rows), .column = @intCast(col) };
                    try list.append(position);
                    antenna[char] = list;
                }
            }
        }
        try map.append(row_line);
        rows += 1;
    }
    const columns = map.items[0].len;
    return Self{
        .allocator = allocator,
        .rows = rows,
        .columns = columns,
        .cells = try map.toOwnedSlice(),
        .antenna = antenna,
    };
}

pub fn deinit(self: Self) void {
    for (0..self.rows) |row| {
        self.allocator.free(self.cells[row]);
    }
    self.allocator.free(self.cells);
    for (0..128) |i| {
        if (self.antenna[i]) |*list| {
            list.*.deinit();
        }
    }
    return;
}

pub fn print(self: Self) void {
    const mask_antenna = 1 << @intFromEnum(EntityMask.Antenna);
    const mask_antinode = 1 << @intFromEnum(EntityMask.Antinode);
    for (0..self.rows) |row| {
        for (0..self.columns) |col| {
            var char: u8 = ' ';
            if ((self.cells[row][col] & mask_antenna) != 0) {
                char = '*';
            } else if ((self.cells[row][col] & mask_antinode) != 0) {
                char = '#';
            }
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
    for (0..128) |i| {
        if (self.antenna[i]) |list| {
            std.debug.print("{c}: {d}\n", .{ @as(u8, @intCast(i)), list.items.len });
            for (list.items) |pos| {
                std.debug.print("({d},{d}) ", .{ pos.row, pos.column });
            }
            std.debug.print("\n", .{});
        }
    }
}
