# Current Limitations

이 페이지는 v11 기준 현재 제약 사항을 모아 정리합니다.

## Why It Exists

- "지원됨"과 "완전 일반화"를 구분하기 위해 필요합니다.
- 사용자/기여자가 구현 한계를 알고 설계/테스트 전략을 세울 수 있습니다.

## Known Limitations (v11)

1. Lambda capture 미지원
- 외부 변수 캡처 시 컴파일 오류

2. 인스턴스 메서드 named arguments 미지원
- static/direct call에서는 지원되지만 instance method는 제한

3. `throw` 사용 맥락 제약
- try 외부 금지
- nested loop/switch 내부 throw 제한

4. Decorator 적용 범위 제한
- top-level non-generic 함수에 한정
- 시그니처 엄격 일치 필요

5. `match`는 현재 switch alias 성격
- 고급 패턴 매칭 기능(바인딩/구조 분해 등)은 미지원

6. 일부 타입 조합 제약
- tagged/복합 중첩 타입에서 제한 가능
- union은 상속/초기화 규칙 제약이 큼

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
