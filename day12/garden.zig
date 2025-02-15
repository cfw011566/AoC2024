/// garden.zig
const std = @import("std");

plant: u8, // character
region_id: ?usize,
perimeters: usize,

const Self = @This();

pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    if (fmt.len != 0) {
        std.fmt.invalidFmtError(fmt, self);
    }
    if (self.region_id) |id| {
        return writer.print("({c}:{d:2},{d})", .{ self.plant, id, self.perimeters });
    } else {
        return writer.print("({c}:?,{d})", .{ self.plant, self.perimeters });
    }
}
