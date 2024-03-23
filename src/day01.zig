const std = @import("std");
const assert = std.debug.assert;
const input_reader = @import("input_reader.zig");

const PuzzleResult = struct {
    floor: i64,
    index: u64,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const solution = try solvePuzzle();
    try stdout.print("Day 01: Part I\n", .{});
    try stdout.print("Result: {d}\n", .{solution.floor});
    try stdout.print("Day 02: Part II\n", .{});
    try stdout.print("Result: {d}\n", .{solution.index});

    try bw.flush();
}

fn solvePuzzle() !PuzzleResult {
    const allocator = std.heap.page_allocator;
    const path = "inputs/day01.txt";
    var floor: i64 = 0;
    var index: u64 = 0;

    var buffer = try allocator.alloc(u8, 10000);
    defer allocator.free(buffer);

    const file_contents = try input_reader.readFileInput(path, buffer);
    for (file_contents, 1..) |char, i| {
        floor += switch (char) {
            '(' => 1,
            ')' => -1,
            else => 0,
        };

        if (index == 0 and floor == -1) {
            index = i;
        }
    }

    return .{ .floor = floor, .index = index };
}
