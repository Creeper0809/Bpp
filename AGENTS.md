# AGENTS.md

이 문서는 Bpp self-hosting compiler 저장소에서 작업하는 에이전트가 따라야 할 개발 지침이다.
온라인 컴파일러 웹사이트, Notion, REST API 기획 문서 규칙은 이 저장소의 기본 작업 범위가 아니다.

## 0) 작업 범위

- Bpp 언어, 파서, AST lowering, typeinfo, emitter, SSA, std library, runtime API, test runner, self-hosting 흐름을 대상으로 한다.
- 문서나 주석을 수정할 때도 실제 컴파일러 동작과 테스트 방법을 기준으로 작성한다.
- 웹 서비스, API 서버, 제품 기획, Notion 문서 관리 규칙은 사용자가 명시적으로 요청한 경우에만 다룬다.

## 1) 기본 작업 원칙

- 저장소 루트에서 작업한다.
- 편집 전 `git status --short`로 현재 변경 사항을 확인한다.
- 사용자가 만든 변경이나 관련 없는 dirty file을 되돌리지 않는다.
- 검색은 우선 `rg`, 파일 목록은 `rg --files`를 사용한다.
- 수동 편집은 `apply_patch`로 수행한다.
- 패치 전후로 주변 코드를 읽어 기존 스타일과 모듈 경계를 따른다.
- 동작 변경은 가능한 한 `test/source`에 focused regression test를 추가하거나 갱신한다.
- 컴파일러 작업의 완료 조건은 항상 4GiB 제한 안에서 `build_and_test.sh`가 통과하고 회귀가 없음을 확인하는 것이다.
- 우회 금지, 근본적인 원인 해결하기. 컴파일러 해석 방법이 바뀌었다면 버전을 업데이트하기.

## 1.1) 빌드 산출물 용량 관리

- `build`, `build-*`, 테스트 결과, 벤치마크 출력, 컴파일 캐시, 임시 어셈블리·오브젝트·실행 파일처럼 재생성 가능한 산출물의 합계를 작업 전후에 확인한다.
- 위 산출물의 합계가 10GiB(10,737,418,240 bytes)를 초과하면 다음 작업을 진행하거나 최종 결과를 전달하기 전에 반드시 정리한다.
- 정리 전에는 저장소 루트와 대상의 절대 경로를 확인하고, 실행 중인 빌드·테스트 프로세스가 없는지 확인한다. 저장소 전체를 대상으로 하는 재귀 삭제나 범위가 불명확한 글롭 삭제는 금지한다.
- 소스 코드, 테스트 입력, 문서, Git 데이터, 미커밋 변경, 사용자가 만든 미추적 파일, 부트스트랩에 필요한 `bin` 바이너리는 자동 정리 대상에서 제외한다.
- `.planning`에서는 계획 문서, 재현용 소스·스크립트와 필요한 측정 근거를 보존하고, 다시 만들 수 있는 `.asm`, `.obj`, `.exe`, 캐시와 대형 실행 결과만 선별해 정리한다.
- 정리 후에는 남은 산출물 용량, 삭제한 범위, 확보한 용량과 복구 가능 여부를 사용자에게 알린다.

## 2) 메모리 제한 필수

컴파일러, 생성된 컴파일러, 테스트 바이너리, self-hosting 스크립트, `build_and_test.sh`, `test/run_tests.sh` 등 Bpp 코드를 실행하는 모든 과정은 4GiB 메모리 제한을 걸고 실행한다.

- 표준 제한값: `4194304` KiB = 4GiB
- Linux에서는 `ulimit -v`로 address space를 제한한다.
- 제한은 서브셸에만 적용되도록 `bash -lc` 안에서 설정한다.
- `build_and_test.sh`를 직접 실행하지 않는다. 반드시 아래 wrapper 형태를 사용한다.

단일 명령 실행:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; exec "$@"' _ <command> <args...>
```

리다이렉션, 파이프, 여러 단계가 필요한 실행:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; <commands>'
```

`ulimit` 사용이 어렵거나 별도 프로세스에 직접 제한을 걸어야 할 때는 `prlimit`를 사용할 수 있다.

```bash
prlimit --as=4294967296 -- <command> <args...>
```

## 3) 빌드와 테스트

회귀 방지는 최우선 조건이다. Bpp 컴파일러, 표준 라이브러리, 테스트 러너, 빌드 스크립트, 문서화된 개발 흐름을 바꾸는 작업은 최종적으로 4GiB 메모리 제한 안에서 `build_and_test.sh` 전체 검증을 통과해야 한다. 부분 테스트나 임시 Stage0 테스트는 디버깅 보조 수단일 뿐이며, 전체 검증을 대체하지 않는다.

현재 소스에서 임시 Stage0 컴파일러를 만들 때:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; ./build/v12.out -asm src/main.bpp > /tmp/bpp_stage0.asm'
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; nasm -felf64 -O1 /tmp/bpp_stage0.asm -o /tmp/bpp_stage0.o'
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; ld /tmp/bpp_stage0.o -o /tmp/bpp_stage0'
```

특정 테스트만 실행할 때:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; env TEST_NAME_FILTER="79_string_type_success" TEST_JOBS=1 bash test/run_tests.sh /tmp/bpp_stage0'
```

전체 검증을 실행할 때:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; nice -n 19 env TEST_JOBS=1 bash build_and_test.sh'
```

정상적인 전체 검증은 Stage 0, Stage 1, Stage 2를 완료하고 `Self-Hosting Success! (Stage 1 == Stage 2)`를 출력하며 테스트를 통과해야 한다.
이 조건을 만족하지 못하면 작업이 끝난 것이 아니다.

## 4) 주요 코드 지도

- `src/main.bpp`: CLI entry와 컴파일 진입점.
- `src/compiler.bpp`: compiler context, AST walking, pass plumbing.
- `src/compiler/loader.bpp`, `src/module_utils.bpp`, `src/compiler/symbol_runtime.bpp`: module loading, prelude, symbol, import, mangling.
- `src/parser/*`: token 이후 declaration, statement, expression, type syntax parsing.
- `src/compiler/ast_lowering.bpp`: `print`, `println`, `to_str`, typed `input()`, `number`, string literal lowering.
- `src/emitter/typeinfo.bpp`: 타입 추론, 타입 검사, 크기, 레이아웃, callable signature.
- `src/emitter/gen/expr.bpp`, `src/emitter/gen/stmt.bpp`: 현재 non-SSA codegen.
- `src/emitter/gen_expr.bpp`, `src/emitter/gen_stmt.bpp`: legacy mirror. 필요한 경우 현재 backend와 일관성을 유지한다.
- `src/ssa/*`: SSA builder와 SSA codegen.
- `src/std/*`: prelude와 standard library.
- `test/source`: 실행 테스트와 regression test.
- `test/source_fail`: 실패가 기대되는 테스트가 있을 때 사용하는 위치.

## 5) 테스트 작성 규칙

테스트 파일에는 필요한 directive를 명시한다.

```bpp
// Mode: ssa|nossa
// Opt: O0|O1
// Stdin: ...
// Expect stdout: ...
// Expect exit code: 0
```

- 버그 수정은 가능하면 재현 테스트를 먼저 두거나 같은 패치에 포함한다.
- 테스트 이름은 기능과 실패 조건이 드러나게 짓는다.
- 새 테스트를 추가할 때는 기존 `test/source`의 성향별 bundle/suite를 먼저 찾고, 비슷한 기능군이면 새 단독 파일보다 기존 묶음에 케이스로 추가한다.
- 디버깅 중에는 원인 축소를 위해 임시 단독 테스트 파일을 만들어도 되지만, 최종 패치에는 임시 파일을 남기지 않는다. 최종 회귀 테스트는 비슷한 성향의 기존 bundle/suite에 합치거나, 같은 성향 테스트가 여러 개 생긴 경우 새 bundle/suite로 정리한다.
- 테스트 파일 수를 불필요하게 늘리지 않는다. 컴파일 성공 runtime 테스트처럼 독립 파일일 필요가 없는 경우에는 `//=== CASE ...` suite나 명시적인 `*_bundle_success.bpp` 패턴을 사용한다.
- 기존 테스트는 테스트 자체가 명백히 잘못됐을 때만 수정한다.
- 구현을 통과시키기 위해 기대값을 약화하거나, 실패 테스트를 삭제하거나, 테스트를 건너뛰게 만들지 않는다.
- 테스트가 틀렸다고 판단하려면 언어 규칙, 기존 의도, 주변 테스트, 실제 컴파일러 동작 중 최소 하나 이상의 근거를 확인하고 수정 이유를 남긴다.
- Stage1 실패는 테스트 자체 문제가 아니라 생성된 컴파일러의 miscompile일 수 있으므로 Stage1/Stage2 차이를 의심한다.

## 6) 자주 깨지는 지점

- System V ABI의 stack argument와 alignment는 민감하다.
- 큰 struct는 hidden sret pointer 규칙을 일관되게 따라야 한다.
- slice 값은 `ptr`, `len` 두 word이며 call return은 `rax`, `rdx`를 사용한다.
- `string`은 lexer primitive가 아니라 `src/std/string.bpp`의 standard-library struct다.
- `number`는 standard `Number` type을 위한 builtin syntax이며 parser, typeinfo, lowering에 특수 처리가 있다.
- build script의 fallback 동작에 속지 말고 최종적으로는 실제 Stage1/Stage2 equality를 확인한다.
