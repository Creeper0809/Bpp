# Contract Checklist

이 문서는 Bpp의 "계약이 드러나는 시스템 언어" 철학이 현재 어디까지 구현되어 있는지 점검하기 위한 체크리스트입니다.

핵심 목적은 두 가지입니다.

- 문서상 철학과 실제 컴파일러 구현이 어디까지 일치하는지 확인
- 새 기능을 추가할 때 "이미 보장되는 계약"과 "아직 비어 있는 계약"을 구분

## How to Read This Page

각 영역은 다음 네 가지 관점으로 정리합니다.

- **Surface**: 사용자가 보는 문법
- **Implemented**: 현재 컴파일러가 실제로 해석/검사하는 규칙
- **Verified**: 테스트로 고정된 범위
- **Missing**: 아직 장식에 가깝거나, 추가 분석이 필요한 부분

## Recommended Strengthening Order

Bpp를 계약 중심 시스템 언어로 강화할 때는, 기능을 넓히는 것보다 아래 순서를 지키는 편이 훨씬 안전합니다.

1. **Contract model freeze**
   - 계약 종류를 먼저 고정합니다.
   - `property`, `decorator`, `metadata`, `complexity`, `compiler-known prelude`가 각각 무엇을 약속하는지 문서와 테스트로 먼저 확정합니다.
2. **Composition rules**
   - 계약이 함께 붙을 때의 우선순위와 충돌 규칙을 고정합니다.
   - 예: property + decorator, decorator + metadata, property + inheritance.
3. **Contract-oriented diagnostics**
   - 타입 오류나 이름 오류로만 말하지 말고, 어떤 계약이 깨졌는지를 우선 설명합니다.
4. **Preservation invariants**
   - lowering, SSA, codegen을 지나도 어떤 계약 의미가 반드시 남아 있어야 하는지 규정합니다.
5. **Surface expansion**
   - 위 네 단계가 갖춰진 뒤에만 새 annotation, 새 sugar, 새 contract surface를 넓힙니다.

이 순서를 거꾸로 가면, 문법은 늘어나지만 계약이 장식품처럼 남을 위험이 큽니다.

## Acceptance Gates

새 contract surface를 받아들이기 전에, 최소한 아래 다섯 질문에 답이 있어야 합니다.

1. 이 contract는 표면 문법에서 한눈에 읽히는가?
2. 이 contract는 어느 pass에서 실제로 검사되는가?
3. 이 contract가 lowering/SSA 이후에도 보존된다는 불변식이 있는가?
4. 이 contract 위반은 compile-fail test로 고정되어 있는가?
5. 이 contract를 AI와 사람이 모두 지역적으로 해석할 수 있는가?

하나라도 비어 있으면, surface 확장보다 contract definition과 diagnostics를 먼저 보강하는 편이 좋습니다.

## 1. Complexity and Symbolic Contract

### Surface

- `@[complexity(...)]`
- `@[complexity_budget(...)]`
- `@[complexity_input(...)]`
- `@[constraints(...)]`
- `@[time_limit(...)]`
- `@[complexity_debug(...)]`
- statement-level `@[complexity_ignore(...)]`
- `@[complexity_memo(...)]`
- symbolic aliases:
  `symbolic_expect`, `symbolic_assume`, `symbolic_input`, `symbolic_budget`,
  `symbolic_memo`, `symbolic_ignore`, `symbolic_debug`

### Implemented

- 함수 단위 complexity 선언과 budget 선언을 읽고 비교합니다.
- declared complexity가 inferred complexity를 과소평가하면 오류를 냅니다.
- time/space budget 위반을 오류로 냅니다.
- `mode` 불일치, unknown confidence, invalid input mapping, duplicate input key 같은 선언 자체 오류를 검사합니다.
- `@[complexity_ignore(...)]`는 statement-level skip contract로 동작합니다.
- std library summary를 읽는 strict mode가 있으며, `--strict-std-complexity-summary`로 더 엄격하게 검증할 수 있습니다.
- decorator/public surface에 남은 complexity-family annotation은 separate surface metadata로 보존됩니다.
- SSA/codegen 직전에는 final callable surface의 SSA summary를 다시 계산해 declared complexity/budget과 비교합니다.
- 이 재검증은 이제 `time`뿐 아니라 `space` rank도 함께 봅니다.
- SSA summary가 아예 만들어지지 않는 경우도 이제 contract preservation 오류로 취급합니다.
- `complexity_input`은 duplicate key와 unknown target을 검사합니다.
- `memo_state`/`memo_transition`은 top-down memoized recursion 비용을 설명하는 힌트로
  사용됩니다.
- symbolic alias는 내부적으로 complexity 계열 annotation으로 정규화됩니다.

### Verified

- `test/source/29_complexity_contract_surface_ssa_success.bpp`
- `test/source/30_complexity_space_contract_surface_ssa_success.bpp`
- `test/source/43_language_feature_runtime_bundle_success.bpp`
- `test/source_fail/82_complexity_contract_surface_ssa_fail.bpp`
- `test/source_fail/83_complexity_space_contract_surface_ssa_fail.bpp`

### Missing

- 현재 complexity는 "언어 전체의 완전한 비용 증명기"가 아닙니다.
- SSA/최적화 이후 time/space complexity preservation은 이미 재검증하지만, 전체 계약 family를 모두 덮는 full preservation verifier는 아직 아닙니다.
- `constraints`와 `time_limit`은 복잡도 분석을 보조하지만, 모든 경로에서 자동 증명되는 상태는 아닙니다.
- interprocedural summary와 library summary의 품질은 여전히 중요한 신뢰 축입니다.

## 2. Property Contract

### Surface

- `property(setter)`
- `property(getter)`
- `property(setter=fn, getter=fn)`
- raw bypass `obj.$field`

### Implemented

- property는 annotation이 아니라 field/member access 규칙으로 해석됩니다.
- auto getter/setter를 생성하거나, 수동 getter/setter를 선언에 연결합니다.
- getter/setter 함수의 존재와 시그니처를 validation pass에서 검사합니다.
- member access와 assignment는 getter/setter hook을 통해 lowering/codegen 됩니다.
- SSA builder도 plain member access와 assignment에서 getter/setter hook을 직접 lowering합니다.
- raw bypass는 property contract를 우회하는 명시적 escape hatch입니다.
- `apply_annotations` 뒤에 contract preservation pass가 다시 돌아, property hook이 post-annotation 상태에서도 callable function으로 남아 있는지 검증합니다.
- SSA/codegen 직전에는 generated contract function 안의 direct symbol target이 여전히 유효한지 추가 verifier가 확인합니다.
- complexity surface metadata도 같은 post-annotation contract preservation pass에서 검증됩니다.

### Verified

- `test/source/03_property_hooks_suite.bpp`
- `test/source/28_contract_composition_success.bpp`
- `test/source/41_struct_abi_runtime_bundle_success.bpp`
- `test/source_fail/19_property_hooks_fail_suite.bpp`
- legacy `@[setter]`/`@[getter]` annotation misuse는 validation error로 막습니다.

### Missing

- property 전용 diagnostics는 기본 골격은 갖췄지만, "어떤 access contract가 깨졌는지"를 더 풍부하게 설명할 여지가 있습니다.
- property와 inheritance, trait, generic field access가 섞일 때의 합성 규칙은 문서화와 테스트를 더 늘릴 수 있습니다.
- tooling 관점에서 property contract를 별도 IR/metadata로 노출하는 체계는 아직 없습니다.
- property-specific SSA verifier는 아직 없습니다.
- 다만 property hook이 호출되는 generated contract function에 대해서는 SSA/codegen 직전 direct symbol target 보존 검사가 들어가 있습니다.

## 3. Decorator and Metadata Contract

### Surface

- built-in annotation: `@[entry]`, `@[override]`
- function decorator: `@[decorator_name]`
- metadata: `@[complexity(...)]`, `@[constraints(...)]`, 기타 built-in contract annotation

### Implemented

- `@[entry]`는 top-level, no-arg function만 허용합니다.
- `@[override]`는 실제 base method를 가져야 하며 시그니처를 검사합니다.
- decorator는 선언 변환 계약으로 해석됩니다.
- decorator 시그니처는 target function과 엄격히 맞아야 합니다.
- unresolved decorator, missing body, signature mismatch는 validation 단계에서 오류가 납니다.
- post-annotation contract preservation pass가 generated wrapper/original function의 module ownership, direct-call resolvability, final entry surface를 다시 확인합니다.
- SSA/codegen 직전 verifier가 generated wrapper/original function의 direct `call`, `call_slice_store`, `lea_func` target이 여전히 유효한 symbol인지 다시 확인합니다.

### Verified

- `docs/wiki/Annotations-and-Decorators.md`에 현재 표면 규칙을 정리했습니다.
- `test/source/28_contract_composition_success.bpp`에서 decorator order, decorated property hook,
  decorated override, decorated entry composition을 고정합니다.
- `test/source/47_llvm_build_contract_main_bundle_success.bpp`에서 contract family metadata
  handoff를 고정합니다.
- `@[override]`와 `@[entry]` 검사는 `src/compiler/virtual_dispatch_runtime.bpp`와
  `src/compiler/validation.bpp`에서 강제됩니다.
- decorator validation과 contract preservation verification은
  `src/compiler/annotations.bpp`, `src/compiler/validation.bpp`,
  `src/compiler/pass_runner.bpp` 경로에 걸쳐 수행됩니다.
- SSA/codegen 전 검증은 `src/ssa.bpp`, `src/codegen.bpp`, `src/llvm/*` handoff 경로에서
  이어집니다.

### Missing

- decorator annotation arguments (`@[deco(...)]`)는 아직 미지원입니다.
- decorator, property, metadata가 더 복잡하게 중첩될 때의 우선순위/합성 규칙은 추가 문서화와 테스트를 더 늘릴 수 있습니다.
- annotation이 "계약 surface"라는 철학에 비해, 일부 경로는 여전히 built-in name dispatch에 많이 의존합니다.
- 현재는 post-annotation AST verifier와 post-SSA direct-symbol verifier까지 있습니다.
- 하지만 property/complexity까지 포함한 full SSA/codegen contract verifier는 아직 아닙니다.

## 4. Compiler-Known Prelude Contract

### Surface

- `number`
- `string`
- `input<T>()`
- `print` / `println`
- `emit` / `emitln`

### Implemented

- `number`와 `string`은 std 타입이지만 compiler-known prelude family로 특별 취급됩니다.
- `input<T>()`는 표면상 generic이지만 lowering 단계에서 전용 std 경로로 변환됩니다.
- `print`/`println`은 formatting-friendly 계층입니다.
- `emit`/`emitln`은 raw emission 계층입니다.

### Verified

- `docs/wiki/Compiler-Known-Prelude.md`
- `test/source/19_typed_input_success.bpp`
- `test/source/20_string_type_success.bpp`
- `test/source/21_number_input_println_success.bpp`
- `test/source/22_number_emitln_to_str_success.bpp`
- `test/source/23_number_input_arithmetic_println_success.bpp`
- `test/source_fail/79_input_generic_arity_fail.bpp`

### Missing

- `number`와 `string`은 철학상 같은 family지만, 구현 레이어가 완전히 대칭적인 것은 아닙니다.
- prelude sugar의 contract를 별도 IR로 정규화한 상태는 아닙니다.
- AI/tooling이 prelude contract를 직접 질의할 수 있는 메타데이터 API는 아직 없습니다.

## 5. Diagnostics Contract

### Surface

- phase tag
- 핵심 오류 메시지
- note/help
- compile-fail substring tests

### Implemented

- parser, validation, lowering, codegen 주요 경로는 structured diagnostics 방향으로 정리되었습니다.
- compile-fail tests는 핵심 substring까지 검증합니다.
- raw `[ERROR]` ad hoc 경로는 이전보다 크게 줄었습니다.
- complexity/contract preservation diagnostics는 이제 contract origin raw text를 함께 출력할 수 있습니다.
- complexity preservation diagnostics는 이제 shared contract-surface metadata(`AnnContractSurfaceMeta`)를 통해 function/module/surface kind/contract family/declared time·space/budget time·space를 같은 순서로 보여줍니다.
- codegen 직전에는 `AnnLoweredContractBoundary`를 사용해 backend로 넘기기 전 최소 invariant(module ownership / std prelude boundary / SSA complexity summary)를 다시 확인합니다.
- pre-backend verifier는 이제 `AnnLoweredContractEntry` 집합을 통해 contract-bearing callable surface를 한 번 수집한 뒤 같은 carrier를 재사용합니다.
- 이 verifier는 이제 `src/codegen.bpp`의 local helper가 아니라 `src/compiler/annotations.bpp`의 backend-independent contract pass로 올라와 있습니다.
- lowered boundary invariant는 이제 family별로 더 구체적입니다: callable body, public surface, zero-argument entry, direct symbol resolution까지 함께 확인합니다.
- contract metadata는 이제 family 단위뿐 아니라 property kind, decorator wrapper kind, prelude kind까지 세분화됩니다.
- lowered contract graph(`AnnLoweredContractGraph`)가 생겨서, contract 전용 lowered layer를 독립 carrier로 다룰 수 있습니다.
- backend-neutral contract envelope(`AnnBackendContractEnvelope`)가 생겨서, lowered graph를 future LLVM/backend adapter가 소비하기 쉬운 atom carrier로 평탄화할 수 있습니다.
- backend contract atom은 이제 callable/property declaration site line·column도 함께 운반합니다.
- LLVM-facing contract adapter(`AnnLLVMContractAdapter`)가 생겨서, envelope를 실제 metadata key 기반 backend 입력으로 한 단계 더 평탄화할 수 있습니다.
- LLVM adapter atom은 `metadata_key`, `surface tag`, `detail tag`를 고정해서 future LLVM metadata emitter가 같은 carrier를 바로 재사용할 수 있습니다.
- CLI `-dump-llvm-contract`로 이 adapter를 바로 stdout에 뽑아볼 수 있어서, 실제 LLVM prototype consumer를 붙이기 전에도 contract carrier를 외부에서 테스트할 수 있습니다.
- `-dump-llvm-proto`로 adapter를 LLVM-like named metadata prototype으로도 뽑을 수 있어서, 실제 LLVM emitter를 붙이기 전의 첫 출력 표면이 생겼습니다.
- `-dump-llvm-ll`로 `target triple + declare/define + !bpp.contract` 형태의 최소 `.ll` skeleton도 뽑을 수 있어서, 실제 LLVM text emitter의 첫 usable surface가 생겼습니다.
- 현재는 reachable function subset에 대해:
  - primitive param/return signature
  - SSA-backed arithmetic / compare / branch / direct-call
  - local pseudo-memory (`load/store`)
  - explicit address subset (`lea_local`, `load64`, `store64`)
  까지 실제 `define` body를 출력합니다.
- `-llvm-build`로는 현재 subset에 한해 `.ll -> clang -> exe -> run` end-to-end 경로도 동작합니다.
- optional post-LLVM metadata survival verifier를 위한 record scaffold가 준비되어 있습니다.
- 현재는 이 scaffold를 graph -> envelope -> record round-trip self-check로 실제 파이프라인에서 한 번 타게 해 두었습니다.
- backend-neutral envelope와 LLVM-facing adapter는 이제 모두 stderr/file dump로 외부화할 수 있어서 future LLVM prototype이나 offline tooling이 같은 contract carrier를 바로 읽어볼 수 있습니다.
- lowered boundary diagnostics는 이제 related declaration과 contract origin chain을 함께 출력합니다.

### Verified

- `docs/wiki/Diagnostics-and-Errors.md`
- `test/source_fail/38_match_variant_non_exhaustive_fail.bpp`
- `test/source_fail/19_property_hooks_fail_suite.bpp`
- `test/source_fail/79_input_generic_arity_fail.bpp`

### Missing

- 모든 경로가 완전히 같은 diagnostic richness를 제공하는 것은 아닙니다.
- secondary span, related declaration site, contract origin reporting은 더 강화될 수 있습니다.
- "어떤 계약을 깼는가"를 first-class로 설명하는 wording 정규화는 아직 진행 중입니다.

## Practical Rule

새 문법이나 새 contract surface를 추가할 때는 아래 네 질문을 먼저 통과해야 합니다.

1. 이 계약은 표면 문법에서 명확히 읽히는가?
2. 이 계약은 parser/lowering/typecheck/codegen 중 어디에서 실제로 검사되는가?
3. 이 계약 위반은 compile-fail test로 고정되어 있는가?
4. 이 계약은 사람이 읽기 쉽고, AI도 지역적으로 해석할 수 있는가?

이 네 질문 중 하나라도 답이 비어 있으면, 기능 추가보다 먼저 계약 정의와 진단을 보강하는 쪽이 우선입니다.

## Related

- [Bpp Manifesto](Bpp-Manifesto)
- [Language Scope](Language-Scope)
- [Annotations and Decorators](Annotations-and-Decorators)
- [Compiler-Known Prelude](Compiler-Known-Prelude)
- [Diagnostics and Errors](Diagnostics-and-Errors)
- [LLVM Contract Boundary](LLVM-Contract-Boundary)
