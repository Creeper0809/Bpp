# Testing and CI

이 페이지는 Bpp 테스트 구조와 CI 검증 흐름을 설명합니다.

## 1. 테스트 철학

- 성공 케이스: 실제 실행 결과까지 검증
- 실패 케이스: 컴파일 실패 + 오류 메시지까지 검증
- 회귀 방지: 신규 기능은 반드시 테스트 동반

## 2. 테스트 실행

전체:

```bash
test/run_tests.sh
```

빠른 프로필:

```bash
TEST_PROFILE=quick TEST_FAST_IO=1 TEST_JOBS=4 test/run_tests.sh
```

## 3. 테스트 파일 구성

- `test/source/*.bpp`
- suite 파일은 `//=== CASE ...` 기준으로 케이스를 분리
- 성공/실패 케이스를 카테고리별로 묶어 관리

## 4. CI 기본 검증 항목

- 빌드 성공
- self-hosting 일치 검증
- 테스트 스위트 통과
- 플랫폼별(특히 Linux/Windows) 동작 확인

## 5. 실패 분석 원칙

- 테스트를 바꿔 숨기지 않기
- 원인 컴파일러 코드를 직접 수정
- 오류 메시지 품질(정확성/가독성)도 함께 개선
