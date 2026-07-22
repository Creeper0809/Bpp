# Windows Support Guide

## Supported scope

Bpp supports a hosted x86-64 Windows pipeline:

- Win64 code generation and the Microsoft x64 ABI
- Windows runtime primitives backed by `kernel32.dll`
- NASM `win64` assembly and `link.exe` or `lld-link`
- Native Stage 0/1/2 self-hosting with a Stage 1 == Stage 2 check
- Runtime and compile-fail tests through PowerShell

`-llvm-build` is not yet available from a Windows-hosted compiler. The native
assembly backend is the supported Windows backend.

## Requirements

- 64-bit Windows 10 or newer
- CMake 3.22 or newer
- Visual Studio Build Tools with the x64 C++ toolchain, or LLVM `lld-link`
- PowerShell 5.1 or newer

NASM can be downloaded automatically by CMake, so it does not need to be
installed globally.

## Configure the toolchain

Run these commands from an x64 Native Tools command prompt:

```powershell
cmake -S . -B build-win -DBPP_BOOTSTRAP_NASM=ON
cmake --build build-win --target toolchain-check windows-smoke --config Release
cmake --build build-win --target bpp-selfhost --config Release
```

CMake writes the resolved paths to `build-win/bpp_toolchain.env`. On Windows,
bootstrap discovery accepts PE executables only; checked-in Linux ELF stage
binaries are ignored.

Use `bpp-selfhost-fast` to perform Stage 0/1/2 equality without the test suite.

## Build and test the compiler

If a matching bootstrap release exists, CMake and `build_and_test.ps1` can use
it automatically. You can also pass a PE seed explicitly:

```powershell
./build_and_test.ps1 `
  -CompilerPath C:\path\to\bpp-bootstrap-v13-windows-x86_64.exe `
  -NasmPath C:\path\to\nasm.exe `
  -LinkerPath C:\path\to\link.exe
```

The script builds Stage 0, Stage 1, and Stage 2, links reproducible PE files,
requires Stage 1 and Stage 2 hashes to match, and then runs the Windows test
suite. Compiler processes and generated test programs run in Windows Job
Objects with a 4 GiB per-process memory limit.

If local execution policy blocks project scripts, use a process-scoped bypass:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_and_test.ps1
```

This does not change the machine-wide execution policy.

To run a focused test subset:

```powershell
./test/run_tests.ps1 `
  -CompilerPath .\bin\v13_stage1.exe `
  -NasmPath C:\path\to\nasm.exe `
  -LinkerPath C:\path\to\link.exe `
  -NameFilter '18_target_windows|01_generics'
```

The native runner follows the Linux assembly-test matrix by default
(`nossa,ssa` and `O0,O1`) and narrows it with each fixture's `// Mode:` and
`// Opt:` directives. Override the global matrix with `-ModeFilter`,
`-OptFilter`, or the matching `TEST_MODE_FILTER`/`TEST_OPT_FILTER`
environment variables. LLVM-only fixtures are reported as skipped because
hosted `-llvm-build` is not available on Windows.

## Bootstrap release flow

The first Windows seed is produced on Linux by
`tools/build_windows_bootstrap.sh`. It runs the verified Linux compiler under
the 4 GiB limit, emits Win64 assembly, and links a PE seed with MinGW
cross-binutils. GitHub Actions transfers that seed to a Windows runner, where
the normal Stage 0/1/2 self-host and test pipeline validates it before release.

Windows users do not need WSL or MinGW; those tools are only used by the release
workflow to break the initial bootstrap cycle.

## Tool installation

Visual Studio Build Tools:

https://aka.ms/vs/17/release/vs_BuildTools.exe

LLVM releases (`lld-link`):

https://releases.llvm.org/

NASM releases:

https://www.nasm.us/pub/nasm/releasebuilds/
