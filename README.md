## Bpp

"HTML을 프로그래밍 언어라고 인정할 수 없다."

## Platform Support

- ✅ **Linux** (x86-64, fully supported)
- 🚧 **Windows** (x86-64, hosted pipeline in progress)
  - CMake toolchain bootstrap (`nasm`) ✅
  - Linker detection with install guidance (`link.exe` / `lld-link`) ✅
  - Windows runner scripts and CI smoke execution ✅
  - Full self-host/runtime parity with Linux ⏳

See [Windows Support Guide](docs/windows_support.md) for details.

## Why?

## File Structure

```text
Bpp/
├─ src/
│  ├─ parser/           # 파싱 단계
│  │  ├─ decl/          # 선언 파싱
│  │  ├─ expr/          # 표현식 파싱
│  │  └─ stmt/          # 문장/제어문 파싱
│  ├─ compiler/         # 의미 분석/변환/lowering
│  │  └─ generic/       # 제네릭 관련 보조 패스
│  ├─ emitter/          # 출력 생성기(백엔드)
│  │  └─ gen/           # emitter 세부 생성 루틴
│  ├─ ssa/              # SSA 관련 중간 표현/처리
│  └─ std/              # 표준 라이브러리(.bpp)
├─ test/                # 자동 테스트 스위트 및 수동 테스트
├─ docs/                # 문서 및 위키 원고
├─ bin/                 # stage 컴파일러 바이너리
├─ scripts/             # 보조 스크립트(배포/유틸)
├─ cmake/               # CMake 모듈/툴체인 보조 파일
├─ fuzz/                # 퍼징 관련 파일
├─ old/                 # 이전 버전 백업
├─ pages/               # 개발 로그 페이지
├─ build_and_test.sh    # Linux 빌드+테스트 진입점
├─ build_and_test.ps1   # Windows 빌드+테스트 진입점
└─ CMakeLists.txt       # 프로젝트 빌드 설정
```

## Build & Run

### Linux
```bash
# Build stage compiler first (required once)
bash build_and_test.sh

# Install bpp launcher + compiler + std library
cmake -S . -B build-linux
cmake --build build-linux --target toolchain-check
sudo cmake --install build-linux

# Use globally
bpp hello.bpp
```

### Windows
```powershell
# Configure (auto-download NASM when missing)
cmake -S . -B build-win -DBPP_BOOTSTRAP_NASM=ON

# Verify toolchain and run Windows executable smoke test
cmake --build build-win --target toolchain-check windows-smoke

# Optional: run hosted Windows test pipeline when a Windows stage compiler exists
.\build_and_test.ps1
```

If `link.exe` is missing, install Visual Studio Build Tools:
https://aka.ms/vs/17/release/vs_BuildTools.exe

### Tests
```bash
# Linux
bash test/run_tests.sh
bash test/run_regression.sh
```

```powershell
# Windows
.\test\run_tests.ps1 -CompilerPath .\bin\v11_stage1.exe
```
