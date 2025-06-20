const std = @import("std");
const root = @import("root.zig");

const ID = root.ID;

pub const CacheConfig = struct {
    size_4: u32 = 4096,
    size_8: u32 = 4096,
    size_16: u32 = 4096,
    size_32: u32 = 4096,
    size_64: u32 = 4096,
    size_128: u32 = 4096,
    size_256: u32 = 4096,
};

// TODO: Gather runtime statistics and provide suggested initial buffer sizes to the developer
pub fn Cache(conf: CacheConfig) type {
    return struct {
        const Self = @This();

        map_4: std.AutoHashMapUnmanaged(ID, u32) = .empty,
        map_8: std.AutoHashMapUnmanaged(ID, u64) = .empty,
        map_16: std.AutoHashMapUnmanaged(ID, u128) = .empty,
        map_32: std.AutoHashMapUnmanaged(ID, u256) = .empty,
        map_64: std.AutoHashMapUnmanaged(ID, u512) = .empty,
        map_128: std.AutoHashMapUnmanaged(ID, u1024) = .empty,
        map_256: std.AutoHashMapUnmanaged(ID, u2048) = .empty,

        pub fn init(alloc: std.mem.Allocator) std.mem.Allocator.Error!Self {
            var self = Self{};
            try self.map_4.ensureTotalCapacity(alloc, conf.size_4);
            try self.map_8.ensureTotalCapacity(alloc, conf.size_8);
            try self.map_16.ensureTotalCapacity(alloc, conf.size_16);
            try self.map_32.ensureTotalCapacity(alloc, conf.size_32);
            try self.map_64.ensureTotalCapacity(alloc, conf.size_64);
            try self.map_128.ensureTotalCapacity(alloc, conf.size_128);
            try self.map_256.ensureTotalCapacity(alloc, conf.size_256);
            return self;
        }

        pub fn deinit(self: *Self, alloc: std.mem.Allocator) void {
            self.map_4.deinit(alloc);
            self.map_8.deinit(alloc);
            self.map_16.deinit(alloc);
            self.map_32.deinit(alloc);
            self.map_64.deinit(alloc);
            self.map_128.deinit(alloc);
            self.map_256.deinit(alloc);
            self.* = Self{};
        }

        pub fn getOrPut(self: *Self, comptime T: type, base_id: ID, val: T) *T {
            var hash = std.hash.Wyhash.init(base_id);
            hash.update(@typeName(T));
            const id = hash.final();

            return switch (nextPow2(u16, @sizeOf(T))) {
                1, 2, 4 => helper(&self.map_4, id, val),
                8 => helper(&self.map_8, id, val),
                16 => helper(&self.map_16, id, val),
                32 => helper(&self.map_32, id, val),
                64 => helper(&self.map_64, id, val),
                128 => helper(&self.map_128, id, val),
                256 => helper(&self.map_256, id, val),
                else => unreachable,
            };
        }

        fn nextPow2(comptime T: type, x: T) T {
            return 1 << @sizeOf(T) - @clz(x);
        }

        fn helper(map: anytype, id: ID, val: anytype) *@TypeOf(val) {
            const res = map.getOrPutAssumeCapacity(id);
            const value_ptr: *@TypeOf(val) = @ptrCast(@alignCast(res.value_ptr));
            if (!res.found_existing) {
                value_ptr.* = val;
            }
            return value_ptr;
        }
    };
}
