const std = @import("std");

const example = "125 17";
const input = "5910927 0 1 47 261223 94788 545 7771";

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const part1 = try puzzle1(input, 25);
    var seconds: f64 = @floatFromInt(timer.lap());
    seconds /= 1e9;
    std.debug.print("puzzle 1 = {d} in {d:.6} seconds\n", .{ part1, seconds });

    timer.reset();
    return;
}

test "puzzle 1" {
    try std.testing.expectEqual(55312, try puzzle1(example, 25));
}

fn puzzle1(content: []const u8, steps: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var stones = std.ArrayList(usize).init(allocator);
    defer stones.deinit();
    var blink = std.ArrayList(usize).init(allocator);
    defer blink.deinit();

    var iter = std.mem.tokenizeScalar(u8, content, ' ');
    while (iter.next()) |text| {
        const num = try std.fmt.parseInt(usize, text, 10);
        try stones.append(num);
    }

    for (0..steps) |_| {
        blink.clearRetainingCapacity();
        const len = stones.items.len;
        for (0..len) |i| {
            const num = stones.items[i];
            if (num == 0) {
                try blink.append(1);
            } else {
                const digits = std.math.log10_int(num) + 1;
                if (digits % 2 == 0) {
                    const denominator = std.math.pow(usize, 10, digits / 2);
                    const num1 = num / denominator;
                    const num2 = num % denominator;
                    try blink.append(num1);
                    try blink.append(num2);
                } else {
                    try blink.append(num * 2024);
                }
            }
        }
        stones.deinit();
        stones = try blink.clone();
        std.debug.print("{d}\n", .{stones.items.len});
        // std.debug.print("{any}\n", .{stones.items});
    }

    return stones.items.len;
}
