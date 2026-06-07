# Support Policy

This package vendors upstream H3 `v4.5.0`. Zig support follows the CI matrix below.

## Support Rule

A Zig version or platform is considered supported only after the GitHub Actions `CI` workflow passes for that version and platform on the relevant branch. Local cross-compilation is useful evidence, but it is not a substitute for a green hosted runner when runtime behavior is claimed.

Current status: the GitHub-hosted `CI` workflow is configured to run the full gate set for Zig `0.15.2` and Zig `0.16.0`. Treat both versions as supported on a branch only after that branch has a green hosted `CI` run with the two-version matrix.

## Supported Zig Versions

| Zig version | CI coverage | Status rule |
|---|---|---|
| `0.15.2` | Formatting, API coverage, native tests, consumer tests, Valgrind, and cross-compile smoke jobs. | Supported after hosted `CI` is green for the branch. |
| `0.16.0` | Formatting, API coverage, native tests, consumer tests, Valgrind, and cross-compile smoke jobs. | Supported after hosted `CI` is green for the branch. |

`build.zig.zon` keeps `.minimum_zig_version = "0.15.2"` because this code line is intended to remain compatible with Zig `0.15.2` while also being tested on Zig `0.16.0`.

## Supported Native Runtime Matrix

These targets are configured to run `zig build test`, the consumer integration test, formatting, API coverage, and the library build in GitHub Actions:

| Platform | Runner | Status |
|---|---|---|
| Linux x64 | `ubuntu-24.04` | Supported |
| Linux arm64 | `ubuntu-24.04-arm` | Supported |
| Windows x64 | `windows-2025` | Supported |
| macOS Intel | `macos-15-intel` | Supported |
| macOS arm64 | `macos-14` | Supported |

Native runtime jobs run both `Debug` and `ReleaseSafe` optimization modes.

## Verified Build-Only Matrix

These targets are configured as cross-compile smoke builds. They prove that the vendored C library and Zig module compile for the target, but they do not execute tests on that target:

| Target | Status |
|---|---|
| `x86_64-linux-musl` | Build-only verified |
| `aarch64-linux-musl` | Build-only verified |
| `x86_64-windows-gnu` | Build-only verified |
| `aarch64-windows-gnu` | Build-only verified |

## Not Currently Supported

The package does not currently claim support for:

- Zig versions other than those listed in Supported Zig Versions.
- WASI/WebAssembly.
- Android, iOS, tvOS, watchOS, or embedded targets.
- BSD and other Unix targets not listed above.
- Dynamically linking against a system H3 installation instead of the vendored source.

## Release Requirements

Before a release is labeled production-ready:

- GitHub Actions must pass for every supported native runtime platform.
- Cross-compile smoke jobs must pass for every build-only target.
- Hosted macOS jobs must complete within the configured workflow timeouts; queued or hung runner jobs are not treated as a supported-platform signal.
- The consumer integration test must pass.
- Public H3 API coverage must be complete.
- Safe wrapper ownership, buffer, and error semantics must have a current audit document.
- Memory checking must pass for covered safe-wrapper paths through the Linux Valgrind CI gate, pinned to baseline CPU features, or an explicitly recorded equivalent platform memory checker.
- Any unported or partially covered upstream public tests and fixtures must be documented in `docs/upstream-test-coverage.md` as residual risk or explicitly scoped out.
