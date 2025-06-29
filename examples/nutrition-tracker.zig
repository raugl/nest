const std = @import("std");
const ui = @import("../src/root.zig");
const print = std.debug.print;

const text_header = ui.TextConfig{};

pub fn main() !void {
    // Grid needs:
    //    - x/y gaps
    //    - x/y borders
    //    - child alignment within a cell
    //    - flow direction for automatic layout
    //    - template rows/cols
    //    - template overflow rows/cols
    //    - maybe something like 'repeat(auto-fit, ...)'
    //
    // Grid cells need:
    //    - start..end row/col
    //    - row/col-start/end/span

    // NOTE: the axis with `..` will be the one in which element overflow
    ui.node("dir-grid rounded-md p-0 col-gap-1 row-gap-2  border-1 border-slate-700 " ++
        "cols-[minmax(1fr, 200px) repeat(5, 1fr) fit] " ++
        "rows-[200px..]")({
        const num_rows = 5;
        const num_cols = 5;

        // NOTE: Order matters for overlapping elements
        // Row alternating background color
        var row: u16 = 1;
        while (row < num_rows) : (row += 2) {
            ui.node("col-start-1.5 col-span-0 col-end col-[1..7] row-[3; 4] rounded-sm bg-gray-600")({
                ui.style(.{ .row = row });
            });
        }

        // Header
        ui.text("Name", text_header);
        ui.text("A", text_header);
        ui.text("B", text_header);
        ui.text("C", text_header);
        ui.text("D", text_header);
        ui.text("E", text_header);
        ui.text("F", text_header);
        ui.node()();

        // Vertical separators
        for (0..num_cols) |col| {
            ui.node("row-0 w-1px span-y-full bg-slate-700")({
                ui.style(.{ .col = col });
            });
        }
    });
}

fn renderDay() !void {
    for (meals) |meal| {
        wx.collapsingHeader(meal.name)({
            try renderMealTable(meal.rows);
        });
    }
}

fn renderMealTable(rows: []Row) !void {
    // Allow two or more grids to be 'synced' with each other. They are different elements with their
    // own properties, but they all participate in a single sizing resolution. They could use the same
    // id, or use 'sync-[meta-table-id]'
    // TODO: Add 'Add food' button

    ui.node("id-[table]")({
        const TableData = struct {
            order: [6]u8 = .{ 0, 1, 2, 3, 4, 5 },
            widths: [6]?f32 = @splat(null),
        };
        const self = ui.persist(TableData, .{});
        const header_names = [_][]const u8{ "Name", "Protein", "Carbo", "Fat", "Energy", "Weight" };

        // TODO: Add column sorting
        // const sort_ctx = Row.SortCtx{ .col = 0 };
        // std.mem.sort(Row, rows, sort_ctx, Row.lessThan);

        ui.node("id-[table-header] dir-col bg-gray-300 rounded-t-md border-all-1 border-slate-700 sync-[table-grid]")({
            // TODO: Draw shadow

            for (self.order) |idx| {
                ui.node("px-2 py-1 align-left")({
                    self.widths[idx] = self.widths[idx] orelse ui.prevRect().w;
                    ui.style(.{ .w = self.widths[idx] });

                    ui.text(header_names[idx], text_header);
                    // TODO: Add column reordering
                    // TODO: Add column resizing
                });
            }
        });

        // name | protein | carbo | fat | energy | weight | remove button
        wx.scroll(.vertical)({
            ui.node("id-[table-body] dir-col sync-[table-grid]")({
                for (rows) |*row| {
                    const info = db.get(row.food_id);

                    wx.dropdown();

                    dragFoodValue(row, info, 0);
                    dragFoodValue(row, info, 1);
                    dragFoodValue(row, info, 2);
                    dragFoodValue(row, info, 3);
                    dragFoodValue(row, info, 4);

                    // TODO: Figure out if I want it inside or outside the table
                    // TODO: delete button
                    ui.node("p-2 rounded-sm")({});
                }
            });
        });

        ui.node("id-[summary-footer] dir-col sync-[table-grid]")({
            // TODO
        });
    });
}

const Row = struct {
    food_id: u32 = 0,
    /// protein | carbo | fat | energy | weight
    /// Expressed in absolute weights
    values: [5]f32 = @splat(1),

    const SortCtx = struct {
        col: u8,
        asc: bool = true,
    };

    fn lessThan(ctx: SortCtx, a: Row, b: Row) bool {
        const ord = std.math.order(a.values[ctx.col], b.values[ctx.col]);
        if (ctx.asc) {
            return ord == .lt;
        }
        return ord == .gt;
    }
};

const FoodInfo = struct {
    name: []const u8,
    /// protein | carbo | fat | energy | weight
    /// Expressed in relative weights
    values: [5]f32 = @splat(1),
};

fn dragFoodValue(row: *Row, info: FoodInfo, idx: u32) void {
    if (wx.dragValue(f32, &row.values[idx], 0.5)) {
        for (0..row.values.len) |i| {
            if (i == idx) continue;
            row.value[i] *= info.values[i] / info.values[idx];
        }
        row.values[idx] = @max(0, row.protein);
    }
}

const Tag = struct {
    title: []const u8,
};

const Card = struct {
    title: []const u8,
    desc: []const u8,
    tags: []const Tag,
};

fn renderCardGrid(cards: []const Card) !void {
    wx.scoll(.vertical)({
        ui.node("id-[card-grid] dir-grid gap-4 cols-[grow..] rows-[minmax(grow, 300px)..]")({
            ui.style(.{ .num_cols = ui.prevRect().w / 200 * px });

            for (cards) |data| {
                ui.node("id-[card] dir-col p-2 gap-2 rounded-md bg-gray-300")({
                    ui.text(data.title, text_heading);
                    ui.text(data.desc, text_content);
                    ui.node("id-[tags-wrapping] dir-wrap gap-2 align-left")({
                        for (data.tags) |tag| {
                            ui.node("id-[tag] rounded-sm bg-indigo-500")({
                                ui.text(tag.title, text_small);
                            });
                        }
                    });
                });
            }
        });
    });
}

/// Widgets namespace
const wx = struct {
    // TODO
    pub fn scroll(dir: ui.ScrollDirection) fn (void) void {
        _ = dir;
        ui.openElement("") catch @panic("out of memory");
        return ui.closeElement;
    }

    fn modalThrowAway(open: *bool) void {
        if (open.*) {
            ui.node(.{ .relative = .root, .size = .grow, .bg = .gray_500.alpha(0.33) })();

            // ui.node("dir-col relative-root center max-w-40% max-h-40% parent-root rounded-md shadow-xl")({
            ui.node(.{ .dir = .col, .relative = .root, .max_size = .precent(40), .parent = .root, .rounded = .md, .shadow = .xl })({
                ui.node("dir-row py-2 px-4 gap-4 align-top")({
                    ui.node("rounded-full bg-rose-300 w-32 h-32")({
                        ui.text("", .{ .color = .red_700 });
                    });
                    ui.node("dir-col gap-2")({
                        ui.text("Deactive account", text_heading);
                        ui.text("Are you sure you want to deactivate your account? All of your data " ++
                            "will be permanently removed. This action cannot be undone.", text_content);
                    });
                });
                ui.node("dir-row bg-gray-200 py-2 px-4 w-grow gap-2")({
                    ui.node("grow")();
                    if (wx.buttonNorm("Cancel")) open.* = false;
                    if (wx.buttonRed("Deactivate")) open.* = false;
                });
            });
        }
    }

    // TODO:
    fn modal(open: *bool) void {
        if (open.*) {
            ui.node("relative-root w-grow h-grow bg-gray-500/33")();

            ui.node("dir-col relative-root center max-w-40% max-h-40% parent-root rounded-md shadow-xl")({
                ui.node("dir-row py-2 px-4 gap-4 align-top")({
                    ui.node("rounded-full bg-rose-300 w-32 h-32")({
                        ui.text("", .{ .color = .red_700 });
                    });
                    ui.node("dir-col gap-2")({
                        ui.text("Deactive account", text_heading);
                        ui.text("Are you sure you want to deactivate your account? All of your data " ++
                            "will be permanently removed. This action cannot be undone.", text_content);
                    });
                });
                ui.node("dir-row bg-gray-200 py-2 px-4 w-grow gap-2")({
                    ui.node("grow")();
                    if (wx.buttonNorm("Cancel")) open.* = false;
                    if (wx.buttonRed("Deactivate")) open.* = false;
                });
            });
        }
    }

    fn slider(comptime T: type, value: *T, min: T, max: T) void {
        const info = @typeInfo(T);
        std.debug.assert(info == .int or info == .float or info == .bool);

        ui.node("id-[slider] align-center p-4")({
            const rect = ui.prevRect();

            if (ui.input().drag) {
                const t = clamp(0, 1, (ui.input().cursor_pos.x - rect.x) / rect.w);
                switch (info) {
                    .int => value.* = @intFromFloat(@round(t * (max - min))),
                    .bool => value.* = t > 0.5,
                    .float => value.* = t * (max - min),
                }
            }
            ui.node("id-[slider-bar] h-4 w-grow rounded-sm bg-gray-500")({
                ui.node("id-[slider-handle] relative-center w-2 h-2 rounded-full bg-gray-500")({
                    ui.style(.{
                        .border_color = pointerInteract(ui.Color.gray_500, .gray_200, .gray_50),
                        .border_width = .all(pointerInteract(1, 2, 3)),
                        .left = rect.w * value.* / (max - min),
                    });
                });
            });
        });

        // TODO: This shouldn't depend on the computed size, is there another way?
        // NOTE: The use of `getRect()` could signal to the library to persist the computed rect
        // only for this element to the next frame, where it would be handed off immediatly. This
        // would then need to return an optional `Rect`.
        // const rect = ui.prevRect();
        // var t = @as(f32, @floatFromInt(ui.input().cursor_pos.x - rect.x));
        // t = clamp(0, 1, t / @as(f32, @floatFromInt(rect.w)));
    }

    var text_buf: [128]u8 = undefined;

    fn dragValue(comptime T: type, value: *T, step: T) bool {
        var changed = false;

        ui.node("align-center px-2 py-0.5")({
            const Mode = enum { drag, text };
            const mode = ui.persist(Mode, .drag);

            const bg, const color, const width = switch (mode) {
                .text => .{ gray_0, .white, 2 },
                .drag => .{
                    pointerInteract(gray_3, gray_2, gray_1),
                    pointerInteract(.black, gray_4, .white),
                    pointerInteract(0, 1, 2),
                },
            };
            ui.style(.{ .bg = bg, .border_color = color, .border_width = .all(width) });

            if (mode == .drag) {
                if (ui.input().clicked()) mode = .text;
                if (ui.input().drag) {
                    const delta = ui.input().cursor_delta;
                    value.* += (delta.x - delta.y) * step;
                }
                changed |= ui.input().drop;
                std.fmt.bufPrint(&text_buf, "{d}°", value.*);
                ui.text(&text_buf, .{ .color = color });
            } else {
                if (ui.input().press(.escape) or ui.input().press(.enter)) {
                    mode = .drag;
                }
                changed |= input.press(.enter);
                // TODO: implement text input
            }
        });
        return changed;
    }
};

fn clamp(value: anytype, min: @TypeOf(value), max: @TypeOf(value)) @TypeOf(value) {
    return @max(min, @min(max, value));
}

fn pointerInteract(default: anytype, hover: @TypeOf(default), press: @TypeOf(default)) @TypeOf(default) {
    const i = ui.input();
    return if (i.drag or i.lmb_down) press else if (i.hover) hover else default;
}
