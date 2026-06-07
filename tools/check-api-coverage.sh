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

comm -23 "$tmp_dir/c-api.txt" "$tmp_dir/zig-api.txt" > "$tmp_dir/missing-wrappers.txt"

if [ -s "$tmp_dir/missing-wrappers.txt" ]; then
  echo "Missing safe Zig wrappers for public H3 API functions:" >&2
  cat "$tmp_dir/missing-wrappers.txt" >&2
  exit 1
fi

: > "$tmp_dir/missing-c-delegation.txt"

while IFS= read -r name; do
  body="$tmp_dir/wrapper-$name.zig"
  awk -v fn="$name" '
    function count_char(s, ch,    i, n) {
      n = 0
      for (i = 1; i <= length(s); i++) {
        if (substr(s, i, 1) == ch) n++
      }
      return n
    }

    $0 ~ "^pub fn " fn "\\(" {
      in_fn = 1
    }

    in_fn {
      print
      opens = count_char($0, "{")
      depth += opens - count_char($0, "}")
      if (opens > 0 && depth == 0) exit
    }
  ' src/root.zig > "$body"

  if ! grep -Eq "c\\.${name}([^A-Za-z0-9_]|$)" "$body"; then
    echo "$name" >> "$tmp_dir/missing-c-delegation.txt"
  fi
done < "$tmp_dir/c-api.txt"

if [ -s "$tmp_dir/missing-c-delegation.txt" ]; then
  echo "Safe Zig wrappers that do not reference the matching raw C function:" >&2
  cat "$tmp_dir/missing-c-delegation.txt" >&2
  exit 1
fi

if [ ! -f docs/public-api-matrix.md ]; then
  echo "Missing docs/public-api-matrix.md." >&2
  exit 1
fi

: > "$tmp_dir/missing-doc-rows.txt"

while IFS= read -r name; do
  if ! grep -Fq "| \`$name\` | \`h3.$name\` |" docs/public-api-matrix.md; then
    echo "$name" >> "$tmp_dir/missing-doc-rows.txt"
  fi
done < "$tmp_dir/c-api.txt"

if [ -s "$tmp_dir/missing-doc-rows.txt" ]; then
  echo "Public H3 API functions missing from docs/public-api-matrix.md:" >&2
  cat "$tmp_dir/missing-doc-rows.txt" >&2
  exit 1
fi

echo "All public H3 API functions have safe Zig wrapper names, matching raw C references, and public API matrix rows."
echo "Note: this is a static guardrail; ownership, buffer, and edge-case semantics are verified by tests and audit."
