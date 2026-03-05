## Bpp

"HTML을 프로그래밍 언어라고 인정할 수 없다."

## Platform Support

- ✅ **Linux** (x86-64, fully supported)
- 🚧 **Windows** (x86-64, hosted pipeline in progress)
  - CMake toolchain bootstrap (`nasm`) ✅
  - Linker detection with install guidance (`link.exe` / `lld-link`) ✅
  - Windows runner scripts and CI smoke execution ✅
  - Full self-host/runtime parity with Linux ⏳

## Why?

<<<<<<< HEAD
=======
이 세상에는 없어져야 더 행복해질 수 있는 것들이 잔뜩있습니다.

- C언어의 레지스터 숨김

- 클로버 리스트

- 그리고... 시험 문제에 bpp 대신 html을 언어라고 적어야하는 상황

그것들을 bpp의 힘으로 모두 없앨겁니다.

## Core Philosophy: High-Level Assembly

Basm의 철학은 단순합니다.

- High-Level Assembly: 어셈블리어의 제어권 + C언어의 가독성.

- Explicit Registers: rax, r8 등을 직접 제어한다.

## Syntax Preview

Traditional C + Inline Assembly (Painful):
```C

// GCC Style....
int val = 10;
__asm__ volatile (
    "movl %1, %%eax \n\t"
    "addl $1, %%eax \n\t"
    : "=a"(val) : "r"(val)
);
```

Basm (EZ & Clean):
```C

// Just do it. (Stage1 현재 구현 기준)
// - 레지스터는 64-bit 이름(rax..r15)만 레지스터로 인식합니다.
// - 비교 연산자는 if 조건에서만 허용됩니다.

rax = 10;
rax += 1;

// 메모리 접근은 ptr8/ptr64를 통해서만 합니다.
// (예: ptr64[var] = rax;  rdi = ptr64[var];)

if (rax > 5) {
        // 함수 호출은 ident(args...);
        // (내장 런타임 예: print_str, print_dec)
        print_str("ok\n");
}
```

## 문법 기준

현재 구현 기준 문법/제약은 `src/` 파서 구현과 `test/source` 케이스를 기준으로 관리합니다.

## Roadmap


>>>>>>> origin/main
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
<<<<<<< HEAD
=======
```bash
# Install dependencies
sudo apt-get install nasm binutils

# Build + self-host + tests
bash build_and_test.sh
```

### Linux (CMake install + bpp command)
>>>>>>> origin/main
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

<<<<<<< HEAD
### Windows
=======
### Package Manifest (`bpp.toml`)
`bpp` now supports a simple project manifest discovered from the source directory upward:

```toml
version=v11
module_root=src
std_root=/abs/path/to/Bpp/src
nasm_path=/usr/bin/nasm
ld_path=/usr/bin/ld
```

- `module_root`: package import root (for non-std modules)
- `std_root`: std library root that contains `std/*.bpp`
- `nasm_path`, `ld_path`: optional tool overrides for default compile+run mode
- `version`: used when deriving defaults

### Windows (toolchain + smoke)
>>>>>>> origin/main
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
