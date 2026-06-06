const std = @import("std");
const h3 = @import("h3");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;
const expectEqualStrings = std.testing.expectEqualStrings;
const allocator = std.testing.allocator;

test "latLngToCell, string conversion, center, and boundary match upstream examples" {
    const statue = h3.latLngDegrees(40.689167, -74.044444);
    const cell = try h3.latLngToCell(statue, 10);
    try expectEqual(@as(h3.H3Index, 0x8a2a1072b59ffff), cell);
    try expect(h3.isValidCell(cell));
    try expect(h3.isValidIndex(cell));
    try expectEqual(@as(c_int, 10), h3.getResolution(cell));

    var buffer: [h3.h3StringBufferLength]u8 = undefined;
    const str = try h3.h3ToString(cell, &buffer);
    try expectEqualStrings("8a2a1072b59ffff", str);
    try expectEqual(cell, try h3.stringToH3("8a2a1072b59ffff"));

    const center = try h3.cellToLatLng(cell);
    try expectApproxEqAbs(@as(f64, 40.6894218437), h3.radsToDegs(center.lat), 0.000000001);
    try expectApproxEqAbs(@as(f64, -74.0444313999), h3.radsToDegs(center.lng), 0.000000001);

    const boundary = try h3.cellToBoundary(cell);
    try expectEqual(@as(c_int, 6), boundary.numVerts);
    try expectEqual(@as(usize, 6), h3.boundaryVertices(&boundary).len);
}

test "latLngToCell rejects invalid resolutions and coordinates like upstream testH3Api" {
    const anywhere = h3.latLngRadians(0, 0);
    try std.testing.expectError(error.ResolutionDomain, h3.latLngToCell(anywhere, -1));
    try std.testing.expectError(error.ResolutionDomain, h3.latLngToCell(anywhere, 16));
    try std.testing.expectError(error.LatLngDomain, h3.latLngToCell(h3.latLngRadians(std.math.nan(f64), 0), 1));
    try std.testing.expectError(error.LatLngDomain, h3.latLngToCell(h3.latLngRadians(0, std.math.nan(f64)), 1));
    try std.testing.expectError(error.LatLngDomain, h3.latLngToCell(h3.latLngRadians(std.math.inf(f64), -std.math.inf(f64)), 1));
}

test "latLngToCell matches upstream rand05 center fixture sample" {
    const fixtures = [_]struct {
        cell: [:0]const u8,
        lat_degrees: f64,
        lng_degrees: f64,
    }{
        .{ .cell = "850dab63fffffff", .lat_degrees = 67.194014, .lng_degrees = 191.598258 },
        .{ .cell = "850336b7fffffff", .lat_degrees = 87.372197, .lng_degrees = 166.176925 },
        .{ .cell = "85440d83fffffff", .lat_degrees = 27.350796, .lng_degrees = 272.064443 },
        .{ .cell = "85f2316bfffffff", .lat_degrees = -79.704099, .lng_degrees = 209.043753 },
        .{ .cell = "8503053bfffffff", .lat_degrees = 87.178177, .lng_degrees = 270.372677 },
        .{ .cell = "85d70b6bfffffff", .lat_degrees = -52.743559, .lng_degrees = 34.199852 },
        .{ .cell = "850ee59bfffffff", .lat_degrees = 55.810429, .lng_degrees = 282.843962 },
        .{ .cell = "85eb885bfffffff", .lat_degrees = -60.693672, .lng_degrees = 187.742078 },
        .{ .cell = "85026c63fffffff", .lat_degrees = 74.269230, .lng_degrees = 290.224650 },
        .{ .cell = "857a9983fffffff", .lat_degrees = 8.317316, .lng_degrees = 47.328903 },
        .{ .cell = "85a49973fffffff", .lat_degrees = -27.648726, .lng_degrees = 324.695477 },
        .{ .cell = "850025cbfffffff", .lat_degrees = 76.626635, .lng_degrees = 26.855924 },
        .{ .cell = "85aef0d3fffffff", .lat_degrees = -30.181101, .lng_degrees = 97.598398 },
        .{ .cell = "8514d353fffffff", .lat_degrees = 48.481818, .lng_degrees = 137.624788 },
        .{ .cell = "857ad90bfffffff", .lat_degrees = 9.391036, .lng_degrees = 40.202655 },
        .{ .cell = "852eb6dbfffffff", .lat_degrees = 46.873620, .lng_degrees = 153.170110 },
        .{ .cell = "8545583bfffffff", .lat_degrees = 25.900462, .lng_degrees = 268.491633 },
        .{ .cell = "850a5a13fffffff", .lat_degrees = 69.673523, .lng_degrees = 106.502495 },
        .{ .cell = "857c11a3fffffff", .lat_degrees = 0.278038, .lng_degrees = 339.938836 },
        .{ .cell = "850db26bfffffff", .lat_degrees = 67.773124, .lng_degrees = 174.912440 },
    };

    for (fixtures) |fixture| {
        const expected = try h3.stringToH3(fixture.cell);
        const actual = try h3.latLngToCell(h3.latLngDegrees(fixture.lat_degrees, fixture.lng_degrees), h3.getResolution(expected));
        try expectEqual(expected, actual);
    }
}

test "cellToBoundary edge cases match upstream fixed public fixtures" {
    const issue_45 = try h3.stringToH3("894cc536537ffff");
    const boundary = try h3.cellToBoundary(issue_45);
    try expectEqual(@as(c_int, 7), boundary.numVerts);

    const expected = [_]h3.LatLng{
        h3.latLngDegrees(18.043333154, -66.27836523500002),
        h3.latLngDegrees(18.042238363, -66.27929062800001),
        h3.latLngDegrees(18.040818259, -66.27854193899998),
        h3.latLngDegrees(18.040492975, -66.27686786700002),
        h3.latLngDegrees(18.041040385, -66.27640518300001),
        h3.latLngDegrees(18.041757122, -66.27596711500001),
        h3.latLngDegrees(18.043007860, -66.27669118199998),
    };
    for (h3.boundaryVertices(&boundary), 0..) |vertex, i| {
        try expectApproxEqAbs(expected[i].lat, vertex.lat, 0.000000001);
        try expectApproxEqAbs(expected[i].lng, vertex.lng, 0.000000001);
    }

    const constrained = try h3.cellToBoundary(0x87dc6d364ffffff);
    try expectEqual(@as(c_int, 6), constrained.numVerts);
}

test "grid disk, ring, distance, and path preserve public traversal contracts" {
    const sf = try h3.latLngToCell(h3.latLngRadians(0.659966917655, 2 * std.math.pi - 2.1364398519396), 0);
    var cells: [7]h3.H3Index = undefined;
    var distances: [7]c_int = undefined;
    try h3.gridDiskDistances(sf, 1, &cells, &distances);
    const allocated = try h3.gridDiskDistancesAlloc(allocator, sf, 1);
    defer allocated.deinit(allocator);
    try expectEqual(cells.len, allocated.cells.len);
    try expectEqual(distances.len, allocated.distances.len);

    const expected = [_]h3.H3Index{
        0x8029fffffffffff,
        0x801dfffffffffff,
        0x8013fffffffffff,
        0x8027fffffffffff,
        0x8049fffffffffff,
        0x8051fffffffffff,
        0x8037fffffffffff,
    };
    for (cells, distances) |cell, distance| {
        try expect(contains(h3.H3Index, &expected, cell));
        try expectEqual(@as(c_int, if (cell == sf) 0 else 1), distance);
    }

    const ring = try h3.gridRingAlloc(allocator, sf, 1);
    defer allocator.free(ring);
    try expectEqual(@as(usize, 6), ring.len);

    const neighbor = ring[0];
    try expect(try h3.areNeighborCells(sf, neighbor));
    try expectEqual(@as(i64, 1), try h3.gridDistance(sf, neighbor));

    const path = try h3.gridPathCellsAlloc(allocator, sf, neighbor);
    defer allocator.free(path);
    try expectEqual(@as(usize, 2), path.len);
    try expectEqual(sf, path[0]);
    try expectEqual(neighbor, path[1]);
}

test "pentagon grid disk preserves upstream deleted-neighbor behavior" {
    const polar = try h3.constructCell(0, 4, &.{});
    var cells: [7]h3.H3Index = undefined;
    var distances: [7]c_int = undefined;
    try h3.gridDiskDistances(polar, 1, &cells, &distances);
    try expectEqual(@as(usize, 6), h3.countNonNull(&cells));
    try expect(h3.isPentagon(polar));
}

test "hierarchy, child positions, compaction, and uncompact roundtrip" {
    const parent = try h3.stringToH3("89283470c27ffff");
    const child_size = try h3.cellToChildrenSize(parent, 10);
    try expect(child_size > 0);

    const children = try h3.cellToChildrenAlloc(allocator, parent, 10);
    defer allocator.free(children);
    try expectEqual(@as(usize, @intCast(child_size)), children.len);

    const center_child = try h3.cellToCenterChild(parent, 10);
    try expect(contains(h3.H3Index, children, center_child));
    try expectEqual(parent, try h3.cellToParent(center_child, 9));

    const pos = try h3.cellToChildPos(center_child, 9);
    try expectEqual(center_child, try h3.childPosToCell(pos, parent, 10));

    const disk = try h3.gridDiskAlloc(allocator, parent, 2);
    defer allocator.free(disk);
    const compacted = try h3.compactCellsAlloc(allocator, disk);
    defer allocator.free(compacted);
    const uncompacted = try h3.uncompactCellsAlloc(allocator, compacted, 9);
    defer allocator.free(uncompacted);
    try expectEqual(h3.countNonNull(disk), h3.countNonNull(uncompacted));
}

test "resolution, base cells, pentagons, digits, faces, and metrics are available" {
    try expectEqual(@as(i64, 122), try h3.getNumCells(0));
    try expectEqual(@as(c_int, 122), h3.res0CellCount());
    try expectEqual(@as(c_int, 12), h3.pentagonCount());

    const res0 = try h3.getRes0CellsAlloc(allocator);
    defer allocator.free(res0);
    try expectEqual(@as(usize, 122), res0.len);
    try expectEqual(@as(h3.H3Index, 0x8001fffffffffff), res0[0]);

    const pentagons = try h3.getPentagonsAlloc(allocator, 1);
    defer allocator.free(pentagons);
    try expectEqual(@as(usize, 12), pentagons.len);
    try expect(h3.isPentagon(pentagons[0]));

    const cell = try h3.stringToH3("8a2a1072b59ffff");
    try expectEqual(@as(c_int, 10), h3.getResolution(cell));
    try expect(h3.getBaseCellNumber(cell) >= 0);
    _ = try h3.getIndexDigit(cell, 1);

    const faces = try h3.getIcosahedronFacesAlloc(allocator, cell);
    defer allocator.free(faces);
    try expect(faces.len >= 1);

    try expect((try h3.getHexagonAreaAvgKm2(5)) > 0);
    try expect((try h3.getHexagonAreaAvgM2(5)) > 0);
    try expect((try h3.cellAreaRads2(cell)) > 0);
    try expect((try h3.cellAreaKm2(cell)) > 0);
    try expect((try h3.cellAreaM2(cell)) > 0);
    try expect((try h3.getHexagonEdgeLengthAvgKm(5)) > 0);
    try expect((try h3.getHexagonEdgeLengthAvgM(5)) > 0);
}

test "public error contracts are preserved for buffer, resolution, digit, and edge inputs" {
    const cell = try h3.stringToH3("8a2a1072b59ffff");
    var short_buffer: [2]u8 = undefined;
    try std.testing.expectError(error.MemoryBounds, h3.h3ToString(cell, &short_buffer));
    try std.testing.expectError(error.ResolutionDomain, h3.getNumCells(16));
    try std.testing.expectError(error.ResolutionDomain, h3.constructCell(16, 0, &.{}));
    try std.testing.expectError(error.BaseCellDomain, h3.constructCell(1, 122, &.{0}));
    try std.testing.expectError(error.DigitDomain, h3.constructCell(1, 0, &.{7}));
    try std.testing.expectError(error.DeletedDigit, h3.constructCell(1, 4, &.{1}));
    try std.testing.expectError(error.DirectedEdgeInvalid, h3.getDirectedEdgeOrigin(cell));
}

test "directed edge public contract and reverse behavior" {
    const origin = try h3.latLngToCell(h3.latLngRadians(0.659966917655, -2.1364398519396), 9);
    const ring = try h3.gridRingAlloc(allocator, origin, 1);
    defer allocator.free(ring);
    const destination = ring[0];

    const edge = try h3.cellsToDirectedEdge(origin, destination);
    try expect(h3.isValidDirectedEdge(edge));
    try expectEqual(origin, try h3.getDirectedEdgeOrigin(edge));
    try expectEqual(destination, try h3.getDirectedEdgeDestination(edge));

    const pair = try h3.directedEdgeToCells(edge);
    try expectEqual(origin, pair[0]);
    try expectEqual(destination, pair[1]);

    const edges = try h3.originToDirectedEdges(origin);
    try expect(contains(h3.H3Index, &edges, edge));

    const boundary = try h3.directedEdgeToBoundary(edge);
    try expect(boundary.numVerts >= 2);

    const reversed = try h3.reverseDirectedEdge(edge);
    try expectEqual(destination, try h3.getDirectedEdgeOrigin(reversed));
    try expectEqual(origin, try h3.getDirectedEdgeDestination(reversed));
    try expect((try h3.edgeLengthRads(edge)) > 0);
    try expect((try h3.edgeLengthKm(edge)) > 0);
    try expect((try h3.edgeLengthM(edge)) > 0);

    try std.testing.expectError(error.NotNeighbors, h3.cellsToDirectedEdge(origin, origin));
}

test "vertex APIs expose canonical vertexes and coordinates" {
    const origin: h3.H3Index = 0x823d6ffffffffff;
    const vertex = try h3.cellToVertex(origin, 0);
    try expect(h3.isValidVertex(vertex));
    const point = try h3.vertexToLatLng(vertex);
    try expect(std.math.isFinite(point.lat));
    try expect(std.math.isFinite(point.lng));

    const vertexes = try h3.cellToVertexes(origin);
    try expectEqual(@as(usize, 6), vertexes.len);
    try expect(contains(h3.H3Index, &vertexes, vertex));
    try std.testing.expectError(error.Domain, h3.cellToVertex(origin, 6));
}

test "polygonToCells and experimental containment modes match upstream CLI fixture" {
    var verts = [_]h3.LatLng{
        h3.latLngDegrees(37.813318999983238, -122.4089866999972145),
        h3.latLngDegrees(37.7198061999978478, -122.3544736999993603),
        h3.latLngDegrees(37.8151571999998453, -122.4798767000009008),
    };
    const loop = h3.GeoLoop{ .numVerts = verts.len, .verts = verts[0..].ptr };
    var polygon = h3.GeoPolygon{
        .geoloop = loop,
        .numHoles = 0,
        .holes = null,
    };

    const cells = try h3.polygonToCellsAlloc(allocator, &polygon, 7, 0);
    defer allocator.free(cells);
    const expected = [_]h3.H3Index{
        0x87283082bffffff,
        0x872830870ffffff,
        0x872830820ffffff,
        0x87283082effffff,
        0x872830828ffffff,
        0x87283082affffff,
        0x872830876ffffff,
    };
    for (expected) |cell| {
        try expect(contains(h3.H3Index, cells, cell));
    }
    try expectEqual(@as(usize, expected.len), h3.countNonNull(cells));

    const experimental = try h3.polygonToCellsExperimentalAlloc(allocator, &polygon, 7, h3.c.CONTAINMENT_CENTER);
    defer allocator.free(experimental);
    try expectEqual(h3.countNonNull(cells), h3.countNonNull(experimental));
}

test "cellsToLinkedMultiPolygon produces destroyable linked output" {
    const origin = try h3.stringToH3("8928308280fffff");
    const disk = try h3.gridDiskAlloc(allocator, origin, 1);
    defer allocator.free(disk);

    var linked = try h3.cellsToLinkedMultiPolygon(disk);
    defer h3.destroyLinkedMultiPolygon(&linked);
    try expect(linked.first != null);
}

test "great circle distance, local IJ, and raw namespace are usable" {
    const a = h3.latLngDegrees(40.689167, -74.044444);
    const b = h3.latLngDegrees(40.689167, -74.044444);
    try expectApproxEqAbs(@as(f64, 0), h3.greatCircleDistanceRads(a, b), 0.000000001);
    try expectApproxEqAbs(@as(f64, 0), h3.greatCircleDistanceKm(a, b), 0.000000001);
    try expectApproxEqAbs(@as(f64, 0), h3.greatCircleDistanceM(a, b), 0.000000001);
    try expectApproxEqAbs(@as(f64, 180), h3.radsToDegs(std.math.pi), 0.000000001);

    const origin = try h3.latLngToCell(h3.latLngRadians(0.659966917655, -2.1364398519396), 9);
    const ring = try h3.gridRingAlloc(allocator, origin, 1);
    defer allocator.free(ring);
    const ij = try h3.cellToLocalIj(origin, ring[0], 0);
    try expectEqual(ring[0], try h3.localIjToCell(origin, ij, 0));

    var raw_out: h3.H3Index = 0;
    try expectEqual(@as(h3.H3Error, h3.c.E_SUCCESS), h3.raw.latLngToCell(&a, 10, &raw_out));
}

test "great circle distance matches upstream CLI fixture" {
    const a = h3.latLngDegrees(0, 1);
    const b = h3.latLngDegrees(1, 2);
    try expectApproxEqAbs(@as(f64, 157.2495585118), h3.greatCircleDistanceKm(a, b), 0.0000000001);
}

fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (item == needle) return true;
    }
    return false;
}
