const std = @import("std");
const net = std.net;
const mem = std.mem;
const fs = std.fs;

pub fn get_dir_entries(path: []const u8) !void {
    var dir = try fs.cwd().openDir(path, .{});
    defer dir.close();

    var it = try dir.walk(std.heap.page_allocator);
    while (try it.next()) |entry| {
        const basename = entry.basename;
        const kind = entry.kind;
        const path = entry.path;

        std.debug.print("Path: {s}\n", .{path});
        std.debug.print("Metadata: {any}\n", .{basename});
        std.debug.print("Stats: {any}\n", .{kind});

        if (entry.kind == .Directory) {
            // If it's a directory, you can optionally recurse into it
            std.debug.print("Entering directory: {s}\n", .{entry.path});
            try get_dir_entries(entry.path); // Recursion to walk subdirectories
        }
    }
}

pub fn main() !void {
    const path = "./notes";
    _ = try get_dir_entries(path);
}
