# Testing and CI

이 페이지는 Bpp 테스트 구조와 CI 검증 흐름을 설명합니다.

## 1. 테스트 철학

- 성공 케이스: 실제 실행 결과까지 검증
- 실패 케이스: 컴파일 실패 + 오류 메시지까지 검증
- 회귀 방지: 신규 기능은 반드시 테스트 동반

## 2. 테스트 실행

전체:

```bash
bash test/run_tests.sh
```

빠른 프로필:

```bash
TEST_PROFILE=quick TEST_FAST_IO=1 TEST_JOBS=4 bash test/run_tests.sh
```

특정 파일만:

```bash
TEST_NAME_FILTER='43_language_feature_runtime_bundle_success' TEST_JOBS=1 bash test/run_tests.sh ./bin/stage1
```

## 3. 테스트 파일 구성

- `test/source/*.bpp`
- `test/source_fail/*.bpp`
- suite 파일은 `//=== CASE ...` 기준으로 케이스를 분리
- 성공/실패 케이스를 카테고리별로 묶어 관리

자주 쓰는 directive:

- `// Mode: ssa|nossa`: SSA와 기존 backend를 모두 검증
- `// Opt: O0|O1`: 최적화 단계별 실행
- `// LLVM Build: true`: LLVM-like IR을 build/run 가능한 경로까지 검증
- `// Stdin: ...`: 실행 입력 지정
- `// Expect stdout: ...`: 표준 출력 검증
- `// Expect exit code: 0`: 종료 코드 검증
- `// Expect llvm metadata contains: ...`: lowering/LLVM metadata 보존 검증

대표 번들은 기능별 작은 테스트를 한 번 더 묶어 end-to-end 의미를 고정합니다.
현재 위키 기준 번들은 [Runtime and LLVM Bundles](Runtime-and-LLVM-Bundles)에
정리되어 있습니다.

## 4. CI 기본 검증 항목

- 빌드 성공
- self-hosting 일치 검증
- 테스트 스위트 통과
- 플랫폼별(특히 Linux/Windows) 동작 확인
- LLVM build fixture 통과
- metadata preservation marker 통과

## 5. 실패 분석 원칙

- 테스트를 바꿔 숨기지 않기
- 원인 컴파일러 코드를 직접 수정
- 오류 메시지 품질(정확성/가독성)도 함께 개선
- LLVM metadata expectation이 깨지면 기능이 "실행은 되지만 계약/최적화 표면을
  잃은" 상태일 수 있으므로, 단순 문자열 수정 전에 lowering 원인을 먼저 확인
