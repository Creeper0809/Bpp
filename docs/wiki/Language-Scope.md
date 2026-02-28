# Language Scope

이 문서는 Bpp v11이 어떤 문제를 해결하려는 언어/컴파일러인지, 그리고 실제 적용 범위를 설명합니다.

## Why It Exists

- Bpp는 시스템 프로그래밍에 필요한 저수준 제어(포인터, 메모리, 레이아웃 제어)와 언어 생산성 기능(impl/trait/generic/annotation)을 함께 제공하기 위해 설계되었습니다.
- "작동하는 컴파일러"뿐 아니라 self-hosting과 테스트 기반 진화를 목표로 합니다.

## How to Use

- 일반 사용자 관점:
  - `.bpp` 파일 작성
  - `bpp <file>.bpp` 또는 stage 바이너리로 컴파일/실행
- 개발자 관점:
  - `v11/src`에서 parser/compiler/codegen 계층을 분리해 수정
  - `v11/test/source` 케이스로 동작과 진단을 검증

## Constraints (v11)

- 일부 고급 문법은 완전 일반화보다 안정성 중심으로 제한되어 있습니다.
- 파서에서 허용하는 문법이라도 의미 분석(pass) 단계에서 금지될 수 있습니다.
- 플랫폼/도구체인(NASM, linker) 의존성이 있습니다.

## Cautions

- 문법 지원 여부와 "의미적으로 완전 지원"은 다를 수 있습니다.
- 새로운 문법을 추가할 때는 parser만 수정하면 불완전합니다.
  - compiler pass
  - codegen
  - 실패 진단
  - 테스트
  모두 동시에 맞춰야 회귀가 없습니다.

## Related

- [Compiler Internals](Compiler-Internals)
- [Testing and CI](Testing-and-CI)
