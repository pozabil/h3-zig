# Upstream Test Coverage

Baseline: upstream H3 [`v4.5.0`](https://github.com/uber/h3/tree/v4.5.0), commit `1b536c34225191ba24a75a840f634d4a48c3b206`.

This document maps upstream public tests and fixtures to the current Zig binding test coverage. It is intentionally scoped to the binding contract:

- Public H3 C APIs exposed from `h3api.h` must have Zig safe wrappers. See `docs/public-api-matrix.md`.
- Public API behavior should be covered through Zig tests where it maps cleanly to package-level contracts.
- Private C implementation tests are excluded unless they are observable through public API behavior.
- Upstream CLI-only, generator, benchmark, and fuzzer behavior is not a required package contract for this Zig library.

Status meanings:

- `Covered`: equivalent public-contract behavior is exercised by Zig tests.
- `Partial`: some upstream cases or fixture rows are covered, but not the entire upstream file/test scope.
- `Excluded`: private/internal C implementation detail, not a Zig binding contract.
- `Not applicable`: upstream tool behavior that this package does not ship.

## Zig Test Files

| Zig file | Role |
|---|---|
| `src/root.zig` | ABI alias and error mapping unit tests. |
| `test/h3_contract_tests.zig` | Public API behavior tests across indexing, grid traversal, hierarchy, compaction, polygons, metrics, directed edges, vertexes, local IJ, raw access, and error cases. |
| `test/upstream_public_fixtures.zig` | Upstream fixture-backed tests for centers, exact cell centers, and boundary samples. |
| `test/consumer/` | External package consumer integration test for safe and raw APIs. |

## Upstream C Testapps

This table lists the 66 upstream `src/apps/testapps/test*.c` files. `Covered` means equivalent public API behavior is tested in Zig; it does not mean a line-for-line C test translation.

| Upstream testapp | Status | Zig evidence | Notes |
|---|---|---|---|
| `testBBoxInternal.c` | Excluded | none | Private bbox/polygon internals. |
| `testBaseCells.c` | Covered | `test/h3_contract_tests.zig` | Public base-cell observations through `getRes0Cells`, `getBaseCellNumber`, pentagons, and fixtures. |
| `testBaseCellsInternal.c` | Excluded | none | Private base-cell internals. |
| `testCellToBBoxExhaustive.c` | Excluded | none | Exhaustive private bbox/polyfill internals. |
| `testCellToBoundary.c` | Partial | `test/upstream_public_fixtures.zig` | 200 rows from `rand05cells.txt`; not every upstream `*cells.txt` fixture. |
| `testCellToBoundaryEdgeCases.c` | Covered | `test/h3_contract_tests.zig` | Public boundary edge cases represented. |
| `testCellToCenterChild.c` | Covered | `test/h3_contract_tests.zig` | Public hierarchy behavior. |
| `testCellToChildPos.c` | Covered | `test/h3_contract_tests.zig` | Public child position roundtrip. |
| `testCellToChildren.c` | Covered | `test/h3_contract_tests.zig` | Public hierarchy behavior and alloc helper. |
| `testCellToChildrenSize.c` | Covered | `test/h3_contract_tests.zig` | Public child size behavior. |
| `testCellToLatLng.c` | Partial | `test/upstream_public_fixtures.zig` | `res00ic.txt` through `res03ic.txt`; `res04ic.txt` not embedded. |
| `testCellToLocalIj.c` | Covered | `test/h3_contract_tests.zig` | Public local IJ roundtrip. |
| `testCellToLocalIjExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public roundtrip; exhaustive traversal not ported. |
| `testCellToLocalIjInternal.c` | Excluded | none | Private local IJ internals. |
| `testCellToParent.c` | Covered | `test/h3_contract_tests.zig` | Public hierarchy behavior. |
| `testCellsToLinkedMultiPolygon.c` | Covered | `test/h3_contract_tests.zig` | Public linked polygon output and destroy path. |
| `testCellsToMultiPoly.c` | Partial | `test/h3_contract_tests.zig` | Public linked polygon behavior is covered; upstream non-public multipoly internals are not. |
| `testCellsToMultiPolyInternal.c` | Excluded | none | Private multipolygon internals. |
| `testCompactCells.c` | Covered | `test/h3_contract_tests.zig` | Public compact/uncompact roundtrip. |
| `testConstructCell.c` | Covered | `test/h3_contract_tests.zig` | Public construction and error cases. |
| `testCoordIjInternal.c` | Excluded | none | Private CoordIJ/internal local IJ behavior. |
| `testCoordIjkInternal.c` | Excluded | none | Private CoordIJK internals. |
| `testDescribeH3Error.c` | Covered | `src/root.zig`, `test/h3_contract_tests.zig` | Public error string and Zig error mapping. |
| `testDirectedEdge.c` | Covered | `test/h3_contract_tests.zig` | Public directed edge API behavior. |
| `testDirectedEdgeExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public directed edge behavior; exhaustive scan not ported. |
| `testGeoLoopArea.c` | Excluded | none | Private area helper behavior, not exported in `h3api.h`. |
| `testGetIcosahedronFaces.c` | Covered | `test/h3_contract_tests.zig` | Public face count/output behavior. |
| `testGridDisk.c` | Covered | `test/h3_contract_tests.zig` | Public disk and distance behavior. |
| `testGridDiskInternal.c` | Excluded | none | Private grid disk internals. |
| `testGridDisksUnsafe.c` | Partial | `docs/public-api-matrix.md`, `test/h3_contract_tests.zig` | Wrapper exists; traversal behavior is represented, but this unsafe variant is not ported line-for-line. |
| `testGridDistance.c` | Covered | `test/h3_contract_tests.zig` | Public distance behavior. |
| `testGridDistanceExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public distance behavior; exhaustive scan not ported. |
| `testGridDistanceInternal.c` | Excluded | none | Private grid distance internals. |
| `testGridPathCells.c` | Covered | `test/h3_contract_tests.zig` | Public path behavior and alloc helper. |
| `testGridPathCellsExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public path behavior; exhaustive scan not ported. |
| `testGridRing.c` | Covered | `test/h3_contract_tests.zig` | Public ring behavior. |
| `testGridRingInternal.c` | Excluded | none | Private grid ring internals. |
| `testGridRingUnsafe.c` | Partial | `docs/public-api-matrix.md`, `test/h3_contract_tests.zig` | Wrapper exists; ring behavior is represented, but this unsafe variant is not ported line-for-line. |
| `testH3Api.c` | Covered | `src/root.zig`, `test/h3_contract_tests.zig` | Public API constants, errors, invalid input behavior. |
| `testH3CellArea.c` | Covered | `test/h3_contract_tests.zig` | Public cell area metrics. |
| `testH3CellAreaExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public area metrics; exhaustive scan not ported. |
| `testH3Index.c` | Covered | `src/root.zig`, `test/h3_contract_tests.zig` | Public string/index/resolution/digit behavior. |
| `testH3IndexInternal.c` | Excluded | none | Private H3 index bit internals. |
| `testH3IteratorsInternal.c` | Excluded | none | Private iterator internals. |
| `testH3Memory.c` | Partial | memory checks | Zig-owned allocations use `std.testing.allocator`; linked polygon destroy path is tested. Upstream custom allocator interception is not ported. |
| `testH3NeighborRotations.c` | Excluded | none | Private neighbor-rotation internals. |
| `testIndexDigits.c` | Covered | `test/h3_contract_tests.zig` | Public digit/construction behavior. |
| `testLatLng.c` | Covered | `test/h3_contract_tests.zig` | Public coordinate conversion and distance behavior. |
| `testLatLngInternal.c` | Excluded | none | Private lat/lng helper internals. |
| `testLatLngToCell.c` | Partial | `test/upstream_public_fixtures.zig` | All `rand05..rand15centers.txt` rows and selected base-cell center files; not every upstream `bc*centers.txt` file. |
| `testLinkedGeoConvert.c` | Excluded | none | Private linked-geo conversion helpers; public linked polygon smoke covered separately. |
| `testLinkedGeoInternal.c` | Excluded | none | Private linked-geo internals. |
| `testMathExtensionsInternal.c` | Excluded | none | Private math extension internals. |
| `testPentagonIndexes.c` | Covered | `test/h3_contract_tests.zig` | Public pentagon count/index behavior. |
| `testPolyfillInternal.c` | Excluded | none | Private polyfill internals. |
| `testPolygonInternal.c` | Excluded | none | Private polygon internals. |
| `testPolygonToCells.c` | Partial | `test/h3_contract_tests.zig` | Public polygon fill behavior covered with representative fixture-derived polygon; full upstream fixed suite not ported. |
| `testPolygonToCellsExperimental.c` | Partial | `test/h3_contract_tests.zig` | Experimental public wrapper covered with representative containment mode; full upstream fixed suite not ported. |
| `testPolygonToCellsReported.c` | Partial | `test/h3_contract_tests.zig` | Representative public polygon behavior; reported-case suite not ported line-for-line. |
| `testPolygonToCellsReportedExperimental.c` | Partial | `test/h3_contract_tests.zig` | Representative experimental polygon behavior; reported-case suite not ported line-for-line. |
| `testVec2dInternal.c` | Excluded | none | Private vector internals. |
| `testVec3.c` | Excluded | none | Private vector helper behavior, not exported in `h3api.h`. |
| `testVec3dInternal.c` | Excluded | none | Private vector internals. |
| `testVertex.c` | Covered | `test/h3_contract_tests.zig` | Public vertex APIs. |
| `testVertexExhaustive.c` | Partial | `test/h3_contract_tests.zig` | Representative public vertex behavior; exhaustive scan not ported. |
| `testVertexInternal.c` | Excluded | none | Private vertex internals. |

## Upstream Input Fixtures

Upstream CMake wires these through `tests/inputfiles/*.txt`. The target repo embeds a selected subset under `test/fixtures/upstream/`.

| Upstream fixture group | Status | Zig evidence | Notes |
|---|---|---|---|
| `rand05centers.txt` through `rand15centers.txt` | Covered | `test/upstream_public_fixtures.zig` | All 55,000 random center rows are embedded and checked against `latLngToCell`. |
| `bc05r08centers.txt`, `bc05r09centers.txt`, `bc14r08centers.txt`, `bc19r08centers.txt` | Covered | `test/upstream_public_fixtures.zig` | 27 selected base-cell hierarchy center rows are embedded. |
| Remaining `bc*centers.txt` files | Partial | none | Not embedded; public `latLngToCell` behavior still has broad random fixture coverage. |
| `res00ic.txt` through `res03ic.txt` | Covered | `test/upstream_public_fixtures.zig` | 48,008 exact center rows are embedded and checked against `cellToLatLng`. |
| `res04ic.txt` | Partial | none | Not embedded; upstream file has 288,122 rows. |
| `rand05cells.txt` | Partial | `test/upstream_public_fixtures.zig` | Full 45,040-row file is embedded for traceability, but the default test checks a 200-cell sample. |
| Other `*cells.txt` boundary fixtures | Partial | none | Not embedded or executed. |
| `great_circle_distance.txt` | Covered | `test/h3_contract_tests.zig` | Single upstream CLI fixture value is represented. |
| `compact_test*.txt`, `uncompact_test*.txt` | Partial | `test/h3_contract_tests.zig` | Public compaction roundtrip is covered; fixture files are not embedded. |
| `polygon_test*.txt` | Partial | `test/h3_contract_tests.zig` | Representative polygon fixture-derived case is covered; fixture files are not embedded. |
| `multipolygon_test*.txt` | Partial | `test/h3_contract_tests.zig` | Linked polygon allocation/destroy path is covered; full multipolygon fixture set is not embedded. |

## Upstream CLI Fixtures

Upstream `tests/cli/*.txt` validates the standalone H3 CLI. This Zig package does not ship that CLI, so these fixtures are not executed as CLI tests. Public API examples from the CLI fixtures are represented through Zig contract tests where they map to safe wrappers.

| CLI fixture scope | Status | Zig evidence | Notes |
|---|---|---|---|
| Public API fixtures matching exported wrappers | Partial | `test/h3_contract_tests.zig` | Indexing, traversal, hierarchy, directed edges, vertexes, metrics, local IJ, strings, and polygons are represented as Zig calls. |
| `intToString.txt`, `stringToInt.txt` | Covered | `test/h3_contract_tests.zig` | Covered through `h3.h3ToString` and `h3.stringToH3`. |
| `readCellsFromFile.txt` | Not applicable | none | CLI file-reader behavior is not part of the Zig package API. |
| `cellsToMultiPolygon.txt` | Partial | `test/h3_contract_tests.zig` | The exported public API is `cellsToLinkedMultiPolygon`; non-linked CLI output formatting is not a Zig binding contract. |

## Current Residual Coverage Gaps

- Full `cellToBoundary` upstream fixture parity is partial: default tests sample 200 rows from `rand05cells.txt` and do not run every upstream `*cells.txt` fixture.
- Exact center fixture parity excludes `res04ic.txt`.
- Base-cell center fixture parity includes selected `bc*centers.txt` files, not all upstream base-cell center files.
- Some unsafe traversal variants are exposed and documented but covered through representative traversal-family tests rather than direct upstream testapp ports.
- Polygon, compact/uncompact, and multipolygon upstream fixture files are represented by public contract tests, not embedded line-for-line.
- Exhaustive upstream scans remain partial unless they exercise private internals, in which case they are excluded from the Zig binding contract.
