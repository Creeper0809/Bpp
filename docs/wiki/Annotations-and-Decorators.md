# Annotations and Decorators

이 페이지는 `@[...]` 문법의 의미와 v11 구현 상태를 설명합니다.

## Why It Exists

- 단순 메타 태그가 아니라, 컴파일러 pass에서 의미를 해석해 동작을 바꾸기 위한 확장 지점입니다.
- `override`/`entry`/decorator 같은 규칙성 있는 기능을 일관된 표기로 제공하기 위해 존재합니다.
- Bpp 관점에서 annotation은 장식이 아니라 declaration-level contract surface입니다.
  - decorator는 선언 변환 계약
  - metadata는 분석/제약/도구 계약

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

## Composition Rules (v11)

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
   - declared `complexity.time`
   - `complexity_budget.time`
   - missing SSA summary
   를 contract preservation 관점에서 다시 확인합니다.

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

## Constraints (v11)

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

## Cautions

- 어노테이션 이름이 함수 심볼로 해석되면 decorator로 동작할 수 있습니다.
  - 의도치 않은 이름 충돌에 주의해야 합니다.
- `@[entry]`를 잘못 붙이면 기존 `main` 엔트리와 충돌하거나 실행 경로가 바뀝니다.
- decorator는 래퍼 함수를 생성하므로 디버깅 시 함수 이름이 내부적으로 바뀔 수 있습니다.

## Best Practices

- 어노테이션 네이밍 규칙(예: `meta_*`, `deco_*`)을 팀 규약으로 고정합니다.
- entry 함수는 별도 파일/섹션에 분리해 가독성을 확보합니다.
- decorator 도입 시 성공/실패 케이스 테스트를 함께 추가합니다.
- contract가 함께 붙는 경우에는 apply order를 주석이나 테스트로 고정하는 편이 좋습니다.
