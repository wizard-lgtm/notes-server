const std = @import("std");
const net = std.net;
const mem = std.mem;
const fs = std.fs;

pub fn get_dir_entries(allocator: mem.Allocator, path: []const u8) !std.ArrayList(fs.Dir.Walker.Entry) {
    var list = std.ArrayList(fs.Dir.Walker.Entry).init(allocator);
    const opendir_opt: fs.Dir.OpenDirOptions = .{ .access_sub_paths = true };
    var dir = try fs.cwd().openDir(path, opendir_opt);
    defer dir.close();

    var it: fs.Dir.Walker = try dir.walk(std.heap.page_allocator);
    while (try it.next()) |entry| {
        _ = try list.append(entry);
    }

    return list;
}

test "get dir test" {
    const allocator = std.testing.allocator;
    const path = "./notes";
    const list = try get_dir_entries(allocator, path);
    defer _ = list.deinit();

    for (list.items) |entry| {
        const basename = entry.basename;
        const kind = entry.kind;
        const epath = entry.path;

        std.debug.print("Path: {s} ", .{epath});
        std.debug.print("basename: {s} ", .{basename});
        std.debug.print("kind: {any}\n", .{kind});
    }
}
