# Windows Support Guide

## Current Scope (v10)

Windows support is split into two layers:

1. Toolchain layer (available now)
- NASM availability (auto-bootstrap through CMake)
- Linker detection (`link.exe` or `lld-link`)
- Executable smoke test in CI on `windows-latest`

2. Full hosted compiler/runtime layer (in progress)
- A Windows-hosted stage compiler binary (`bin/v10_stage1.exe`)
- Full runtime parity with Linux for process/file/memory primitives

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
.\v10\build_and_test.ps1
```

or directly:

```powershell
.\v10\test\run_tests.ps1 -CompilerPath .\bin\v10_stage1.exe
```

If `bin/v10_stage1.exe` is missing, the script exits with an explicit bootstrap requirement message.
