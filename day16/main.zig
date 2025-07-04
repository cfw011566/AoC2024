const std = @import("std");

pub fn main() !void {
    std.debug.print("Day 16\n", .{});
    var gpa = std.heap.DebugAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    std.debug.print("part1 = {d}\n", .{try part1(allocator, "input.txt")});
}

fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    var content = std.ArrayList(u8).init(allocator);
    defer content.deinit();
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var buffered = std.io.bufferedReader(file.reader());
    var bufreader = buffered.reader();
    var buffer: [1024]u8 = undefined;
    @memset(buffer[0..], 0);
    while (try bufreader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        try content.appendSlice(line);
        try content.append('\n');
    }
    return content.toOwnedSlice();
}

test "example1" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(7036, part1(allocator, "example1.txt"));
    try std.testing.expectEqual(11048, part1(allocator, "example2.txt"));
}

const Cell = enum(u8) {
    Empty = 0,
    Wall = 1,
    Start = 2,
    End = 3,
    East = 101,
    West,
    South,
    North,
};

const Position = struct {
    row: usize = 0,
    column: usize = 0,

    pub fn format(self: Position, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) {
            std.fmt.invalidFmtError(fmt, self);
        }
        try writer.print("{d},{d}", .{ self.row, self.column });
    }
};

const Direction = enum(u8) {
    East = 101,
    West,
    South,
    North,
};

const Map = struct {
    allocator: std.mem.Allocator,
    rows: usize,
    columns: usize,
    cells: [][]Cell,
    steps: [][]usize,
    start_pos: Position,
    end_pos: Position,

    pub fn init(allocator: std.mem.Allocator, content: []const u8) !Map {
        var cells = std.ArrayList([]Cell).init(allocator);
        var steps = std.ArrayList([]usize).init(allocator);
        var lines = std.mem.tokenizeScalar(u8, content, '\n');
        var rows: usize = 0;
        var start: Position = undefined;
        var end: Position = undefined;
        while (lines.next()) |line| {
            const row = try allocator.alloc(Cell, line.len);
            @memset(row, .Empty);
            const step = try allocator.alloc(usize, line.len);
            @memset(step, 0);
            for (line, 0..) |c, column| {
                switch (c) {
                    '#' => row[column] = .Wall,
                    '.' => row[column] = .Empty,
                    'S' => {
                        start = .{ .row = rows, .column = column };
                        row[column] = .Start;
                    },
                    'E' => {
                        end = .{ .row = rows, .column = column };
                        row[column] = .End;
                    },
                    else => return error.InvalidCharacter,
                }
            }
            try cells.append(row);
            try steps.append(step);
            rows += 1;
        }
        const columns = cells.items[0].len;
        return .{
            .allocator = allocator,
            .rows = rows,
            .columns = columns,
            .cells = try cells.toOwnedSlice(),
            .steps = try steps.toOwnedSlice(),
            .start_pos = start,
            .end_pos = end,
        };
    }

    pub fn format(self: Map, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) {
            std.fmt.invalidFmtError(fmt, self);
        }
        var ch: u8 = undefined;
        for (0..self.rows) |i| {
            for (0..self.columns) |j| {
                if (i == self.start_pos.row and j == self.start_pos.column) {
                    ch = 'S';
                } else if (i == self.end_pos.row and j == self.end_pos.column) {
                    ch = 'E';
                } else {
                    const cell = self.cells[i][j];
                    ch = switch (cell) {
                        .Empty => '.',
                        .Wall => '#',
                        .Start => 'S',
                        .End => 'E',
                        .East => '>',
                        .West => '<',
                        .North => '^',
                        .South => 'v',
                    };
                }
                try writer.print("{c}", .{ch});
            }
            try writer.print("\n", .{});
        }
        return;
    }

    pub fn deinit(self: Map) void {
        for (0..self.rows) |i| {
            self.allocator.free(self.cells[i]);
            self.allocator.free(self.steps[i]);
        }
        self.allocator.free(self.cells);
        self.allocator.free(self.steps);
        return;
    }
};

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const content = try readFile(allocator, filename);
    defer allocator.free(content);
    const map = try Map.init(allocator, content);
    defer map.deinit();
    std.debug.print("{}", .{map});

    var path = std.ArrayList(Position).init(allocator);
    defer path.deinit();
    var directions = std.ArrayList(Cell).init(allocator);
    defer directions.deinit();

    // var direction: Cell = .East;
    var minimum_score: usize = std.math.maxInt(usize);
    var steps: usize = 0;
    map.steps[map.start_pos.row][map.start_pos.column] = 0;
    try path.append(map.start_pos);
    try directions.append(.East);
    while (path.pop()) |current| {
        const current_dir = directions.pop() orelse unreachable;
        map.cells[current.row][current.column] = Cell.East; // Mark as visited
        steps = map.steps[current.row][current.column];
        // std.debug.print("Current position: {} : {d}\n", .{ current, steps });
        if (current.row == map.end_pos.row and current.column == map.end_pos.column) {
            std.debug.print("Steps = {d}\n", .{steps});
            if (minimum_score > steps) {
                minimum_score = steps;
            }
        }
        // Check neighbors
        const dirs: []const Cell = &.{ .East, .West, .South, .North };
        for (dirs) |dir| {
            const neighbor: Position = switch (dir) {
                .East => .{ .row = current.row, .column = current.column + 1 },
                .West => .{ .row = current.row, .column = current.column - 1 },
                .South => .{ .row = current.row + 1, .column = current.column },
                .North => .{ .row = current.row - 1, .column = current.column },
                else => unreachable,
            };
            // std.debug.print("Checking direction: {d} {}\n", .{ dir, neighbor });
            if (neighbor.row < map.rows and neighbor.column < map.columns and
                map.cells[neighbor.row][neighbor.column] != .Wall and
                (map.cells[neighbor.row][neighbor.column] == .Empty or map.cells[neighbor.row][neighbor.column] == .End or
                    steps < map.steps[neighbor.row][neighbor.column]))
            {
                try path.append(neighbor);
                try directions.append(dir);
                map.cells[neighbor.row][neighbor.column] = dir; // Mark as visited
                if (dir == current_dir) {
                    map.steps[neighbor.row][neighbor.column] = steps + 1;
                } else {
                    map.steps[neighbor.row][neighbor.column] = steps + 1001;
                }
            }
        }
    }
    // std.debug.print("score: {d}\n", .{minimum_score});

    return minimum_score;
}
