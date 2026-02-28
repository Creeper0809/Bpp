# Diagnostics and Errors

이 페이지는 Bpp의 오류 진단 방식과 실패 케이스 검증 전략을 설명합니다.

## Why It Exists

- 언어 완성도는 "컴파일 성공"뿐 아니라 "실패 시 얼마나 정확히 설명하는가"에 크게 좌우됩니다.
- Bpp는 실패 케이스 테스트에서 오류 substring까지 검증합니다.

## How to Use

### Error Categories

- Lexer 오류: 잘못된 문자/리터럴/주석 종료 등
- Parser 오류: 예상 토큰 불일치, 문법 위반
- Semantic 오류: 타입/시그니처/접근제어/override/trait 규칙 위반
- Pipeline 오류: 특정 compiler pass 실패

### Reading Error Output

일반적으로 다음 정보를 우선 확인합니다.

1. line/column
2. expected vs got token
3. 구체 메시지 (예: named args 제한, throw 제약, decorator 시그니처 오류)

### Compile-fail Test

- `v11/test/source/*_fail*.bpp` 케이스는 의도적으로 실패해야 정상입니다.
- 진단 메시지 포함 여부까지 CI에서 검증합니다.

## Constraints (v11)

- 일부 경로는 아직 panic 기반 종료를 사용합니다.
- 진단 정밀도는 parser/semantic 분기마다 편차가 있습니다.
- 메시지 wording이 버전별로 바뀔 수 있으므로 테스트 substring은 핵심 문구 중심으로 유지해야 합니다.

## Cautions

- 테스트를 바꿔 실패를 숨기지 말아야 합니다.
- 성공 케이스가 깨질 때 테스트를 완화하기보다 컴파일러 원인을 우선 수정해야 합니다.
- 오류 메시지 개선은 동작 변화가 없더라도 회귀 위험이 있으므로 테스트를 같이 수정해야 합니다.

## Best Practices

- 새 문법 추가 시:
  - 성공 케이스 1개 이상
  - 대표 실패 케이스 1개 이상
  - 핵심 진단 substring 검증
- 동일한 종류의 실패는 suite 단위로 묶어 관리합니다.
