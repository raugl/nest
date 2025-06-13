const std = @import("std");
const ui = @import("root.zig");

threadlocal var button_result: ui.CursorState = undefined;

pub fn buttonEx() fn (void) ui.CursorState {
    ui.openElement("id-[button] dir-left-right py-1 gap-6 rounded-md consume-press-left");

    const t = ui.persist(f32);
    if (ui.cursor().enter) ui.animate(.ease_out_expo, 200, t);
    if (ui.cursor().leave) ui.animate(.ease_out_expo, -200, t);

    ui.style(.{
        .scale = util.lerp(100, 105, t),
        .bg = .lerp(.purple_400, .purple_200, t),
    });

    const Fn = struct {
        fn close() ui.CursorState {
            ui.closeElement();
            return button_result;
        }
    };
    return Fn.close;
}

pub fn button(label: []const u8) ui.CursorState {
    return buttonEx()({
        ui.text(label, .{});
    });
}

threadlocal var menu_result: u64 = 0;

/// The `Options` should be an enum and contain a zero value reserved for no interactions
pub fn menuWrapper(comptime Options: type, icons: []const ?ui.Texture) fn (void) Options {
    const options = std.meta.fieldNames(Options)[1..];
    std.debug.assert(icons.len == options.len);
    std.debug.assert(@typeInfo(Options) == .@"enum");

    ui.openElement("w-grow h-grow consume-press-right");
    const t = ui.persist(f32);
    const is_open = ui.persist(bool);

    if (ui.cursor().press_right) {
        is_open = true;
        ui.animate(.ease_out, -200, t);
    }

    if (is_open or t > 0) {
        ui.node("id-[context-menu] dir-top-down min-w-[200px] p-2 gap-2 rounded-md bg-purple-600")({
            if (is_open) ui.style(.{
                .scale = util.lerp(100, 80, t),
                .opacity = util.lerp(100, 0, t),
            }) else ui.style(.{
                .scale = util.lerp(100, 10, t),
            });

            for (options, icons, 0..) |option, icon, i| {
                const res = ui.buttonEx()({
                    ui.text(option, .{});
                    ui.node("id-[spacing] w-grow")();
                    if (icon) ui.image(icon.?, 64, 64);
                });
                if (res.press_left) {
                    is_open = false;
                    ui.animate(.ease_out, 200, t);
                    menu_result = @enumFromInt(i + 1);
                }
            }
        });
    }

    const Fn = struct {
        fn close() Options {
            ui.closeElement();
            return @intFromEnum(menu_result);
        }
    };
    return Fn.close;
}

pub fn slider(value_ptr: anytype, min: @TypeOf(value_ptr.*), max: @TypeOf(value_ptr.*)) void {}
