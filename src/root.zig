const std = @import("std");

pub const c = @import("h3_c");
pub const raw = c;

pub const H3Index = c.H3Index;
pub const H3Error = c.H3Error;
pub const H3ErrorCodes = c.H3ErrorCodes;
pub const LatLng = c.LatLng;
pub const CellBoundary = c.CellBoundary;
pub const GeoLoop = c.GeoLoop;
pub const GeoPolygon = c.GeoPolygon;
pub const GeoMultiPolygon = c.GeoMultiPolygon;
pub const ContainmentMode = c.ContainmentMode;
pub const LinkedLatLng = c.LinkedLatLng;
pub const LinkedGeoLoop = c.LinkedGeoLoop;
pub const LinkedGeoPolygon = c.LinkedGeoPolygon;
pub const CoordIJ = c.CoordIJ;

pub const h3Null: H3Index = c.H3_NULL;
pub const maxResolution: c_int = 15;
pub const maxCellBoundaryVerts: usize = c.MAX_CELL_BNDRY_VERTS;
pub const h3StringBufferLength: usize = 17;
pub const directedEdgeCount: usize = 6;
pub const directedEdgeCellCount: usize = 2;
pub const vertexCount: usize = 6;

pub const GridDiskDistances = struct {
    cells: []H3Index,
    distances: []c_int,

    pub fn deinit(self: GridDiskDistances, allocator: std.mem.Allocator) void {
        allocator.free(self.cells);
        allocator.free(self.distances);
    }
};

pub const Error = error{
    Failed,
    Domain,
    LatLngDomain,
    ResolutionDomain,
    CellInvalid,
    DirectedEdgeInvalid,
    UndirectedEdgeInvalid,
    VertexInvalid,
    Pentagon,
    DuplicateInput,
    NotNeighbors,
    ResolutionMismatch,
    MemoryAllocation,
    MemoryBounds,
    OptionInvalid,
    IndexInvalid,
    BaseCellDomain,
    DigitDomain,
    DeletedDigit,
    Unknown,
};

pub fn errorFromCode(code: H3Error) ?Error {
    return switch (code) {
        c.E_SUCCESS => null,
        c.E_FAILED => error.Failed,
        c.E_DOMAIN => error.Domain,
        c.E_LATLNG_DOMAIN => error.LatLngDomain,
        c.E_RES_DOMAIN => error.ResolutionDomain,
        c.E_CELL_INVALID => error.CellInvalid,
        c.E_DIR_EDGE_INVALID => error.DirectedEdgeInvalid,
        c.E_UNDIR_EDGE_INVALID => error.UndirectedEdgeInvalid,
        c.E_VERTEX_INVALID => error.VertexInvalid,
        c.E_PENTAGON => error.Pentagon,
        c.E_DUPLICATE_INPUT => error.DuplicateInput,
        c.E_NOT_NEIGHBORS => error.NotNeighbors,
        c.E_RES_MISMATCH => error.ResolutionMismatch,
        c.E_MEMORY_ALLOC => error.MemoryAllocation,
        c.E_MEMORY_BOUNDS => error.MemoryBounds,
        c.E_OPTION_INVALID => error.OptionInvalid,
        c.E_INDEX_INVALID => error.IndexInvalid,
        c.E_BASE_CELL_DOMAIN => error.BaseCellDomain,
        c.E_DIGIT_DOMAIN => error.DigitDomain,
        c.E_DELETED_DIGIT => error.DeletedDigit,
        else => error.Unknown,
    };
}

pub fn errorToCode(err: Error) H3Error {
    return switch (err) {
        error.Failed => c.E_FAILED,
        error.Domain => c.E_DOMAIN,
        error.LatLngDomain => c.E_LATLNG_DOMAIN,
        error.ResolutionDomain => c.E_RES_DOMAIN,
        error.CellInvalid => c.E_CELL_INVALID,
        error.DirectedEdgeInvalid => c.E_DIR_EDGE_INVALID,
        error.UndirectedEdgeInvalid => c.E_UNDIR_EDGE_INVALID,
        error.VertexInvalid => c.E_VERTEX_INVALID,
        error.Pentagon => c.E_PENTAGON,
        error.DuplicateInput => c.E_DUPLICATE_INPUT,
        error.NotNeighbors => c.E_NOT_NEIGHBORS,
        error.ResolutionMismatch => c.E_RES_MISMATCH,
        error.MemoryAllocation => c.E_MEMORY_ALLOC,
        error.MemoryBounds => c.E_MEMORY_BOUNDS,
        error.OptionInvalid => c.E_OPTION_INVALID,
        error.IndexInvalid => c.E_INDEX_INVALID,
        error.BaseCellDomain => c.E_BASE_CELL_DOMAIN,
        error.DigitDomain => c.E_DIGIT_DOMAIN,
        error.DeletedDigit => c.E_DELETED_DIGIT,
        error.Unknown => c.E_FAILED,
    };
}

pub fn check(code: H3Error) Error!void {
    if (errorFromCode(code)) |err| return err;
}

pub fn describeErrorCode(code: H3Error) []const u8 {
    return describeH3Error(code);
}

pub fn describeH3Error(code: H3Error) []const u8 {
    return std.mem.span(c.describeH3Error(code));
}

pub fn describeError(err: Error) []const u8 {
    return describeErrorCode(errorToCode(err));
}

pub fn latLngRadians(lat: f64, lng: f64) LatLng {
    return .{ .lat = lat, .lng = lng };
}

pub fn latLngDegrees(lat: f64, lng: f64) LatLng {
    return .{ .lat = degsToRads(lat), .lng = degsToRads(lng) };
}

pub fn boundaryVertices(boundary: *const CellBoundary) []const LatLng {
    std.debug.assert(boundary.numVerts >= 0);
    std.debug.assert(boundary.numVerts <= c.MAX_CELL_BNDRY_VERTS);
    return boundary.verts[0..@as(usize, @intCast(boundary.numVerts))];
}

pub fn latLngToCell(g: LatLng, res: c_int) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.latLngToCell(&g, res, &out));
    return out;
}

pub fn cellToLatLng(h3: H3Index) Error!LatLng {
    var out: LatLng = undefined;
    try check(c.cellToLatLng(h3, &out));
    return out;
}

pub fn cellToBoundary(h3: H3Index) Error!CellBoundary {
    var out: CellBoundary = undefined;
    try check(c.cellToBoundary(h3, &out));
    return out;
}

pub fn maxGridDiskSize(k: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.maxGridDiskSize(k, &out));
    return out;
}

pub fn gridDiskUnsafe(origin: H3Index, k: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try maxGridDiskSize(k)));
    @memset(out, h3Null);
    try check(c.gridDiskUnsafe(origin, k, out.ptr));
}

pub fn gridDiskUnsafeAlloc(allocator: std.mem.Allocator, origin: H3Index, k: c_int) Error![]H3Index {
    const out = try allocIndexes(allocator, try maxGridDiskSize(k));
    errdefer allocator.free(out);
    try gridDiskUnsafe(origin, k, out);
    return out;
}

pub fn gridDiskDistancesUnsafe(origin: H3Index, k: c_int, out: []H3Index, distances: []c_int) Error!void {
    const required = try countToUsize(try maxGridDiskSize(k));
    try ensureLen(out.len, required);
    try ensureLen(distances.len, required);
    @memset(out, h3Null);
    @memset(distances, 0);
    try check(c.gridDiskDistancesUnsafe(origin, k, out.ptr, distances.ptr));
}

pub fn gridDiskDistancesSafe(origin: H3Index, k: c_int, out: []H3Index, distances: []c_int) Error!void {
    const required = try countToUsize(try maxGridDiskSize(k));
    try ensureLen(out.len, required);
    try ensureLen(distances.len, required);
    @memset(out, h3Null);
    @memset(distances, 0);
    try check(c.gridDiskDistancesSafe(origin, k, out.ptr, distances.ptr));
}

pub fn gridDisksUnsafe(h3_set: []const H3Index, k: c_int, out: []H3Index) Error!void {
    const disk_size = try countToUsize(try maxGridDiskSize(k));
    try ensureLen(out.len, try checkedMulUsize(h3_set.len, disk_size));
    @memset(out, h3Null);
    try check(c.gridDisksUnsafe(h3_set.ptr, try usizeToCInt(h3_set.len), k, out.ptr));
}

pub fn gridDisk(origin: H3Index, k: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try maxGridDiskSize(k)));
    @memset(out, h3Null);
    try check(c.gridDisk(origin, k, out.ptr));
}

pub fn gridDiskAlloc(allocator: std.mem.Allocator, origin: H3Index, k: c_int) Error![]H3Index {
    const out = try allocIndexes(allocator, try maxGridDiskSize(k));
    errdefer allocator.free(out);
    try gridDisk(origin, k, out);
    return out;
}

pub fn gridDiskDistances(origin: H3Index, k: c_int, out: []H3Index, distances: []c_int) Error!void {
    const required = try countToUsize(try maxGridDiskSize(k));
    try ensureLen(out.len, required);
    try ensureLen(distances.len, required);
    @memset(out, h3Null);
    @memset(distances, 0);
    try check(c.gridDiskDistances(origin, k, out.ptr, distances.ptr));
}

pub fn gridDiskDistancesAlloc(allocator: std.mem.Allocator, origin: H3Index, k: c_int) Error!GridDiskDistances {
    const size = try countToUsize(try maxGridDiskSize(k));
    const cells = allocator.alloc(H3Index, size) catch return error.MemoryAllocation;
    errdefer allocator.free(cells);
    const distances = allocator.alloc(c_int, size) catch return error.MemoryAllocation;
    errdefer allocator.free(distances);
    try gridDiskDistances(origin, k, cells, distances);
    return .{ .cells = cells, .distances = distances };
}

pub fn maxGridRingSize(k: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.maxGridRingSize(k, &out));
    return out;
}

pub fn gridRingUnsafe(origin: H3Index, k: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try maxGridRingSize(k)));
    @memset(out, h3Null);
    try check(c.gridRingUnsafe(origin, k, out.ptr));
}

pub fn gridRing(origin: H3Index, k: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try maxGridRingSize(k)));
    @memset(out, h3Null);
    try check(c.gridRing(origin, k, out.ptr));
}

pub fn gridRingAlloc(allocator: std.mem.Allocator, origin: H3Index, k: c_int) Error![]H3Index {
    const out = try allocIndexes(allocator, try maxGridRingSize(k));
    errdefer allocator.free(out);
    try gridRing(origin, k, out);
    return out;
}

pub fn maxPolygonToCellsSize(geo_polygon: *const GeoPolygon, res: c_int, flags: u32) Error!i64 {
    var out: i64 = 0;
    try check(c.maxPolygonToCellsSize(geo_polygon, res, flags, &out));
    return out;
}

pub fn polygonToCells(geo_polygon: *const GeoPolygon, res: c_int, flags: u32, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try maxPolygonToCellsSize(geo_polygon, res, flags)));
    @memset(out, h3Null);
    try check(c.polygonToCells(geo_polygon, res, flags, out.ptr));
}

pub fn polygonToCellsAlloc(allocator: std.mem.Allocator, geo_polygon: *const GeoPolygon, res: c_int, flags: u32) Error![]H3Index {
    const out = try allocIndexes(allocator, try maxPolygonToCellsSize(geo_polygon, res, flags));
    errdefer allocator.free(out);
    try polygonToCells(geo_polygon, res, flags, out);
    return out;
}

pub fn maxPolygonToCellsSizeExperimental(geo_polygon: *const GeoPolygon, res: c_int, flags: u32) Error!i64 {
    var out: i64 = 0;
    try check(c.maxPolygonToCellsSizeExperimental(geo_polygon, res, flags, &out));
    return out;
}

pub fn polygonToCellsExperimental(geo_polygon: *const GeoPolygon, res: c_int, flags: u32, out: []H3Index) Error!void {
    @memset(out, h3Null);
    try check(c.polygonToCellsExperimental(geo_polygon, res, flags, try usizeToI64(out.len), out.ptr));
}

pub fn polygonToCellsExperimentalAlloc(allocator: std.mem.Allocator, geo_polygon: *const GeoPolygon, res: c_int, flags: u32) Error![]H3Index {
    const out = try allocIndexes(allocator, try maxPolygonToCellsSizeExperimental(geo_polygon, res, flags));
    errdefer allocator.free(out);
    try polygonToCellsExperimental(geo_polygon, res, flags, out);
    return out;
}

pub fn cellsToLinkedMultiPolygon(h3_set: []const H3Index) Error!LinkedGeoPolygon {
    var out: LinkedGeoPolygon = std.mem.zeroes(LinkedGeoPolygon);
    try check(c.cellsToLinkedMultiPolygon(h3_set.ptr, try usizeToCInt(h3_set.len), &out));
    return out;
}

pub fn destroyLinkedMultiPolygon(polygon: *LinkedGeoPolygon) void {
    c.destroyLinkedMultiPolygon(polygon);
}

pub fn degsToRads(degrees: f64) f64 {
    return c.degsToRads(degrees);
}

pub fn radsToDegs(radians: f64) f64 {
    return c.radsToDegs(radians);
}

pub fn greatCircleDistanceRads(a: LatLng, b: LatLng) f64 {
    return c.greatCircleDistanceRads(&a, &b);
}

pub fn greatCircleDistanceKm(a: LatLng, b: LatLng) f64 {
    return c.greatCircleDistanceKm(&a, &b);
}

pub fn greatCircleDistanceM(a: LatLng, b: LatLng) f64 {
    return c.greatCircleDistanceM(&a, &b);
}

pub fn getHexagonAreaAvgKm2(res: c_int) Error!f64 {
    var out: f64 = 0;
    try check(c.getHexagonAreaAvgKm2(res, &out));
    return out;
}

pub fn getHexagonAreaAvgM2(res: c_int) Error!f64 {
    var out: f64 = 0;
    try check(c.getHexagonAreaAvgM2(res, &out));
    return out;
}

pub fn cellAreaRads2(h: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.cellAreaRads2(h, &out));
    return out;
}

pub fn cellAreaKm2(h: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.cellAreaKm2(h, &out));
    return out;
}

pub fn cellAreaM2(h: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.cellAreaM2(h, &out));
    return out;
}

pub fn getHexagonEdgeLengthAvgKm(res: c_int) Error!f64 {
    var out: f64 = 0;
    try check(c.getHexagonEdgeLengthAvgKm(res, &out));
    return out;
}

pub fn getHexagonEdgeLengthAvgM(res: c_int) Error!f64 {
    var out: f64 = 0;
    try check(c.getHexagonEdgeLengthAvgM(res, &out));
    return out;
}

pub fn edgeLengthRads(edge: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.edgeLengthRads(edge, &out));
    return out;
}

pub fn edgeLengthKm(edge: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.edgeLengthKm(edge, &out));
    return out;
}

pub fn edgeLengthM(edge: H3Index) Error!f64 {
    var out: f64 = 0;
    try check(c.edgeLengthM(edge, &out));
    return out;
}

pub fn getNumCells(res: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.getNumCells(res, &out));
    return out;
}

pub fn res0CellCount() c_int {
    return c.res0CellCount();
}

pub fn getRes0Cells(out: []H3Index) Error!void {
    try ensureLen(out.len, @as(usize, @intCast(res0CellCount())));
    @memset(out, h3Null);
    try check(c.getRes0Cells(out.ptr));
}

pub fn getRes0CellsAlloc(allocator: std.mem.Allocator) Error![]H3Index {
    const out = allocator.alloc(H3Index, @intCast(res0CellCount())) catch return error.MemoryAllocation;
    errdefer allocator.free(out);
    try getRes0Cells(out);
    return out;
}

pub fn pentagonCount() c_int {
    return c.pentagonCount();
}

pub fn getPentagons(res: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, @as(usize, @intCast(pentagonCount())));
    @memset(out, h3Null);
    try check(c.getPentagons(res, out.ptr));
}

pub fn getPentagonsAlloc(allocator: std.mem.Allocator, res: c_int) Error![]H3Index {
    const out = allocator.alloc(H3Index, @intCast(pentagonCount())) catch return error.MemoryAllocation;
    errdefer allocator.free(out);
    try getPentagons(res, out);
    return out;
}

pub fn getResolution(h: H3Index) c_int {
    return c.getResolution(h);
}

pub fn getBaseCellNumber(h: H3Index) c_int {
    return c.getBaseCellNumber(h);
}

pub fn getIndexDigit(h: H3Index, res: c_int) Error!c_int {
    var out: c_int = 0;
    try check(c.getIndexDigit(h, res, &out));
    return out;
}

pub fn constructCell(res: c_int, base_cell_number: c_int, digits: []const c_int) Error!H3Index {
    if (res < 0 or res > maxResolution) return error.ResolutionDomain;
    try ensureLen(digits.len, @as(usize, @intCast(res)));
    var out: H3Index = h3Null;
    try check(c.constructCell(res, base_cell_number, digits.ptr, &out));
    return out;
}

pub fn stringToH3(str: [:0]const u8) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.stringToH3(str.ptr, &out));
    return out;
}

pub fn h3ToString(h: H3Index, buffer: []u8) Error![]const u8 {
    try ensureLen(buffer.len, h3StringBufferLength);
    try check(c.h3ToString(h, buffer.ptr, buffer.len));
    const end = std.mem.indexOfScalar(u8, buffer[0..h3StringBufferLength], 0) orelse return error.Failed;
    return buffer[0..end];
}

pub fn h3ToStringAlloc(allocator: std.mem.Allocator, h: H3Index) Error![]u8 {
    var buffer: [h3StringBufferLength]u8 = undefined;
    const str = try h3ToString(h, &buffer);
    return allocator.dupe(u8, str) catch return error.MemoryAllocation;
}

pub fn isValidCell(h: H3Index) bool {
    return c.isValidCell(h) != 0;
}

pub fn isValidIndex(h: H3Index) bool {
    return c.isValidIndex(h) != 0;
}

pub fn cellToParent(h: H3Index, parent_res: c_int) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.cellToParent(h, parent_res, &out));
    return out;
}

pub fn cellToChildrenSize(h: H3Index, child_res: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.cellToChildrenSize(h, child_res, &out));
    return out;
}

pub fn cellToChildren(h: H3Index, child_res: c_int, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try cellToChildrenSize(h, child_res)));
    @memset(out, h3Null);
    try check(c.cellToChildren(h, child_res, out.ptr));
}

pub fn cellToChildrenAlloc(allocator: std.mem.Allocator, h: H3Index, child_res: c_int) Error![]H3Index {
    const out = try allocIndexes(allocator, try cellToChildrenSize(h, child_res));
    errdefer allocator.free(out);
    try cellToChildren(h, child_res, out);
    return out;
}

pub fn cellToCenterChild(h: H3Index, child_res: c_int) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.cellToCenterChild(h, child_res, &out));
    return out;
}

pub fn cellToChildPos(child: H3Index, parent_res: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.cellToChildPos(child, parent_res, &out));
    return out;
}

pub fn childPosToCell(child_pos: i64, parent: H3Index, child_res: c_int) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.childPosToCell(child_pos, parent, child_res, &out));
    return out;
}

pub fn compactCells(h3_set: []const H3Index, out: []H3Index) Error!void {
    try ensureLen(out.len, h3_set.len);
    @memset(out, h3Null);
    try check(c.compactCells(h3_set.ptr, out.ptr, try usizeToI64(h3_set.len)));
}

pub fn compactCellsAlloc(allocator: std.mem.Allocator, h3_set: []const H3Index) Error![]H3Index {
    const out = allocator.alloc(H3Index, h3_set.len) catch return error.MemoryAllocation;
    errdefer allocator.free(out);
    try compactCells(h3_set, out);
    return out;
}

pub fn uncompactCellsSize(compacted_set: []const H3Index, res: c_int) Error!i64 {
    var out: i64 = 0;
    try check(c.uncompactCellsSize(compacted_set.ptr, try usizeToI64(compacted_set.len), res, &out));
    return out;
}

pub fn uncompactCells(compacted_set: []const H3Index, res: c_int, out: []H3Index) Error!void {
    @memset(out, h3Null);
    try check(c.uncompactCells(compacted_set.ptr, try usizeToI64(compacted_set.len), out.ptr, try usizeToI64(out.len), res));
}

pub fn uncompactCellsAlloc(allocator: std.mem.Allocator, compacted_set: []const H3Index, res: c_int) Error![]H3Index {
    const out = try allocIndexes(allocator, try uncompactCellsSize(compacted_set, res));
    errdefer allocator.free(out);
    try uncompactCells(compacted_set, res, out);
    return out;
}

pub fn isResClassIII(h: H3Index) bool {
    return c.isResClassIII(h) != 0;
}

pub fn isPentagon(h: H3Index) bool {
    return c.isPentagon(h) != 0;
}

pub fn maxFaceCount(h3: H3Index) Error!c_int {
    var out: c_int = 0;
    try check(c.maxFaceCount(h3, &out));
    return out;
}

pub fn getIcosahedronFaces(h3: H3Index, out: []c_int) Error!void {
    try ensureLen(out.len, @intCast(try maxFaceCount(h3)));
    @memset(out, 0);
    try check(c.getIcosahedronFaces(h3, out.ptr));
}

pub fn getIcosahedronFacesAlloc(allocator: std.mem.Allocator, h3: H3Index) Error![]c_int {
    const out = allocator.alloc(c_int, @intCast(try maxFaceCount(h3))) catch return error.MemoryAllocation;
    errdefer allocator.free(out);
    try getIcosahedronFaces(h3, out);
    return out;
}

pub fn areNeighborCells(origin: H3Index, destination: H3Index) Error!bool {
    var out: c_int = 0;
    try check(c.areNeighborCells(origin, destination, &out));
    return out != 0;
}

pub fn cellsToDirectedEdge(origin: H3Index, destination: H3Index) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.cellsToDirectedEdge(origin, destination, &out));
    return out;
}

pub fn isValidDirectedEdge(edge: H3Index) bool {
    return c.isValidDirectedEdge(edge) != 0;
}

pub fn getDirectedEdgeOrigin(edge: H3Index) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.getDirectedEdgeOrigin(edge, &out));
    return out;
}

pub fn getDirectedEdgeDestination(edge: H3Index) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.getDirectedEdgeDestination(edge, &out));
    return out;
}

pub fn directedEdgeToCells(edge: H3Index) Error![directedEdgeCellCount]H3Index {
    var out: [directedEdgeCellCount]H3Index = .{h3Null} ** directedEdgeCellCount;
    try check(c.directedEdgeToCells(edge, out[0..].ptr));
    return out;
}

pub fn originToDirectedEdges(origin: H3Index) Error![directedEdgeCount]H3Index {
    var out: [directedEdgeCount]H3Index = .{h3Null} ** directedEdgeCount;
    try check(c.originToDirectedEdges(origin, out[0..].ptr));
    return out;
}

pub fn directedEdgeToBoundary(edge: H3Index) Error!CellBoundary {
    var out: CellBoundary = undefined;
    try check(c.directedEdgeToBoundary(edge, &out));
    return out;
}

pub fn reverseDirectedEdge(edge: H3Index) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.reverseDirectedEdge(edge, &out));
    return out;
}

pub fn cellToVertex(origin: H3Index, vertex_num: c_int) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.cellToVertex(origin, vertex_num, &out));
    return out;
}

pub fn cellToVertexes(origin: H3Index) Error![vertexCount]H3Index {
    var out: [vertexCount]H3Index = .{h3Null} ** vertexCount;
    try check(c.cellToVertexes(origin, out[0..].ptr));
    return out;
}

pub fn vertexToLatLng(vertex: H3Index) Error!LatLng {
    var out: LatLng = undefined;
    try check(c.vertexToLatLng(vertex, &out));
    return out;
}

pub fn isValidVertex(vertex: H3Index) bool {
    return c.isValidVertex(vertex) != 0;
}

pub fn gridDistance(origin: H3Index, h3: H3Index) Error!i64 {
    var out: i64 = 0;
    try check(c.gridDistance(origin, h3, &out));
    return out;
}

pub fn gridPathCellsSize(start: H3Index, end: H3Index) Error!i64 {
    var out: i64 = 0;
    try check(c.gridPathCellsSize(start, end, &out));
    return out;
}

pub fn gridPathCells(start: H3Index, end: H3Index, out: []H3Index) Error!void {
    try ensureLen(out.len, try countToUsize(try gridPathCellsSize(start, end)));
    @memset(out, h3Null);
    try check(c.gridPathCells(start, end, out.ptr));
}

pub fn gridPathCellsAlloc(allocator: std.mem.Allocator, start: H3Index, end: H3Index) Error![]H3Index {
    const out = try allocIndexes(allocator, try gridPathCellsSize(start, end));
    errdefer allocator.free(out);
    try gridPathCells(start, end, out);
    return out;
}

pub fn cellToLocalIj(origin: H3Index, h3: H3Index, mode: u32) Error!CoordIJ {
    var out: CoordIJ = undefined;
    try check(c.cellToLocalIj(origin, h3, mode, &out));
    return out;
}

pub fn localIjToCell(origin: H3Index, ij: CoordIJ, mode: u32) Error!H3Index {
    var out: H3Index = h3Null;
    try check(c.localIjToCell(origin, &ij, mode, &out));
    return out;
}

pub fn countNonNull(cells: []const H3Index) usize {
    var count: usize = 0;
    for (cells) |cell| {
        if (cell != h3Null) count += 1;
    }
    return count;
}

fn allocIndexes(allocator: std.mem.Allocator, count: i64) Error![]H3Index {
    const len = try countToUsize(count);
    const out = allocator.alloc(H3Index, len) catch return error.MemoryAllocation;
    @memset(out, h3Null);
    return out;
}

fn countToUsize(count: i64) Error!usize {
    if (count < 0) return error.MemoryBounds;
    const unsigned: u64 = @intCast(count);
    if (unsigned > std.math.maxInt(usize)) return error.MemoryBounds;
    return @intCast(unsigned);
}

fn usizeToI64(value: usize) Error!i64 {
    if (value > std.math.maxInt(i64)) return error.MemoryBounds;
    return @intCast(value);
}

fn usizeToCInt(value: usize) Error!c_int {
    if (value > std.math.maxInt(c_int)) return error.MemoryBounds;
    return @intCast(value);
}

fn checkedMulUsize(a: usize, b: usize) Error!usize {
    return std.math.mul(usize, a, b) catch error.MemoryBounds;
}

fn ensureLen(actual: usize, required: usize) Error!void {
    if (actual < required) return error.MemoryBounds;
}

test "ABI aliases match imported C types" {
    try std.testing.expectEqual(@sizeOf(u64), @sizeOf(H3Index));
    try std.testing.expectEqual(@sizeOf(c.LatLng), @sizeOf(LatLng));
    try std.testing.expectEqual(@sizeOf(c.CellBoundary), @sizeOf(CellBoundary));
    try std.testing.expectEqual(@as(c_int, 4), c.H3_VERSION_MAJOR);
    try std.testing.expectEqual(@as(c_int, 5), c.H3_VERSION_MINOR);
    try std.testing.expectEqual(@as(c_int, 0), c.H3_VERSION_PATCH);
}

test "H3 error mapping is complete for public error codes" {
    try check(c.E_SUCCESS);
    try std.testing.expectError(error.ResolutionDomain, check(c.E_RES_DOMAIN));
    try std.testing.expectError(error.CellInvalid, check(c.E_CELL_INVALID));
    try std.testing.expect(std.mem.indexOf(u8, describeErrorCode(c.E_RES_DOMAIN), "Resolution") != null);
}
