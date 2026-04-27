# Language Scope

이 문서는 Bpp v11이 어떤 문제를 해결하려는 언어/컴파일러인지, 그리고 실제 적용 범위를 설명합니다.

## Why It Exists

- Bpp는 시스템 프로그래밍에 필요한 저수준 제어(포인터, 메모리, 레이아웃 제어)를 중심에 두고, 그 위에 제한된 생산성 기능(impl/trait/generic/annotation)을 얹는 언어로 설계되었습니다.
- "작동하는 컴파일러"뿐 아니라 self-hosting과 테스트 기반 진화를 목표로 합니다.

## Core Thesis

- Bpp는 저수준 제어를 유지하면서, 프로그램의 의도와 계약을 정적으로 드러내는 시스템 언어를 지향합니다.
- 여기서 계약은 타입 선언만이 아니라 생성, 접근, 선언, 비용, compiler-known prelude의 사용 규칙까지 포함합니다.
- Bpp 컴파일러는 단순 번역기가 아니라, 가능한 범위 안에서 이 계약을 읽고 보존하고 설명하는 쪽으로 발전해야 합니다.

## Language Shape

- Bpp의 기본 철학은 "명시적 시스템 언어 + 제한된 문맥 설탕"입니다.
- 같은 개념에는 가능하면 하나의 대표 표면 문법을 둡니다.
  - 예: 분기 계열은 `match`를 중심으로 이해합니다.
- 표면 문법은 다음 세 계층으로 나누어 이해하는 것이 가장 정확합니다.
  - core language
  - compiler-known prelude
  - annotation layer
- property hook은 더 이상 annotation layer에 속하지 않으며, core language의 member access 규칙으로 다룹니다.
- annotation layer는 현재 다음 두 역할을 가집니다.
  - decorator: 선언을 감싸는 변환
  - metadata: 분석/제약/도구용 정보

## How to Use

- 일반 사용자 관점:
  - `.bpp` 파일 작성
  - `bpp <file>.bpp` 또는 stage 바이너리로 컴파일/실행
- 개발자 관점:
  - `src`에서 parser/compiler/codegen 계층을 분리해 수정
  - `test/source` 케이스로 동작과 진단을 검증

## Constraints (v11)

- 일부 고급 문법은 완전 일반화보다 안정성 중심으로 제한되어 있습니다.
- 파서에서 허용하는 문법이라도 의미 분석(pass) 단계에서 금지될 수 있습니다.
- 플랫폼/도구체인(NASM, linker) 의존성이 있습니다.
- compiler-known prelude에는 `number`, `string`, `input<T>()`, `print`/`println`, `emit`/`emitln`처럼 컴파일러가 특별 취급하는 이름이 포함됩니다.
- annotation layer는 모든 것을 같은 의미로 다루지 않습니다.
  - decorator는 wrapper generation 같은 선언 변환을 담당합니다.
  - metadata는 complexity/constraints 같은 분석 정보를 담당합니다.
- 진단 메시지는 phase tag, 핵심 메시지, note/help를 포함하는 방향으로 정리되고 있지만, 아직 일부 경로에는 편차가 남아 있습니다.

## Cautions

- 문법 지원 여부와 "의미적으로 완전 지원"은 다를 수 있습니다.
- 문서상 같은 계층으로 묶인 기능이라도 구현 레이어(parser/lowering/typeinfo/runtime)는 서로 다를 수 있습니다.
- `print`/`println`과 `emit`/`emitln`은 같은 출력이 아니라 서로 다른 계층입니다.
  - `print`/`println`: formatting-friendly output
  - `emit`/`emitln`: raw text emission
- `input<T>()` 같은 prelude sugar는 표면 문법은 generic처럼 보이지만 lowering 단계에서 전용 std 경로로 변환됩니다.
- 새로운 문법을 추가할 때는 parser만 수정하면 불완전합니다.
  - compiler pass
  - codegen
  - 실패 진단
  - 테스트
  모두 동시에 맞춰야 회귀가 없습니다.
- 표면 문법 정리는 문서만 바꿔서는 끝나지 않습니다.
  - parser keyword
  - lowering 규칙
  - SSA/non-SSA backend
  - compile-fail diagnostics
  까지 함께 맞춰야 실제 언어 철학과 구현이 일치합니다.

## Related

- [Bpp Manifesto](Bpp-Manifesto)
- [Contract Checklist](Contract-Checklist)
- [Compiler Internals](Compiler-Internals)
- [Compiler-Known Prelude](Compiler-Known-Prelude)
- [Diagnostics and Errors](Diagnostics-and-Errors)
- [Object Construction](Object-Construction)
- [Testing and CI](Testing-and-CI)
