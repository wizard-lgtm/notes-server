const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const fileop = @import("./fileop.zig");

///
/// returns an ul li list for notes
///
pub fn notes(allocator: mem.Allocator) ![]const u8 {
    const npath = "./notes"; // path for notes
    const flist = try fileop.dir_entries(allocator, npath);
    defer _ = flist.deinit();

    const ul = "<ul>";
    const ulend = "</ul>";
    const li = "<li>";
    const liend = "</li>";

    var buffer = try allocator.alloc(u8, 0);

    buffer = try std.mem.concat(allocator, u8, .{ buffer, ul });
    for (flist.items) |entry| {
        buffer = std.mem.concat(allocator, u8, .{ buffer, li });

        buffer = std.mem.concat(allocator, u8, .{ buffer, entry.name });

        buffer = std.mem.concat(allocator, u8, .{ buffer, liend });
    }
    buffer = try std.mem.concat(allocator, u8, .{ buffer, ulend });
}

test "notes" {
    const allocator = std.testing.allocator;
    const noteshtml = try notes(allocator);

    std.debug.print("notes: {s}\n", .{noteshtml});
}
