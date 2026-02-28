# Modules and Name Resolution

이 페이지는 모듈 import와 심볼 해석 과정을 설명합니다.

## Why It Exists

- Bpp는 모듈 단위 컴파일과 심볼 mangling을 함께 사용합니다.
- 이름 충돌을 피하고 cross-module 호출을 안정화하려면 해석 규칙이 중요합니다.

## How to Use

모듈 사용은 "경로 설계 -> import 방식 결정 -> 이름 충돌 방지" 순서로 진행합니다.

### Import Forms

```bpp
import std.io;
import str_eq from std.str;
import str_eq as eq from std.str;
```

권장 import 정렬:

1. 표준 라이브러리
2. 프로젝트 내부 모듈
3. selective/alias import

### Name Resolution Flow (High-level)

1. 토큰/파서가 import 선언 수집
2. 모듈 경로를 실제 파일 경로로 해석
3. module ID/prefix 계산
4. export map/alias map을 통해 최종 심볼 해석

### Prelude

- 표준 prelude 모듈은 기본 로딩 경로가 있습니다.
- 일반적으로 `std/*` 모듈 일부를 별도 import 없이 사용할 수 있는 기반을 제공합니다.

### Directory Pattern

예를 들어 아래 구조라면:

```text
modules/
  math.bpp
  util.bpp
main.bpp
```

`main.bpp`에서:

```bpp
import modules.math;
import add as add_i64 from modules.math;
```

### Invalid Examples

```bpp
// 잘못된 예: 존재하지 않는 모듈 경로
import modules.not_found;
```

```bpp
// 잘못된 예: export되지 않은 심볼 선택 import
import hidden_func from modules.math;
```

## Constraints (v11)

- import path가 잘못되면 pass1 또는 full parse에서 실패합니다.
- selective import는 해당 모듈 export 맵에 심볼이 있어야 합니다.
- 동일 이름의 로컬 선언/alias/prelude 심볼 충돌 시 해석 우선순위의 영향을 받습니다.

## Cautions

- "파일 경로"와 "모듈 식별자"가 항상 1:1로 보이는 것은 아닙니다.
- mangling된 이름과 원래 소스 이름을 혼동하면 디버깅이 어려워집니다.
- prelude로 자동 공급되는 심볼은 명시 import와 혼용할 때 충돌이 생길 수 있습니다.

## Best Practices

- 공개 모듈은 export 표면을 최소화합니다.
- 대규모 프로젝트에서는 alias 규칙을 문서화해 이름 충돌을 줄입니다.
- 경로 해석 문제는 먼저 module ID와 resolved path를 확인합니다.
