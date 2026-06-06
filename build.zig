const std = @import("std");

const h3_c_sources = [_][]const u8{
    "src/h3lib/lib/h3Assert.c",
    "src/h3lib/lib/algos.c",
    "src/h3lib/lib/bbox.c",
    "src/h3lib/lib/polygon.c",
    "src/h3lib/lib/polyfill.c",
    "src/h3lib/lib/h3Index.c",
    "src/h3lib/lib/vec2d.c",
    "src/h3lib/lib/vertex.c",
    "src/h3lib/lib/linkedGeo.c",
    "src/h3lib/lib/localij.c",
    "src/h3lib/lib/latLng.c",
    "src/h3lib/lib/directedEdge.c",
    "src/h3lib/lib/mathExtensions.c",
    "src/h3lib/lib/iterators.c",
    "src/h3lib/lib/faceijk.c",
    "src/h3lib/lib/baseCells.c",
    "src/h3lib/lib/area.c",
    "src/h3lib/lib/cellsToMultiPoly.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const h3 = b.addModule("h3", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    addH3C(b, h3, target);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "h3-zig",
        .root_module = h3,
    });
    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_module = h3,
    });

    const contract_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/h3_contract_tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "h3", .module = h3 },
            },
        }),
    });

    const test_step = b.step("test", "Run unit and public-contract tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
    test_step.dependOn(&b.addRunArtifact(contract_tests).step);
}

fn addH3C(b: *std.Build, module: *std.Build.Module, target: std.Build.ResolvedTarget) void {
    module.addIncludePath(b.path("vendor/h3/src/h3lib/include"));
    module.addCSourceFiles(.{
        .root = b.path("vendor/h3"),
        .files = &h3_c_sources,
        .flags = &.{
            "-std=c99",
            "-DBUILDING_H3=1",
        },
    });

    if (target.result.os.tag != .windows) {
        module.linkSystemLibrary("m", .{});
    }
}
