const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const fileop = @import("./fileop.zig");

// ///
// /// concats str to buffer
// ///
pub fn strcat(allocator: std.mem.Allocator, dest: *[]u8, src: []const u8) !void {
    const oldsize = dest.len;
    const newsize = oldsize + src.len;
    dest.* = try allocator.realloc(dest.*, newsize);

    @memcpy(dest.*[oldsize..newsize], src);
}

test "strcat" {
    const allocator = std.testing.allocator;

    const str = "Hello";
    const str2 = " world!";
    var buffer = try allocator.alloc(u8, str.len);
    defer _ = allocator.free(buffer);
    @memcpy(buffer[0..str.len], str);

    _ = try strcat(allocator, &buffer, str2);

    try std.testing.expect(std.mem.eql(u8, buffer, "Hello world!"));
}

///
/// chops n size of character from end of the given buffer
/// frees old buffer and returns new sized buffer
///
pub fn chopn(allocator: mem.Allocator, buffer: []u8, n: usize) ![]u8 {
    if (buffer.len < n) {
        return error.bufferTooSmall;
    }
    const newsize = buffer.len - n;
    const newbuffer = try allocator.alloc(u8, newsize);

    // copy buffer parts as newsize to newbuffer
    @memcpy(newbuffer[0..newsize], buffer[0..newsize]);

    // free buffer
    allocator.free(buffer);

    return newbuffer;
}

test "chopn" {
    const allocator = std.testing.allocator;
    const str = "Hello world!123";
    const buffer = try allocator.alloc(u8, str.len);
    @memcpy(buffer[0..str.len], str);

    const newbuffer = try chopn(allocator, buffer, 3);
    defer _ = allocator.free(newbuffer);

    try std.testing.expect(mem.eql(u8, newbuffer, "Hello world!"));
}
