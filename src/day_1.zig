const std = @import("std");
const fs = std.fs;
const expectEqual = std.testing.expectEqual;

/// Solves the puzzle with the specified file path, returning
/// the number of times the depth measurement increases from
/// the previous measurement.
fn solvePuzzle(path: []const u8, comptime windowSize: u8) !u32 {
    const dir = std.fs.cwd();

    const file = try dir.openFile(
        path,
        .{ .read = true },
    );
    defer file.close();

    const reader = file.reader();
    var buffer: [500]u8 = undefined;
    var previous: ?u32 = null;
    var increases: u32 = 0;

    // Keep track of weighted depths with a sums array
    var sums: [windowSize + 1]u32 = std.mem.zeroes([windowSize + 1]u32);

    var i: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        // The depth received by the submarine
        const depth: u32 = try std.fmt.parseUnsigned(u32, line, 10);

        var j: u32 = 0;
        while (j < windowSize + 1) : (j += 1) {
            if (i < j or (i + windowSize + 1 - j + 1) % (windowSize + 1) == 0) {
                // Reset the sums on a rolling window
                sums[j] = 0;
            } else {
                sums[j] += depth;
            }
        }

        // Increment line counter
        i += 1;
        if (i >= windowSize) {
            // Once we have enough data points, compare weighted depths
            const weightedDepth = sums[(i + 1) % (windowSize + 1)];
            if (previous) |previousValue| {
                // If the previous value isn't null and is less than the depth,
                // register an increase.
                if (weightedDepth > previousValue) {
                    increases += 1;
                }
            }
            previous = weightedDepth;
        }
    }
    return increases;
}

pub fn main() !void {
    std.debug.print("Day 1:\n", .{});

    const part_1_solution: u32 = try solvePuzzle("./fixtures/day_1/input.txt", 1);
    std.debug.print("    Solved part 1: {d}\n", .{part_1_solution});

    const part_2_solution: u32 = try solvePuzzle("./fixtures/day_1/input.txt", 3);
    std.debug.print("    Solved part 2: {d}\n", .{part_2_solution});
}

test "Day 1, part 1" {
    const solution: u32 = try solvePuzzle("./fixtures/day_1/example.txt", 1);
    try expectEqual(solution, 7);
}

test "Day 1, part 2" {
    const solution: u32 = try solvePuzzle("./fixtures/day_1/example.txt", 3);
    try expectEqual(solution, 5);
}
