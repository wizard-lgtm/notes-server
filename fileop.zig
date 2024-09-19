const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const Dir = fs.Dir;

///
/// Returns an arraylist of Dir.Entry for spesific path given by argument
///
pub fn dir_entries(allocator: mem.Allocator, path: []const u8) !std.ArrayList(Dir.Entry) {
    var list = std.ArrayList(Dir.Entry).init(allocator);

    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |next_entry| {
        // Skip '.' and '..'
        if (std.mem.eql(u8, next_entry.name, ".") or std.mem.eql(u8, next_entry.name, "..")) {
            continue;
        }
        try list.append(next_entry);
    }

    return list;
}

test "dir entries" {
    const allocator = std.testing.allocator;

    const list = try dir_entries(allocator, ".");
    defer list.deinit();

    for (list.items) |entry| {
        std.debug.print("Entry: {s}\n", .{entry.name});
    }
}
