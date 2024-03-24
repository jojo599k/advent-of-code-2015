const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const input_reader = @import("input_reader.zig");

const allocator = std.heap.page_allocator;

const PuzzleSolution = struct {
    wrapping_paper_needed: u64,
    ribbon_needed: u64,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const solution = try solvePuzzle();
    try stdout.print("Day 02: Part I\n", .{});
    try stdout.print("Result: {d}\n", .{solution.wrapping_paper_needed});
    try stdout.print("Day 02: Part II\n", .{});
    try stdout.print("Result: {d}\n", .{solution.ribbon_needed});

    try bw.flush();
}

const Present = struct {
    length: u32,
    width: u32,
    height: u32,

    pub fn init(length: u32, width: u32, height: u32) Present {
        return .{ .length = length, .width = width, .height = height };
    }

    pub fn empty() Present {
        return init(0, 0, 0);
    }

    pub fn calculateSurface(self: *const Present) u64 {
        return 2 * self.length * self.width +
            2 * self.width * self.height +
            2 * self.height * self.length;
    }

    pub fn calculateSlag(self: *const Present) u64 {
        var min1: u32 = self.length;
        var min2 = if (self.width < self.height) self.width else self.height;

        if (self.width < min1) {
            min1 = self.width;
            min2 = if (self.length < self.height) self.length else self.height;
        }
        if (self.height < min1) {
            min1 = self.height;
            min2 = if (self.length < self.width) self.length else self.width;
        }

        return min1 * min2;
    }

    pub fn calculateRibbon(self: *const Present) u64 {
        var min1: u32 = self.length;
        var min2 = if (self.width < self.height) self.width else self.height;

        if (self.width < min1) {
            min1 = self.width;
            min2 = if (self.length < self.height) self.length else self.height;
        }
        if (self.height < min1) {
            min1 = self.height;
            min2 = if (self.length < self.width) self.length else self.width;
        }

        return 2 * min1 + 2 * min2;
    }

    pub fn calculateBow(self: *const Present) u64 {
        return self.length * self.width * self.height;
    }
};

fn solvePuzzle() !PuzzleSolution {
    var wrapping_paper_needed: u64 = 0;
    var ribbon_needed: u64 = 0;

    const presents = try allocator.alloc(Present, 1100);
    defer allocator.free(presents);
    var real_presents = try readPresents(&presents);
    assert(real_presents.len < presents.len);

    for (real_presents) |present| {
        //print("Present: l={d},w={d},h={d}\n", .{ present.length, present.width, present.height });
        wrapping_paper_needed += present.calculateSurface() + present.calculateSlag();
        ribbon_needed += present.calculateRibbon() + present.calculateBow();
        //print("Current wrapping paper needed: {d}\n", .{wrapping_paper_needed});
    }

    return .{
        .wrapping_paper_needed = wrapping_paper_needed,
        .ribbon_needed = ribbon_needed,
    };
}

const ParsingStep = enum {
    length,
    width,
    height,
};

const ParsingData = struct {
    index: u32,
    present: Present,
    value: u32,
    step: ParsingStep,

    pub fn init() ParsingData {
        return ParsingData{
            .index = 0,
            .present = Present.empty(),
            .value = 0,
            .step = ParsingStep.length,
        };
    }

    pub fn addDigit(self: *ParsingData, char: u8) void {
        self.value *= 10;
        self.value += char - '0';
    }

    pub fn nextStep(self: *ParsingData) void {
        switch (self.step) {
            ParsingStep.length => {
                self.present.length = self.value;
                self.value = 0;
                self.step = ParsingStep.width;
            },
            ParsingStep.width => {
                self.present.width = self.value;
                self.value = 0;
                self.step = ParsingStep.height;
            },
            ParsingStep.height => {
                assert(self.present.height == 0);
                self.present.height = self.value;
            },
        }
    }

    pub fn nextPresent(self: *ParsingData) void {
        self.index += 1;
        self.present = Present.empty();
        self.value = 0;
        self.step = ParsingStep.length;
    }
};

fn readPresents(presents: *const []Present) ![]Present {
    const path = "inputs/day02.txt";
    var data = ParsingData.init();

    var buffer = try allocator.alloc(u8, 12_000);
    defer allocator.free(buffer);

    const file_contents = try input_reader.readFileInput(path, buffer);
    for (file_contents) |char| {
        switch (char) {
            '0'...'9' => {
                //print("Found digit: {d}\n", .{char});
                data.addDigit(char);
            },
            'x' => {
                //print("Found seperator: {d}\n", .{char});
                data.nextStep();
            },
            '\n' => {
                //print("Found new line: {d}\n", .{char});
                data.nextStep();
                presents.*[data.index] = data.present;
                //print("Present: l={d},w={d},h={d}\n", .{ present.length, present.width, present.height });
                data.nextPresent();
            },
            else => {
                unreachable;
            },
        }
    }

    // if the input file doesnt have an empty line at the end
    // this code will not add the last present
    //print("Current Length: {d}\n", .{data.index});
    return presents.*[0..data.index];
}
