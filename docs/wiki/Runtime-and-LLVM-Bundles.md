# Runtime and LLVM Bundles

이 페이지는 최근 Bpp 기능을 가장 압축적으로 보여주는 런타임/LLVM 번들 테스트를
설명합니다. 위키를 갱신할 때는 이 파일을 체크리스트처럼 사용하면 됩니다.

## 왜 번들이 중요한가

초기 테스트는 기능 하나당 파일 하나에 가까웠지만, 현재는 기능들이 서로 강하게
엮입니다. 예를 들어 `new`는 constructor/destructor, tagged pointer policy,
SSA lowering, LLVM metadata와 동시에 관련됩니다. 그래서 현재 테스트 전략은
"작은 기능 테스트 + 대표 번들 테스트"를 함께 유지합니다.

대표 번들은 다음을 확인합니다.

- 기존 non-SSA backend와 SSA backend가 같은 언어 의미를 유지하는지
- `O0`/`O1`에서 runtime semantics가 보존되는지
- LLVM `.ll` skeleton/build 경로가 실제 실행 가능한 subset을 유지하는지
- contract/tagged/stack-new 같은 metadata가 출력물에서 사라지지 않는지

## 핵심 번들

`38_number_runtime_bundle_success.bpp`:

- `number`의 작은 정수 fast path, 큰 정수, Karatsuba/Toom/NTT 곱셈, 큰 나눗셈
- `f64`, 복소수, 허수 리터럴, 유리수/십진수/bigfloat 계층
- 컨테이너 합산과 proof-slice 기반 number 접근 최적화

`39_tagged_metadata_runtime_bundle_success.bpp`:

- `BppObjectTag`의 lifecycle/ownership/storage/barrier/shape/profiled 필드
- tagged delete, heap lifecycle, allocator free 가능성 판단
- refcount/barrier skip fast path
- tagged slice sum/min/max/count/find의 LLVM vector lowering
- shape cache, proof slice, bounds proof, Vec/Number proven access metadata

`40_core_runtime_bundle_success.bpp`:

- 산술, 비교, 제어 흐름, enum/match/string, recursion, 함수 포인터
- 포인터, 배열, slice, nested array/slice
- inline asm, global state, `defer`, literal family, `sizeof`, Vec 기본 동작

`41_struct_abi_runtime_bundle_success.bpp`:

- struct layout, packed layout, method/static method
- struct return ABI, slice field ABI
- access control, protected/private/default-private
- operator/property hook과 raw bypass

`42_container_module_runtime_bundle_success.bpp`:

- `Vec<T>`, `HashMap<K,V>`, 큰 struct element, pointer element
- module import와 generic 인스턴스화
- trait/vtable heap object와 generic `new`/`delete` ABI

`43_language_feature_runtime_bundle_success.bpp`:

- `new`/`delete`, constructor/destructor, stack constructor
- Option/Result와 `?` propagation
- inheritance, multi-inherit layout/cast, trait vtable
- complexity/symbolic annotation, implicit conversions, `match`
- `number`, modular number, string slice comparison
- SSA parallel-copy phi, inline asm generalized lowering
- stack-new escape analysis/SROA/tag policy metadata

`44_number_bitwise_runtime_bundle_success.bpp`:

- 큰 `number`에 대한 `&`, `|`, `^`, `~`, `<<`, `>>`
- 나눗셈 뒤 입력 보존, 후속 bitwise 연산, parse round-trip

`45_llvm_build_runtime_fixture_bundle_success.bpp`:

- LLVM build 경로의 call/branch/loop/bitwise/call pointer
- float, narrow integer signature, small/large struct ABI
- phi merge, slice/array/bool/string/global pointer fixture
- `@[entry]`가 conventional `main` 대신 runtime entry로 내려가는 경로

`46_llvm_build_abi_only_bundle_success.bpp`:

- nested packed struct parameter/return ABI
- tagged pointer metadata를 가진 struct return ABI

`47_llvm_build_contract_main_bundle_success.bpp`:

- conventional `main` lowering
- condition/effects/ownership/memory/concurrency/ABI/execution contract family
- contract annotation family가 backend lowering과 LLVM metadata handoff를 통과하는지

## LLVM Build Directive

테스트 파일의 `// LLVM Build: true`는 해당 케이스가 `.ll` emission만 보는 것이
아니라, 가능한 경우 `clang -x ir`로 실행 파일까지 연결되는 경로를 요구한다는
뜻입니다.

추가 directive인 `// Expect llvm metadata contains: ...`는 emitted LLVM-like
텍스트나 build 경로의 metadata에 특정 문자열이 반드시 남아야 한다는 계약입니다.
이 문자열은 단순 주석이 아니라, feature가 lowering 중에 사라지지 않았는지
잡아내는 문서화된 테스트 표면입니다.

## stack-new metadata

`43_language_feature_runtime_bundle_success.bpp`는 다음 metadata를 요구합니다.

- `bpp.ssa.new_stack_lowering=escape-stack-slot`
- `bpp.ssa.stack_new.noescape_summary=interprocedural`
- `bpp.ssa.stack_new.tag_policy=escape-lifecycle`
- `bpp.ssa.stack_new.sroa=field-address`

의미는 다음과 같습니다.

- `new T{...}`가 항상 힙 할당으로만 남는 것이 아니라, escape 분석 결과에 따라
  스택 slot으로 낮아질 수 있습니다.
- 함수 호출을 단순히 "모두 escape"로 보지 않고, known helper의 no-escape 성격을
  요약해 stack allocation 후보를 살립니다.
- tagged pointer는 no-escape면 `storage=stack`, `ownership=stack` 쪽으로
  정책을 잡고, escape하면 heap/escaped 정책으로 되돌아갑니다.
- struct field access가 충분히 지역적이면 SROA처럼 field address/load/store
  중심으로 더 작게 낮출 수 있습니다.

사용자가 작성하는 표면 문법은 여전히 `new`/`delete`입니다. 최적화가 적용되어도
constructor/destructor 순서, `delete`의 의미, tagged metadata 관측 가능성은
보존되어야 합니다.

## tagged vector metadata

`39_tagged_metadata_runtime_bundle_success.bpp`의 vector metadata는 현재 LLVM
prototype이 실제 SIMD-ish IR 모양을 출력한다는 뜻입니다.

예를 들어 tagged slice shape가 `i64`, 길이가 충분하고 profiled bit가 켜져 있으면
sum/min/max/count/find 계열은 `<4 x i64>` 또는 `<4 x double>` 형태의 load/compare
패턴으로 내려갈 수 있습니다. guard가 맞지 않는 경우에는 scalar/cold path가 남아야
합니다.

이 최적화의 핵심은 "태그가 빠른 경로를 선택하게 도와준다"는 점입니다. 태그가
없거나 shape/profile이 맞지 않으면 correctness를 위해 일반 경로를 써야 합니다.

## contract family metadata

LLVM contract bundle은 아래 family를 현재 표면 계약으로 고정합니다.

- condition: `requires`, `ensures`, `invariant`
- effects: `effects`, `pure`, `no_alloc`, `no_io`, `no_throw`, `no_panic`
- ownership: `takes_ownership`, `returns_ownership`, `borrows`, `moves`,
  `consumes`, `no_escape`, `lifetime`
- memory: `nonnull`, `bounds`, `aligned`, `initialized`, `no_alias`
- concurrency: `thread_safe`, `requires_lock`, `acquires_lock`, `releases_lock`,
  `no_blocking`, `atomic`
- ABI: `abi`, `extern`, `calling_convention`, `repr`, `layout`
- execution: `test`, `bench`, `timeout`, `retry`, `memoize`, `cache`,
  `transactional`, `panic_policy`

현재 LLVM은 이 계약을 "증명"하지 않습니다. Bpp front/mid-end가 계약을 읽고,
validation 가능한 argument shape를 검사하고, backend handoff metadata로
보존합니다.

## 문서 갱신 규칙

새 기능을 추가하면 위키에 최소한 세 가지를 적어야 합니다.

1. 사용자가 보는 표면 문법
2. 어느 pass/runtime/helper가 실제 의미를 책임지는지
3. 어느 성공/실패 테스트 또는 bundle이 그 의미를 고정하는지

이 세 가지가 없으면 문서는 친절해 보여도 구현 기준으로는 불완전합니다.
