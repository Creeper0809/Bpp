# Declarations

이 페이지는 선언 구문(`var`, `const`, `enum`, `import`)을 정리합니다.

## Why It Exists

- 선언은 심볼 테이블과 이름 해석의 시작점입니다.
- 선언 규칙이 모호하면 모듈 경계/패스 간 일관성이 무너집니다.

## How to Use

선언은 아래 순서로 작성하면 충돌과 해석 오류를 크게 줄일 수 있습니다.

1. 상수/열거형처럼 기반이 되는 심볼을 먼저 선언
2. 전역 `var` 선언
3. 함수/impl에서 지역 `var` 선언
4. 필요한 모듈 import를 파일 상단에 정리

### Variable Declaration

```bpp
var g_count: u64 = 0;

func f() {
    var x: u64 = 10;
    var y = 20;
}
```

- 전역/지역 선언 모두 지원
- 타입 주석 생략은 문맥별 기본 경로를 따릅니다.

권장 템플릿:

```bpp
var <name>: <type> = <expr>;
```

타입 생략형은 빠르지만, 공개 API나 장기 유지 코드에서는 명시형을 권장합니다.

### Constant Declaration

```bpp
const LIMIT = 1024;
const NL = '\n';
```

- compile-time 상수 문맥에서 사용합니다.

권장 템플릿:

```bpp
const <NAME> = <const-expr>;
```

`const`는 런타임 계산값이 아니라 컴파일 시점에 확정 가능한 식으로 유지해야 진단이 명확합니다.

### Enum Declaration

```bpp
enum Color {
    RED,
    GREEN = 5,
    BLUE,
}
```

- 값 자동 증가를 지원합니다.

권장 템플릿:

```bpp
enum <Name> {
    A,
    B = 10,
    C,
}
```

### Import Declaration

```bpp
import std.io;
import str_eq from std.str;
import str_eq as eq from std.str;
```

- 모듈 전체 import
- 선택 import (`from`)
- 별칭 import (`as`)

실무 작성 순서:

1. 표준 모듈(`std.*`)부터 선언
2. 프로젝트 내부 모듈
3. 선택 import/alias import
4. 동일 심볼 alias 충돌 여부 확인

예시:

```bpp
import std.io;
import modules.math;
import add as add_u64 from modules.math;
```

### Invalid Examples

```bpp
// 잘못된 예: top-level에서 허용되지 않는 문장
if (1) { }
```

```bpp
// 잘못된 예: import 경로 토큰이 깨진 경우
import 'x';
```

## Constraints (v11)

- import path 형식이 잘못되면 파서/이름 해석 단계에서 실패합니다.
- top-level 문맥에서 허용되지 않는 선언은 즉시 오류입니다.
- annotation과 함께 사용할 때 target 제약이 적용됩니다.

## Cautions

- 선언 순서가 달라도 multi-pass에서 수집되지만, 모든 참조가 항상 안전한 것은 아닙니다.
- 모듈 prefix/mangling 때문에 "같아 보이는 이름"이 다르게 해석될 수 있습니다.
- enum/const를 런타임 값처럼 사용하면 의도와 다르게 최적화/치환될 수 있습니다.

## Best Practices

- 공개 API 수준 선언은 명시 타입을 권장합니다.
- import는 필요한 심볼만 제한적으로 가져와 충돌을 줄입니다.
- 상수/열거는 의미 단위로 묶어 테스트를 함께 관리합니다.
