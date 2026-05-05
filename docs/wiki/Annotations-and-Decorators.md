# Annotations and Decorators

이 페이지는 `@[...]` 문법의 의미와 현재 구현 상태를 설명합니다.

## Why It Exists

- 단순 메타 태그가 아니라, 컴파일러 pass에서 의미를 해석해 동작을 바꾸기 위한 확장 지점입니다.
- `override`/`entry`/decorator 같은 규칙성 있는 기능을 일관된 표기로 제공하기 위해 존재합니다.
- Bpp 관점에서 annotation은 장식이 아니라 declaration-level contract surface입니다.
  - decorator는 선언 변환 계약
  - metadata는 분석/제약/도구 계약
  - contract family는 LLVM handoff와 diagnostics가 공유하는 선언 표면

## How to Use

어노테이션은 "붙이는 위치"와 "의미 해석 시점"을 먼저 구분해야 합니다.

1. target 확정 (func/var)
2. built-in인지 decorator 후보인지 결정
3. 제약 검사 (entry/override/decorator signature)
4. 테스트로 성공/실패 동시 고정

### Basic Annotation

```bpp
@[config]
var G: u64 = 1;

@[feature]
func f() -> u64 {
    return G;
}
```

여러 개를 연속으로 사용할 수 있습니다.

```bpp
@[hot]
@[trace]
func f() -> u64 { ... }
```

### Built-in: `@[entry]`

```bpp
@[entry]
func run() -> u64 {
    return 0;
}
```

엔트리 지정 절차:

1. top-level 함수 하나 선택
2. 파라미터 없는 함수로 선언
3. `@[entry]` 부여
4. 기존 `main`과 충돌 여부 확인

### Built-in: `@[override]`

```bpp
impl Child {
    @[override]
    public func foo(self: *Child) -> u64 { ... }
}
```

override 절차:

1. 부모 계층에 대상 메서드 존재 확인
2. 메서드 시그니처 정합성 확인
3. trait impl 맥락이 아닌지 확인
4. `@[override]` 적용

### Function Decorator

```bpp
func add_one(next: u64, x: u64) -> u64 {
    return next(x) + 1;
}

@[add_one]
func f(x: u64) -> u64 {
    return x * 2;
}
```

decorator 시그니처 템플릿:

```bpp
func <decorator>(next: u64, <target-params...>) -> <target-ret>
```

작성 절차:

1. 대상 함수 시그니처 확정
2. 같은 파라미터/반환 타입으로 decorator 정의
3. 대상 함수 위에 `@[decorator_name]` 부여
4. 다중 decorator면 적용 순서(아래->위) 의도 확인

## Built-in Contract Families

현재 annotation layer는 decorator뿐 아니라 여러 contract family를 인식합니다.
이 family들은 LLVM이 의미를 증명하는 대상이 아니라, Bpp front/mid-end가 읽고
검사한 뒤 metadata로 보존해야 하는 선언 계약입니다.

### Condition

```bpp
@[requires("n >= 0")]
@[ensures(expr="result >= n")]
@[invariant("buf != other")]
func f(n: u64, buf: u64, other: u64) -> u64 {
    return n;
}
```

사용 목적:

- precondition, postcondition, invariant를 선언 표면에 남깁니다.
- 현재는 expression string/identifier shape를 validation하고 metadata로 보존합니다.
- 실제 수학 증명기는 아니며, future verifier/tooling이 읽을 origin을 잃지 않는 것이 핵심입니다.

### Effects

```bpp
@[effects(io=false, alloc=false, throws=false, panic=false)]
@[pure]
@[no_alloc]
@[no_io]
@[no_throw]
@[no_panic]
func pure_add(a: u64, b: u64) -> u64 {
    return a + b;
}
```

사용 목적:

- 함수가 IO/할당/throw/panic 같은 side effect를 갖는지 선언합니다.
- marker annotation은 인자를 받지 않고, `effects(...)`는 boolean-like scalar clause를 받습니다.

### Ownership and Lifetime

```bpp
@[takes_ownership("buf")]
@[returns_ownership]
@[borrows(param="other")]
@[moves("tmp")]
@[consumes("tmp")]
@[no_escape("buf")]
@[lifetime(value="buf", owner="caller")]
func own(buf: u64, other: u64) -> u64 {
    return buf + other;
}
```

사용 목적:

- 포인터/핸들 값의 소유권, borrow, move, escape 의도를 표면화합니다.
- `no_escape`는 stack-new/tag policy 같은 최적화와 같은 철학을 공유하지만,
  annotation 하나만으로 임의 코드가 자동으로 안전하다고 증명되는 것은 아닙니다.

### Memory

```bpp
@[nonnull("buf")]
@[bounds(ptr="buf", len="n")]
@[aligned(ptr="buf", align=8)]
@[initialized("buf")]
@[no_alias("buf", "other")]
func mem(buf: u64, other: u64, n: u64) -> u64 {
    return n;
}
```

사용 목적:

- 포인터 값에 대한 nonnull/bounds/alignment/initialization/alias 의도를 metadata로 남깁니다.
- `bounds`와 `aligned`는 target clause와 scalar clause shape를 검사합니다.

### Concurrency

```bpp
@[thread_safe]
@[requires_lock("mu")]
@[acquires_lock(lock="mu")]
@[releases_lock("mu")]
@[no_blocking]
@[atomic]
func locked() -> u64 {
    return 0;
}
```

사용 목적:

- 스레드 안전성, lock discipline, blocking/atomic 의도를 선언합니다.
- lock contract는 lock 이름을 문자열/identifier로 받습니다.

### ABI and Layout

```bpp
@[abi("sysv")]
@[calling_convention("sysv")]
@[repr("C")]
@[layout(size=24, align=8, packed=false)]
func abi_surface() -> u64 {
    return 0;
}
```

사용 목적:

- 외부 ABI, calling convention, representation, layout 의도를 backend handoff에 남깁니다.
- struct ABI/packed/tagged return 같은 LLVM fixture와 함께 관리해야 합니다.

### Execution

```bpp
@[test]
@[bench]
@[timeout(ms=10)]
@[retry(count=1)]
@[memoize]
@[cache(key="n", ttl_ms=1000)]
@[transactional]
@[panic_policy("abort")]
func run_case(n: u64) -> u64 {
    return n;
}
```

사용 목적:

- 테스트/벤치/타임아웃/재시도/캐시/트랜잭션/panic 정책 같은 실행 의도를 표면화합니다.
- 현재는 annotation shape와 metadata preservation이 핵심입니다.

대표 검증은 `test/source/47_llvm_build_contract_main_bundle_success.bpp`가 담당합니다.

## Complexity and Symbolic Aliases

복잡도 계열 annotation은 가장 실제 검증이 많이 들어간 contract family입니다.

```bpp
@[complexity(time="O(n)", space="O(1)", mode="worst")]
@[complexity_budget(time="O(2*n)", space="O(1)")]
@[constraints(n=4096)]
@[time_limit(ms=100, machine="ref_v1")]
@[complexity_debug]
func linear(n: u64) -> u64 {
    var s: u64 = 0;
    for (var i: u64 = 0; i < n; i = i + 1) {
        s = s + i;
    }
    return s;
}
```

지원되는 보조 표면:

- `@[complexity_input(x="k")]`: 분석 변수와 실제 파라미터/constraint symbol 연결
- `@[complexity_memo(...)]` 또는 `memo_state`/`memo_transition` clause:
  memoization 상태 수와 전이 비용 힌트
- statement-level `@[complexity_ignore(...)]`: 특정 호출/문장 비용 제외
- symbolic alias:
  - `symbolic_expect` -> `complexity`
  - `symbolic_assume` -> `constraints`
  - `symbolic_input` -> `complexity_input`
  - `symbolic_budget` -> `complexity_budget`
  - `symbolic_memo` -> `complexity_memo`
  - `symbolic_ignore` -> `complexity_ignore`
  - `symbolic_debug` -> `complexity_debug`

복잡도 계약은 AST 단계에서 한 번 읽고, SSA/codegen 직전 final callable surface에서
다시 summary와 비교합니다. time뿐 아니라 space rank도 보존 검사 대상입니다.

## Composition Rules

현재 구현에서 합성 규칙은 다음 순서로 이해하는 것이 가장 정확합니다.

1. `property(...)`는 field/member access contract로 먼저 확정됩니다.
   - property는 annotation이 아니며, field declaration에서 직접 해석됩니다.
   - manual getter/setter로 연결된 함수가 decorator를 가지더라도, property hook은 최종 public wrapper 이름을 통해 계속 접근됩니다.
2. built-in annotation(`@[entry]`, `@[override]`)은 decorator 후보가 아닙니다.
   - built-in annotation은 먼저 validation되고, decorator 수집에서는 제외됩니다.
3. multiple decorator는 아래에서 위로 적용됩니다.
   - 함수에 더 가까운 annotation이 inner wrapper가 됩니다.
   - 맨 위 annotation이 최종 public surface를 감싸는 outer wrapper가 됩니다.
4. impl method에 붙은 decorator는 최종 public wrapper에 impl metadata를 유지합니다.
   - 따라서 decorated override/magic method도 method lookup과 override contract를 잃지 않습니다.
5. `@[entry]`와 decorator를 함께 쓰면, entry target은 최종 public wrapper surface를 가리킵니다.
   - 즉 entry function도 decorator를 통해 감싸진 최종 실행 경로로 진입합니다.
6. annotation expansion 뒤에는 contract preservation pass가 다시 한 번 실행됩니다.
   - generated wrapper/original function이 module ownership을 잃지 않았는지
   - wrapper body의 direct call이 여전히 resolvable한지
   - final entry surface가 callable zero-arg 함수로 남아 있는지
   - complexity surface metadata가 parseable한 상태로 final public surface에 남아 있는지
   를 확인합니다.
7. SSA/codegen 직전에도 generated contract function을 한 번 더 검증합니다.
   - direct `call`
   - direct `call_slice_store`
   - `lea_func` function reference
   가 여전히 유효한 symbol target을 가리키는지 확인합니다.
8. complexity-family annotation이 붙은 final callable surface는 SSA summary로 다시 검증됩니다.
9. 이 재검증은 현재 `time`과 `space` rank를 포함하며, wrapper surface에서 더 무거워진 계약은 preservation 오류가 납니다.
10. 관련 diagnostics는 shared contract-surface metadata를 사용해 function/module/surface kind/contract family와 declared/budget rank를 같은 형식으로 출력합니다.
   - declared `complexity.time`
   - `complexity_budget.time`
   - missing SSA summary
   를 contract preservation 관점에서 다시 확인합니다.
11. backend 직전에는 lowered contract boundary verifier가 한 번 더 실행됩니다.
   - module ownership
   - std/prelude module ownership
   - final SSA complexity summary
   를 확인한 뒤 backend emission으로 넘어갑니다.

### Invalid Examples

```bpp
// 잘못된 예: top-level에서 func/var 외 target
@[x]
import std.io;
```

```bpp
// 잘못된 예: entry 중복
@[entry] func a() -> u64 { return 0; }
@[entry] func b() -> u64 { return 0; }
```

```bpp
// 잘못된 예: decorator 시그니처 불일치
func deco(next: u64, x: i64) -> u64 { return 0; }
@[deco]
func f(x: u64) -> u64 { return x; }
```

## Constraints

- annotation target:
  - top-level: `func`, `var`
  - statement scope: `var`만 허용
- `@[entry]`:
  - top-level 함수만 허용
  - 파라미터 없는 함수만 허용
  - 여러 개 지정 불가
- decorator:
  - top-level 함수, generic 함수, impl 메서드(일반/trait impl)에 적용 가능
  - decorator 시그니처는 엄격히 일치해야 함
  - `next` 첫 인자는 `u64` 함수 포인터
  - decorator annotation 인수(`@[deco(...)]`)는 현재 미지원
- `@[override]`:
  - trait impl에서는 금지
  - 부모 대상 없으면 오류
- built-in annotation(`entry`, `override`)은 인수를 받지 않음
- non-complex contract family는 family별로 허용되는 argument shape가 다릅니다.
- contract family annotation은 final surface metadata와 LLVM-facing atom으로 보존되어야 합니다.

## Cautions

- unknown annotation은 decorator 후보로 해석될 수 있습니다. 단순 메타 태그를
  추가할 때도 decorator 이름 충돌과 signature validation을 의식해야 합니다.
- contract family annotation은 현재 "보존되는 선언 계약"입니다. 모든 family가
  full static verifier를 갖는 것은 아닙니다.
- complexity family는 상대적으로 강하게 검증되며, budget/declared rank가 SSA
  summary보다 약하면 compile-fail이 날 수 있습니다.
- 어노테이션 이름이 함수 심볼로 해석되면 decorator로 동작할 수 있습니다.
  - 의도치 않은 이름 충돌에 주의해야 합니다.
- `@[entry]`를 잘못 붙이면 기존 `main` 엔트리와 충돌하거나 실행 경로가 바뀝니다.
- decorator는 래퍼 함수를 생성하므로 디버깅 시 함수 이름이 내부적으로 바뀔 수 있습니다.

## Best Practices

- 어노테이션 네이밍 규칙(예: `meta_*`, `deco_*`)을 팀 규약으로 고정합니다.
- entry 함수는 별도 파일/섹션에 분리해 가독성을 확보합니다.
- decorator 도입 시 성공/실패 케이스 테스트를 함께 추가합니다.
- contract가 함께 붙는 경우에는 apply order를 주석이나 테스트로 고정하는 편이 좋습니다.

## Related

- [Contract Checklist](Contract-Checklist)
- [LLVM Contract Boundary](LLVM-Contract-Boundary)
- [Runtime and LLVM Bundles](Runtime-and-LLVM-Bundles)
