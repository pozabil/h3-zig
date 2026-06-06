# Support Policy

This package targets Zig `0.15.2` and vendors upstream H3 `v4.5.0`.

## Support Rule

A platform is considered supported only after the GitHub Actions `CI` workflow passes for that platform on the default branch. Local cross-compilation is useful evidence, but it is not a substitute for a green hosted runner when runtime behavior is claimed.

## Candidate Native Runtime Matrix

These targets are configured to run `zig build test`, the consumer integration test, formatting, API coverage, and the library build in GitHub Actions:

| Platform | Runner | Status |
|---|---|---|
| Linux x64 | `ubuntu-24.04` | Candidate until first green CI run |
| Linux arm64 | `ubuntu-24.04-arm` | Candidate until first green CI run |
| Windows x64 | `windows-2025` | Candidate until first green CI run |
| macOS Intel | `macos-15-intel` | Candidate until first green CI run |
| macOS arm64 | `macos-14` | Candidate until first green CI run |

Native runtime jobs run both `Debug` and `ReleaseSafe` optimization modes.

## Candidate Build-Only Matrix

These targets are configured as cross-compile smoke builds. They prove that the vendored C library and Zig module compile for the target, but they do not execute tests on that target:

| Target | Status |
|---|---|
| `x86_64-linux-musl` | Build-only candidate until first green CI run |
| `aarch64-linux-musl` | Build-only candidate until first green CI run |
| `x86_64-windows-gnu` | Build-only candidate until first green CI run |
| `aarch64-windows-gnu` | Build-only candidate until first green CI run |

## Not Currently Supported

The package does not currently claim support for:

- Zig versions other than `0.15.2`.
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
- Memory checking must pass for covered safe-wrapper paths through the Linux Valgrind CI gate or an explicitly recorded equivalent platform memory checker.
- Any unported upstream public tests must be documented as residual risk or explicitly scoped out.
