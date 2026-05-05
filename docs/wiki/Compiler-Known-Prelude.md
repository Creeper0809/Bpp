# Compiler-Known Prelude

이 문서는 Bpp 표면 문법 중에서 "일반 stdlib처럼 보이지만 컴파일러가 특별 취급하는 항목"을 정리합니다.

## Why It Exists

- Bpp는 시스템 언어 코어 위에 제한된 문맥 설탕을 올립니다.
- 이때 일부 타입/함수는 단순 라이브러리 심볼이 아니라 parser/lowering/typeinfo가 알고 있는 이름입니다.

## Current Rules

- `number`와 `string`은 둘 다 compiler-known prelude 이름입니다.
  - `number`는 lexer primitive가 아니라 std `Number` 타입으로 해석되는 known type name입니다.
  - source에서는 `number`와 `Number`를 같은 prelude type family로 취급합니다.
  - `number`의 numeric tower, 연산 의미, 최적화는 [Number](Number)에 정리되어 있습니다.
  - `string`은 std 타입이며, 문자열 리터럴과 `input<string>()`은 `string_from_cstr`/`string_input`으로 lowering됩니다.
- `input<T>()`은 compiler-known prelude generic sugar입니다.
  - `input<number>()`, `input<string>()`, `input<i64>()`, `input<[]u8>()` 같은 형태를 사용합니다.
  - lowering은 `number_input`, `string_input`, `input_i64`, `input_slice` 같은 전용 경로로 연결됩니다.
  - plain `input()`은 low-level std.io raw input 함수로 남아 있습니다.
- `print`/`println` 1-인자 sugar는 formatting 계층입니다.
  - 값은 `to_str()` 계열을 거쳐 문자열로 변환됩니다.
  - 현재 구현에서는 buffered text output 경로를 사용합니다.
- `emit`/`emitln`은 raw text emission 계층입니다.
  - 인자는 C-string 포인터여야 합니다.
  - formatting 없이 즉시 출력됩니다.

## Output Flush Contract

`print`/`println`은 buffered text output 계층이고, `emit`/`emitln`은 raw emission
계층입니다. 현재 런타임은 다음 동작을 테스트로 고정합니다.

- buffered numeric printer는 출력 순서를 보존합니다.
- raw `emit`/`emitln`은 pending buffered text를 먼저 flush해야 합니다.
- `main`이 정상 return하면 buffered print output이 flush되어야 합니다.

대표 테스트:

- `test/source/14_print_anything_success.bpp`
- `test/source/26_output_runtime_corner_cases_success.bpp`
- `test/source/34_print_flush_on_return_success.bpp`
- `test/source/43_language_feature_runtime_bundle_success.bpp`

## Philosophy

- core language:
  - 메모리, 포인터, 구조체, 제어 흐름
- compiler-known prelude:
  - 한 번에 설명 가능한 문맥 설탕
- ordinary stdlib:
  - 이름 해석만으로 충분한 일반 라이브러리 API

새 sugar를 추가할 때는 "ordinary stdlib로 충분한가?"를 먼저 보고, 정말 필요할 때만 compiler-known prelude로 승격합니다.
