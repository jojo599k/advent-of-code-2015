const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const input_reader = @import("input_reader.zig");

const allocator = std.heap.page_allocator;

const PuzzleSolution = struct {
    n_different_houses: u32,
    n_different_houses_robo: u32,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const solution = try solvePuzzle();
    try stdout.print("Day 03: Part I\n", .{});
    try stdout.print("Result: {d}\n", .{solution.n_different_houses});
    try stdout.print("Day 03: Part II\n", .{});
    try stdout.print("Result: {d}\n", .{solution.n_different_houses_robo});

    try bw.flush();
}

const House = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) House {
        return .{ .x = x, .y = y };
    }

    pub fn next(self: *const House, direction: Direction) House {
        const x: i32 = self.x + switch (direction) {
            Direction.East => @as(i32, 1),
            Direction.West => @as(i32, -1),
            else => @as(i32, 0),
        };
        const y: i32 = self.y + switch (direction) {
            Direction.North => @as(i32, 1),
            Direction.South => @as(i32, -1),
            else => @as(i32, 0),
        };
        return .{ .x = x, .y = y };
    }
};

const Direction = enum {
    North,
    East,
    West,
    South,
};

fn solvePuzzle() !PuzzleSolution {
    var houses = std.AutoHashMap(House, u32).init(allocator);
    defer houses.deinit();
    var houses_with_robo = std.AutoHashMap(House, u32).init(allocator);
    defer houses_with_robo.deinit();

    const houses_visited = try readInstructions(&houses, false);
    print("Visited {d} houses\n", .{houses_visited});
    const houses_visited2 = try readInstructions(&houses_with_robo, true);
    print("Visited {d} houses\n", .{houses_visited2});

    return .{ .n_different_houses = houses.count(), .n_different_houses_robo = houses_with_robo.count() };
}

fn readInstructions(houses: anytype, with_robo_santa: bool) !u32 {
    const path = "inputs/day03.txt";
    var houses_visited: u32 = 0;

    var buffer = try allocator.alloc(u8, 10_000);
    defer allocator.free(buffer);
    const file_contents = try input_reader.readFileInput(path, buffer);

    var current = House.init(0, 0);
    var current_robo = current;
    var robo_turn: bool = false;
    houses_visited += 1 + (if (with_robo_santa) @as(u32, 1) else @as(u32, 0));
    try houses.put(current, 1 + (if (with_robo_santa) @as(u32, 1) else @as(u32, 0)));
    for (file_contents) |char| {
        switch (char) {
            '^' => {
                const next: House = (if (with_robo_santa and robo_turn) current_robo else current)
                    .next(Direction.North);
                try addOrIncrement(houses, &next);
                if (with_robo_santa and robo_turn) {
                    current_robo = next;
                } else {
                    current = next;
                }
                robo_turn = !robo_turn;
                houses_visited += 1;
            },
            '>' => {
                const next: House = (if (with_robo_santa and robo_turn) current_robo else current)
                    .next(Direction.East);
                try addOrIncrement(houses, &next);
                if (with_robo_santa and robo_turn) {
                    current_robo = next;
                } else {
                    current = next;
                }
                robo_turn = !robo_turn;
                houses_visited += 1;
            },
            'v' => {
                const next: House = (if (with_robo_santa and robo_turn) current_robo else current)
                    .next(Direction.South);
                try addOrIncrement(houses, &next);
                if (with_robo_santa and robo_turn) {
                    current_robo = next;
                } else {
                    current = next;
                }
                robo_turn = !robo_turn;
                houses_visited += 1;
            },
            '<' => {
                const next: House = (if (with_robo_santa and robo_turn) current_robo else current)
                    .next(Direction.West);
                try addOrIncrement(houses, &next);
                if (with_robo_santa and robo_turn) {
                    current_robo = next;
                } else {
                    current = next;
                }
                robo_turn = !robo_turn;
                houses_visited += 1;
            },
            else => {},
        }
    }

    return houses_visited;
}

fn addOrIncrement(houses: anytype, house: *const House) !void {
    const value = houses.get(house.*) orelse 0;
    try houses.put(house.*, value + 1);
}
