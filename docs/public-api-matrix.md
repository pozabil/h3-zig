# Public API Matrix

Baseline: upstream H3 `v4.5.0`, vendored commit `1b536c34225191ba24a75a840f634d4a48c3b206`.

This matrix maps every public C function exported from `vendor/h3/src/h3lib/include/h3api.h` with `H3_EXPORT(...)` to the top-level safe Zig wrapper in `src/root.zig`.

Current status:

- Public C API functions: 79
- Safe Zig wrapper names: 79 / 79
- Raw C access: every entry is also available as `h3.raw.<function>` and `h3.c.<function>`.
- Automated guard: `bash tools/check-api-coverage.sh`

The safe wrapper name intentionally matches the C function name where possible. Zig-only convenience helpers are listed after the matrix.

The `Coverage evidence` column is a traceability note, not a claim that every wrapper has a separate one-function-only assertion. Some low-level or unsafe variants are covered through the same public wrapper family and traversal contract tests.

## Function Matrix

| Area | C API | Safe Zig wrapper | Zig contract | Coverage evidence |
|---|---|---|---|---|
| Indexing | `latLngToCell` | `h3.latLngToCell` | Returns `H3Index` or `h3.Error`. | Contract tests plus 55,027 upstream center fixture rows. |
| Indexing | `cellToLatLng` | `h3.cellToLatLng` | Returns `LatLng` or `h3.Error`. | Contract tests plus 48,008 upstream exact-center rows. |
| Indexing | `cellToBoundary` | `h3.cellToBoundary` | Returns `CellBoundary` or `h3.Error`. | Contract tests plus 200-row upstream boundary fixture sample. |
| Units | `degsToRads` | `h3.degsToRads` | Direct scalar conversion. | Contract tests. |
| Units | `radsToDegs` | `h3.radsToDegs` | Direct scalar conversion. | Contract tests. |
| Distance | `greatCircleDistanceRads` | `h3.greatCircleDistanceRads` | Direct scalar distance in radians. | Contract tests. |
| Distance | `greatCircleDistanceKm` | `h3.greatCircleDistanceKm` | Direct scalar distance in kilometers. | Contract tests and upstream CLI fixture value. |
| Distance | `greatCircleDistanceM` | `h3.greatCircleDistanceM` | Direct scalar distance in meters. | Contract tests. |
| Grid disk | `maxGridDiskSize` | `h3.maxGridDiskSize` | Returns required output length or `h3.Error`. | Contract tests through disk wrappers. |
| Grid disk | `gridDiskUnsafe` | `h3.gridDiskUnsafe` | Fills caller-owned slice after size validation. | Contract tests through traversal behavior. |
| Grid disk | `gridDiskDistancesUnsafe` | `h3.gridDiskDistancesUnsafe` | Fills caller-owned cell and distance slices after size validation. | Contract tests through traversal behavior. |
| Grid disk | `gridDiskDistancesSafe` | `h3.gridDiskDistancesSafe` | Fills caller-owned cell and distance slices after size validation. | Contract tests through traversal behavior. |
| Grid disk | `gridDisksUnsafe` | `h3.gridDisksUnsafe` | Fills caller-owned slice for multiple origins after size validation. | Contract tests through traversal behavior. |
| Grid disk | `gridDisk` | `h3.gridDisk` | Fills caller-owned slice after size validation. | Contract tests; `h3.gridDiskAlloc` convenience helper. |
| Grid disk | `gridDiskDistances` | `h3.gridDiskDistances` | Fills caller-owned cell and distance slices after size validation. | Contract tests; `h3.gridDiskDistancesAlloc` convenience helper. |
| Grid ring | `maxGridRingSize` | `h3.maxGridRingSize` | Returns required output length or `h3.Error`. | Contract tests through ring wrappers. |
| Grid ring | `gridRingUnsafe` | `h3.gridRingUnsafe` | Fills caller-owned slice after size validation. | Contract tests through ring behavior. |
| Grid ring | `gridRing` | `h3.gridRing` | Fills caller-owned slice after size validation. | Contract tests; `h3.gridRingAlloc` convenience helper. |
| Polygon fill | `maxPolygonToCellsSize` | `h3.maxPolygonToCellsSize` | Returns required output length or `h3.Error`. | Contract tests through polygon fill wrappers. |
| Polygon fill | `polygonToCells` | `h3.polygonToCells` | Fills caller-owned slice after size validation. | Contract tests; `h3.polygonToCellsAlloc` convenience helper. |
| Polygon fill | `maxPolygonToCellsSizeExperimental` | `h3.maxPolygonToCellsSizeExperimental` | Returns required output length or `h3.Error`. | Contract tests through experimental polygon fill. |
| Polygon fill | `polygonToCellsExperimental` | `h3.polygonToCellsExperimental` | Fills caller-owned slice using explicit containment mode flags. | Contract tests; `h3.polygonToCellsExperimentalAlloc` convenience helper. |
| Linked polygon | `cellsToLinkedMultiPolygon` | `h3.cellsToLinkedMultiPolygon` | Returns C-owned linked polygon head or `h3.Error`. | Contract tests. |
| Linked polygon | `destroyLinkedMultiPolygon` | `h3.destroyLinkedMultiPolygon` | Frees C-owned linked polygon memory. | Contract tests plus memory checks. |
| Area metrics | `getHexagonAreaAvgKm2` | `h3.getHexagonAreaAvgKm2` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Area metrics | `getHexagonAreaAvgM2` | `h3.getHexagonAreaAvgM2` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Area metrics | `cellAreaRads2` | `h3.cellAreaRads2` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Area metrics | `cellAreaKm2` | `h3.cellAreaKm2` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Area metrics | `cellAreaM2` | `h3.cellAreaM2` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Edge metrics | `getHexagonEdgeLengthAvgKm` | `h3.getHexagonEdgeLengthAvgKm` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Edge metrics | `getHexagonEdgeLengthAvgM` | `h3.getHexagonEdgeLengthAvgM` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Edge metrics | `edgeLengthRads` | `h3.edgeLengthRads` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Edge metrics | `edgeLengthKm` | `h3.edgeLengthKm` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Edge metrics | `edgeLengthM` | `h3.edgeLengthM` | Returns scalar metric or `h3.Error`. | Contract tests. |
| Counts | `getNumCells` | `h3.getNumCells` | Returns scalar count or `h3.Error`. | Contract tests. |
| Counts | `res0CellCount` | `h3.res0CellCount` | Direct scalar count. | Contract tests. |
| Counts | `getRes0Cells` | `h3.getRes0Cells` | Fills caller-owned slice after size validation. | Contract tests; `h3.getRes0CellsAlloc` convenience helper. |
| Counts | `pentagonCount` | `h3.pentagonCount` | Direct scalar count. | Contract tests. |
| Counts | `getPentagons` | `h3.getPentagons` | Fills caller-owned slice after size validation. | Contract tests; `h3.getPentagonsAlloc` convenience helper. |
| Cell inspection | `getResolution` | `h3.getResolution` | Direct scalar inspection. | Contract tests and fixture parsers. |
| Cell inspection | `getBaseCellNumber` | `h3.getBaseCellNumber` | Direct scalar inspection. | Contract tests. |
| Cell inspection | `getIndexDigit` | `h3.getIndexDigit` | Returns scalar digit or `h3.Error`. | Contract tests. |
| Cell construction | `constructCell` | `h3.constructCell` | Validates digit slice length and returns `H3Index` or `h3.Error`. | Contract tests. |
| String conversion | `stringToH3` | `h3.stringToH3` | Converts NUL-terminated text to `H3Index` or `h3.Error`. | Contract tests. |
| String conversion | `h3ToString` | `h3.h3ToString` | Writes into caller buffer and returns non-NUL slice. | Contract tests; `h3.h3ToStringAlloc` convenience helper. |
| Validation | `isValidCell` | `h3.isValidCell` | Returns Zig `bool`. | Contract tests. |
| Validation | `isValidIndex` | `h3.isValidIndex` | Returns Zig `bool`. | Contract tests. |
| Hierarchy | `cellToParent` | `h3.cellToParent` | Returns parent cell or `h3.Error`. | Contract tests. |
| Hierarchy | `cellToChildrenSize` | `h3.cellToChildrenSize` | Returns required child count or `h3.Error`. | Contract tests. |
| Hierarchy | `cellToChildren` | `h3.cellToChildren` | Fills caller-owned slice after size validation. | Contract tests; `h3.cellToChildrenAlloc` convenience helper. |
| Hierarchy | `cellToCenterChild` | `h3.cellToCenterChild` | Returns center child or `h3.Error`. | Contract tests. |
| Hierarchy | `cellToChildPos` | `h3.cellToChildPos` | Returns child position or `h3.Error`. | Contract tests. |
| Hierarchy | `childPosToCell` | `h3.childPosToCell` | Returns child cell or `h3.Error`. | Contract tests. |
| Compaction | `compactCells` | `h3.compactCells` | Fills caller-owned slice after size validation. | Contract tests; `h3.compactCellsAlloc` convenience helper. |
| Compaction | `uncompactCellsSize` | `h3.uncompactCellsSize` | Returns required uncompact count or `h3.Error`. | Contract tests. |
| Compaction | `uncompactCells` | `h3.uncompactCells` | Fills caller-owned slice. | Contract tests; `h3.uncompactCellsAlloc` convenience helper. |
| Cell class | `isResClassIII` | `h3.isResClassIII` | Returns Zig `bool`. | Contract tests. |
| Cell class | `isPentagon` | `h3.isPentagon` | Returns Zig `bool`. | Contract tests. |
| Faces | `maxFaceCount` | `h3.maxFaceCount` | Returns required face count or `h3.Error`. | Contract tests through face wrappers. |
| Faces | `getIcosahedronFaces` | `h3.getIcosahedronFaces` | Fills caller-owned slice after size validation. | Contract tests; `h3.getIcosahedronFacesAlloc` convenience helper. |
| Directed edge | `areNeighborCells` | `h3.areNeighborCells` | Returns Zig `bool` or `h3.Error`. | Contract tests. |
| Directed edge | `cellsToDirectedEdge` | `h3.cellsToDirectedEdge` | Returns directed edge or `h3.Error`. | Contract tests. |
| Directed edge | `isValidDirectedEdge` | `h3.isValidDirectedEdge` | Returns Zig `bool`. | Contract tests. |
| Directed edge | `getDirectedEdgeOrigin` | `h3.getDirectedEdgeOrigin` | Returns origin cell or `h3.Error`. | Contract tests. |
| Directed edge | `getDirectedEdgeDestination` | `h3.getDirectedEdgeDestination` | Returns destination cell or `h3.Error`. | Contract tests. |
| Directed edge | `directedEdgeToCells` | `h3.directedEdgeToCells` | Returns fixed `[2]H3Index` array or `h3.Error`. | Contract tests. |
| Directed edge | `originToDirectedEdges` | `h3.originToDirectedEdges` | Returns fixed `[6]H3Index` array or `h3.Error`. | Contract tests. |
| Directed edge | `directedEdgeToBoundary` | `h3.directedEdgeToBoundary` | Returns `CellBoundary` or `h3.Error`. | Contract tests. |
| Directed edge | `reverseDirectedEdge` | `h3.reverseDirectedEdge` | Returns reversed directed edge or `h3.Error`. | Contract tests. |
| Vertex | `cellToVertex` | `h3.cellToVertex` | Returns vertex index or `h3.Error`. | Contract tests. |
| Vertex | `cellToVertexes` | `h3.cellToVertexes` | Returns fixed `[6]H3Index` array or `h3.Error`. | Contract tests. |
| Vertex | `vertexToLatLng` | `h3.vertexToLatLng` | Returns vertex coordinate or `h3.Error`. | Contract tests. |
| Vertex | `isValidVertex` | `h3.isValidVertex` | Returns Zig `bool`. | Contract tests. |
| Local IJ | `gridDistance` | `h3.gridDistance` | Returns grid distance or `h3.Error`. | Contract tests. |
| Local IJ | `gridPathCellsSize` | `h3.gridPathCellsSize` | Returns required path length or `h3.Error`. | Contract tests. |
| Local IJ | `gridPathCells` | `h3.gridPathCells` | Fills caller-owned slice after size validation. | Contract tests; `h3.gridPathCellsAlloc` convenience helper. |
| Local IJ | `cellToLocalIj` | `h3.cellToLocalIj` | Returns `CoordIJ` or `h3.Error`. | Contract tests. |
| Local IJ | `localIjToCell` | `h3.localIjToCell` | Returns `H3Index` or `h3.Error`. | Contract tests. |
| Errors | `describeH3Error` | `h3.describeH3Error` | Returns `[]const u8` view over upstream static C string. | Unit and contract tests. |

## Zig-Only Convenience API

These functions do not correspond to separate upstream `H3_EXPORT(...)` entries. They adapt C contracts to Zig ownership and ergonomics:

| Helper | Purpose |
|---|---|
| `h3.c`, `h3.raw` | Direct `@cImport("h3api.h")` escape hatch. |
| `h3.Error`, `h3.errorFromCode`, `h3.errorToCode`, `h3.check`, `h3.describeErrorCode`, `h3.describeError` | Zig error-set mapping for `H3Error`. |
| `h3.latLngRadians`, `h3.latLngDegrees` | `LatLng` constructors. |
| `h3.boundaryVertices` | Safe slice view over `CellBoundary.verts`. |
| `h3.countNonNull` | Count non-null H3 output cells in fixed-size upstream buffers. |
| `*Alloc` helpers | Allocate Zig-owned output slices for caller-sized-buffer APIs. Caller frees returned slices. |
| `GridDiskDistances.deinit` | Frees paired `gridDiskDistancesAlloc` slices. |
