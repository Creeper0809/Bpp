# Annotations and Decorators

이 페이지는 `@[...]` 문법의 의미와 v11 구현 상태를 설명합니다.

## Why It Exists

- 단순 메타 태그가 아니라, 컴파일러 pass에서 의미를 해석해 동작을 바꾸기 위한 확장 지점입니다.
- `override`/`entry`/decorator 같은 규칙성 있는 기능을 일관된 표기로 제공하기 위해 존재합니다.

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
  - top-level non-generic 함수만 지원
  - decorator 시그니처는 엄격히 일치해야 함
  - `next` 첫 인자는 `u64` 함수 포인터
- `@[override]`:
  - trait impl에서는 금지
  - 부모 대상 없으면 오류

## Cautions

- 어노테이션 이름이 함수 심볼로 해석되면 decorator로 동작할 수 있습니다.
  - 의도치 않은 이름 충돌에 주의해야 합니다.
- `@[entry]`를 잘못 붙이면 기존 `main` 엔트리와 충돌하거나 실행 경로가 바뀝니다.
- decorator는 래퍼 함수를 생성하므로 디버깅 시 함수 이름이 내부적으로 바뀔 수 있습니다.

## Best Practices

- 어노테이션 네이밍 규칙(예: `meta_*`, `deco_*`)을 팀 규약으로 고정합니다.
- entry 함수는 별도 파일/섹션에 분리해 가독성을 확보합니다.
- decorator 도입 시 성공/실패 케이스 테스트를 함께 추가합니다.
