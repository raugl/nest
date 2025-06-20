const std = @import("std");
const nt = @import("../src/root.zig");
const print = std.debug.print;

const text_title = nt.TextConfig{};
const text_content = nt.TextConfig{};
const text_hint = nt.TextConfig{};

const gray0 = nt.Color{};
const light_gray0 = nt.Color{};
const light_gray1 = nt.Color{};
const black_trans = nt.Color{};

const icon_minimize = nt.Texture{};
const icon_maximize = nt.Texture{};
const icon_cross = nt.Texture{};

pub fn main() !void {
    nt.node("id-[#window] rounded-lg relative dir-col")({
        nt.style(.{ .bg = gray0 });

        nt.node("id-[tool-bar] dir-row p-2")({
            nt.node("id-[left-padding] w-1fr")();
            nt.node("id-[title] w-grow")({
                nt.text("Clocks", text_title);
            });
            nt.node("id-[right-controls] w-1fr")({
                nt.node("id-[main-menu-button] min-16 rounded-md py-1 px-4")({
                    if (hoverDelay(300)) {
                        nt.node("relative-bottom -top-1 rounded-md border-1 py-2 px-4")({
                            nt.style(.{ .bg = black_trans, .border_color = light_gray0 });
                            nt.text("Main Menu", text_content);
                        });
                    }
                    const is_open = nt.persist(bool, false);
                    if (nt.cursor().press_left and nt.cursor().inside) is_open.* = true;
                    if (nt.cursor().pressAny() and nt.cursor().outside) is_open.* = false;

                    nt.style(.{ .bg = switch (is_open) {
                        true => .lerp(.transparent, light_gray0, animHover(.ease_in_out, 150)),
                        false => .lerp(light_gray0, light_gray1, animHover(.ease_in_out, 150)),
                    } });

                    if (is_open) {
                        // TODO: render the little arrow

                        nt.node("id-[main-context-menu] dir-col relative-bottom -top-3 rounded-lg shadow p-1")({
                            nt.style(.{ .bg = light_gray0 });
                            nt.node("id-[button-0] dir-row rounded-md py-1.5 px-2 gap-2")({
                                nt.text("Keyboard Shortcuts", text_content);
                                spacer();
                                nt.text("Ctrl+?", text_hint);
                                if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                                if (nt.cursor().press_left) print("[Action]: open keyboard shortcuts\n"); // TODO
                            });
                            nt.node("id-[button-1] dir-row rounded-md py-1.5 px-2 gap-2")({
                                nt.text("Help", text_content);
                                spacer();
                                nt.text("F1", text_hint);
                                if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                                if (nt.cursor().press_left) print("[Action]: open help\n"); // TODO
                            });
                            nt.node("id-[button-2] dir-row rounded-md py-1.5 px-2 gap-2")({
                                nt.text("About Clocks", text_content);
                                spacer();
                                if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                                if (nt.cursor().press_left) print("[Action]: open about\n"); // TODO
                            });
                        });
                    }
                });
            });

            nt.node("id-[window-controls] dir-row gap-2 p-2")({
                nt.node("id-[minimize-button] rounded-full p-1")({
                    nt.style(.{ .bg = light_gray0 });
                    nt.image(icon_minimize, .{ .x = 4, .y = 4 });

                    if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                    if (nt.cursor().press_left) print("[Action]: minizime window\n"); // TODO
                });
                nt.node("id-[maximize-button] rounded-full p-1")({
                    nt.style(.{ .bg = light_gray0 });
                    nt.image(icon_maximize, .{ .x = 4, .y = 4 });

                    if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                    if (nt.cursor().press_left) print("[Action]: maximize window\n");
                });
                nt.node("id-[close-button] rounded-full p-1")({
                    nt.style(.{ .bg = light_gray0 });
                    nt.image(icon_cross, .{ .x = 4, .y = 4 });

                    if (nt.cursor().inside) nt.style(.{ .bg = light_gray1 });
                    if (nt.cursor().press_left) print("[Action]: close window\n"); // TODO
                });
            });
        });

        scroll(.vertical)({
            nt.node("id-[main-content] dir-row")({
                spacer();
                nt.node("dir-col pt-10 pb-4 gap-4")({
                    // timer
                    // resume/clear
                    // laps
                });
                spacer();
            });
        });

        nt.node("id-[foot-bar]")({
            //
        });
    });
}

fn scroll(dir: nt.ScrollDirection) fn () void {
    nt.openElement("id-[scroll-container]");
    nt.style(.{ .scroll = dir });

    // NOTE: There is only one active animation for a poineter, but there can be multiple poinetrs inside an element
    const T = struct { t: f32 };
    const U = struct { t: f32 };
    const opacity = &nt.persist(T, .{ .t = 0 }).t;
    const timeout = &nt.persist(U, .{ .t = 0 }).t;

    if (nt.cursor().moved() and nt.cursor().inside) {
        nt.animate(.ease_in_out, 250, opacity);
        timeout.* = 0;
    }
    if (opacity > 0.999) nt.animate(.linear, 1000, timeout);
    if (timeout > 0.999) nt.animate(.ease_in_out, -250, opacity);

    // TODO: Implement both scroll bars
    // TODO: Look at Clay for ideas
    const delta = nt.getScroll().y;
    nt.node("id-[vertical-scroll-bar] relative-right -right-0.5 w-0.5 rounded-full")({
        nt.style(.{
            .bg = light_gray0,
            .h = 0,
        });
    });
    return nt.closeElement;
}

fn spacer() void {
    nt.node("w-grow")();
}

fn hoverDelay(delay_ms: i32) bool {
    return animHover(.linear, delay_ms) > 0.999;
}

fn animHover(curve: nt.AnimationCurve, duration_ms: i32) f32 {
    const T = struct { t: f32 = 0 };
    const t = &nt.persist(T, .{}).t;

    if (nt.cursor().enter) nt.animate(curve, duration_ms, t);
    if (nt.cursor().leave) nt.animate(curve, -duration_ms, t);
    return t.*;
}
