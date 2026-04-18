# Windows Support Guide

## Current Scope (v11)

Windows support is split into two layers:

1. Toolchain layer (available now)
- NASM availability (auto-bootstrap through CMake)
- Linker detection (`link.exe` or `lld-link`)
- Executable smoke test in CI on `windows-latest`

2. Full hosted compiler/runtime layer (in progress)
- A Windows-hosted stage compiler binary (`bin/v11_stage1.exe`)
- Target-aware std runtime selection for `std.os`
- Windows entry/link/test-runner plumbing (`mainCRTStartup`, `link.exe`/`lld-link`)
- File/process/heap primitives needed by the hosted compiler are being rebuilt

## Quick Start

```powershell
cmake -S . -B build-win -DBPP_BOOTSTRAP_NASM=ON
cmake --build build-win --target toolchain-check windows-smoke
```

CMake writes resolved tool paths to:
- `build-win/bpp_toolchain.env`

## Required Tools

### NASM
- Auto-download is supported on Windows via:
  - `-DBPP_BOOTSTRAP_NASM=ON`
- Manual install reference:
  - https://www.nasm.us/pub/nasm/releasebuilds/

### Linker
One of these must exist:
- `link.exe` (recommended)
- `lld-link`

Install sources:
- Visual Studio Build Tools (`link.exe`):
  - https://aka.ms/vs/17/release/vs_BuildTools.exe
- LLVM (`lld-link`):
  - https://releases.llvm.org/

## Windows Hosted Test Runner

When a Windows compiler binary is available:

```powershell
.\build_and_test.ps1
```

or directly:

```powershell
.\test\run_tests.ps1 -CompilerPath .\bin\v11_stage1.exe
```

`build_and_test.ps1` now uses the seed compiler to build `bin\<version>_stage0.exe`
and `bin\<version>_stage1.exe` before running the Windows test suite.

The PowerShell runner invokes the compiler with `--target windows-x86_64` so the
Windows entry/runtime path is used consistently.

If `bin/v11_stage1.exe` is missing, the script exits with an explicit bootstrap requirement message.

The PowerShell runner also supports downloading a release bootstrap asset named
`bpp-bootstrap-<version>-windows-x86_64.exe` from the `bootstrap-<version>` release tag.
This asset currently acts as a seed binary until full Windows self-host builds are implemented.
