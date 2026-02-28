# Language Reference

이 페이지는 Bpp 언어 기능을 사용자 관점에서 요약합니다.

## 1. 기본 문법 요소

- 함수: `func`
- 변수/상수: `var`, `const`
- 구조체/구현: `struct`, `impl`
- 트레잇: `trait`, `impl Trait for Type`
- 제어문: `if`, `while`, `for`, `switch`, `match`, `try/catch/finally`

## 2. 타입 시스템

- 정수/부동소수: `u8/u16/u32/u64`, `i8/i16/i32/i64`, `f64`
- 포인터: `*T`
- 배열/슬라이스: `[N]T`, `[]T`
- 구조체/트레잇 타입
- 제네릭(타입/상수)

## 3. 함수 호출 기능

- 기본 인자(default arguments)
- 이름 있는 인자(named arguments)
- 정적/인스턴스 메서드 호출
- 함수 포인터 호출

## 4. 어노테이션과 데코레이터

- 선언 어노테이션 문법: `@[name]`
- 예: `@[entry]`, `@[used]`, `@[hot]`
- 함수 이름을 어노테이션으로 쓰면 데코레이터로 해석 가능
- 데코레이터는 시그니처 검증 후 래퍼 함수로 낮춰져 동작이 바뀜

## 5. 제약/주의사항(요약)

- 일부 고급 기능은 점진적으로 확장 중
- 실패 케이스는 테스트 스위트에서 엄격 검증
- 구현 세부는 [Compiler Internals](Compiler-Internals) 참고

## 상세 문서 분리 예정

- Lexical Rules
- Type System
- Functions and Calls
- Struct / Impl / Inheritance
- Trait / Virtual Dispatch
- Generics
- Annotations and Decorators
