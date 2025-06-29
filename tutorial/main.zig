const std = @import("std");

const Index = u32;

const Color = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,
};

const Vec2 = struct {
    x: f32,
    y: f32,

    const zero = Vec2{ .x = 0, .y = 0 };
    const one = Vec2{ .x = 1, .y = 1 };
};

const Size = struct {
    w: f32,
    h: f32,

    const zero = Size{ .w = 0, .h = 0 };
    const inf = Size{ .w = std.math.inf(f32), .h = std.math.inf(f32) };
};

const Rect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    const zero = Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };

    fn isPointInside(self: Rect, p: Vec2) bool {
        return (self.x <= p.x and p.x <= self.x + self.w) and
            (self.y <= p.y and p.y <= self.y + self.h);
    }
};

const LayoutDirection = enum {
    row,
    col,
    wrap,
    grid_row,
    grid_col,
};

const SizingType = enum {
    fit,
    grow,
    percent,
    fixed,
};

const SizingLimits = struct {
    min: f32 = 0,
    max: f32 = std.math.inf(f32),
};

const Sizing = struct {
    /// Either the size for .fixed, fraction for .grow, or [[0..100]] for percent
    data: f32,
    type: SizingType,
    min: f32 = 0,
    max: f32 = std.math.inf(f32),

    fn fit(lim: ?SizingLimits) Sizing {
        const l = lim orelse SizingLimits{};
        return Sizing{ .type = .fit, .data = undefined, .min = l.min, .max = l.max };
    }

    fn grow(lim: ?SizingLimits) Sizing {
        const l = lim orelse SizingLimits{};
        return Sizing{ .type = .grow, .data = 1, .min = l.min, .max = l.max };
    }

    fn fraction(fr: f32, lim: ?SizingLimits) Sizing {
        const l = lim orelse SizingLimits{};
        return Sizing{ .type = .grow, .data = fr, .min = l.min, .max = l.max };
    }

    fn percent(per: f32, lim: ?SizingLimits) Sizing {
        const l = lim orelse SizingLimits{};
        return Sizing{ .type = .percent, .data = per, .min = l.min, .max = l.max };
    }

    fn fixed(size: f32, lim: ?SizingLimits) Sizing {
        const l = lim orelse SizingLimits{};
        return Sizing{ .type = .fixed, .data = size, .min = l.min, .max = l.max };
    }
};

const Padding = struct {
    top: f32 = 0,
    left: f32 = 0,
    right: f32 = 0,
    bottom: f32 = 0,
    gap_row: f32 = 0,
    gap_col: f32 = 0,
};

const Border = packed struct {
    top: bool = false,
    left: bool = false,
    right: bool = false,
    bottom: bool = false,
    between: bool = false,
    width: f32 = 0,
    color: Color = .{},
    shader: ?usize = null,
};

const Rounding = struct {
    tl: f32 = 0,
    tr: f32 = 0,
    bl: f32 = 0,
    br: f32 = 0,
};

const ElementConfig = struct {
    bg: Color = .{},
    dir: LayoutDirection = .col,
    width: Sizing = .fit(null),
    height: Sizing = .fit(null),
    border: Border = .{},
    padding: Padding = .{},
    rounding: Rounding = .{},
    expand: Size = .zero, // i.e. css negative margin
    // TODO:
    // align: Foo = .{},
    // floating: Foo = .{},
};

const TextConfig = struct {
    font_id: u32,
    font_size: f32,
    color: Color,
    text: []const u8,
    // TODO: alignment, spacing, wrapping etc.
};

const ImageConfig = struct {
    w: f32,
    h: f32,
    handle: usize,
};

const ElementNode = struct {
    rect: Rect = .zero,
    min: Size = .zero,
    max: Size = .inf,
    conf: union(enum) {
        node: ElementConfig,
        text: TextConfig,
        image: ImageConfig,
        // custom: *anyopaque, // TODO: maybe
    },
    children: std.ArrayListUnmanaged(Index) = .empty,
    parent: Index,
};

// TODO:
const DrawCommand = struct {
    _: void,
};

const no_parent = std.math.maxInt(Index);

const Context = struct {
    alloc: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,

    // TODO: Consider changing this to a MultiArrayList
    nodes: std.ArrayListUnmanaged(ElementNode) = .empty,
    stack: std.ArrayListUnmanaged(Index) = .empty,

    // FIXME: wrong lifetime for local arena
    fn init(allocator: std.mem.Allocator) Context {
        const arena = std.heap.ArenaAllocator.init(allocator);
        return Context{
            .arena = arena,
            .alloc = arena.allocator(),
        };
    }

    fn openElement(self: *Context, conf: ElementConfig) std.mem.Allocator.Error!void {
        try self.stack.append(self.alloc, self.nodes.items.len);
        try self.nodes.append(self.alloc, .{
            .conf = conf,
            .parent = self.stack.getLastOrNull() orelse no_parent,
        });
    }

    fn closeElement(self: *Context) void {
        fitSizingPass(self);
    }

    fn fitSizingPass(self: *Context) void {
        const idx = self.stack.pop().?;
        const node = self.nodes.items[idx];
        const parent = self.nodes.items[node.parent];
        const num_gaps: f32 = @floatFromInt(@max(node.children.items.len, 1) - 1);

        switch (node.conf.dir) {
            .row => node.rect.w += node.conf.padding.gap_row * num_gaps,
            .col => node.rect.h += node.conf.padding.gap_col * num_gaps,
        }
        node.rect.w += node.conf.padding.left + node.conf.padding.right;
        node.rect.h += node.conf.padding.top + node.conf.padding.bottom;

        // TODO: for all grow children, find the min fr and normalize them by *= 1 / fr_min
        switch (parent.conf.dir) {
            .row => {
                parent.rect.w = @max(parent.rect.w + node.rect.w, parent.max.w);
                parent.rect.h = @max(parent.rect.h, node.rect.h, parent.max.h);
                parent.min.w += node.min.w;
                parent.min.h = @max(parent.min.h, node.min.h);
            },
            .col => {
                parent.rect.h = @max(parent.rect.h + node.rect.h, parent.max.h);
                parent.rect.w = @max(parent.rect.w, node.rect.w, parent.max.w);
                parent.min.h += node.min.h;
                parent.min.w = @max(parent.min.w, node.min.w);
            },
        }
    }

    fn growSizingPass(self: *Context, node: *const ElementNode) void {
        const num_gaps: f32 = @floatFromInt(@max(node.children.items.len, 1) - 1);
        const padding_h = node.conf.padding.top + node.conf.padding.bottom;
        const padding_w = node.conf.padding.left + node.conf.padding.right + node.conf.padding.gap * num_gaps;

        var fr_sum: f32 = 0;
        var fr_size = node.rect.w - padding_w;
        var growable = std.BoundedArray(Index, 128){};

        for (node.children) |child_idx| {
            const child = self.nodes.items[child_idx];
            const child_fr = child.conf.width.data;

            if (child.conf.width.type == .grow) {
                fr_sum += child_fr;
                growable.append(child_idx) catch @panic("Out of memory");
            } else {
                fr_size -= child.rect.w;
            }
        }

        if (total_w > node.rect.w) {
            // TODO: Shrink grow/fit children
            return;
        }

        // Growing
        while (fr_size > 0) {
            var i: u32 = 0;
            while (i < growable.len) : (i +%= 1) {
                const child = self.nodes.items[i];
                const child_fr = child.conf.width.data;
                const child_w = child_fr * fr_size / fr_sum;

                if (child_w <= child.max.w) {
                    child.rect.w = child_w;
                    fr_size -= child_w;
                } else {
                    child.rect.w = child.max.w;
                    fr_size -= child.max.w;
                    fr_sum -= child.conf.width.data;
                    _ = growable.swapRemove(i);
                    i -%= 1;
                }
            }
        }
    }

    // fn growSizingPass(self: *Context, node: *const ElementNode) void {
    //     if (node.conf != .node) @panic("unimplemented");
    //     const node_conf = node.conf.node;
    //
    //     var fr_sum: f32 = 0;
    //     var remaining_w = node.rect.w;
    //     var remaining_h = node.rect.w;
    //     remaining_w -= node_conf.padding.left + node_conf.padding.right;
    //     remaining_h -= node_conf.padding.top + node_conf.padding.bottom;
    //
    //     for (node.children) |child_idx| {
    //         const child = self.nodes.items[child_idx];
    //         const child_conf = child.conf.node;
    //
    //         switch (child_conf.width.type) {
    //             .grow => {
    //                 fr_sum += child_conf.width.data;
    //                 growable.append(child_idx) catch @panic("Out of memory");
    //             },
    //             else => remaining_w -= child.rect.w,
    //         }
    //     }
    //
    //     const num_gaps: f32 = @floatFromInt(@max(node.children.items.len, 1) - 1);
    //     remaining_w -= node_conf.padding.gap_row * num_gaps;
    //
    //     if (growable.len > 0) while (remaining_w > 0) {
    //         var smallest = std.math.inf(f32);
    //         var second = std.math.inf(f32);
    //         var w_to_add = remaining_w;
    //
    //         for (growable.slice()) |child_idx| {
    //             const child = self.nodes.items[child_idx];
    //             const child_prop_size = child.rect.w / child.conf.node.width.data;
    //
    //             if (child_prop_size < smallest) {
    //                 second = smallest;
    //                 smallest = child_prop_size;
    //             }
    //             if (child_prop_size > smallest) {
    //                 second = @min(second, child_prop_size);
    //                 w_to_add = second - smallest;
    //             }
    //         }
    //
    //         // Wrong
    //         w_to_add = @min(w_to_add, remaining_w / growable.len);
    //
    //         for (growable.slice()) |child_idx| {
    //             const child = self.nodes.items[child_idx];
    //             const child_prop_size = child.rect.w / child.conf.node.width.data;
    //             const prop_w_to_add = w_to_add * child.conf.node.width.data;
    //
    //             if (floatEql(child_prop_size, smallest)) {
    //                 child.rect.w += prop_w_to_add;
    //                 remaining_w -= prop_w_to_add;
    //             }
    //         }
    //     };
    // }

    fn floatEql(x: f32, y: f32) bool {
        const tolerance = @sqrt(std.math.floatEps(f32));
        return std.math.approxEqRel(f32, x, y, tolerance);
    }

    fn render(self: Context) []const DrawCommand {
        // TODO
    }
};
