const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const fileop = @import("./fileop.zig");

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
