const std = @import("std");
const startsWith = std.mem.startsWith;
const expectEqual = std.testing.expectEqual;

const forward = "forward ";
const up = "up ";
const down = "down ";

fn solvePuzzle(path: []const u8, horizontal_position: *i64, depth: *i64, use_aim: bool) !i64 {
    const dir = std.fs.cwd();

    const file = try dir.openFile(path, .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [500]u8 = undefined;

    var aim: i64 = 0;

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var number_part: []u8 = undefined;
        var horizontal_multiplier: i64 = 0;
        var depth_multiplier: i64 = 0;
        if (startsWith(u8, line, forward)) {
            number_part = line[forward.len..];
            horizontal_multiplier = 1;
        } else if (startsWith(u8, line, up)) {
            number_part = line[up.len..];
            depth_multiplier = -1;
        } else if (startsWith(u8, line, down)) {
            number_part = line[down.len..];
            depth_multiplier = 1;
        } else {
            unreachable;
        }

        // Parse the number
        const amount: i64 = try std.fmt.parseInt(i64, number_part, 10);
        horizontal_position.* += amount * horizontal_multiplier;
        if (use_aim) {
            aim += amount * depth_multiplier;
            depth.* += amount * horizontal_multiplier * aim;
        } else {
            depth.* += amount * depth_multiplier;
        }
    }

    return horizontal_position.* * depth.*;
}

pub fn main() !void {
    std.debug.print("\nDay 2:\n", .{});

    var horizontal_position: i64 = 0;
    var depth: i64 = 0;
    var result: i64 = try solvePuzzle("./fixtures/day_2/input.txt", &horizontal_position, &depth, false);
    std.debug.print("    Solved part 1:\n      horizontal position: {d}\n      depth: {d}\n      multiplied: {d}\n", .{ horizontal_position, depth, result });

    horizontal_position = 0;
    depth = 0;
    result = try solvePuzzle("./fixtures/day_2/input.txt", &horizontal_position, &depth, true);
    std.debug.print("    Solved part 2:\n      horizontal position: {d}\n      depth: {d}\n      multiplied: {d}\n", .{ horizontal_position, depth, result });
}

test "Day 2, part 1" {
    var horizontal_position: i64 = 0;
    var depth: i64 = 0;
    const result = try solvePuzzle("./fixtures/day_2/example.txt", &horizontal_position, &depth, false);

    try expectEqual(horizontal_position, 15);
    try expectEqual(depth, 10);
    try expectEqual(result, 150);
}

test "Day 2, part 2" {
    var horizontal_position: i64 = 0;
    var depth: i64 = 0;
    const result = solvePuzzle("./fixtures/day_2/example.txt", &horizontal_position, &depth, true);

    try expectEqual(horizontal_position, 15);
    try expectEqual(depth, 60);
    try expectEqual(result, 900);
}
