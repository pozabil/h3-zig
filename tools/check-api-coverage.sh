#!/usr/bin/env bash
set -euo pipefail

tmp_dir="${TMPDIR:-/tmp}/h3-zig-api-coverage.$$"
mkdir -p "$tmp_dir"
trap 'rm -rf "$tmp_dir"' EXIT

grep -Eo 'H3_EXPORT\([A-Za-z0-9_]+\)' vendor/h3/src/h3lib/include/h3api.h \
  | sed 's/H3_EXPORT(//; s/)//' \
  | grep -v '^name$' \
  | sort -u > "$tmp_dir/c-api.txt"

grep -Eo 'pub fn [A-Za-z0-9_]+' src/root.zig \
  | sed 's/pub fn //' \
  | sort -u > "$tmp_dir/zig-api.txt"

if ! comm -23 "$tmp_dir/c-api.txt" "$tmp_dir/zig-api.txt" > "$tmp_dir/missing.txt"; then
  exit 1
fi

if [ -s "$tmp_dir/missing.txt" ]; then
  echo "Missing safe Zig wrappers for public H3 API functions:" >&2
  cat "$tmp_dir/missing.txt" >&2
  exit 1
fi

echo "All public H3 API functions have safe Zig wrapper names."
