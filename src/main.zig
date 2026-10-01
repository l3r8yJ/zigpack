const std = @import("std");
const Io = std.Io;

const zigpack = @import("zigpack");
const log = @import("fmts/log.zig");
const format = @import("fmts/format.zig");

const c = @cImport({
    @cInclude("alpm.h");
    @cInclude("alpm_list.h");
});

pub fn main(_: std.process.Init) !void {
    var err: c.alpm_errno_t = undefined;
    const handle = c.alpm_initialize("/", "/var/lib/pacman", &err);
    if (null == handle) {
        log.debug("Failed to initialize libalpm: {s}\n", .{c.alpm_strerror(err)});
        return;
    }
    log.debug("libalpm initialized successfully!", .{});
    const local_db = c.alpm_get_localdb(handle) orelse {
        log.debug("Failed to get local DB", .{});
        return;
    };
    const installed = c.alpm_db_get_pkgcache(local_db);
    var node = installed;
    while (node != null) : (node = node.*.next) {
        const casted: *c.alpm_pkg_t = @ptrCast(@alignCast(node.*.data));
        const package = init_package(casted);
        log.debug(format.auto(Package), .{package});
    }
}

const Package = struct {
    name: []const u8,
};

fn init_package(src: *c.alpm_pkg_t) Package {
    return .{ .name = std.mem.span(c.alpm_pkg_get_name(src)) };
}
