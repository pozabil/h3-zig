const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const h3 = b.dependency("h3", .{
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "h3", .module = h3.module("h3") },
            },
        }),
    });

    const test_step = b.step("test", "Run consumer integration tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
