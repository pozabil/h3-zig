const std = @import("std");
const h3 = @import("h3");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

const CenterFixture = struct {
    name: []const u8,
    text: []const u8,
};

const center_fixtures = [_]CenterFixture{
    .{ .name = "bc05r08centers.txt", .text = @embedFile("fixtures/upstream/bc05r08centers.txt") },
    .{ .name = "bc05r09centers.txt", .text = @embedFile("fixtures/upstream/bc05r09centers.txt") },
    .{ .name = "bc14r08centers.txt", .text = @embedFile("fixtures/upstream/bc14r08centers.txt") },
    .{ .name = "bc19r08centers.txt", .text = @embedFile("fixtures/upstream/bc19r08centers.txt") },
    .{ .name = "rand05centers.txt", .text = @embedFile("fixtures/upstream/rand05centers.txt") },
    .{ .name = "rand06centers.txt", .text = @embedFile("fixtures/upstream/rand06centers.txt") },
    .{ .name = "rand07centers.txt", .text = @embedFile("fixtures/upstream/rand07centers.txt") },
    .{ .name = "rand08centers.txt", .text = @embedFile("fixtures/upstream/rand08centers.txt") },
    .{ .name = "rand09centers.txt", .text = @embedFile("fixtures/upstream/rand09centers.txt") },
    .{ .name = "rand10centers.txt", .text = @embedFile("fixtures/upstream/rand10centers.txt") },
    .{ .name = "rand11centers.txt", .text = @embedFile("fixtures/upstream/rand11centers.txt") },
    .{ .name = "rand12centers.txt", .text = @embedFile("fixtures/upstream/rand12centers.txt") },
    .{ .name = "rand13centers.txt", .text = @embedFile("fixtures/upstream/rand13centers.txt") },
    .{ .name = "rand14centers.txt", .text = @embedFile("fixtures/upstream/rand14centers.txt") },
    .{ .name = "rand15centers.txt", .text = @embedFile("fixtures/upstream/rand15centers.txt") },
};

const exact_center_fixtures = [_]CenterFixture{
    .{ .name = "res00ic.txt", .text = @embedFile("fixtures/upstream/res00ic.txt") },
    .{ .name = "res01ic.txt", .text = @embedFile("fixtures/upstream/res01ic.txt") },
    .{ .name = "res02ic.txt", .text = @embedFile("fixtures/upstream/res02ic.txt") },
    .{ .name = "res03ic.txt", .text = @embedFile("fixtures/upstream/res03ic.txt") },
};

const boundary_fixture = @embedFile("fixtures/upstream/rand05cells.txt");
const epsilon_degrees = 0.000001;
const epsilon_radians = epsilon_degrees * std.math.pi / 180.0;

test "upstream public center fixtures match latLngToCell" {
    var total: usize = 0;
    for (center_fixtures) |fixture| {
        total += try assertLatLngToCellFixture(fixture);
    }
    try expectEqual(@as(usize, 55_027), total);
}

test "upstream public exact center fixtures match cellToLatLng" {
    var total: usize = 0;
    for (exact_center_fixtures) |fixture| {
        total += try assertCellToLatLngFixture(fixture);
    }
    try expectEqual(@as(usize, 48_008), total);
}

test "upstream public boundary fixture sample matches cellToBoundary" {
    // Full rand05cells.txt is intentionally embedded for traceability, but a
    // bounded sample keeps local test runtime reasonable while exercising the
    // upstream parser shape and exact public boundary contract.
    try assertBoundaryFixtureSample(boundary_fixture, 200);
}

fn assertLatLngToCellFixture(fixture: CenterFixture) !usize {
    var lines = std.mem.splitScalar(u8, fixture.text, '\n');
    var count: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        var fields = std.mem.tokenizeAny(u8, trimmed, " \t");
        const cell_text = fields.next() orelse return error.BadFixture;
        const lat_text = fields.next() orelse return error.BadFixture;
        const lng_text = fields.next() orelse return error.BadFixture;
        if (fields.next() != null) return error.BadFixture;

        const expected = try std.fmt.parseInt(h3.H3Index, cell_text, 16);
        const lat_degrees = try std.fmt.parseFloat(f64, lat_text);
        const lng_degrees = try std.fmt.parseFloat(f64, lng_text);
        const expected_center = h3.latLngDegrees(lat_degrees, lng_degrees);
        const resolution = h3.getResolution(expected);

        try expectEqual(expected, try h3.latLngToCell(expected_center, resolution));
        count += 1;
    }

    return count;
}

fn assertCellToLatLngFixture(fixture: CenterFixture) !usize {
    var lines = std.mem.splitScalar(u8, fixture.text, '\n');
    var count: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        var fields = std.mem.tokenizeAny(u8, trimmed, " \t");
        const cell_text = fields.next() orelse return error.BadFixture;
        const lat_text = fields.next() orelse return error.BadFixture;
        const lng_text = fields.next() orelse return error.BadFixture;
        if (fields.next() != null) return error.BadFixture;

        const expected = try std.fmt.parseInt(h3.H3Index, cell_text, 16);
        const expected_center = h3.latLngDegrees(
            try std.fmt.parseFloat(f64, lat_text),
            try std.fmt.parseFloat(f64, lng_text),
        );
        const resolution = h3.getResolution(expected);

        const actual_center = try h3.cellToLatLng(expected);
        try expectApproxEqAbs(expected_center.lat, actual_center.lat, epsilon_radians);
        try expectApproxEqAbs(expected_center.lng, actual_center.lng, epsilon_radians);
        try expectEqual(expected, try h3.latLngToCell(actual_center, resolution));

        count += 1;
    }

    return count;
}

fn assertBoundaryFixtureSample(text: []const u8, max_cells: usize) !void {
    var lines = std.mem.splitScalar(u8, text, '\n');
    var count: usize = 0;

    while (count < max_cells) {
        const maybe_cell_line = nextNonEmptyLine(&lines) orelse break;
        const cell_text = std.mem.trim(u8, maybe_cell_line, " \t\r");
        const cell = try std.fmt.parseInt(h3.H3Index, cell_text, 16);

        const open_line = nextNonEmptyLine(&lines) orelse return error.BadFixture;
        if (!std.mem.eql(u8, std.mem.trim(u8, open_line, " \t\r"), "{")) return error.BadFixture;

        var expected: [h3.maxCellBoundaryVerts]h3.LatLng = undefined;
        var expected_count: usize = 0;

        while (true) {
            const vertex_line = nextNonEmptyLine(&lines) orelse return error.BadFixture;
            const trimmed = std.mem.trim(u8, vertex_line, " \t\r");
            if (std.mem.eql(u8, trimmed, "}")) break;
            if (expected_count == expected.len) return error.BadFixture;

            var fields = std.mem.tokenizeAny(u8, trimmed, " \t");
            const lat_text = fields.next() orelse return error.BadFixture;
            const lng_text = fields.next() orelse return error.BadFixture;
            if (fields.next() != null) return error.BadFixture;

            expected[expected_count] = h3.latLngDegrees(
                try std.fmt.parseFloat(f64, lat_text),
                try std.fmt.parseFloat(f64, lng_text),
            );
            expected_count += 1;
        }

        const actual = try h3.cellToBoundary(cell);
        const actual_vertices = h3.boundaryVertices(&actual);
        try expectEqual(expected_count, actual_vertices.len);
        for (actual_vertices, 0..) |vertex, index| {
            try expectApproxEqAbs(expected[index].lat, vertex.lat, epsilon_radians);
            try expectApproxEqAbs(expected[index].lng, vertex.lng, epsilon_radians);
        }

        count += 1;
    }

    try expectEqual(max_cells, count);
}

fn nextNonEmptyLine(lines: *std.mem.SplitIterator(u8, .scalar)) ?[]const u8 {
    while (lines.next()) |line| {
        if (std.mem.trim(u8, line, " \t\r").len != 0) return line;
    }
    return null;
}
