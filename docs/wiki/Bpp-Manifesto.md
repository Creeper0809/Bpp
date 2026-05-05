# Bpp Manifesto

이 문서는 Bpp가 어떤 시스템 언어가 되려는지, 그리고 어떤 경쟁 축에서 차별화되려는지를 짧고 단단하게 정리합니다.

## Core Thesis

Bpp는 저수준 제어를 유지하면서, 프로그램의 의도와 계약을 정적으로 드러내는 시스템 언어를 지향합니다.

여기서 계약(contract)은 단순 타입 선언만을 뜻하지 않습니다. Bpp는 다음과 같은 층위의 계약을 표면 문법에 올리는 방향을 택합니다.

- 생성 계약: 값이 어떻게 할당되고 초기화되며 생성되는가
- 접근 계약: 어떤 필드/프로퍼티가 어떤 규칙으로 읽히고 써지는가
- 선언 계약: decorator, annotation, metadata가 어떤 의도를 표현하는가
- 비용 계약: 코드가 어떤 복잡도와 제약을 전제로 하는가
- 실용 계약: compiler-known prelude가 어떤 문맥 설탕을 제공하는가

## Five Statements

1. Bpp는 계약이 드러나는 시스템 언어다.
2. Bpp는 메모리, 초기화, 생성, 접근 규칙을 숨기지 않는다.
3. Bpp의 계약은 지역적이고 정적이어야 한다.
4. Bpp의 설탕 문법은 항상 설명 가능한 desugaring을 가져야 한다.
5. Bpp 컴파일러의 역할은 단순 번역기가 아니라 계약 검증기여야 한다.

## Why This Direction

Rust는 메모리 소유권과 수명 규칙을 중심으로 강한 안전성을 제공합니다. Bpp는 그 철학을 복제하려 하지 않습니다. 대신 다음 경쟁 축을 택합니다.

- 메모리 규칙만이 아니라 의도와 제약을 더 많이 표면화합니다.
- 타입만이 아니라 property, decorator, metadata, complexity로 상위 계층 계약을 표현합니다.
- 코드의 의미를 함수/타입/선언 단위에서 더 지역적으로 읽히게 만듭니다.

즉, Bpp의 목표는 "또 다른 C-like 언어"가 아니라, 계약을 더 많이 드러내는 시스템 언어가 되는 것입니다.

## AI Era Fit

AI는 암묵적 규칙이 많은 코드보다, 지역적이고 선언적인 제약이 붙은 코드를 더 안정적으로 다룹니다.

Bpp는 다음 강점을 노립니다.

- 함수/타입/프로퍼티 선언만 보고도 제약을 읽을 수 있음
- decorator와 metadata를 통해 코드 생성 조건을 더 짧은 문맥에서 파악할 수 있음
- diagnostics가 "무엇이 틀렸는가"를 넘어 "어떤 계약을 깼는가"를 설명할 수 있음

이 방향이 성공하려면 계약이 장식품으로 남아서는 안 됩니다. 계약은 실제로 검사되거나, 최소한 진단과 도구 체인에서 의미 있게 반영되어야 합니다.

## What Bpp Must Prove

Bpp가 이 철학을 실제 경쟁력으로 만들려면 다음을 구현으로 증명해야 합니다.

1. contract-aware diagnostics
2. property, decorator, metadata의 일관된 합성 규칙
3. complexity 같은 선언적 계약을 읽는 정적 분석
4. lowering/SSA/codegen 이후에도 계약 의미를 보존하는 pass 설계
5. 시스템 언어로서 신뢰할 수 있는 메모리 위험 통제 전략

## Non-Goals

- Rust의 ownership 모델을 그대로 복제하는 것
- annotation으로 언어 핵심 의미를 전부 대체하는 것
- 문맥 없는 마법 같은 sugar를 늘리는 것

## Related

- [Language Scope](Language-Scope)
- [Compiler-Known Prelude](Compiler-Known-Prelude)
- [Annotations and Decorators](Annotations-and-Decorators)
- [Diagnostics and Errors](Diagnostics-and-Errors)
- [LLVM Contract Boundary](LLVM-Contract-Boundary)
