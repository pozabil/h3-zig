# h3-zig

[![CI](https://github.com/pozabil/h3-zig/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/pozabil/h3-zig/actions/workflows/ci.yml)
![Zig](https://img.shields.io/badge/Zig-0.15.2%20%7C%200.16.0-f7a41d)
![H3](https://img.shields.io/badge/H3-v4.5.0-0f766e)
![Package](https://img.shields.io/badge/package-0.1.0-blue)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

Zig bindings for [H3 v4.5.0](https://github.com/uber/h3/tree/v4.5.0), Uber's Hexagonal Hierarchical Geospatial Indexing System.

H3 indexes geographies into a hierarchical hexagonal grid. This package vendors the upstream H3 C library and compiles it through Zig, so consumers do not need a system `h3` install. The public surface has two layers:

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

The tests are derived from upstream public H3 examples, CLI fixtures, and test fixtures. They exercise indexing, string conversion, boundaries, grid traversal, hierarchy, compaction, directed edges, vertexes, polygons, local IJ, metrics, linked polygons, raw C access, error mapping, 55,000 upstream random center fixture rows, selected base-cell center rows, and an upstream boundary fixture sample.

`zig build test-valgrind` runs the same unit and public-contract test executables under Valgrind on Linux systems with Valgrind installed. In CI, this gate pins `x86_64-linux-gnu` with `baseline` CPU features so the result does not depend on the specific hosted runner CPU.

GitHub Actions runs native tests on Linux x64, Linux arm64, Windows x64, macOS Intel, and macOS arm64 in both Debug and ReleaseSafe modes for Zig `0.15.2` and Zig `0.16.0`. It also runs a Linux Valgrind memory gate and cross-compiles library artifacts for Linux and Windows x64/arm64 targets on both Zig versions. The supported native runtime matrix and build-only cross-compile matrix have passed the GitHub-hosted `CI` workflow.

## Reference Docs

- [Public API Matrix](docs/public-api-matrix.md): C functions mapped to Zig wrappers.
- [Upstream Test Coverage](docs/upstream-test-coverage.md): upstream test and fixture parity.
- [Support Policy](docs/support-policy.md): supported Zig versions, platforms, and release requirements.
- [Safe Wrapper Audit](docs/safe-wrapper-audit.md): ownership, buffer, and error semantics.

## Ownership

Allocator-returning helpers allocate Zig-owned slices that callers must free. `cellsToLinkedMultiPolygon` returns C-owned linked memory; release it with `destroyLinkedMultiPolygon`.

Buffer-taking helpers preserve H3's public C conventions. Some H3 APIs fill pre-sized arrays that may contain `h3.h3Null`; use `countNonNull` if you need the populated count.

## Upstream Snapshot

- H3 version: [`v4.5.0`](https://github.com/uber/h3/tree/v4.5.0)
- Upstream commit: `1b536c34225191ba24a75a840f634d4a48c3b206`
- Upstream license: Apache-2.0

Vendored source lives under `vendor/h3/`. `vendor/h3/src/h3lib/include/h3api.h` is generated from upstream `h3api.h.in` with version values substituted.
