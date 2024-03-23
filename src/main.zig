const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Advent Of Code 2015\n", .{});
    try stdout.print("\tzig run src/dayXX.zig", .{});

    try bw.flush();
}
