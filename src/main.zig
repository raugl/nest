const std = @import("std");
const ui = @import("root.zig");

fn lerp(_: anytype, _: anytype, _: *const f32) void {}

pub fn main() !void {
    std.debug.print("My first UI!\n", .{});

    ui.node("id-[ask-box] dir-top-down rounded-xl border-2 border-slate-300 bg-gray-500 px-4 py-2 gap-2")({
        ui.inputText();
        ui.node("id-[buttons-bar] dir-left-righ gap-2")({
            ui.node("id-[upload-button] border-slate-300 boredr-2 rounded-lg p-2 consume-press-left")({
                const t = ui.persist(f32);
                ui.style(.{ .scale = lerp(100, 105, t) });

                if (ui.cursor().press_left) {
                    ui.animate(.ease_in, 150, t);
                    // TODO: Open context menu
                }

                if (ui.cursor().inside) {
                    ui.tooltip("Upload files and more");
                }
                ui.text("+", .{ .font_size = 32 });
            });
            ui.node("id-[web-search-button] dir-left-right border-slate-300 boredr-2 rounded-lg p-2 gap-1")({
                if (ui.cursor().inside) {
                    ui.tooltip("Search the web");
                }
                ui.text("@", .{ .font_size = 32 });
                ui.text("Search", .{ .font_size = 16 });
            });
            ui.node("id-[reason-button] dir-left-right border-slate-300 boredr-2 rounded-lg p-2 gap-1")({
                if (ui.cursor().inside) {
                    ui.tooltip("Think before responding");
                }
                ui.text("P", .{ .font_size = 32 });
                ui.text("Reason", .{ .font_size = 16 });
            });
            ui.node("id-[more-tools-button] border-slate-300 boredr-2 rounded-lg p-2")({
                if (ui.cursor().inside) {
                    ui.tooltip("View tools");
                }
                ui.text("...", .{ .font_size = 32 });
            });
            ui.node("id-[padding] w-grow")();
            ui.node("id-[dictate-button] border-slate-300 boredr-2 rounded-lg p-2")({
                if (ui.cursor().inside) {
                    ui.tooltip("Dictate");
                }
                ui.text("Y", .{ .font_size = 32 });
            });
            ui.node("id-[submit-button] bg-amber-50 rounded-lg p-2")({
                ui.text("^", .{ .font_size = 32 });
            });
        });
    });

    while (true) {
        // TODO: Improve this API
        const icons_ = [_]i32{1};
        const Options = enum(u8) { none, @"New Document", Edit, Delete };
        const icons = &.{ icons_[0], icons_[10], icons_[7] };

        const res = ui.menuWrapper(Options, icons)({
            ui.node("w-[1600px] p-[32px] gap-[32px] bg-indigo-900")({
                ui.node("w-[300px] h-[300px] bg-red-400")();
                ui.node("w-grow h-[200px] bg-yellow-400")();
                ui.node("w-[300px] h-[300px] bg-cyan-500")({
                    ui.style(.{ .bg = .cyan_500 });
                });
            });
        });

        switch (res) {
            .@"New Document" => {},
            .Delete => {},
            .Edit => {},
            else => {},
        }

        if (ui.button("Press Me").press_left) {
            std.debug.print("You pressed the button");
        }

        var t: f32 = 0.5;
        ui.slider(&t, 0, 1);
    }
}
