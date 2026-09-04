# Functions and Calls

이 페이지는 함수 선언, 호출 규칙, 파라미터 기능을 설명합니다.

## Why It Exists

- 함수 호출은 ABI, 타입 검증, 이름 해석이 동시에 만나는 핵심 경계입니다.
- default/named/variadic을 지원하면 호출 정규화(pass)가 필요합니다.

## How to Use

함수 작성은 아래 순서로 하면 오류를 줄일 수 있습니다.

1. 시그니처를 먼저 고정(파라미터 타입/반환 타입)
2. default/named/variadic 필요 여부 결정
3. 호출 지점에서 인자 전달 방식 일관화
4. 필요 시 테스트에 성공+실패 케이스 동시 추가

### Basic Function

```bpp
func add(a: u64, b: u64) -> u64 {
    return a + b;
}
```

문법 템플릿:

```bpp
func <name>(<param>: <type>, ...) -> <ret-type> {
    ...
}
```

### Default and Named Arguments

```bpp
func add3(a: u64, b: u64 = 7, c: u64 = 11) -> u64 {
    return a + b + c;
}

var x: u64 = add3(1);
var y: u64 = add3(a: 1, c: 100, b: 2);
```

사용 규칙:

- named 인자를 쓰면 순서를 바꿀 수 있습니다.
- 같은 파라미터를 중복 지정하면 오류입니다.
- 필수 파라미터를 누락하면 오류입니다.

### Variadic Parameter

```bpp
func head_sum(head: u64, ...rest: u64) -> u64 {
    return head + rest;
}
```

variadic 사용 순서:

1. 고정 파라미터를 먼저 배치
2. 마지막 파라미터만 `...`로 선언
3. 호출부에서 추가 인자를 0개 이상 전달

### Function Pointer Style

```bpp
var fp: u64 = some_func;
var out: u64 = fp(10);
```

`u64` 함수 포인터는 유연하지만 타입 안정성이 약합니다.  
시그니처가 맞는지 호출자/피호출자 양쪽에서 명시적으로 유지해야 합니다.

### Lambda and Closure Handle

```bpp
var base: u64 = 40;
var inc: u64 = func (x: u64) -> u64 { x + base + 1 };
var v: u64 = inc(1);
```

람다는 `u64` 클로저 핸들로 취급되며, 캡처/복사 초기화를 지원합니다.

### Method Call Notes

```bpp
var out: u64 = TypeName.static_add(1, 2);
var out2: u64 = obj.instance_add(1, 2);
```

- static/direct 호출은 named 인자 지원 경로가 있습니다.
- instance method 호출도 named/default 인자를 지원합니다.

## Constraints

- variadic parameter는 마지막에만 허용됩니다.
- variadic parameter에 default 값은 금지됩니다.
- default parameter 뒤에 non-default parameter가 오면 오류입니다.
- by-ref lambda capture(`&x`)는 현재 함수 파라미터에 대해서만 허용됩니다.
- 로컬 변수에 대한 by-ref capture는 컴파일 오류입니다.
- LLVM build subset은 direct call, call pointer, primitive/narrow signature, small/large
  struct return, slice param/return을 fixture로 고정합니다.

### Invalid Examples

```bpp
// 잘못된 예: variadic 뒤에 일반 파라미터
func bad(...rest: u64, x: u64) -> u64 { return x; }
```

```bpp
// 잘못된 예: by-ref 로컬 캡처
var x: u64 = 1;
var f: u64 = func [&x] () -> u64 { x + 1 };
```

## Cautions

- 이름 있는 인자를 섞어 쓸 때는 중복/누락 파라미터가 발생하기 쉽습니다.
- 함수 포인터(`u64`) 기반 호출은 타입 안전성이 약하므로 시그니처 검증을 따로 해야 합니다.
- by-ref capture는 수명/escape 규칙 제약이 있으므로 우선 by-value capture를 기본값으로 두는 편이 안전합니다.

## Best Practices

- public API 함수는 default/named를 과도하게 섞지 말고 명시 호출을 우선합니다.
- variadic은 최소화하고 명시적 오버로드(또는 helper 함수)로 분리합니다.
- 람다를 API 경계로 넘길 때는 함수 타입 시그니처를 명시해 회귀를 줄입니다.
- ABI가 중요한 함수는 `45_llvm_build_runtime_fixture_bundle_success`와
  `46_llvm_build_abi_only_bundle_success` 같은 LLVM fixture에 작은 재현을 추가하는
  편이 안전합니다.
