const std = @import("std");
const nt = @import("../src/root.zig");
const print = std.debug.print;

const text_header = nt.TextConfig{};

pub fn main() !void {
    nt.grid("dir-col rounded-md p-0 border-1 border-slate-700" ++
        "templ-cols:[max-w-200px repeat(5, w-1fr) w-fit]" ++
        "templ-rows:[]")({

        // Header
        nt.text("Name", text_header);
        nt.text("A", text_header);
        nt.text("B", text_header);
        nt.text("C", text_header);
        nt.text("D", text_header);
        nt.text("E", text_header);
        nt.text("F", text_header);
        nt.node()();

        // Rows
        nt.node("col-1 row-0 w-1px h-grow bg-slate-700")();
        nt.node("col-2 row-0 w-1px h-grow bg-slate-700")();
        nt.node("col-3 row-0 w-1px h-grow bg-slate-700")();
        nt.node("col-4 row-0 w-1px h-grow bg-slate-700")();
        nt.node("col-5 row-0 w-1px h-grow bg-slate-700")();
    });
}
