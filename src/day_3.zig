const std = @import("std");
const expectEqual = std.testing.expectEqual;

const bufferSize: usize = 500;

const Part2Error = error{NoMatchingItem};

fn solvePart1(path: []const u8, gamma: *u32, epsilon: *u32) !i64 {
    const dir = std.fs.cwd();

    const file = try dir.openFile(path, .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [bufferSize]u8 = undefined;
    var length: usize = undefined;
    var numOnes: [bufferSize]u32 = std.mem.zeroes([bufferSize]u32);
    var numZeroes: [bufferSize]u32 = std.mem.zeroes([bufferSize]u32);

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        length = line.len;

        var i: u32 = 0;
        while (i < length) : (i += 1) {
            numZeroes[i] += if (line[i] == '0') @as(u32, 1) else 0;
            numOnes[i] += if (line[i] == '1') @as(u32, 1) else 0;
        }
    }

    // Calculate gamma and epsilon
    var multiplier: u32 = 1;
    var i: i32 = @intCast(i32, length) - 1;
    while (i >= 0) : ({
        i -= 1;
        multiplier *= 2;
    }) {
        const idx: usize = @intCast(usize, i);
        gamma.* += if (numOnes[idx] > numZeroes[idx]) multiplier else 0;
        epsilon.* += if (numZeroes[idx] > numOnes[idx]) multiplier else 0;
    }

    return gamma.* * epsilon.*;
}

fn solvePart2(allocator: *std.mem.Allocator, path: []const u8, useOxygenGeneratorRating: bool) !u32 {
    // Store all the data
    var data = std.ArrayList(u8).init(allocator);
    defer data.clearAndFree();

    const dir = std.fs.cwd();

    const file = try dir.openFile(path, .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [bufferSize]u8 = undefined;
    var length: usize = undefined;

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        length = line.len;

        var i: u32 = 0;
        while (i < length) : (i += 1) {
            // Consume all the data
            try data.append(line[i]);
        }
    }

    // Calculate each bit of the result
    var i: u32 = 0;
    while (i <= length) : (i += 1) {
        if (data.items.len == length) {
            // Stop, this is our answer
            var z: i32 = @intCast(i32, length) - 1;
            var multiplier: u32 = 1;
            var result: u32 = 0;
            while (z >= 0) : ({
                z -= 1;
                multiplier *= 2;
            }) {
                result += (if (data.items[@intCast(usize, z)] == '0') @as(u32, 0) else @as(u32, 1)) * multiplier;
            }
            return result;
        }

        // Iterate through the entire array
        var numZeroes: u32 = 0;
        var numOnes: u32 = 0;
        var j: i32 = 0;
        while (j < data.items.len) : (j += @intCast(i32, length)) {
            if (data.items[@intCast(u32, j) + i] == '0') {
                numZeroes += 1;
            }
            if (data.items[@intCast(u32, j) + i] == '1') {
                numOnes += 1;
            }
        }
        // See which number had more
        var seekBit: u8 = undefined;
        if (useOxygenGeneratorRating) {
            // Grab most common, ties resolve to 1
            if (numZeroes > numOnes) {
                seekBit = '0';
            } else if (numOnes > numZeroes) {
                seekBit = '1';
            } else {
                seekBit = '1';
            }
        } else {
            // Grab least common, ties resolve to 0
            if (numZeroes < numOnes) {
                seekBit = '0';
            } else if (numOnes < numZeroes) {
                seekBit = '1';
            } else {
                seekBit = '0';
            }
        }

        // Remove entries that don't match the desired bit
        j = 0;
        while (j < data.items.len) : (j += @intCast(i32, length)) {
            if (data.items[@intCast(u32, j) + i] != seekBit) {
                var k: u32 = 0;
                while (k < length) : (k += 1) {
                    _ = data.orderedRemove(@intCast(usize, j));
                }
                // Resize j to not overextend
                j -= @intCast(i32, length);
            }
        }
    }

    return Part2Error.NoMatchingItem;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = &arena.allocator;

    std.debug.print("\nDay 3:\n  part 1:\n", .{});
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    const solution = try solvePart1("./fixtures/day_3/input.txt", &gamma, &epsilon);
    std.debug.print("    gamma: {d}\n    epsilon: {d}\n    solution: {d}\n", .{ gamma, epsilon, solution });

    const oxygenGeneratorRating = try solvePart2(allocator, "./fixtures/day_3/input.txt", true);
    const co2ScrubberRating = try solvePart2(allocator, "./fixtures/day_3/input.txt", false);
    std.debug.print("  part 2:\n    oxygen rating: {d}\n", .{oxygenGeneratorRating});
    std.debug.print("    scrubber rating: {d}\n", .{co2ScrubberRating});
    std.debug.print("    answer: {d}\n", .{oxygenGeneratorRating * co2ScrubberRating});
}

test "Day 3, part 1" {
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    const solution = try solvePart1("./fixtures/day_3/example.txt", &gamma, &epsilon);
    try expectEqual(gamma, 22);
    try expectEqual(epsilon, 9);
    try expectEqual(solution, 198);
}

test "Day 3, part 2" {
    const oxygenGeneratorRating = try solvePart2(std.testing.allocator, "./fixtures/day_3/example.txt", true);
    const co2ScrubberRating = try solvePart2(std.testing.allocator, "./fixtures/day_3/example.txt", false);
    try expectEqual(oxygenGeneratorRating, 23);
    try expectEqual(co2ScrubberRating, 10);
    try expectEqual(oxygenGeneratorRating * co2ScrubberRating, 230);
}
