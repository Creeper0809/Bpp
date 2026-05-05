# Compiler Internals

이 페이지는 현재 Bpp 컴파일러 파이프라인과 주요 패스를 설명합니다.

## 1. 큰 흐름

1. Lexer: 토큰화
2. Parser: AST 생성
3. Lowering Passes: 문법 설탕 제거/정규화
4. Semantic Passes: override/trait/entry/annotation 검증 및 적용
5. Monomorphization: 제네릭 실체화
6. SSA Pipeline: CFG/SSA 생성, O1 최적화, contract preservation 검사
7. Codegen: ASM 생성 또는 LLVM-like IR skeleton emission
8. Optional LLVM Build: emitted `.ll`을 clang으로 build/run

## 2. 주요 컴포넌트

- `src/compiler.bpp`: 컴파일러 컨텍스트, 패스, 의미 분석
- `src/parser/*`: 파서 구현
- `src/emitter/*`: 기존 ASM 코드 생성과 타입/ABI 보조
- `src/ssa/*`: SSA/IR 경로
- `src/llvm/*`: LLVM contract/SSA lowering prototype과 text emitter
- `src/compiler/annotations.bpp`: annotation, decorator, complexity, contract family,
  LLVM handoff metadata의 중심 구현
- `src/std/*`: compiler-known prelude와 런타임 helper가 만나는 표준 라이브러리

## 3. 최근 핵심 변화

- 전역 상태를 `CompilerCtx`로 집중 관리
- 어노테이션을 의미 단계에서 해석/적용
- `@[entry]` 기반 엔트리 함수 선택
- 데코레이터 어노테이션을 래퍼 함수로 lowering
- complexity/symbolic annotation을 SSA summary와 다시 비교하는 preservation pass
- contract family를 `condition/effects/ownership/memory/concurrency/ABI/execution`으로
  분류하고 LLVM-facing metadata atom으로 전달
- tagged pointer/slice metadata를 SSA/LLVM prototype에서 fast path와 vector lowering
  후보로 소비
- `new`의 일부 no-escape 경로를 stack slot으로 낮추고, tagged pointer policy와
  SROA metadata를 함께 남김
- LLVM build subset에서 call/branch/loop/phi/struct/slice/string/global/contract
  fixture를 실제 build/run

## 4. 패스 설계 원칙

- 파싱 단계: 문법 인식 + AST 보존
- 컴파일 단계: 의미 검증 + 변환
- 코드젠 단계: 타깃 코드 출력
- 테스트 단계: 성공/실패 케이스 모두 고정
- metadata 단계: 최적화나 backend 전환 중 사라지면 안 되는 feature marker를
  `Expect llvm metadata contains`로 고정

## 5. 디버깅 팁

- 특정 패스 전후 AST/시그니처 변화를 확인
- 실패 메시지의 "어떤 패스에서 실패했는지"를 우선 추적
- quick profile 테스트로 재현 시간을 단축
- LLVM 경로 문제는 먼저 `-dump-llvm-ll`, `-dump-llvm-contract`,
  `-dump-llvm-proto` 같은 dump surface로 handoff metadata가 남아 있는지 확인
- stack-new 문제는 escape 판단, constructor/destructor 순서, tagged storage/ownership
  관측값을 함께 봐야 합니다.
