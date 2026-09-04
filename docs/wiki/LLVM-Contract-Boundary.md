# LLVM Contract Boundary

이 문서는 Bpp가 LLVM backend를 붙일 때, 계약(contract) 의미를 어디까지 front-end/mid-end에서 책임지고 어디서부터 backend로 넘길지를 정리합니다.

핵심 원칙은 단순합니다.

- LLVM은 Bpp contract를 "이해"하는 계층이 아닙니다.
- Bpp 컴파일러는 LLVM으로 내려가기 전에 contract를 해석하고 검증 가능한 형태로 정규화해야 합니다.
- LLVM으로는 contract 그 자체가 아니라, contract를 반영한 canonical lowering과 필요한 metadata만 넘어가야 합니다.

## Current Boundary

현재 코드에는 이 경계를 위한 첫 실제 metadata 구조가 이미 들어가 있습니다.

- `AnnContractSurfaceMeta` in `src/compiler/annotations.bpp`
  - final callable surface의 함수 이름
  - module ownership
  - public/generator wrapper 구분
  - contract family flags (`complexity`, `decorator`, `property`, `entry`, `compiler-known prelude`)
  - declared/budget time·space rank
  - contract annotation 개수
  - property kind (`getter`, `setter`, `getter+setter`) + owning field metadata
  - decorator wrapper kind (`public-decorated`, `generated-wrapper`, `generated-original`)
  - prelude kind (`input`, `print`, `emit`, ...)
- `AnnLoweredContractBoundary` in `src/compiler/annotations.bpp`
  - backend 직전 lowered surface가 유지해야 할 최소 contract invariant
  - module ownership
  - direct symbol resolution requirement
  - SSA complexity summary requirement
  - std/prelude module ownership requirement
  - callable body requirement
  - public callable surface requirement
  - zero-argument entry requirement
- `AnnLoweredContractEntry` in `src/compiler/annotations.bpp`
  - `AstProgram`에서 contract-bearing function surface를 수집한 실제 pre-backend carrier
  - owner function
  - shared surface metadata
  - lowered boundary invariant
- `AnnLoweredContractGraph` / `AnnLoweredContractNode` in `src/compiler/annotations.bpp`
  - contract 전용 lowered graph layer
  - surface/property/decorator/prelude/entry/complexity node를 분리해 future LLVM boundary에서 재사용
- `AnnBackendContractEnvelope` / `AnnBackendContractAtom` in `src/compiler/annotations.bpp`
  - backend-neutral contract handoff carrier
  - lowered graph를 backend가 소비하기 쉬운 atom list로 평탄화
  - surface kind / family mask / boundary requirement / lowered node detail을 함께 운반
  - callable/property declaration site line·column도 함께 운반
- `AnnLLVMContractAdapter` / `AnnLLVMContractAtom` in `src/compiler/annotations.bpp`
  - future LLVM backend가 바로 소비할 수 있는 metadata adapter 입력
  - backend-neutral envelope를 `metadata_key`, `surface tag`, `detail tag`가 붙은 LLVM-facing atom으로 변환
  - `bpp.contract.property`, `bpp.contract.decorator`, `bpp.contract.prelude` 같은 namespace를 여기서 고정
- `annotation_validate_lowered_contract_boundary(...)` in `src/compiler/annotations.bpp`
  - backend에 독립적인 pre-LLVM verifier
  - lowered contract entry 집합을 사용해 final boundary를 검사
- `annotation_validate_backend_contract_envelope(...)` in `src/compiler/annotations.bpp`
  - lowered graph와 backend-neutral envelope 사이의 구조 보존을 검증
  - future LLVM adapter가 envelope를 소비해도 contract node를 잃지 않도록 현재 단계에서 먼저 고정
- `annotation_validate_llvm_contract_adapter(...)` in `src/compiler/annotations.bpp`
  - backend-neutral envelope와 LLVM adapter 사이의 구조/태그 보존을 검증
  - future LLVM metadata emitter가 바로 쓸 adapter input을 현재 파이프라인에서 미리 고정
- `annotation_dump_backend_contract_envelope_*` in `src/compiler/annotations.bpp`
  - envelope를 stderr 또는 파일로 외부화하는 textual dump
  - future LLVM prototype이나 offline tooling이 contract carrier를 그대로 읽어볼 수 있는 inspection surface
- `annotation_dump_llvm_contract_adapter_*` in `src/compiler/annotations.bpp`
  - LLVM-facing adapter를 stderr 또는 파일로 외부화하는 textual dump
  - future LLVM metadata emitter와 동일한 입력 표면을 디버깅할 수 있는 inspection surface
  - CLI에서는 `-dump-llvm-contract`로 stdout에 바로 출력할 수 있습니다.
- `annotation_dump_llvm_contract_proto_*` in `src/compiler/annotations.bpp`
  - adapter를 LLVM-like named metadata prototype 형태로 출력하는 초소형 emitter
  - CLI에서는 `-dump-llvm-proto`로 stdout에 바로 출력할 수 있습니다.
- `annotation_dump_llvm_ll_skeleton_*` in `src/compiler/annotations.bpp`
  - adapter를 `target triple + declare + !bpp.contract` 구조의 최소 `.ll` skeleton으로 출력하는 초소형 emitter
  - 현재는 reachable function subset에 한해 실제 `define` body도 직접 출력합니다.
    - zero-argument entry surface
    - primitive parameter / return signature
    - SSA-backed arithmetic / compare / branch / direct-call subset
    - local pseudo-memory (`load/store`) + explicit address subset (`lea_local`, `load64`, `store64`)
  - CLI에서는 `-dump-llvm-ll`로 stdout에 바로 출력할 수 있습니다.
- `-llvm-build`
  - 현재는 emitted `.ll`을 `clang -x ir`로 바로 실행 파일까지 연결하는 첫 end-to-end 경로가 있습니다.
  - 아직 full general backend는 아니지만, reachable subset에서는 실제 `Bpp -> .ll -> clang -> exe -> run`이 동작합니다.
- `AnnPostLLVMContractRecord` in `src/compiler/annotations.bpp`
  - optional post-LLVM metadata survival verifier를 위한 record shape
  - 현재는 LLVM backend가 없으므로 `graph -> envelope -> record` round-trip scaffold로 먼저 검증합니다.

즉, boundary는 문서로만 존재하는 게 아니라, diagnostics와 verifier가 공유하는 실제 contract-surface metadata와 pre-backend carrier로도 나타나기 시작했습니다.

현재 구현은 다음과 같은 경계를 가지고 있습니다.

1. **Surface AST**
   - `property`
   - `@[entry]`, `@[override]`, decorator
   - `@[complexity(...)]`, `@[complexity_budget(...)]`, `@[constraints(...)]`
   - compiler-known prelude (`number`, `string`, `input<T>()`, `print`, `emit`)

2. **Post-annotation AST**
   - decorator expansion이 끝난 뒤에도 public callable surface가 contract를 유지하는지 검증합니다.
   - property hook, entry contract, generated wrapper/original function의 module ownership을 검사합니다.
   - complexity-family annotation은 final public surface에 남아 있어야 합니다.

3. **SSA / Codegen boundary**
   - generated contract function의 direct symbol target(`call`, `call_slice_store`, `lea_func`) 보존을 검증합니다.
   - complexity contract는 SSA summary와 비교해 final callable surface에서 다시 검사합니다.
   - 현재는 `time`과 `space` rank를 다시 확인하고, summary 자체가 빠진 경우도 preservation 오류로 취급합니다.

4. **Backend boundary**
   - 여기서부터는 contract-aware verification이 끝난 lowered semantics를 backend가 소비합니다.
   - LLVM backend가 붙더라도, contract의 1차 의미 해석과 위반 진단은 LLVM 앞단에서 끝나야 합니다.

## What Must Survive As Semantics

다음 항목은 LLVM 전에 이미 "의미가 풀려 있어야" 합니다.

### Property

- getter/setter hook 여부
- raw bypass(`$field`) 여부
- access control

LLVM으로는 "property"라는 개념이 직접 넘어가는 것이 아니라,

- explicit getter/setter call
- explicit raw load/store

같은 canonical operation으로 내려가야 합니다.

### Decorator

- wrapper/original function 구조
- entry surface와 decorated impl metadata
- direct symbol resolvability

LLVM은 `@[trace]` 같은 decorator 개념을 모릅니다.
따라서 LLVM 전에 wrapper expansion과 preservation verification이 끝나 있어야 합니다.

### Compiler-Known Prelude

- `input<T>()`
- `print` / `println`
- `emit` / `emitln`
- `number` / `string`

이 계층은 LLVM에서 특별 취급하지 않습니다.
LLVM으로는 이미 정규화된 runtime/helper call로 내려가야 합니다.

## What May Survive As Metadata

다음 항목은 canonical lowering만으로 끝내지 않고, 별도 metadata나 summary로도 함께 가져갈 수 있습니다.

### Complexity

복잡도 계약은 LLVM IR에서 직접 증명하기 어렵습니다.
따라서 권장 구조는 이렇습니다.

1. AST / lowered IR에서 complexity contract를 읽음
2. SSA에서 summary를 계산하고 preservation을 검증함
3. LLVM으로는 선택적으로 summary/metadata를 전달함

즉 complexity는 **LLVM에서 재해석할 의미**가 아니라, **LLVM 전에 검증된 계약**으로 보는 편이 맞습니다.

### Contract Origin

diagnostics 품질을 위해서는 contract origin을 잃지 않는 것이 중요합니다.

예:

- `@[complexity(time="O(n)")]`
- `@[complexity_budget(time="O(2*n)")]`
- `@[constraints(n=64)]`

이 raw annotation text는 LLVM에서 직접 필요하지 않을 수 있지만,

- compile-fail diagnostics
- symbolic report
- future IDE / AI tooling

에는 여전히 중요한 metadata입니다.

## Recommended IR Split

LLVM 도입 전 기준으로, Bpp는 최소한 아래 세 계층을 유지하는 편이 좋습니다.

1. **Surface AST**
   - 사용자가 작성한 문법
2. **Contract-preserving lowered IR**
   - property / decorator / prelude / try / construction semantics가 정규화된 상태
   - contract metadata와 origin을 아직 추적 가능한 상태
   - 현재 코드에는 full general-purpose lowered IR 대신 `AnnLoweredContractGraph -> AnnBackendContractEnvelope -> AnnLLVMContractAdapter` 형태의 contract-specialized lowered layer가 있습니다.
3. **Backend IR**
   - SSA / lowered machine-oriented IR
   - canonical call/load/store/control-flow 중심

LLVM backend는 3번 이후에 붙는 것이 가장 안전합니다.

## Verification Points

LLVM 대비 관점에서 최소 verifier 지점은 다음과 같습니다.

1. **Post-annotation verifier**
   - final public surface가 contract를 유지하는가
2. **Post-SSA verifier**
   - generated symbol target과 complexity contract가 유지되는가
3. **Pre-LLVM verifier**
   - backend로 넘길 canonical lowering이 contract-preserving form인가
   - 현재는 `build_ssa_pipeline()` 마지막에서 `annotation_validate_lowered_contract_boundary(...)`를 호출해 `AnnLoweredContractEntry` 집합 기반으로 lowered contract boundary를 실제로 검사합니다.
   - 이어서 `annotation_validate_backend_contract_envelope(...)`가 lowered graph와 backend-neutral envelope 사이의 구조 보존도 확인합니다.
   - 마지막으로 `annotation_validate_llvm_contract_adapter(...)`가 envelope와 LLVM-facing adapter 사이의 metadata key / surface tag / detail tag 보존을 확인합니다.
4. **Post-LLVM verifier** (optional, future)
   - 선택적으로 metadata survival만 확인
   - 현재는 `AnnBackendContractEnvelope` + `AnnPostLLVMContractRecord` + `annotation_validate_post_llvm_contract_metadata(...)` scaffold가 준비되어 있습니다.

## Non-Goals

- LLVM IR 자체에서 property/decorator semantics를 다시 해석하는 것
- LLVM optimizer가 complexity contract를 자동 증명해주기를 기대하는 것
- contract-aware diagnostics를 LLVM backend에 맡기는 것

## Practical Rule

LLVM을 붙일 때는 항상 이 질문을 먼저 통과해야 합니다.

1. 이 contract는 LLVM 전에 canonical lowering으로 풀렸는가?
2. 이 contract origin은 diagnostics/tooling을 위해 별도 metadata로 남는가?
3. SSA 이후 보존 검사는 LLVM 전에 끝났는가?

셋 중 하나라도 아니면, 아직 LLVM 단계로 넘길 준비가 덜 된 것입니다.

## Related

- [Bpp Manifesto](Bpp-Manifesto)
- [Contract Checklist](Contract-Checklist)
- [Annotations and Decorators](Annotations-and-Decorators)
- [Compiler-Known Prelude](Compiler-Known-Prelude)
