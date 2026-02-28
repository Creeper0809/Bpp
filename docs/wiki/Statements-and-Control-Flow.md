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

### switch / match

```bpp
switch (v) {
    case 1: ...
    default: ...
}

match (v) {
    case 1: ...
    case _: ...
}
```

`match` 사용 시 주의:

- 현재는 패턴 매칭 언어 기능이 아니라 `switch` alias 성격
- `case _`는 default 대체 용도로 사용

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
3. throw는 try 내부, nested breakable 문맥 여부 확인

### Invalid Examples

```bpp
// 잘못된 예: try 핸들러 없음
try { var x: u64 = 1; }
```

```bpp
// 잘못된 예: try 바깥 throw
throw 1;
```

## Constraints (v11)

- `try`는 `catch` 또는 `finally` 중 하나 이상이 필수입니다.
- `throw`는 `try` 문맥 안에서만 허용됩니다.
- `throw`는 nested loop/switch 내부에서 제한됩니다.
- `match`는 현재 `switch` alias 성격이 강합니다(동일 AST 계열로 수렴).

## Cautions

- `throw`를 예외 시스템처럼 일반적으로 기대하면 안 됩니다.
  - 현재 구현은 lowering 기반 제약이 강합니다.
- `match`를 패턴 매칭 언어 수준으로 기대하면 과한 가정입니다.
  - 현재는 case 기반 분기와 거의 동일합니다.

## Best Practices

- 복잡한 `for` 절은 `while + 명시적 update`로 풀어 쓰면 디버깅이 쉽습니다.
- `try/throw`는 작은 블록으로 좁혀 제약 충돌을 줄입니다.
- `match`는 가독성 목적 정도로 사용하고, 고급 패턴은 별도 분기로 명시합니다.
