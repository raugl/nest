const std = @import("std");

// TODO: Open zig issue about caller source location

fn log(comptime msg: []const u8) !void {
    const address = @returnAddress();
    const debug_info = try std.debug.getSelfDebugInfo();
    const module = try debug_info.getModuleForAddress(address);
    const symbol_info = try module.getSymbolAtAddress(debug_info.allocator, address);
    defer if (symbol_info.source_location) |sl| debug_info.allocator.free(sl.file_name);

    var buffer: [128]u8 = undefined;
    const loc = symbol_info.source_location.?;
    @compileLog(try std.fmt.bufPrint(
        &buffer,
        "[INFO]: Message from '{s}' {}:{}\n{s}\n",
        .{ symbol_info.name, loc.line, loc.column, msg },
    ));
}

fn proc() void {
    comptime {
        log("from proc") catch unreachable;
    }
}

pub fn main() !void {
    std.debug.print("{d}", .{});
    // comptime {
    //     log("from main") catch unreachable;
    // }
    // proc();
}
