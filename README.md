# h3-zig

Zig 0.15.2 bindings for Uber H3 v4.5.0.

The package vendors the upstream H3 C library and compiles it through Zig, so consumers do not need a system `h3` install. The public surface has two layers:

- `h3.raw` / `h3.c`: direct `@cImport("h3api.h")` access to the complete public C API.
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
zig build test
```

The tests are derived from upstream public H3 examples and test fixtures. They exercise indexing, string conversion, boundaries, grid traversal, hierarchy, compaction, directed edges, vertexes, polygons, local IJ, metrics, linked polygons, and raw C access.

## Ownership

Allocator-returning helpers allocate Zig-owned slices that callers must free. `cellsToLinkedMultiPolygon` returns C-owned linked memory; release it with `destroyLinkedMultiPolygon`.

Buffer-taking helpers preserve H3's public C conventions. Some H3 APIs fill pre-sized arrays that may contain `h3.h3Null`; use `countNonNull` if you need the populated count.

## Upstream Snapshot

- H3 version: `v4.5.0`
- Upstream commit: `1b536c34225191ba24a75a840f634d4a48c3b206`
- Upstream license: Apache-2.0

Vendored source lives under `vendor/h3/`. `vendor/h3/src/h3lib/include/h3api.h` is generated from upstream `h3api.h.in` with version values substituted.
