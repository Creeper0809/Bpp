# Expressions

이 페이지는 Bpp의 표현식 체계와 lowering 포인트를 설명합니다.

## Why It Exists

- 표현식은 파서 precedence, 타입추론, 코드생성이 모두 결합된 영역입니다.
- 문법은 단순해 보여도 내부적으로는 여러 sugar가 assignment/call 형태로 내려갑니다.

## How to Use

### Core Operators

```bpp
var a: u64 = 1 + 2 * 3;
var b: u64 = (a << 2) & 7;
var ok: bool = (a > 0) && (b != 0);
```

### Unary / Cast / Sizeof

```bpp
var p: *u64 = &a;
var v: u64 = *p;
var i: i64 = (i64)a;
var sz: u64 = sizeof(u64);
```

### Member / Index / Safe Navigation

```bpp
var v0: u64 = arr[0];
var x: u64 = obj.field;
var y: u64 = obj.?field;
```

### IncDec / Compound Assignment

```bpp
x++;
++x;
x += 5;
x *= 2;
```

## Constraints (v11)

- `++/--`는 대입 가능한 표현식에서만 허용됩니다.
- `++/--`는 내부적으로 대입 구문으로 lowering 됩니다.
- compound assignment도 동일하게 `x = x <op> rhs` 형태로 변환됩니다.

## Cautions

- `++/--`를 일반 식으로 취급하면 오해가 생길 수 있습니다.
  - 구현은 statement sugar 중심입니다.
- safe navigation(`.?`)은 일반 member access와 lowering 경로가 다르므로 SSA/최적화 적용 범위가 달라질 수 있습니다.

## Best Practices

- side effect가 많은 표현식은 문장으로 분리해 가독성을 유지합니다.
- operator chaining은 괄호로 의도를 명시합니다.
- cast는 경계 지점에서만 수행하고 내부 로직은 일관 타입을 유지합니다.
