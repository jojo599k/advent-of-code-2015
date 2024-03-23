const std = @import("std");
const assert = std.debug.assert;

pub fn readFileInput(input_path: []const u8, buffer: []u8) ![]u8 {
    const result = try std.fs.cwd().readFile(input_path, buffer);
    assert(result.len < buffer.len);
    return result;
}
