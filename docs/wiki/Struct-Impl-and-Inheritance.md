# Struct, Impl, and Inheritance

이 페이지는 구조체/impl/상속 규칙을 설명합니다.

## Why It Exists

- Bpp의 객체 모델은 클래스가 아니라 `struct + impl` 중심입니다.
- 상속/접근제어/override 검증이 compiler pass에서 수행되므로 문법과 의미를 함께 이해해야 합니다.

## How to Use

권장 작성 순서:

1. 데이터 레이아웃(`struct`) 먼저 정의
2. 동작(`impl`)을 인스턴스/정적 메서드로 분리
3. 상속 도입 시 override 규칙 테스트 추가

### Struct

```bpp
struct Base {
    public x: u64;
}

struct Child : Base {
    public y: u64;
}
```

상속을 쓸 때는 부모 필드 접근 권한(`public/protected/private`)을 먼저 확인해야 합니다.

### Impl

```bpp
impl Child {
    public func sum(self: *Child) -> u64 {
        return self.x + self.y;
    }

    public static func make(v: u64) -> Child {
        return Child { v, v };
    }
}
```

impl 분리 패턴:

- 생성 관련: constructor/static make
- 조회 관련: getter/read-only
- 변경 관련: mutation methods

### Override

```bpp
impl Child {
    @[override]
    public func f(self: *Child) -> u64 { ... }
}
```

override 체크리스트:

1. 부모에 동일 이름 후보가 있는가
2. 접근 제어상 override 가능한가
3. trait impl 블록이 아닌가
4. 시그니처가 의도대로 맞는가

### Invalid Examples

```bpp
// 잘못된 예: 부모 대상 없는 override
impl Child {
    @[override]
    public func unknown(self: *Child) -> u64 { return 0; }
}
```

```bpp
// 잘못된 예: union 상속
union U : Base {
    a: u64;
}
```

## Constraints (v11)

- `@[override]`는 부모 대상이 있어야 합니다.
- trait impl 메서드에서 `@[override]`는 금지됩니다.
- 생성자/소멸자와 override/abstract/static 조합에는 제약이 있습니다.
- `union`은 상속 금지입니다.

## Cautions

- "이름만 같으면 override"가 아닙니다.
  - 접근제어/시그니처/계층 검색 결과까지 맞아야 합니다.
- private/protected 접근 실패는 런타임이 아니라 컴파일 단계에서 막힙니다.
- constructor sugar가 자동 삽입되는 경로가 있어 의도와 다른 호출이 생길 수 있으니 생성자 시그니처를 명확히 유지해야 합니다.

## Best Practices

- override 의도는 항상 `@[override]`로 명시합니다.
- impl 블록을 역할별(생성/조회/변경)로 나누어 관리합니다.
- 상속 계층이 깊어질수록 메서드 이름 충돌 테스트를 추가합니다.
