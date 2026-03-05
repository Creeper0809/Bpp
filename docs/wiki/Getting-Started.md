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
build_and_test.sh
```

빠른 검증만 할 때:

```bash
TEST_PROFILE=quick TEST_QUIET=1 TEST_FAST_IO=1 TEST_JOBS=4 build_and_test.sh
```

## 4. 첫 컴파일

```bash
bpp your_file.bpp
```

또는 v11 바이너리를 직접 사용할 경우:

```bash
./bin/v11_stage1 your_file.bpp
```

## 5. 흔한 이슈

- `nasm not found`: NASM 설치 및 PATH 확인
- 링커 오류: 플랫폼에 맞는 링커 경로 설정 확인
- 권한 오류: 실행 파일 권한(`chmod +x`) 점검

## 다음 읽을 문서

- 언어 문법: [Language Reference](Language-Reference)
- 내부 동작: [Compiler Internals](Compiler-Internals)
