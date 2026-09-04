# Statements and Control Flow

이 페이지는 문장(statement) 레벨 문법과 제어 흐름 제약을 설명합니다.

## Why It Exists

- 제어문은 의미적으로 맞아도 lowering에서 제한이 걸릴 수 있는 영역입니다.
- 특히 `try/throw`, `match`, `for` 업데이트 절은 구현 제약을 명확히 아는 것이 중요합니다.

## How to Use

제어문은 "의미 일관성 + lowering 가능성"을 동시에 고려해 작성해야 합니다.

작성 순서:

1. 조건식 부작용 최소화
2. loop update를 명시적으로 유지
3. `break/continue/throw` 위치를 블록 단위로 검토

### Basic Statements

```bpp
var x: u64 = 0;
x = x + 1;
return x;
```

표현식 문장과 대입 문장은 분리해 쓰면 디버깅이 쉬워집니다.

### if / while / for

```bpp
if (x > 0) { ... } else { ... }

while (x < 10) {
    x = x + 1;
}

for (var i: u64 = 0; i < 10; i = i + 1) {
    ...
}
```

`for` 절 권장:

- init: 선언 또는 단순 대입
- cond: 순수 조건식
- update: 단순 증감/대입

### match

```bpp
match (v) {
    case 1: ...
    default: ...
}

match (v) {
    case 1: ...
    case _: ...
}
```

`switch`는 더 이상 surface syntax가 아니며, 기존 코드는 `match`로 옮겨야 합니다.

`match` 사용 시 주의:

- `case 1, 2, 3` 형태의 multi-value arm을 지원합니다.
- enum payload 바인딩(`case E.Some(x):`)을 지원합니다.
- `match expression`은 타입 일관성을 만족해야 합니다.

### try / catch / finally / throw

```bpp
try {
    ...
    throw 1;
} catch {
    ...
} finally {
    ...
}
```

`try` 작성 순서:

1. try 블록 최소화
2. catch/finally 중 최소 하나 명시
3. typed catch payload가 필요한지 확인 (`catch (e: T)`)

### Invalid Examples

```bpp
// 잘못된 예: try 핸들러 없음
try { var x: u64 = 1; }
```

```bpp
// 잘못된 예: wildcard와 명시 값 혼합
match (1) {
    case 1, _:
        return 0;
}
```

## Constraints

- `try`는 `catch` 또는 `finally` 중 하나 이상이 필수입니다.
- `throw`는 try 밖에서도 파싱/의미 분석이 허용됩니다.
- `match expression`은 기본적으로 `default` arm이 필요하지만, enum exhaustive인 경우 생략할 수 있습니다.
- `match expression`의 각 arm은 반환 타입을 일관되게 만족해야 합니다.
- `case _`와 명시 값을 동일 arm에 혼합할 수 없습니다.
- `do-while`과 ternary operator는 core runtime suite에서 고정되어 있습니다.
- SSA phi/parallel-copy 문제는 루프/분기 의미와 직접 관련되며
  `test/source/43_language_feature_runtime_bundle_success.bpp`의 parallel-copy phi
  케이스로 회귀를 잡습니다.

## Cautions

- `try`/`catch`는 payload 타입 불일치 시 즉시 컴파일 오류가 발생합니다.
- `match expression`으로 구조체를 직접 반환할 때는 함수/표현식 타입 힌트를 명확히 주는 것이 안전합니다.

## Best Practices

- 복잡한 `for` 절은 `while + 명시적 update`로 풀어 쓰면 디버깅이 쉽습니다.
- `try`/`catch`는 payload 타입을 명시해 진단 품질을 높입니다.
- `match expression`은 enum exhaustive 설계와 함께 사용해 `default` 의존을 줄입니다.
