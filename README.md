# h3-zig

Zig bindings for Uber H3 v4.5.0.

The package vendors the upstream H3 C library and compiles it through Zig, so consumers do not need a system `h3` install. The public surface has two layers:

- `h3.raw` / `h3.c`: translated `h3api.h` access to the complete public C API.
- top-level `h3.*` functions: thin Zig wrappers that return values, accept slices, and map `H3Error` codes to `h3.Error`.

## Use

Add the package as a Zig dependency, then import the exposed `h3` module:

```zig
const h3 = @import("h3");

pub fn main() !void {
    const statue = h3.latLngDegrees(40.689167, -74.044444);
    const cell = try h3.latLngToCell(statue, 10);

    var buffer: [h3.h3StringBufferLength]u8 = undefined;
    const text = try h3.h3ToString(cell, &buffer);
    _ = text; // "8a2a1072b59ffff"
}
```

## Build And Test

```sh
zig fmt --check build.zig build.zig.zon src test
zig build test
bash tools/check-api-coverage.sh
cd test/consumer && zig build test
```

The tests are derived from upstream public H3 examples, CLI fixtures, and test fixtures. They exercise indexing, string conversion, boundaries, grid traversal, hierarchy, compaction, directed edges, vertexes, polygons, local IJ, metrics, linked polygons, raw C access, error mapping, 55,000 upstream random center fixture rows, and an upstream boundary fixture sample.

`zig build test-valgrind` runs the same unit and public-contract test executables under Valgrind on Linux systems with Valgrind installed. In CI, this gate pins `x86_64-linux-gnu` with `baseline` CPU features so the result does not depend on the specific hosted runner CPU.

GitHub Actions runs native tests on Linux x64, Linux arm64, Windows x64, macOS Intel, and macOS arm64 in both Debug and ReleaseSafe modes for Zig `0.15.2` and Zig `0.16.0`. It also runs a Linux Valgrind memory gate and cross-compiles library artifacts for Linux and Windows x64/arm64 targets on both Zig versions. The supported native runtime matrix and build-only cross-compile matrix have passed the GitHub-hosted `CI` workflow.

Supported Zig versions are documented in [Support Policy](docs/support-policy.md).

See [Public API Matrix](docs/public-api-matrix.md) for the C-to-Zig wrapper map, [Upstream Test Coverage](docs/upstream-test-coverage.md) for upstream test and fixture parity, [Support Policy](docs/support-policy.md) for the exact support matrix and release requirements, and [Safe Wrapper Audit](docs/safe-wrapper-audit.md) for current ownership, buffer, and error-semantics review notes.

## Upstream Test Parity

The Zig suite ports upstream public fixture coverage where it maps cleanly to package-level public contracts, rather than private H3 internals. Current fixture-backed coverage includes:

- `testLatLngToCell`: all upstream `rand05..rand15centers` rows plus selected base-cell hierarchy center rows.
- `testCellToLatLng`: upstream `res00..res03ic` rows.
- `testCellToBoundary`: an upstream `rand05cells` boundary sample.
- Additional public contracts from upstream examples and CLI fixtures for grid traversal, hierarchy, compaction, directed edges, vertexes, polygons, metrics, local IJ, and error cases.

Internal upstream tests that depend on private headers, bit macros, base-cell internals, or FaceIJK internals are intentionally excluded from the Zig binding contract.

## Ownership

Allocator-returning helpers allocate Zig-owned slices that callers must free. `cellsToLinkedMultiPolygon` returns C-owned linked memory; release it with `destroyLinkedMultiPolygon`.

Buffer-taking helpers preserve H3's public C conventions. Some H3 APIs fill pre-sized arrays that may contain `h3.h3Null`; use `countNonNull` if you need the populated count.

## Upstream Snapshot

- H3 version: `v4.5.0`
- Upstream commit: `1b536c34225191ba24a75a840f634d4a48c3b206`
- Upstream license: Apache-2.0

Vendored source lives under `vendor/h3/`. `vendor/h3/src/h3lib/include/h3api.h` is generated from upstream `h3api.h.in` with version values substituted.
