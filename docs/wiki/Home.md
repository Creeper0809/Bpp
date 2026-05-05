# Bpp Wiki

이 위키는 현재 Bpp 구현을 기준으로 언어 표면, 런타임, 컴파일러 내부,
LLVM 전환 경계, 테스트 기준을 한 곳에서 읽을 수 있게 정리한 문서입니다.

## 빠른 길잡이

- 처음 빌드하고 실행하려면 [Getting Started](Getting-Started)를 먼저 봅니다.
- 언어가 어떤 방향으로 가는지 보려면 [Bpp Manifesto](Bpp-Manifesto)와
  [Language Scope](Language-Scope)를 봅니다.
- 문법과 기능별 사용법은 아래 "언어 기능" 섹션에서 필요한 페이지로 들어갑니다.
- 컴파일러/LLVM 작업자는 [Compiler Internals](Compiler-Internals),
  [LLVM Contract Boundary](LLVM-Contract-Boundary),
  [Runtime and LLVM Bundles](Runtime-and-LLVM-Bundles)를 같이 읽는 편이 좋습니다.

## 언어 기능

- [Functions and Calls](Functions-and-Calls): 함수, default/named/variadic 인자,
  함수 포인터, 람다 호출 규칙
- [Statements and Control Flow](Statements-and-Control-Flow): `if`, `while`, `for`,
  `do-while`, `match`, `try/catch/finally`, `defer`
- [Generics](Generics): generic 함수/구조체, const generic, 모노모피제이션
- [Object Construction](Object-Construction): `Type{}`, `Type()`, `new`, `delete`,
  constructor/destructor, stack-new lowering
- [Number](Number): compiler-known `number`, 큰 정수, 실수, 복소수, 정확 수 계층,
  비트 연산
- [Tagged Metadata](Tagged-Metadata): tagged pointer/slice, lifecycle/ownership/storage
  태그, fast path와 vector lowering
- [Compiler-Known Prelude](Compiler-Known-Prelude): `number`, `string`,
  `input<T>()`, `print`/`println`, `emit`/`emitln`
- [Annotations and Decorators](Annotations-and-Decorators): `@[entry]`,
  `@[override]`, decorator, contract-family annotation

## 계약과 검증

- [Contract Checklist](Contract-Checklist): property, decorator, complexity,
  prelude, LLVM handoff 계약의 구현/검증 상태
- [LLVM Contract Boundary](LLVM-Contract-Boundary): Bpp contract를 LLVM 전에
  어떻게 해석, 보존, metadata로 넘기는지
- [Diagnostics and Errors](Diagnostics-and-Errors): 오류 메시지와 phase tag 설계
- [Testing and CI](Testing-and-CI): 테스트 directive, bundle 구조, self-host 검증
- [Current Limitations](Current-Limitations): 현재 의도적으로 남아 있는 제약

## 현재 대표 회귀 번들

현재 위키의 구현 기준은 작고 흩어진 예전 테스트보다 아래 번들 테스트에 더
가깝습니다.

- `test/source/38_number_runtime_bundle_success.bpp`
- `test/source/39_tagged_metadata_runtime_bundle_success.bpp`
- `test/source/40_core_runtime_bundle_success.bpp`
- `test/source/41_struct_abi_runtime_bundle_success.bpp`
- `test/source/42_container_module_runtime_bundle_success.bpp`
- `test/source/43_language_feature_runtime_bundle_success.bpp`
- `test/source/44_number_bitwise_runtime_bundle_success.bpp`
- `test/source/45_llvm_build_runtime_fixture_bundle_success.bpp`
- `test/source/46_llvm_build_abi_only_bundle_success.bpp`
- `test/source/47_llvm_build_contract_main_bundle_success.bpp`

이 번들은 단순 예제가 아니라 "현재 언어가 실제로 유지해야 하는 동작 표면"입니다.
새 기능 문서를 업데이트할 때는 해당 기능이 어느 번들에 고정되어 있는지도 함께
갱신해야 합니다.
