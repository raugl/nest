const Vec2 = struct {
    x: f32,
    y: f32,
};

const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

const InstanceData = struct {
    center: Vec2,
    size: Vec2,
    radius: f32,
    color: Color,
    // rotation: f32
    depth: u8,
};

fn stencilFragmentShader() u8 {
    const frag_coord: Vec2 = .{};
    const instance: InstanceData = .{};

    // TODO: Maybe rotation
    const q = @abs(instance.center - instance.size * 0.5) - (instance.size * 0.5 - instance.radius);
    const d = length(max(q, 0)) - instance.radius;
    if (d > 0) discard;
    return instance.depth;
}

fn renderFragmentShader() Color {
    const frag_coord: Vec2 = .{};
    const instance: InstanceData = .{};
    const stencil_buffer: [][]u8 = .{};

    // TODO: Maybe anti-aliasing
    // TODO: Maybe discard transparent rects in an earlier stage
    if (instance.color == vec4(0)) discard;

    const depth = texture(stencil_buffer, frag_coord);
    if (depth < instance.depth) discard;
    return instance.color;
}

fn render() void {
    // TODO: Implement a hybrid clipping approach where `SDL_SetGPUScissor` is used for windows
    // and scroll areas, the stencil texture for rounded corners, and nothing for the rest.

    // Step 1: transform the tree into a list of InstanceData's and upload them to a storage buffer
    // Step 2: render instanced quads to a stencil texture, only if they have rounded corners
    // Step 3: render instanced quads again, this time to the frame buffer. Manually do the stencil test
}
