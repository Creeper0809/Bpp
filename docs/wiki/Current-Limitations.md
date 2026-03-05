# Current Limitations

이 페이지는 v11 기준 현재 제약 사항을 모아 정리합니다.

## Why It Exists

- "지원됨"과 "완전 일반화"를 구분하기 위해 필요합니다.
- 사용자/기여자가 구현 한계를 알고 설계/테스트 전략을 세울 수 있습니다.

## Known Limitations (v11)

1. Lambda by-ref capture 범위 제한
- `func [&x]`는 현재 함수 파라미터에 대해서만 허용됩니다.
- 로컬 변수 by-ref capture는 컴파일 오류입니다.

2. Lambda generic call target 제약
- lambda 내부 generic call target은 전역 심볼이어야 합니다.

3. Annotation 인수 제약
- built-in annotation(`@[entry]`, `@[override]`)은 인수를 받지 않습니다.
- decorator annotation도 현재 인수 전달(`@[deco(...)]`)을 지원하지 않습니다.

4. Decorator 시그니처 엄격 일치
- 첫 인자 `next: u64` + 나머지 파라미터/반환 타입이 대상과 정확히 맞아야 합니다.

5. `try`/`catch` 정적 규칙
- `try`는 `catch` 또는 `finally` 중 하나가 반드시 필요합니다.
- `catch`에서 바인딩 식별자를 쓰면 타입을 명시해야 합니다 (`catch (e: T)`).
- throw payload 타입과 typed catch payload 타입이 불일치하면 오류입니다.

6. `match expression` 제약
- 기본적으로 `default` arm이 필요합니다.
- 단, enum exhaustive arm이면 `default` 없이 허용됩니다.
- wildcard(`_`)와 명시 값을 동일 arm에 혼합할 수 없습니다.

7. Safe index와 try operator 구조 제약
- safe index(`x?[i]`)는 포인터 receiver에서만 허용됩니다.
- try operator(`x?`)는 try-compatible 구조(`is_some`, `value` 계열 검사)를 만족해야 합니다.

8. Generic bound/assoc type 엄격 검증
- `where` bound가 충족되지 않으면 컴파일 오류입니다.
- trait impl에서 필요한 associated type binding 누락 시 오류입니다.
- const generic 인자는 대상 타입 범위를 벗어나면 오류입니다(예: `bool`에 `2`).

## Recently Lifted (No Longer Limited)

- lambda capture 지원
- 인스턴스 메서드 named/default arguments 지원
- `throw`의 try 외부 문맥 파싱/의미 분석 지원
- enum payload match와 exhaustive enum match expression 지원
- generic 함수/impl 메서드 decorator 지원

## Cautions

- 제한 사항을 우회하려고 parser만 확장하면 후속 패스에서 실패합니다.
- 문법 허용이 곧 런타임 의미 보장을 뜻하지 않습니다.

## Upgrade Strategy

- 기능 확장은 최소 단위로 진행:
  1. parser 허용
  2. semantic 검증
  3. codegen 경로
  4. 성공/실패 테스트
- 기존 제한을 해제할 때는 실패 테스트를 성공 테스트로 승격하는 절차를 권장합니다.

## Related

- [Annotations and Decorators](Annotations-and-Decorators)
- [Statements and Control Flow](Statements-and-Control-Flow)
- [Diagnostics and Errors](Diagnostics-and-Errors)
