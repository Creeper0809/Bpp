# Compiler Internals

이 페이지는 v11 컴파일러 파이프라인과 주요 패스를 설명합니다.

## 1. 큰 흐름

1. Lexer: 토큰화
2. Parser: AST 생성
3. Lowering Passes: 문법 설탕 제거/정규화
4. Semantic Passes: override/trait/entry/annotation 검증 및 적용
5. Monomorphization: 제네릭 실체화
6. Codegen: ASM 생성 및 링크

## 2. 주요 컴포넌트

- `v11/src/compiler.bpp`: 컴파일러 컨텍스트, 패스, 의미 분석
- `v11/src/parser/*`: 파서 구현
- `v11/src/codegen.bpp`, `v11/src/emitter/*`: 코드 생성
- `v11/src/ssa/*`: SSA/IR 경로

## 3. 최근 핵심 변화(v11)

- 전역 상태를 `CompilerCtx`로 집중 관리
- 어노테이션을 의미 단계에서 해석/적용
- `@[entry]` 기반 엔트리 함수 선택
- 데코레이터 어노테이션을 래퍼 함수로 lowering

## 4. 패스 설계 원칙

- 파싱 단계: 문법 인식 + AST 보존
- 컴파일 단계: 의미 검증 + 변환
- 코드젠 단계: 타깃 코드 출력
- 테스트 단계: 성공/실패 케이스 모두 고정

## 5. 디버깅 팁

- 특정 패스 전후 AST/시그니처 변화를 확인
- 실패 메시지의 "어떤 패스에서 실패했는지"를 우선 추적
- quick profile 테스트로 재현 시간을 단축
