# Generics

이 페이지는 Bpp의 타입/상수 제네릭과 모노모피제이션 흐름을 설명합니다.

## Why It Exists

- 코드 재사용성과 타입 안전성을 동시에 유지하기 위해 generic이 필요합니다.
- Bpp는 multi-pass에서 시그니처를 먼저 수집하고, 이후 인스턴스화를 생성합니다.

## How to Use

제네릭은 "선언 -> 인수 지정 호출 -> 인스턴스화 확인" 순서로 접근하면 안정적입니다.

### Generic Function (Conceptual)

```bpp
func id<T>(x: T) -> T { return x; }
```

실사용(테스트 기반) 예시:

```bpp
func id<T>(x: T) -> T { return x; }
var a: i64 = id<i64>(42);
var b: i64 = id(7); // 타입 추론
```

### Const Generic (Conceptual)

```bpp
struct Buf<T, N> {
    data: [N]T;
}
```

실사용(테스트 기반) 예시:

```bpp
func size_of_buf<const N: u64>() -> u64 {
    return sizeof([N]u64);
}
var sz: u64 = size_of_buf<4>();
```

실제 사용 구문은 현재 파서/테스트 케이스(`v11/test/source/10_generics.bpp`, `11_const_generics_sizeof.bpp`) 기준으로 따르십시오.

### Generic Struct Usage

```bpp
struct Pair<T, U> {
    public a: T;
    public b: U;
}

var p: Pair<i64, i64>;
p.a = 10;
p.b = 32;
```

### Invalid Examples

```bpp
// 잘못된 예: 타입 인자 수 불일치
var p: Pair<i64>;
```

```bpp
// 잘못된 예: const generic 타입 불일치
var s: u64 = size_of_buf<"x">();
```

## Constraints (v11)

- generic은 선언/호출/인스턴스화가 모두 맞아야 합니다.
- 일부 조합(특히 고차 제네릭, 복합 타입 조합)은 제한될 수 있습니다.
- generic 함수/구조체는 이름 mangling과 인스턴스 캐시를 사용합니다.

## Cautions

- "generic 선언이 있다"와 "모든 호출이 자동 지원된다"는 다릅니다.
- 타입 인자 누락/불일치가 파서가 아니라 의미 단계에서 드러날 수 있습니다.
- codegen 이전 모노모피제이션 결과를 기준으로 디버깅해야 원인 추적이 빠릅니다.

## Best Practices

- 인스턴스화 패턴을 테스트로 고정합니다.
- generic API는 최소 단위로 쪼개서 진단 메시지가 명확하게 나오도록 설계합니다.
- 성능 민감 구간은 생성되는 인스턴스 수를 확인합니다.
