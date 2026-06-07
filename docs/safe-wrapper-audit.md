# Safe Wrapper Audit

Date: 2026-06-07

Scope: `src/root.zig` safe wrappers over upstream H3 `v4.5.0` public `h3api.h`.

## Method

- Compared every `H3_EXPORT(...)` public function in `vendor/h3/src/h3lib/include/h3api.h` against top-level `pub fn` wrappers in `src/root.zig`.
- Reviewed wrappers by ownership pattern: scalar output, fixed-size output, caller-sized output, allocator helper, linked C-owned memory, direct boolean/scalar functions, and raw passthrough.
- Verified current automated checks:
  - `bash tools/check-api-coverage.sh`
  - `zig build test --summary all`
  - `zig build test --summary all` from `test/consumer`
  - `zig build --summary all`
  - cross-compile smoke for Linux/Windows x64/arm64 targets
- Verified local macOS memory checks with `/usr/bin/leaks --atExit` for all three Zig test executables.
- Configured Linux CI memory checks through `zig build test-valgrind -Dtarget=x86_64-linux-gnu -Dcpu=baseline --summary all`.
- Public API mapping is documented in `docs/public-api-matrix.md`.
- Upstream test and fixture parity is documented in `docs/upstream-test-coverage.md`.

## Audit Summary

| Area | Status | Notes |
|---|---|---|
| Public API coverage | Pass | `tools/check-api-coverage.sh` fails if a public H3 entrypoint lacks a safe wrapper name. |
| Raw API escape hatch | Pass | `h3.raw` and `h3.c` expose direct `@cImport("h3api.h")` access. |
| Error mapping | Pass | All documented `H3ErrorCodes` map to `h3.Error`; unknown codes map to `error.Unknown`. |
| ABI type aliases | Pass | Unit tests check representative imported C type sizes and H3 version constants. |
| Caller-sized buffers | Pass | Wrappers compute required sizes through upstream `max*Size` APIs where available and reject undersized Zig slices with `error.MemoryBounds`. |
| Allocator helpers | Pass | Zig-owned slices are allocated by the caller-provided allocator and returned to the caller for explicit free. |
| C-owned linked polygons | Pass | `cellsToLinkedMultiPolygon` returns C-owned linked memory; `destroyLinkedMultiPolygon` is exposed and tested. |
| Covered-path leak check | Partial | The current Zig test executables report `0 leaked bytes` under macOS `leaks`; the Linux Valgrind gate is configured with baseline CPU features and needs a fresh hosted CI run after that workflow change. |
| String conversion | Pass | `h3ToString` requires `h3StringBufferLength` bytes and returns a slice excluding the C NUL. |
| Polygon input ownership | Pass | `GeoPolygon`/`GeoLoop` wrappers pass caller-owned coordinate buffers through to C; no Zig wrapper takes ownership. |
| Public fixture behavior | Partial | Fixture parity covers large public lat/lng and center datasets plus a bounded `cellToBoundary` boundary sample. `docs/upstream-test-coverage.md` lists covered, partial, excluded, and not-applicable upstream tests and fixtures. |

## Wrapper Families

### Direct scalar or boolean wrappers

These wrappers do not allocate and preserve upstream return semantics directly:

- `degsToRads`, `radsToDegs`
- `greatCircleDistanceRads`, `greatCircleDistanceKm`, `greatCircleDistanceM`
- `res0CellCount`, `pentagonCount`
- `getResolution`, `getBaseCellNumber`
- `isValidCell`, `isValidIndex`, `isResClassIII`, `isPentagon`, `isValidDirectedEdge`, `isValidVertex`
- `describeH3Error`, `describeErrorCode`, `describeError`

### Scalar output wrappers

These wrappers translate `H3Error` to `h3.Error` and return a Zig value:

- Indexing and coordinates: `latLngToCell`, `cellToLatLng`, `cellToBoundary`
- Sizing: `maxGridDiskSize`, `maxGridRingSize`, `maxPolygonToCellsSize`, `maxPolygonToCellsSizeExperimental`, `cellToChildrenSize`, `uncompactCellsSize`, `gridPathCellsSize`
- Metrics: `getHexagonAreaAvgKm2`, `getHexagonAreaAvgM2`, `cellAreaRads2`, `cellAreaKm2`, `cellAreaM2`, `getHexagonEdgeLengthAvgKm`, `getHexagonEdgeLengthAvgM`, `edgeLengthRads`, `edgeLengthKm`, `edgeLengthM`, `getNumCells`
- Hierarchy and identity: `getIndexDigit`, `constructCell`, `stringToH3`, `cellToParent`, `cellToCenterChild`, `cellToChildPos`, `childPosToCell`
- Directed edges and vertices: `areNeighborCells`, `cellsToDirectedEdge`, `getDirectedEdgeOrigin`, `getDirectedEdgeDestination`, `reverseDirectedEdge`, `cellToVertex`, `vertexToLatLng`, `gridDistance`, `cellToLocalIj`, `localIjToCell`

### Caller-buffer wrappers

These wrappers require caller-provided slices and check obvious size contracts before calling C:

- Grid: `gridDiskUnsafe`, `gridDiskDistancesUnsafe`, `gridDiskDistancesSafe`, `gridDisksUnsafe`, `gridDisk`, `gridDiskDistances`, `gridRingUnsafe`, `gridRing`
- Polygon fill: `polygonToCells`, `polygonToCellsExperimental`
- Resolution sets: `getRes0Cells`, `getPentagons`, `getIcosahedronFaces`
- Hierarchy sets: `cellToChildren`, `compactCells`, `uncompactCells`
- Paths and fixed arrays: `directedEdgeToCells`, `originToDirectedEdges`, `cellToVertexes`, `gridPathCells`
- Strings: `h3ToString`

### Allocator helpers

These helpers allocate Zig-owned memory:

- `gridDiskUnsafeAlloc`, `gridDiskAlloc`, `gridDiskDistancesAlloc`, `gridRingAlloc`, `polygonToCellsAlloc`, `polygonToCellsExperimentalAlloc`
- `getRes0CellsAlloc`, `getPentagonsAlloc`, `getIcosahedronFacesAlloc`
- `cellToChildrenAlloc`, `compactCellsAlloc`, `uncompactCellsAlloc`, `gridPathCellsAlloc`, `h3ToStringAlloc`

The caller owns returned Zig slices and must free them. `GridDiskDistances.deinit` frees both slices in the paired result.

## Residual Risks

- `cellToBoundary` fixture coverage samples 200 rows from `rand05cells.txt` rather than running all 45,040 boundary cases in the default suite.
- Additional upstream fixture groups remain partially covered as documented in `docs/upstream-test-coverage.md`.
- The Linux Valgrind memory gate needs a fresh hosted CI run after pinning the test target to baseline CPU features.
- Cross-compile jobs are build-only unless a runner or emulator executes the target binaries.
