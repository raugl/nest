/// TODO: implement `persist()`
/// TODO: implement scroll containers
/// TODO: implement floating containers
/// TODO: implement wrapping containers
/// TODO: implement cursor interactions
/// TODO: implement the style parser
/// TODO: think about grid layout
const std = @import("std");
pub usingnamespace api;

const api = struct {
    /// Open a UI element
    pub fn node(comptime config: []const u8) fn (void) void {
        openElement(config);
        return closeElement;
    }

    pub fn cursor() CursorState {
        return .{};
    }

    /// Adds extra values of configuration to the currently open UI element.
    /// Useful for setting computed values, while avoiding formatting strings.
    /// Must be called before opening any child elements with anoter call to `ctx.ui()`.
    pub fn style(style: StyleConfig) void {}

    pub fn animate(curve: AnimationCurve, duration_ms: i32, t: *f32) void {}

    pub fn persist(comptime T: type, init_val: T) *T {
        return ctx.cache.getOrPut(T, ctx.curr_id, init_val);
    }

    pub fn image(texture: Texture, size: Vec2) void {}

    pub fn text(text: []const u8, config: TextConfig) void {}
};

pub const Vec2 = struct {
    x: i32,
    y: i32,

    pub const zero = Vec2{ .x = 0, .y = 0 };
    pub const one = Vec2{ .x = 1, .y = 1 };
};

pub const Mat4 = struct {
    x: [4]f32,
    y: [4]f32,
    z: [4]f32,
    w: [4]f32,

    pub const zero = Mat4{ .x = @splat(0), .y = @splat(0), .z = @splat(0), .w = @splat(0) };

    pub const identity = Mat4{
        .x = .{ 1, 0, 0, 0 },
        .y = .{ 0, 1, 0, 0 },
        .z = .{ 0, 0, 1, 0 },
        .w = .{ 0, 0, 0, 1 },
    };
};

/// An image strored in GPU memory
pub const Texture = struct {
    handle: u64 = 0,
    width: u32 = 0,
    height: u32 = 0,
};

/// An image stored in CPU memory
pub const Image = struct {
    bytes: []const u8,
    width: u32 = 0,
    height: u32 = 0,
};

pub const Color = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,

    pub fn lerp(from: Color, to: Color, t: f32) Color {
        return Color{
            .r = from.r * t + to.r * (1 - t),
            .g = from.g * t + to.g * (1 - t),
            .b = from.b * t + to.b * (1 - t),
            .a = from.a * t + to.a * (1 - t),
        };
    }

    // Slate
    pub const slate_50 = Color{ .r = 248, .g = 250, .b = 252 };
    pub const slate_100 = Color{ .r = 241, .g = 245, .b = 249 };
    pub const slate_200 = Color{ .r = 226, .g = 232, .b = 240 };
    pub const slate_300 = Color{ .r = 203, .g = 213, .b = 225 };
    pub const slate_400 = Color{ .r = 148, .g = 163, .b = 184 };
    pub const slate_500 = Color{ .r = 100, .g = 116, .b = 139 };
    pub const slate_600 = Color{ .r = 71, .g = 85, .b = 105 };
    pub const slate_700 = Color{ .r = 51, .g = 65, .b = 85 };
    pub const slate_800 = Color{ .r = 30, .g = 41, .b = 59 };
    pub const slate_900 = Color{ .r = 15, .g = 23, .b = 42 };
    pub const slate_950 = Color{ .r = 2, .g = 6, .b = 23 };

    // Gray
    pub const gray_50 = Color{ .r = 249, .g = 250, .b = 251 };
    pub const gray_100 = Color{ .r = 243, .g = 244, .b = 246 };
    pub const gray_200 = Color{ .r = 229, .g = 231, .b = 235 };
    pub const gray_300 = Color{ .r = 209, .g = 213, .b = 219 };
    pub const gray_400 = Color{ .r = 156, .g = 163, .b = 175 };
    pub const gray_500 = Color{ .r = 107, .g = 114, .b = 128 };
    pub const gray_600 = Color{ .r = 75, .g = 85, .b = 99 };
    pub const gray_700 = Color{ .r = 55, .g = 65, .b = 81 };
    pub const gray_800 = Color{ .r = 31, .g = 41, .b = 55 };
    pub const gray_900 = Color{ .r = 17, .g = 24, .b = 39 };
    pub const gray_950 = Color{ .r = 3, .g = 7, .b = 18 };

    // Zinc
    pub const zinc_50 = Color{ .r = 250, .g = 250, .b = 250 };
    pub const zinc_100 = Color{ .r = 244, .g = 244, .b = 245 };
    pub const zinc_200 = Color{ .r = 228, .g = 228, .b = 231 };
    pub const zinc_300 = Color{ .r = 212, .g = 212, .b = 216 };
    pub const zinc_400 = Color{ .r = 161, .g = 161, .b = 170 };
    pub const zinc_500 = Color{ .r = 113, .g = 113, .b = 122 };
    pub const zinc_600 = Color{ .r = 82, .g = 82, .b = 91 };
    pub const zinc_700 = Color{ .r = 63, .g = 63, .b = 70 };
    pub const zinc_800 = Color{ .r = 39, .g = 39, .b = 42 };
    pub const zinc_900 = Color{ .r = 24, .g = 24, .b = 27 };
    pub const zinc_950 = Color{ .r = 9, .g = 9, .b = 11 };

    // Neutral
    pub const neutral_50 = Color{ .r = 250, .g = 250, .b = 250 };
    pub const neutral_100 = Color{ .r = 245, .g = 245, .b = 245 };
    pub const neutral_200 = Color{ .r = 229, .g = 229, .b = 229 };
    pub const neutral_300 = Color{ .r = 212, .g = 212, .b = 212 };
    pub const neutral_400 = Color{ .r = 163, .g = 163, .b = 163 };
    pub const neutral_500 = Color{ .r = 115, .g = 115, .b = 115 };
    pub const neutral_600 = Color{ .r = 82, .g = 82, .b = 82 };
    pub const neutral_700 = Color{ .r = 64, .g = 64, .b = 64 };
    pub const neutral_800 = Color{ .r = 38, .g = 38, .b = 38 };
    pub const neutral_900 = Color{ .r = 23, .g = 23, .b = 23 };
    pub const neutral_950 = Color{ .r = 10, .g = 10, .b = 10 };

    // Stone
    pub const stone_50 = Color{ .r = 250, .g = 250, .b = 249 };
    pub const stone_100 = Color{ .r = 245, .g = 245, .b = 244 };
    pub const stone_200 = Color{ .r = 231, .g = 229, .b = 228 };
    pub const stone_300 = Color{ .r = 214, .g = 211, .b = 209 };
    pub const stone_400 = Color{ .r = 168, .g = 162, .b = 158 };
    pub const stone_500 = Color{ .r = 120, .g = 113, .b = 108 };
    pub const stone_600 = Color{ .r = 87, .g = 83, .b = 78 };
    pub const stone_700 = Color{ .r = 68, .g = 64, .b = 60 };
    pub const stone_800 = Color{ .r = 41, .g = 37, .b = 36 };
    pub const stone_900 = Color{ .r = 28, .g = 25, .b = 23 };
    pub const stone_950 = Color{ .r = 12, .g = 10, .b = 9 };

    // Red
    pub const red_50 = Color{ .r = 254, .g = 242, .b = 242 };
    pub const red_100 = Color{ .r = 254, .g = 226, .b = 226 };
    pub const red_200 = Color{ .r = 254, .g = 202, .b = 202 };
    pub const red_300 = Color{ .r = 252, .g = 165, .b = 165 };
    pub const red_400 = Color{ .r = 248, .g = 113, .b = 113 };
    pub const red_500 = Color{ .r = 239, .g = 68, .b = 68 };
    pub const red_600 = Color{ .r = 220, .g = 38, .b = 38 };
    pub const red_700 = Color{ .r = 185, .g = 28, .b = 28 };
    pub const red_800 = Color{ .r = 153, .g = 27, .b = 27 };
    pub const red_900 = Color{ .r = 127, .g = 29, .b = 29 };
    pub const red_950 = Color{ .r = 69, .g = 10, .b = 10 };

    // Orange
    pub const orange_50 = Color{ .r = 255, .g = 247, .b = 237 };
    pub const orange_100 = Color{ .r = 255, .g = 237, .b = 213 };
    pub const orange_200 = Color{ .r = 254, .g = 215, .b = 170 };
    pub const orange_300 = Color{ .r = 253, .g = 186, .b = 116 };
    pub const orange_400 = Color{ .r = 251, .g = 146, .b = 60 };
    pub const orange_500 = Color{ .r = 249, .g = 115, .b = 22 };
    pub const orange_600 = Color{ .r = 234, .g = 88, .b = 12 };
    pub const orange_700 = Color{ .r = 194, .g = 65, .b = 12 };
    pub const orange_800 = Color{ .r = 154, .g = 52, .b = 18 };
    pub const orange_900 = Color{ .r = 124, .g = 45, .b = 18 };
    pub const orange_950 = Color{ .r = 67, .g = 20, .b = 7 };

    // Amber
    pub const amber_50 = Color{ .r = 255, .g = 251, .b = 235 };
    pub const amber_100 = Color{ .r = 254, .g = 243, .b = 199 };
    pub const amber_200 = Color{ .r = 253, .g = 230, .b = 138 };
    pub const amber_300 = Color{ .r = 252, .g = 211, .b = 77 };
    pub const amber_400 = Color{ .r = 251, .g = 191, .b = 36 };
    pub const amber_500 = Color{ .r = 245, .g = 158, .b = 11 };
    pub const amber_600 = Color{ .r = 217, .g = 119, .b = 6 };
    pub const amber_700 = Color{ .r = 180, .g = 83, .b = 9 };
    pub const amber_800 = Color{ .r = 146, .g = 64, .b = 14 };
    pub const amber_900 = Color{ .r = 120, .g = 53, .b = 15 };
    pub const amber_950 = Color{ .r = 69, .g = 26, .b = 3 };

    // Yellow
    pub const yellow_50 = Color{ .r = 254, .g = 252, .b = 232 };
    pub const yellow_100 = Color{ .r = 254, .g = 249, .b = 195 };
    pub const yellow_200 = Color{ .r = 254, .g = 240, .b = 138 };
    pub const yellow_300 = Color{ .r = 253, .g = 224, .b = 71 };
    pub const yellow_400 = Color{ .r = 250, .g = 204, .b = 21 };
    pub const yellow_500 = Color{ .r = 234, .g = 179, .b = 8 };
    pub const yellow_600 = Color{ .r = 202, .g = 138, .b = 4 };
    pub const yellow_700 = Color{ .r = 161, .g = 98, .b = 7 };
    pub const yellow_800 = Color{ .r = 133, .g = 77, .b = 14 };
    pub const yellow_900 = Color{ .r = 113, .g = 63, .b = 18 };
    pub const yellow_950 = Color{ .r = 66, .g = 32, .b = 6 };

    // Lime
    pub const lime_50 = Color{ .r = 247, .g = 254, .b = 231 };
    pub const lime_100 = Color{ .r = 236, .g = 252, .b = 203 };
    pub const lime_200 = Color{ .r = 217, .g = 249, .b = 157 };
    pub const lime_300 = Color{ .r = 190, .g = 242, .b = 100 };
    pub const lime_400 = Color{ .r = 163, .g = 230, .b = 53 };
    pub const lime_500 = Color{ .r = 132, .g = 204, .b = 22 };
    pub const lime_600 = Color{ .r = 101, .g = 163, .b = 13 };
    pub const lime_700 = Color{ .r = 77, .g = 124, .b = 15 };
    pub const lime_800 = Color{ .r = 63, .g = 98, .b = 18 };
    pub const lime_900 = Color{ .r = 54, .g = 83, .b = 20 };
    pub const lime_950 = Color{ .r = 26, .g = 46, .b = 5 };

    // Green
    pub const green_50 = Color{ .r = 240, .g = 253, .b = 244 };
    pub const green_100 = Color{ .r = 220, .g = 252, .b = 231 };
    pub const green_200 = Color{ .r = 187, .g = 247, .b = 208 };
    pub const green_300 = Color{ .r = 134, .g = 239, .b = 172 };
    pub const green_400 = Color{ .r = 74, .g = 222, .b = 128 };
    pub const green_500 = Color{ .r = 34, .g = 197, .b = 94 };
    pub const green_600 = Color{ .r = 22, .g = 163, .b = 74 };
    pub const green_700 = Color{ .r = 21, .g = 128, .b = 61 };
    pub const green_800 = Color{ .r = 22, .g = 101, .b = 52 };
    pub const green_900 = Color{ .r = 20, .g = 83, .b = 45 };
    pub const green_950 = Color{ .r = 5, .g = 46, .b = 22 };

    // Emerald
    pub const emerald_50 = Color{ .r = 236, .g = 253, .b = 245 };
    pub const emerald_100 = Color{ .r = 209, .g = 250, .b = 229 };
    pub const emerald_200 = Color{ .r = 167, .g = 243, .b = 208 };
    pub const emerald_300 = Color{ .r = 110, .g = 231, .b = 183 };
    pub const emerald_400 = Color{ .r = 52, .g = 211, .b = 153 };
    pub const emerald_500 = Color{ .r = 16, .g = 185, .b = 129 };
    pub const emerald_600 = Color{ .r = 5, .g = 150, .b = 105 };
    pub const emerald_700 = Color{ .r = 4, .g = 120, .b = 87 };
    pub const emerald_800 = Color{ .r = 6, .g = 95, .b = 70 };
    pub const emerald_900 = Color{ .r = 6, .g = 78, .b = 59 };
    pub const emerald_950 = Color{ .r = 2, .g = 44, .b = 34 };

    // Teal
    pub const teal_50 = Color{ .r = 240, .g = 253, .b = 250 };
    pub const teal_100 = Color{ .r = 204, .g = 251, .b = 241 };
    pub const teal_200 = Color{ .r = 153, .g = 246, .b = 228 };
    pub const teal_300 = Color{ .r = 94, .g = 234, .b = 212 };
    pub const teal_400 = Color{ .r = 45, .g = 212, .b = 191 };
    pub const teal_500 = Color{ .r = 20, .g = 184, .b = 166 };
    pub const teal_600 = Color{ .r = 13, .g = 148, .b = 136 };
    pub const teal_700 = Color{ .r = 15, .g = 118, .b = 110 };
    pub const teal_800 = Color{ .r = 17, .g = 94, .b = 89 };
    pub const teal_900 = Color{ .r = 19, .g = 78, .b = 74 };
    pub const teal_950 = Color{ .r = 4, .g = 47, .b = 46 };

    // Cyan
    pub const cyan_50 = Color{ .r = 236, .g = 254, .b = 255 };
    pub const cyan_100 = Color{ .r = 207, .g = 250, .b = 254 };
    pub const cyan_200 = Color{ .r = 165, .g = 243, .b = 252 };
    pub const cyan_300 = Color{ .r = 103, .g = 232, .b = 249 };
    pub const cyan_400 = Color{ .r = 34, .g = 211, .b = 238 };
    pub const cyan_500 = Color{ .r = 6, .g = 182, .b = 212 };
    pub const cyan_600 = Color{ .r = 8, .g = 145, .b = 178 };
    pub const cyan_700 = Color{ .r = 14, .g = 116, .b = 144 };
    pub const cyan_800 = Color{ .r = 21, .g = 94, .b = 117 };
    pub const cyan_900 = Color{ .r = 22, .g = 78, .b = 99 };
    pub const cyan_950 = Color{ .r = 8, .g = 51, .b = 68 };

    // Sky
    pub const sky_50 = Color{ .r = 240, .g = 249, .b = 255 };
    pub const sky_100 = Color{ .r = 224, .g = 242, .b = 254 };
    pub const sky_200 = Color{ .r = 186, .g = 230, .b = 253 };
    pub const sky_300 = Color{ .r = 125, .g = 211, .b = 252 };
    pub const sky_400 = Color{ .r = 56, .g = 189, .b = 248 };
    pub const sky_500 = Color{ .r = 14, .g = 165, .b = 233 };
    pub const sky_600 = Color{ .r = 2, .g = 132, .b = 199 };
    pub const sky_700 = Color{ .r = 3, .g = 105, .b = 161 };
    pub const sky_800 = Color{ .r = 7, .g = 89, .b = 133 };
    pub const sky_900 = Color{ .r = 12, .g = 74, .b = 110 };
    pub const sky_950 = Color{ .r = 8, .g = 47, .b = 73 };

    // Blue
    pub const blue_50 = Color{ .r = 239, .g = 246, .b = 255 };
    pub const blue_100 = Color{ .r = 219, .g = 234, .b = 254 };
    pub const blue_200 = Color{ .r = 191, .g = 219, .b = 254 };
    pub const blue_300 = Color{ .r = 147, .g = 197, .b = 253 };
    pub const blue_400 = Color{ .r = 96, .g = 165, .b = 250 };
    pub const blue_500 = Color{ .r = 59, .g = 130, .b = 246 };
    pub const blue_600 = Color{ .r = 37, .g = 99, .b = 235 };
    pub const blue_700 = Color{ .r = 29, .g = 78, .b = 216 };
    pub const blue_800 = Color{ .r = 30, .g = 64, .b = 175 };
    pub const blue_900 = Color{ .r = 30, .g = 58, .b = 138 };
    pub const blue_950 = Color{ .r = 23, .g = 37, .b = 84 };

    // Indigo
    pub const indigo_50 = Color{ .r = 238, .g = 242, .b = 255 };
    pub const indigo_100 = Color{ .r = 224, .g = 231, .b = 255 };
    pub const indigo_200 = Color{ .r = 199, .g = 210, .b = 254 };
    pub const indigo_300 = Color{ .r = 165, .g = 180, .b = 252 };
    pub const indigo_400 = Color{ .r = 129, .g = 140, .b = 248 };
    pub const indigo_500 = Color{ .r = 99, .g = 102, .b = 241 };
    pub const indigo_600 = Color{ .r = 79, .g = 70, .b = 229 };
    pub const indigo_700 = Color{ .r = 67, .g = 56, .b = 202 };
    pub const indigo_800 = Color{ .r = 55, .g = 48, .b = 163 };
    pub const indigo_900 = Color{ .r = 49, .g = 46, .b = 129 };
    pub const indigo_950 = Color{ .r = 30, .g = 27, .b = 75 };

    // Violet
    pub const violet_50 = Color{ .r = 245, .g = 243, .b = 255 };
    pub const violet_100 = Color{ .r = 237, .g = 233, .b = 254 };
    pub const violet_200 = Color{ .r = 221, .g = 214, .b = 254 };
    pub const violet_300 = Color{ .r = 196, .g = 181, .b = 253 };
    pub const violet_400 = Color{ .r = 167, .g = 139, .b = 250 };
    pub const violet_500 = Color{ .r = 139, .g = 92, .b = 246 };
    pub const violet_600 = Color{ .r = 124, .g = 58, .b = 237 };
    pub const violet_700 = Color{ .r = 109, .g = 40, .b = 217 };
    pub const violet_800 = Color{ .r = 91, .g = 33, .b = 182 };
    pub const violet_900 = Color{ .r = 76, .g = 29, .b = 149 };
    pub const violet_950 = Color{ .r = 46, .g = 16, .b = 101 };

    // Purple
    pub const purple_50 = Color{ .r = 250, .g = 245, .b = 255 };
    pub const purple_100 = Color{ .r = 243, .g = 232, .b = 255 };
    pub const purple_200 = Color{ .r = 233, .g = 213, .b = 255 };
    pub const purple_300 = Color{ .r = 216, .g = 180, .b = 254 };
    pub const purple_400 = Color{ .r = 192, .g = 132, .b = 252 };
    pub const purple_500 = Color{ .r = 168, .g = 85, .b = 247 };
    pub const purple_600 = Color{ .r = 147, .g = 51, .b = 234 };
    pub const purple_700 = Color{ .r = 126, .g = 34, .b = 206 };
    pub const purple_800 = Color{ .r = 107, .g = 33, .b = 168 };
    pub const purple_900 = Color{ .r = 88, .g = 28, .b = 135 };
    pub const purple_950 = Color{ .r = 59, .g = 7, .b = 100 };

    // Fuchsia
    pub const fuchsia_50 = Color{ .r = 253, .g = 244, .b = 255 };
    pub const fuchsia_100 = Color{ .r = 250, .g = 232, .b = 255 };
    pub const fuchsia_200 = Color{ .r = 245, .g = 208, .b = 254 };
    pub const fuchsia_300 = Color{ .r = 240, .g = 171, .b = 252 };
    pub const fuchsia_400 = Color{ .r = 232, .g = 121, .b = 249 };
    pub const fuchsia_500 = Color{ .r = 217, .g = 70, .b = 239 };
    pub const fuchsia_600 = Color{ .r = 192, .g = 38, .b = 211 };
    pub const fuchsia_700 = Color{ .r = 162, .g = 28, .b = 175 };
    pub const fuchsia_800 = Color{ .r = 134, .g = 25, .b = 143 };
    pub const fuchsia_900 = Color{ .r = 112, .g = 26, .b = 117 };
    pub const fuchsia_950 = Color{ .r = 74, .g = 4, .b = 78 };

    // Pink
    pub const pink_50 = Color{ .r = 253, .g = 242, .b = 248 };
    pub const pink_100 = Color{ .r = 252, .g = 231, .b = 243 };
    pub const pink_200 = Color{ .r = 251, .g = 207, .b = 232 };
    pub const pink_300 = Color{ .r = 249, .g = 168, .b = 212 };
    pub const pink_400 = Color{ .r = 244, .g = 114, .b = 182 };
    pub const pink_500 = Color{ .r = 236, .g = 72, .b = 153 };
    pub const pink_600 = Color{ .r = 219, .g = 39, .b = 119 };
    pub const pink_700 = Color{ .r = 190, .g = 24, .b = 93 };
    pub const pink_800 = Color{ .r = 157, .g = 23, .b = 77 };
    pub const pink_900 = Color{ .r = 131, .g = 24, .b = 67 };
    pub const pink_950 = Color{ .r = 80, .g = 7, .b = 36 };

    // Rose
    pub const rose_50 = Color{ .r = 255, .g = 241, .b = 242 };
    pub const rose_100 = Color{ .r = 255, .g = 228, .b = 230 };
    pub const rose_200 = Color{ .r = 254, .g = 205, .b = 211 };
    pub const rose_300 = Color{ .r = 253, .g = 164, .b = 175 };
    pub const rose_400 = Color{ .r = 251, .g = 113, .b = 133 };
    pub const rose_500 = Color{ .r = 244, .g = 63, .b = 94 };
    pub const rose_600 = Color{ .r = 225, .g = 29, .b = 72 };
    pub const rose_700 = Color{ .r = 190, .g = 18, .b = 60 };
    pub const rose_800 = Color{ .r = 159, .g = 18, .b = 57 };
    pub const rose_900 = Color{ .r = 136, .g = 19, .b = 55 };
    pub const rose_950 = Color{ .r = 76, .g = 5, .b = 25 };
};

const CursorState = packed struct {
    enter: bool = false, // The cursor just entered the current element
    leave: bool = false, // The cursor just left the current element
    inside: bool = false, // The cursor is inside the current element
    outside: bool = false, // The cursor is outside the current element
    drag: bool = false, // The currsor is currently dragging something
    drop: bool = false, // The cursor just dropped something

    press_left: bool = false, // Mouse button 1 is being pressed
    press_right: bool = false, // Mouse button 2 is being pressed
    press_middle: bool = false, // Mouse button 3 is being pressed
    press_4: bool = false, // Mouse button 4 is being pressed
    press_5: bool = false, // Mouse button 5 is being pressed
    press_6: bool = false, // Mouse button 6 is being pressed
    press_7: bool = false, // Mouse button 7 is being pressed
    press_8: bool = false, // Mouse button 8 is being pressed

    hold_left: bool = false, // Mouse button 1 is being held
    hold_right: bool = false, // Mouse button 2 is being held
    hold_middle: bool = false, // Mouse button 3 is being held
    hold_4: bool = false, // Mouse button 4 is being held
    hold_5: bool = false, // Mouse button 5 is being held
    hold_6: bool = false, // Mouse button 6 is being held
    hold_7: bool = false, // Mouse button 7 is being held
    hold_8: bool = false, // Mouse button 8 is being held

    release_left: bool = false, // Mouse button 1 is being released
    release_right: bool = false, // Mouse button 2 is being released
    release_middle: bool = false, // Mouse button 3 is being released
    release_4: bool = false, // Mouse button 4 is being released
    release_5: bool = false, // Mouse button 5 is being released
    release_6: bool = false, // Mouse button 6 is being released
    release_7: bool = false, // Mouse button 7 is being released
    release_8: bool = false, // Mouse button 8 is being released
};

const CursorShape = enum {
    default,
    pointer, // hand
    help,
    wait,
    progress,
    text,
    crosshair,
    move,
    grab,
    grabbing,
    no_drop,
    not_allowed,
    all_scroll,

    // Resize: cardinal directions
    nresize,
    sresize,
    eresize,
    wresize,

    // Resize: corners
    neresize,
    nwresize,
    seresize,
    swresize,

    // Resize: logical directions
    ewresize,
    nsresize,
    nesWResize,
    nwsEResize,

    // Resize: table/grid
    ColResize,
    RowResize,
};

const LayoutDirection = enum {
    top_down,
    left_right,
};

const ScrollDirection = enum {
    none,
    vertical,
    horizontal,
    both,
};

const ChildAlignment = enum {
    top_left,
    top_center,
    top_right,
    center_left,
    center,
    center_right,
    bottom_left,
    bottom_center,
    bottom_right,
};

const SizingType = enum {
    fit,
    grow,
    fixed,
    percent,
};

const Sizing = struct {
    type: SizingType = .fit,
    fixed: Scalar = 0,
    percent: f32 = 0,
    min: ?Scalar = null,
    max: ?Scalar = null,
};

const Padding = struct {
    left: u16 = 0,
    right: u16 = 0,
    top: u16 = 0,
    bottom: u16 = 0,
};

const Rounding = struct {
    top_left: u16 = 0,
    top_right: u16 = 0,
    bottom_left: u16 = 0,
    bottom_right: u16 = 0,
};

const BorderWidth = struct {
    left: u16 = 0,
    right: u16 = 0,
    top: u16 = 0,
    bottom: u16 = 0,
    between_children: u16 = 0,
};

const Border = struct {
    width: BorderWidth = .{},
    color: Color = .{},
};

const FloatingAttachTo = enum {
    none,
    parent,
    element_with_id,
    root,
};

const FloatingAttachPoints = extern struct {
    /// Controls the origin point on the floating element that attaches to its parent
    element: ChildAlignment = .top_left,
    /// Controls the origin point on the parent element that the floating element attaches to
    parent: ChildAlignment = .top_left,
};

const Floating = extern struct {
    /// Offsets this floating element by these x,y coordinates from its attachPoints
    offset: Vec2 = .zero,
    /// When using CLAY_ATTACH_TO_ELEMENT_WITH_ID, attaches to element with this ID
    parent_id: ID = 0,
    /// Z-index controls stacking order (ascending)
    z_idx: u16 = 0,
    /// Controls attachment points between floating element and its parent
    attach_points: FloatingAttachPoints = .{ .element = .left_top, .parent = .left_top },
    /// Controls which element this floating element is attached to
    attach_to: FloatingAttachTo = .none,
};

const ImageConfig = struct {
    texture: Texture,
    width: u32,
    height: u32,
};

const NodeConfig = struct {
    width: Sizing = .{},
    height: Sizing = .{},
    border: Border = .{},
    rounding: Rounding = .{},
    padding: Padding = .{},
    child_gap: u16 = 0,
    child_alignment: ChildAlignment = .{},
    direction: LayoutDirection = .{},
    scroll: ScrollDirection = .{},
    background_color: Color = .{},
    floating: Floating = .{},

    // Extra
    transform: Mat4 = .identity,
    cursor_shape: CursorShape = .default,
    cursor_capture: CursorState = .{},
};

const TextWrapping = enum {
    words, // (default) Breaks text on whitespace characters
    new_lines, // Don't break on space characters, only on newlines
    none, // Disable text wrapping entirely
};

const WrapAlignment = enum {
    left, // (default) Aligns text to the left edge
    center, // Aligns text to the center
    right, // Aligns text to the right edge
};

const TextConfig = struct {
    color: Color = .{},
    font_id: u16 = 0,
    font_size: u16 = 20,
    letter_spacing: u16 = 0,
    vertical_spacing: u16 = 0,
    wrap_mode: TextWrapping = .words,
    alignement: WrapAlignment = .left,
};

pub const AnimationCurve = enum {
    linear,
    ease_in,
    ease_out,
    ease_in_out,
};

const ScaleType = enum {
    xs,
    sm,
    md,
    lg,
    xl,
    xl2,
    xl3,
    xl4,
    xl5,
    xl6,
    xl7,
    xl8,
    xl9,
};

pub const StyleConfig = struct {
    // Width
    w: ?u16 = null,
    min_w: ?u16 = null,
    max_w: ?u16 = null,
    w_fit: ?bool = null,
    w_grow: ?bool = null,
    w_precent: ?f32 = null,

    // Height
    h: ?u16 = null,
    min_h: ?u16 = null,
    max_h: ?u16 = null,
    h_fit: ?bool = null,
    h_grow: ?bool = null,
    h_precent: ?f32 = null,

    // Rounding
    rounded: ?ScaleType = null,
    rounded_l: ?ScaleType = null,
    rounded_r: ?ScaleType = null,
    rounded_t: ?ScaleType = null,
    rounded_b: ?ScaleType = null,
    rounded_tl: ?ScaleType = null,
    rounded_tr: ?ScaleType = null,
    rounded_bl: ?ScaleType = null,
    rounded_br: ?ScaleType = null,

    // Padding
    p: ?u16 = null,
    px: ?u16 = null,
    py: ?u16 = null,
    pl: ?u16 = null,
    pr: ?u16 = null,
    pt: ?u16 = null,
    pb: ?u16 = null,
    gap: u16 = 0,

    dir: ?LayoutDirection = null,
    bg: Color = .{},
    scroll: ?ScrollDirection = null,
    @"align": ?ChildAlignment = null,

    border: Border = .{},
    floating: Floating = .{},
};

const ID = u32;
const Index = u32;
const Scalar = i32;
const Queue = std.fifo.LinearFifo(Index, .Slice);

const Node = struct {
    parent: Index = 0,
    config: NodeConfig,
    children: std.ArrayListUnmanaged(Index) = .{},

    scroll_x: f32 = 0,
    scroll_y: f32 = 0,

    width: Scalar = 0,
    height: Scalar = 0,
    min_width: Scalar = 0,
    min_height: Scalar = 0,
};

const no_parrent = 0xffff_ffff;
var ctx: Context = undefined;

const Context = struct {
    alloc: std.mem.Allocator,
    nodes: std.ArrayListUnmanaged(Node),
    stack: std.ArrayListUnmanaged(Index),
    curr_idx: Index = 0,
    curr_id: ID = 0,

    cache: @import("persist_cache.zig").Cache,

    // TODO
    fn init(alloc: std.mem.Allocator) !Context {
        const elements = try alloc.alloc(Index, 256);
        errdefer alloc.free(elements);

        return Context{
            .alloc = alloc,
            .stack = elements,
        };
    }

    fn deinit(self: Context) void {
        self.nodes.deinit(self.alloc);
        self.stack.deinit(self.alloc);
    }
};

// TODO
fn openElement(comptime config: []const u8) std.mem.Allocator.Error!void {
    try ctx.nodes.append(ctx.alloc, .{
        .config = parseElementConfig(config),
        .parent = ctx.stack.getLastOrNull() orelse no_parrent,
    });
    try ctx.stack.append(ctx.alloc, ctx.nodes.items.len);
}

// TODO
fn closeElement() void {
    const node = &ctx.nodes.items[ctx.stack.pop().?]; // Did you forget to open a node?
    const parent = &ctx.nodes.items[node.parent];

    const padding = node.config.padding;
    node.width += padding.left + padding.right;
    node.height += padding.top + padding.bottom;

    switch (node.config.direction) {
        .left_right => {
            node.width += (@max(1, node.children.items.len) - 1) * node.config.child_gap;
            parent.width += node.width;
            parent.min_width += node.min_width;
            parent.height = @max(parent.height, node.height);
            parent.min_height = @max(parent.min_height, node.min_height);
        },
        .top_down => {
            node.height += (@max(1, node.children.items.len) - 1) * node.config.child_gap;
            parent.height += node.height;
            parent.min_height += node.min_height;
            parent.width = @max(parent.width, node.width);
            parent.min_width = @max(parent.min_width, node.min_width);
        },
    }
}

fn growChildren(node: Node) void {
    var buffer: [256]Index = undefined;
    var queue: Queue = .init(&buffer);
    queue.writeItemAssumeCapacity(0);
    // TODO: implement BFS

    while (queue.reader().readUntilDelimiterArrayList) {}
    std.RingBuffer.i();

    if (node.config.direction == .top_down) growChildrenVertical(node, &queue) else growChildrenHorizontal(node, &queue);
}

fn growChildrenHorizontal(node: Node, queue: *Queue) void {
    var remaining_width = node.width;
    var remaining_height = node.height;

    const padding = node.config.padding;
    remaining_height -= padding.top + padding.bottom;
    remaining_width -= padding.left + padding.right;
    remaining_width -= (@max(1, node.children.items.len) - 1) * node.config.child_gap;

    for (node.children.items) |idx| {
        remaining_width -= ctx.nodes.items[idx].width;
    }

    var buffer: [64]*Node = undefined;
    var resizable = std.ArrayListUnmanaged(*Node).initBuffer(&buffer);

    for (node.children.items) |idx| {
        const child = &ctx.nodes.items[idx];
        if (child.config.height.type == .grow) {
            child.height = remaining_height;
        }
        if (child.config.width.type == .fit or child.config.width.type == .grow) {
            resizable.appendAssumeCapacity(child); // NOTE: If you broke out of bounds here, its safe to just increase the buffer size
            queue.writeItemAssumeCapacity(idx);
        }
    }

    while (remaining_width > 0) {
        const is_growing = false;
        const op = if (is_growing) .gt else .lt;

        var width_to_add = remaining_width;
        var first_width = resizable.items[0].width;
        var second_width = if (is_growing) std.math.maxInt(Scalar) else 0;

        for (resizable.items[1..]) |idx| {
            const child = &ctx.nodes.items[idx];

            if (std.math.compare(child.width, op, first_width)) {
                second_width = first_width;
                first_width = child.width;
            }
            if (std.math.compare(first_width, op, child.width)) {
                clamp(&second_width, op, child.width);
                width_to_add = second_width - first_width;
            }
        }
        clamp(&width_to_add, op, remaining_width / resizable.items.len);

        for (resizable.items, 0..) |idx, i| {
            const child = &ctx.nodes.items[idx];
            const prev_width = child.width;

            if (child.width == first_width) {
                child.width += width_to_add;
                if (!std.math.compare(child.min_width, op, child.width)) {
                    child.width = child.min_width;
                    _ = resizable.swapRemove(i);
                }
                remaining_width -= (child.width - prev_width);
            }
        }
    }
}

fn clamp(comptime T: type, val: *T, other: T, op: std.math.CompareOperator) void {
    if (std.math.compare(other, op, val.*)) val.* = other;
}

fn growChildrenVertical(node: Node, queue: *Queue) void {
    var remaining_width = node.width;
    var remaining_height = node.height;

    const padding = node.config.padding;
    remaining_width -= padding.left + padding.right;
    remaining_height -= padding.top + padding.bottom;
    remaining_height -= (@max(1, node.children.items.len) - 1) * node.config.child_gap;

    for (node.children.items) |idx| {
        remaining_height -= ctx.nodes.items[idx].height;
    }

    var buffer: [64]*Node = undefined;
    var growable = std.ArrayListUnmanaged(*Node).initBuffer(&buffer);

    for (node.children.items) |idx| {
        const child = &ctx.nodes.items[idx];
        if (child.config.height.type == .grow) {
            growable.appendAssumeCapacity(child); // If you broke out of bounds here, its safe to just increase the buffer size
            queue.writeItemAssumeCapacity(idx);
        }
        if (child.config.width.type == .grow) {
            child.width = remaining_width;
        }
    }

    while (remaining_height > 0) {
        var grow = remaining_height;
        var min2 = std.math.maxInt(Scalar);
        var min1 = growable.items[0].height;

        for (growable.items[1..]) |idx| {
            const child = &ctx.nodes.items[idx];

            if (child.height < min1) {
                min2 = min1;
                min1 = child.height;
            }
            if (child.height > min1) {
                min2 = @min(min2, child.height);
                grow = min2 - min1;
            }
        }
        grow = @min(grow, remaining_height / growable.items.len);

        for (growable.items) |idx| {
            const child = &ctx.nodes.items[idx];
            if (child.height == min1) {
                child.height += grow;
                remaining_height -= grow;
            }
        }
    }
}

// TODO
fn parseElementConfig(comptime str: []const u8) NodeConfig {
    _ = str;
    return NodeConfig{};
}
