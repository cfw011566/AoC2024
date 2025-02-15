/// position.zig
const std = @import("std");

row: isize,
column: isize,

const Self = @This();

pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    if (fmt.len != 0) {
        std.fmt.invalidFmtError(fmt, self);
    }
    try writer.print("({d},{d})", .{ self.row, self.column });
}
