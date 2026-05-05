# Object Construction

이 문서는 Bpp의 객체 생성/초기화 모델을 정리합니다.

## Core Roles

- `Type{...}`
  - aggregate/data initialization
- `Type(...)`
  - constructor-oriented value construction
- `new Type{...}`
  - heap allocation + aggregate initialization
- `new Type{...}()`
  - heap allocation + aggregate initialization + constructor phase

## Current Surface Model

- Bpp는 heap 경로에서 `new Type{...}()`를 정식 지원합니다.
- 즉, 저장소 획득과 데이터 초기화, 생성자 행위를 한 문장 안에서 분리해 표현할 수 있습니다.
- 이 모델에서는:
  1. `new`가 저장소를 확보하고
  2. `{}`가 초기 데이터를 채우고
  3. `()`가 constructor를 실행합니다.

예시:

```bpp
struct Node {
    public id: i64;
}

impl Node {
    public constructor() {
        self.id = self.id + 10;
    }

    public destructor {
        // delete 시점에 실행됩니다.
    }
}

var p: *Node = new Node{123}();
delete p;
```

`new Type{...}`와 `new Type{...}()`는 다릅니다. 앞의 형태는 저장소 확보와
aggregate initialization까지만 표현하고, 뒤의 형태는 명시 constructor phase까지
요구합니다.

## Stack-New Lowering

표면 문법은 `new`여도, SSA/O1 경로는 일부 no-escape allocation을 스택 slot으로
낮출 수 있습니다. 이 최적화는 사용자가 직접 `stack new` 같은 별도 문법을 쓰는
기능이 아니라, 기존 `new` 의미를 보존하는 backend lowering입니다.

현재 metadata 기준:

- `bpp.ssa.new_stack_lowering=escape-stack-slot`
- `bpp.ssa.stack_new.noescape_summary=interprocedural`
- `bpp.ssa.stack_new.tag_policy=escape-lifecycle`
- `bpp.ssa.stack_new.sroa=field-address`

동작 원칙:

- constructor가 있으면 aggregate 값이 채워진 뒤 constructor를 실행합니다.
- destructor가 있으면 `delete` 지점에서 기존 의미와 같은 순서로 실행되어야 합니다.
- 포인터가 전역 저장, escaping call, 반환 등으로 새면 heap allocation 경로를
  유지해야 합니다.
- no-escape로 판단되면 로컬 stack slot과 field address/load/store 중심으로 낮출 수
  있습니다.
- tagged pointer로 관측되는 경우 no-escape allocation은 `storage=stack`,
  `ownership=stack` 정책을 가질 수 있고, escape allocation은 heap/escaped 정책을
  가져야 합니다.

테스트 기준은 `test/source/43_language_feature_runtime_bundle_success.bpp`의
`bundle_case__22b_stack_new_slot_lowering`입니다.

## Design Intent

- 중괄호는 데이터 모양을 드러냅니다.
- 소괄호는 호출/행위를 드러냅니다.
- `new`는 저장소 획득을 드러냅니다.

즉, Bpp의 생성 문법은 "메모리", "데이터", "행위"를 서로 다른 표면 기호로 분리하는 방향을 지향합니다.

## Caution

- value 경로의 모든 조합이 동일하게 열려 있는 것은 아닙니다.
- 상속된 타입의 constructor는 더 이상 자동으로 부모 constructor를 주입받지 않습니다.
  - 부모 constructor가 존재하면 derived constructor에서 `super.constructor();`를 명시적으로 호출해야 합니다.
- stack-new lowering은 최적화입니다. 프로그램이 힙 주소의 장기 생존을 전제로 하거나
  포인터를 외부로 escape시키면 스택으로 낮추면 안 됩니다.
- 새 생성 문법을 추가할 때는 parser만이 아니라 lowering, typeinfo, SSA/codegen, diagnostics, tests까지 함께 맞춰야 합니다.
