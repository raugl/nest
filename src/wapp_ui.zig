const std = @import("std");

const Emoji = u32;
const UserID = u64;
const MessageID = u32;
const Timestamp = i64;

const Color = union {
    f: struct {
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    },
    u: u32,
};

const TextConfig = struct {
    font: i32,
    color: Color,
};

const Image = struct {
    bytes: []const u8,
    width: u32 = 0,
    height: u32 = 0,
};

const User = struct {
    id: UserID = 0,
    phone_number: []const u8,
    name: ?[]const u8 = null,
    nickname: ?[]const u8 = null,
    profile_pic: Image,
    color: Color,
};

const Message = struct {
    id: MessageID,
    time: Timestamp,
    sender: User,
    content: union(enum) {
        text: []const u8,
        photo: Image,
        video: void, // TODO
        audio: void, // TODO
        sticker: void, // TODO
    },
    is_reply: ?MessageID = null,
    reactions: std.AutoArrayHashMap(UserID, Emoji), // PERF: replace this with a sorted array
};

const BG_GRAY_1 = "";
const BG_GRAY_2 = "";
const FG_GRAY_1 = "";
const FG_GRAY_2 = "";
const FG_PRIMARY = "";

const Data = struct {
    alloc: std.mem.Allocator,
    messages: []Message,
    this_user: UserID = 1234,
    open_menu_id: ?MessageID = null,
};

fn render(ctx: Data) !void {
    const emoji_icon: Image = .{};
    const corner_triangle: Image = .{};
    const down_chevron: Image = .{};

    ui.elem("id-[#message-list] dir-col px-2 scroll-y")({
        var curr_day: Timestamp = 0;
        var prev_sender: ?UserID = null;

        for (ctx.messages) |msg| {
            const msg_day = msg.time / std.time.s_per_day;
            if (msg_day != curr_day) {
                curr_day = msg_day;

                ui.elem("id-[date-label] dir-row py-2")({
                    ui.elem("w-grow")();
                    ui.elemf("px-4 py-2 rounded-md bg-{}", .{ .bg = BG_GRAY_1 })({
                        ui.label(msg.time, .{ .font = 0, .color = FG_GRAY_2 });
                    });
                    ui.elem("w-grow")();
                });
            }

            const same_sender = prev_sender == msg.sender.id;
            prev_sender = msg.sender.id;

            if (msg.sender.id == ctx.this_user) {
                ui.label("unimplemeneted", .{});

                //
            } else {
                ui.elem("id-[message-bounding-area] dir-row align-top")({
                    ui.elem("id-[profile-pic] rounded-full")({
                        ui.image(msg.sender.profile_pic);
                    });
                    ui.image(corner_triangle);
                    ui.elemf(
                        "id-[message-panel] dir-col p-0.5 space-2 rounded-b-md rounded-tr-md max-w-{} bg-{}",
                        .{ .bg = BG_GRAY_2, .max_w = ui.getSizePx(.root).x },
                    )({
                        if (!same_sender) {
                            ui.elem("id-[message-header] dir-row p-1.5")({
                                const name_conf = TextConfig{ .font = 0, .color = msg.sender.color };

                                if (msg.sender.name) |name| {
                                    ui.label(name, name_conf);
                                } else {
                                    ui.label("~ ", name_conf);
                                    ui.label(msg.sender.nickname orelse "user", name_conf);
                                    ui.elem("w-min-0 w-max-16")();
                                    ui.label(msg.sender.phone_number, .{ .font = 0, .color = FG_GRAY_1 });
                                }
                            });
                        }

                        if (ctx.open_menu_id != msg.idx) {
                            if (ui.cursor().enter) ui.transition(.ease_out_expo, 0.5);
                            if (ui.cursor().leave) ui.transition(.ease_out_expo_rev, 0.5);
                        }

                        if (ui.getTransition() != 0) {
                            ui.elemf(
                                "id-[animated-context-button] relative clip top-0 -right-{}px",
                                .{ .right = ui.getTransition() * down_chevron.width },
                            )({
                                ui.image(down_chevron);
                                if (ui.cursor().press_1) {
                                    ctx.open_menu_id = msg.id;
                                    // TODO: Transition open the menu
                                }
                            });

                            if (ctx.open_menu_id == msg.id and ui.cursor().press_1 and ui.cursor().outside) {
                                ctx.open_menu_id = null;
                                ui.transition(.ease_out_expo_rev, 0.5);
                                // TODO: Transition closed the menu
                            }
                        }

                        if (ctx.open_menu_id == msg.id) {}

                        if (msg.is_reply) |idx| {
                            const sender = ctx.messages[idx].sender;

                            ui.elem("id-[message-reply] dir-row rounded-md border-r-2")({
                                ui.elemf("h-grow w-1.5 bg-{}", .{ .bg = sender.color })();
                                ui.elem("dir-col")({
                                    ui.elem("h-grow")();
                                    ui.label(sender.name, .{ .color = sender.color });
                                    ui.label(ctx.messages[idx].content);
                                    ui.elem("h-grow")();
                                });
                                if (ctx.messages[idx].content.preview()) {}
                            });
                        }

                        // id-[message-content]
                        switch (msg.content) {
                            .text => |text| ui.elem("p-1.5")({
                                ui.label(text, .{ .font = 0, .color = FG_PRIMARY });
                            }),
                            .photo => |image| ui.elem("rounded-md")({
                                ui.image(image);
                                // TODO: add permanently visible share button
                            }),
                        }

                        // FIXME: Make sure that the text content and the time stamp don't overlap
                        ui.elem("id-[message-time] relative -bottom-1 -right-2")({
                            ui.label(format(msg.time), .{ .font = 0, .color = FG_GRAY_2 });
                        });

                        if (ui.hovered()) {
                            ui.elem("id-[react-button] relative top-0 right-2 h-grow align-center take-up-space")({
                                ui.elem("bg-black bg-opacity-30 rounded-full p-1")({
                                    ui.image(emoji_icon);
                                });
                            });
                        }

                        if (msg.reactions.count() != 0) {
                            ui.elem(
                                "id-[message-reactions] dir-row relative no-clip take-up-space -bottom-1 right-2 rounded-full max-w-{}",
                                .{ .max_w = @min(ui.getSize(ui.parentID()).x, 16) },
                            )({
                                for (msg.reactions.values()) |emoji| {
                                    ui.label(std.mem.asBytes(emoji), .{ .font = 0, .color = FG_GRAY_2 });
                                }
                                if (msg.reactions.count() > 1) {
                                    ui.label(format(msg.reactions.count()));
                                }
                            });
                        }
                    });
                });
                ui.elem("mb-{}", .{ .mb = if (same_sender) 0.2 else 2 })();
            }
        }
    });
}

fn format(_: anytype) []const u8 {
    return "formatted";
}

const ui = struct {
    const CursorState = packed struct {
        enter: bool = false, // The cursor just entered the current element
        leave: bool = false, // The cursor just left the current element
        inside: bool = false, // The cursor is inside the current element
        outside: bool = false, // The cursor is outside the current element
        drag: bool = false, // The currsor is currently dragging something
        drop: bool = false, // The cursor just dropped something

        press_1: bool = false, // Mouse button 1 is being pressed
        press_2: bool = false, // Mouse button 2 is being pressed
        press_3: bool = false, // Mouse button 3 is being pressed
        press_4: bool = false, // Mouse button 4 is being pressed
        press_5: bool = false, // Mouse button 5 is being pressed
        press_6: bool = false, // Mouse button 6 is being pressed
        press_7: bool = false, // Mouse button 7 is being pressed
        press_8: bool = false, // Mouse button 8 is being pressed

        hold_1: bool = false, // Mouse button 1 is being held
        hold_2: bool = false, // Mouse button 2 is being held
        hold_3: bool = false, // Mouse button 3 is being held
        hold_4: bool = false, // Mouse button 4 is being held
        hold_5: bool = false, // Mouse button 5 is being held
        hold_6: bool = false, // Mouse button 6 is being held
        hold_7: bool = false, // Mouse button 7 is being held
        hold_8: bool = false, // Mouse button 8 is being held

        release_1: bool = false, // Mouse button 1 is being released
        release_2: bool = false, // Mouse button 2 is being released
        release_3: bool = false, // Mouse button 3 is being released
        release_4: bool = false, // Mouse button 4 is being released
        release_5: bool = false, // Mouse button 5 is being released
        release_6: bool = false, // Mouse button 6 is being released
        release_7: bool = false, // Mouse button 7 is being released
        release_8: bool = false, // Mouse button 8 is being released
    };

    fn cursor() CursorState {
        return false;
    }

    fn elem(comptime style: []const u8) fn (void) void {
        _ = style;
    }

    fn elemf(comptime style_fmt: []const u8, args: anytype) fn (void) void {
        _ = .{ style_fmt, args };
    }

    fn label(text: []const u8, conf: TextConfig) void {
        _ = .{ text, conf };
    }

    fn image(bar: Image) void {
        _ = bar;
    }

    fn hovered() bool {
        return false;
    }
};
