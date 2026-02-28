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

### Lambda (Non-capturing)

```bpp
var inc: u64 = func (x: u64) -> u64 { x + 1 };
var v: u64 = inc(41);
```

현재 람다는 "비캡처 함수 리터럴"로 보는 것이 정확합니다.

### Method Call Notes

```bpp
var out: u64 = TypeName.static_add(1, 2);
var out2: u64 = obj.instance_add(1, 2);
```

- static/direct 호출은 named 인자 지원 경로가 있습니다.
- instance method 호출은 현재 named 인자 미지원입니다.

## Constraints (v11)

- variadic parameter는 마지막에만 허용됩니다.
- variadic parameter에 default 값은 금지됩니다.
- default parameter 뒤에 non-default parameter가 오면 오류입니다.
- 인스턴스 메서드 호출에서 named argument는 아직 미지원입니다.
- lambda capture(외부 변수 캡처)는 미지원입니다.

### Invalid Examples

```bpp
// 잘못된 예: variadic 뒤에 일반 파라미터
func bad(...rest: u64, x: u64) -> u64 { return x; }
```

```bpp
// 잘못된 예: instance method named args
obj.set(a: 1, b: 2);
```

## Cautions

- 이름 있는 인자를 섞어 쓸 때는 중복/누락 파라미터가 발생하기 쉽습니다.
- 함수 포인터(`u64`) 기반 호출은 타입 안전성이 약하므로 시그니처 검증을 따로 해야 합니다.
- lambda는 현재 설탕 수준이 아니라 실질 제약(캡처 금지)이 있으므로 범용 클로저처럼 쓰면 깨집니다.

## Best Practices

- public API 함수는 default/named를 과도하게 섞지 말고 명시 호출을 우선합니다.
- variadic은 최소화하고 명시적 오버로드(또는 helper 함수)로 분리합니다.
- lambda 대신 top-level helper function을 우선 고려하면 진단/디버깅이 쉽습니다.
