# Traits and Virtual Dispatch

이 페이지는 trait 시스템과 virtual dispatch 구성 방식을 설명합니다.

## Why It Exists

- Bpp는 구현 재사용과 다형성 경로를 trait + impl로 제공합니다.
- 컴파일러는 trait 시그니처 검증, thunk 생성, vtable 전개를 pass에서 처리합니다.

## How to Use

trait 사용 순서:

1. trait에 필요한 최소 메서드 시그니처 정의
2. 각 대상 구조체에 `impl Trait for Type` 작성
3. 시그니처/self 타입 정합성 검증
4. 호출 경로 테스트(정적/가상) 추가

### Trait Definition

```bpp
trait Drawable {
    func draw(self: *Self);
}
```

trait는 "행동 계약"만 정의하고 저장 레이아웃은 포함하지 않습니다.

### Trait Implementation

```bpp
impl Drawable for Sprite {
    func draw(self: *Sprite) {
        ...
    }
}
```

impl에서는 self 타입이 대상 구조체와 일치해야 하며, trait 시그니처와 파라미터/반환 타입이 맞아야 합니다.

### Practical Pattern

```bpp
trait Area {
    func area(self: *Self) -> u64;
}

impl Area for Rect {
    func area(self: *Rect) -> u64 {
        return self.w * self.h;
    }
}
```

### Invalid Examples

```bpp
// 잘못된 예: trait impl self 타입 불일치
impl Area for Rect {
    func area(self: *Other) -> u64 { return 0; }
}
```

```bpp
// 잘못된 예: trait impl 금지 수식자 사용
impl Area for Rect {
    static func area(self: *Rect) -> u64 { return 0; }
}
```

## Constraints (v11)

- impl 메서드 시그니처는 trait 시그니처와 엄격히 일치해야 합니다.
- self 타입 규칙 위반 시 컴파일 오류입니다.
- trait impl 메서드에서는 static/abstract/override 같은 일부 수식자가 금지됩니다.
- trait method에서 Self 사용 위치(반환/파라미터) 제약이 있습니다.

## Cautions

- trait는 문법만 맞으면 되는 기능이 아닙니다.
  - trait def
  - impl def
  - vtable 생성
  - call site
  가 모두 맞아야 동작합니다.
- default impl을 사용할 때도 최종 시그니처 검증이 수행되므로 "암묵적 호환"을 기대하면 안 됩니다.

## Best Practices

- trait 메서드는 최소한의 표면 API로 유지합니다.
- impl마다 시그니처 mismatch 테스트를 추가합니다.
- 가상 디스패치가 필요한 지점과 정적 dispatch 지점을 분리해 성능/가독성을 관리합니다.
