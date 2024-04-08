const std = @import("std");
const fmt = std.fmt;
const assert = std.debug.assert;
const print = std.debug.print;
const allocator = std.heap.page_allocator;

const input_reader = @import("input_reader.zig");

const PuzzleSolution = struct {
    nice_strings_one: u32,
    nice_strings_two: u32,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const solution = try solvePuzzle();
    try stdout.print("Day 05: Part I\n", .{});
    try stdout.print("Result: {d}\n", .{solution.nice_strings_one});
    try stdout.print("Day 05: Part II\n", .{});
    try stdout.print("Result: {d}\n", .{solution.nice_strings_two});

    try bw.flush();
}

fn solvePuzzle() !PuzzleSolution {
    const path = "inputs/day05.txt";
    var nice_strings_one: u32 = 0;
    var nice_strings_two: u32 = 0;

    var buffer = try allocator.alloc(u8, 20_000);
    defer allocator.free(buffer);
    const file_contents = try input_reader.readFileInput(path, buffer);

    var strings_it = std.mem.split(u8, file_contents, "\n");
    while (strings_it.next()) |str| {
        if (nicePartOne(str)) {
            nice_strings_one += 1;
        }
        if (nicePartTwo(str)) {
            nice_strings_two += 1;
        }
    }

    return .{ .nice_strings_one = nice_strings_one, .nice_strings_two = nice_strings_two };
}

fn nicePartOne(str: []const u8) bool {
    var vowel_count: u8 = 0;
    var double_letters: u8 = 0;
    var illegal = false;

    for (str, 0..str.len) |c, i| {
        if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u') {
            vowel_count += 1;
        }

        if (i + 1 < str.len) {
            if (c == str[i + 1]) {
                double_letters += 1;
            } else {
                if (c == 'a' and str[i + 1] == 'b' or
                    c == 'c' and str[i + 1] == 'd' or
                    c == 'p' and str[i + 1] == 'q' or
                    c == 'x' and str[i + 1] == 'y')
                {
                    illegal = true;
                }
            }
        }
    }

    return vowel_count >= 3 and double_letters >= 1 and !illegal;
}

fn nicePartTwo(str: []const u8) bool {
    var repeating_letters: u8 = 0;
    var has_repeating_double = false;

    for (str, 0..str.len) |c, i| {
        if (i + 2 < str.len and c == str[i + 2]) {
            repeating_letters += 1;
        }

        if (i + 1 < str.len and !has_repeating_double) {
            for ((i + 2)..str.len) |j| {
                if (j + 1 < str.len and c == str[j] and str[i + 1] == str[j + 1]) {
                    has_repeating_double = true;
                    break;
                }
            }
        }
    }

    return repeating_letters >= 1 and has_repeating_double;
}
