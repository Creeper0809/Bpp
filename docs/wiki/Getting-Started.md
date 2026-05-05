# Getting Started

이 페이지는 Bpp를 가장 빠르게 빌드하고 실행하는 절차를 설명합니다.

## 1. 요구 사항

- Linux 또는 Windows 개발 환경
- NASM
- 링커(`ld` 또는 `link.exe`)
- CMake(프로젝트 빌드/도구체인 점검용)

## 2. 저장소 준비

```bash
git clone <repo-url>
cd Bpp
```

## 3. 기본 빌드/테스트

```bash
cmake -S . -B build-linux
cmake --build build-linux --target bpp-selfhost-fast
```

빠른 검증만 할 때:

```bash
TEST_PROFILE=quick TEST_QUIET=1 TEST_FAST_IO=1 TEST_JOBS=4 bash build_and_test.sh
```

풀 self-host + 전체 테스트:

```bash
cmake --build build-linux --target bpp-selfhost
```

## 4. 첫 컴파일

```bash
bpp your_file.bpp
```

또는 현재 stage 바이너리를 직접 사용할 경우:

```bash
./bin/stage1 your_file.bpp
```

## 5. 흔한 이슈

- `nasm not found`: NASM 설치 및 PATH 확인
- 링커 오류: 플랫폼에 맞는 링커 경로 설정 확인
- 권한 오류: 실행 파일 권한(`chmod +x`) 점검
- bootstrap compiler가 없으면 CMake가 GitHub release asset(`bootstrap-<version>`)을 다운로드합니다
- 저장소가 여러 stage 바이너리를 가지고 있으면 `bin/stage1`이 최신 성공 stage1
  alias로 쓰입니다.

## 6. 자주 쓰는 개발 명령

특정 테스트만 볼 때:

```bash
TEST_NAME_FILTER='43_language_feature_runtime_bundle_success' TEST_JOBS=1 bash test/run_tests.sh ./bin/stage1
```

LLVM build 경로가 붙은 fixture를 볼 때:

```bash
TEST_NAME_FILTER='45_llvm_build_runtime_fixture_bundle_success' TEST_JOBS=1 bash test/run_tests.sh ./bin/stage1
```

전체 self-host 검증은 Stage 0/1/2를 만들고 Stage 1과 Stage 2 assembly가 같은지
확인합니다.

```bash
nice -n 19 TEST_JOBS=1 bash build_and_test.sh
```

## 다음 읽을 문서

- 언어 범위: [Language Scope](Language-Scope)
- 런타임/LLVM 번들: [Runtime and LLVM Bundles](Runtime-and-LLVM-Bundles)
- 내부 동작: [Compiler Internals](Compiler-Internals)
