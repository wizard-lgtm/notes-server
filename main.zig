const std = @import("std");
const net = std.net;
const mem = std.mem;
const fs = std.fs;

const PORT: u16 = 4000;
const addr: net.Address = net.Address.initIp4(.{ 127, 0, 0, 1 }, PORT);
const listen_opt: net.Address.ListenOptions = .{ .reuse_address = true, .reuse_port = true };

const StatusLine = struct { version: []const u8, path: []const u8, method: []const u8 };
fn parse_head(head: []const u8) StatusLine {
    var headlines = std.mem.splitAny(u8, head, "\r\n");
    const statusline_buffer = headlines.first();
    var statusline_parts = std.mem.splitAny(u8, statusline_buffer, " ");

    var statusline: StatusLine = undefined;
    statusline.method = statusline_parts.first();
    statusline.path = statusline_parts.next() orelse "";
    statusline.version = statusline_parts.next() orelse "";

    return statusline;
}
const Mime = enum {
    Text,
    Http,
    Json,
    Bin,
    Jpg,
};

const mime_text = "text/plain";
const mime_http = "text/html";
const mime_json = "application/json";
const mime_bin = "application/octet-stream";
const mime_jpg = "image/jpeg";

fn get_mime_string(mime: Mime) []const u8 {
    switch (mime) {
        Mime.Text => return mime_text,
        Mime.Http => return mime_http,
        Mime.Json => return mime_json,
        Mime.Bin => return mime_bin,
        Mime.Jpg => return mime_jpg,
    }
}

fn pack_http(allocator: mem.Allocator, status: u16, code: []const u8, mime: Mime, body: []const u8) ![]u8 {
    const len: usize = body.len;

    const mime_str: []const u8 = get_mime_string(mime);
    const fmt = "HTTP/1.1 {d} {s}\r\nContent-Type: {s}\r\nContent-Length: {d}\r\n\r\n{s}";
    const buffer: []u8 = try std.fmt.allocPrint(allocator, fmt, .{ status, code, mime_str, len, body });
    return buffer;
}
fn end_stream(buffer: []u8, stream: net.Stream) !void {
    // write message
    const written: usize = try stream.write(buffer);
    _ = written; // no need to handle written len

    // end stream
    stream.close();
}

fn handle_connection(allocator: mem.Allocator, server: *net.Server) !void {
    const connection: net.Server.Connection = try server.accept();

    const stream = connection.stream;
    const client_address = connection.address;

    const buffer: []u8 = try allocator.alloc(u8, 1024);
    const read: usize = try stream.read(buffer);
    const head: []u8 = buffer[0..read];

    std.debug.print("new steam: {any} read:{s}\n", .{ client_address.in, head });

    // get status line
    const statusline: StatusLine = parse_head(head);
    const path = statusline.path;
    const method = statusline.method;
    const version = statusline.version;
    std.debug.print("statusline: \n", .{});
    std.debug.print("method: {s}\n", .{method});
    std.debug.print("path: {s}\n", .{path});
    std.debug.print("version: {s}\n", .{version});

    // routing

    // home / GET
    if (std.mem.eql(
        u8,
        path,
        "/",
    ) and std.mem.eql(u8, method, "GET")) {
        const body = "<h1>Welcome to notes server</h1>, <i>wizard lgtm</i>";

        const http = try pack_http(allocator, 200, "OK", Mime.Http, body);

        _ = try end_stream(http, stream);
    }
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator: mem.Allocator = gpa.allocator();

    var server: net.Server = try addr.listen(listen_opt);

    while (true) {
        _ = try handle_connection(allocator, &server);
    }
}
