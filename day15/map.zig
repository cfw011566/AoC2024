const std = @import("std");
const Allocator = std.mem.Allocator;

const Coordinate = struct {
    row: isize,
    column: isize,
};

const offsets = [_]Coordinate{
    Coordinate{ .row = -1, .column = 0 },
    Coordinate{ .row = 0, .column = 1 },
    Coordinate{ .row = 1, .column = 0 },
    Coordinate{ .row = 0, .column = -1 },
    Coordinate{ .row = 0, .column = 0 },
};

pub const Direction = enum(u8) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
    none = 4,
};

pub const Item = enum(u8) {
    Space = 0,
    Wall = 1,
    Box = 2,
    Robot = 3,
};

pub const Map = struct {
    const Self = @This();

    allocator: Allocator,
    rows: usize,
    columns: usize,
    cells: [][]Item,
    robot: Coordinate,

    pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        // if (fmt.len != 0) {
        //     std.fmt.invalidFmtError(fmt, self);
        // }
        var is_digit = true;
        if (fmt.len != 0) {
            if (fmt[0] == 'd') {
                is_digit = true;
            } else if (fmt[0] == 'c') {
                is_digit = false;
            } else {
                return;
            }
        }
        for (0..self.rows) |row| {
            for (0..self.columns) |col| {
                const cell = self.cells[row][col];
                if (is_digit) {
                    try writer.print("{d}", .{@intFromEnum(cell)});
                } else {
                    const char: u8 = switch (cell) {
                        .Space => '.',
                        .Wall => '#',
                        .Box => 'O',
                        .Robot => '@',
                    };
                    try writer.print("{c}", .{char});
                }
            }
            try writer.print("\n", .{});
        }
        return;
    }

    pub fn init(allocator: Allocator, content: [][]const u8) !Self {
        var map = std.ArrayList([]Item).init(allocator);
        var robot: Coordinate = undefined;
        for (0..content.len) |row| {
            const line = content[row];
            const items = try allocator.alloc(Item, line.len);
            for (0..line.len) |column| {
                if (line[column] == '#') {
                    items[column] = .Wall;
                }
                if (line[column] == '.') {
                    items[column] = .Space;
                }
                if (line[column] == 'O') {
                    items[column] = .Box;
                }
                if (line[column] == '@') {
                    items[column] = .Robot;
                    robot.row = @intCast(row);
                    robot.column = @intCast(column);
                }
            }
            try map.append(items);
        }
        const rows = content.len;
        const columns = content[0].len;

        return Self{ .allocator = allocator, .rows = rows, .columns = columns, .cells = try map.toOwnedSlice(), .robot = robot };
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

        return Self{ .allocator = allocator, .rows = self.rows, .columns = self.columns, .cells = cells, .robot = self.robot };
    }

    pub fn move(self: *Self, direction: Direction) void {
        // std.debug.print("{d}", .{@intFromEnum(direction)});
        const offset = offsets[@intFromEnum(direction)];
        const next_row = self.robot.row + offset.row;
        const next_column = self.robot.column + offset.column;
        const next_cell = self.cells[@intCast(next_row)][@intCast(next_column)];
        if (next_row < 0 or next_row >= self.rows or next_column < 0 or next_column >= self.rows) {
            std.log.err("out of bound ({d},{d})\n", .{ next_row, next_column });
            return;
        }
        if (next_cell == .Space) {
            self.cells[@intCast(self.robot.row)][@intCast(self.robot.column)] = .Space;
            self.robot.row = next_row;
            self.robot.column = next_column;
            self.cells[@intCast(self.robot.row)][@intCast(self.robot.column)] = .Robot;
        } else if (next_cell == .Box) {
            var not_box_row = next_row;
            var not_box_column = next_column;
            var not_box_cell = next_cell;
            while (not_box_cell == .Box) {
                not_box_row += offset.row;
                not_box_column += offset.column;
                not_box_cell = self.cells[@intCast(not_box_row)][@intCast(not_box_column)];
            }
            if (not_box_cell == .Space) {
                self.cells[@intCast(self.robot.row)][@intCast(self.robot.column)] = .Space;
                self.cells[@intCast(not_box_row)][@intCast(not_box_column)] = .Box;
                self.robot.row = next_row;
                self.robot.column = next_column;
                self.cells[@intCast(self.robot.row)][@intCast(self.robot.column)] = .Robot;
            }
        }
        return;
    }

    pub const Iterator = struct {
        map: *Map,
        index: usize,

        pub fn next(it: *Iterator) ?Coordinate {
            while (true) {
                if (it.index >= it.map.rows * it.map.columns)
                    return null;
                const row = it.index / it.map.rows;
                const col = it.index % it.map.rows;
                it.index += 1;
                if (it.map.cells[row][col] == .Box) {
                    return Coordinate{ .row = @intCast(row), .column = @intCast(col) };
                }
            }
        }
    };

    pub fn iterator(self: *Self) Iterator {
        return Iterator{
            .map = self,
            .index = 0,
        };
    }
};
