const std = @import("std");
const builtin = @import("builtin");
const log = std.log.scoped(.main);

pub inline fn debug(comptime fmt: []const u8, args: anytype) void {
    if (builtin.mode == .Debug) {
        log.debug(fmt, args);
    }
}
