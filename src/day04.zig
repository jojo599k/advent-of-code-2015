const std = @import("std");
const fmt = std.fmt;
const Md5 = std.crypto.hash.Md5;
const assert = std.debug.assert;
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const PuzzleSolution = struct {
    part_one_number: u64,
    part_two_number: u64,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const solution = try solvePuzzle();
    try stdout.print("Day 04: Part I\n", .{});
    try stdout.print("Result: {d}\n", .{solution.part_one_number});
    try stdout.print("Day 04: Part II\n", .{});
    try stdout.print("Result: {d}\n", .{solution.part_two_number});

    try bw.flush();
}

fn solvePuzzle() !PuzzleSolution {
    const secret_key = "ckczppom";
    var part_one_number: ?u64 = null;
    var number: u64 = 0;
    var found: bool = false;

    var hash: [16]u8 = undefined;
    @memset(&hash, 0);

    while (!found) {
        number += 1;
        const combined = try fmt.allocPrint(allocator, "{s}{d}", .{ secret_key, number });
        defer allocator.free(combined);
        Md5.hash(combined, &hash, .{});

        if (hash[0] == 0 and hash[1] == 0 and
            (hash[2] & 0xF0) == 0)
        {
            if (part_one_number == null) {
                part_one_number = number;
            }

            if (hash[2] == 0) {
                found = true;
            }
        }
        //print("Checked number {d}\n", .{number});
    }

    return .{ .part_one_number = part_one_number orelse 0, .part_two_number = number };
}
