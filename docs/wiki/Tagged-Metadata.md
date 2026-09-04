# Tagged Metadata

Bpp의 tagged pointer는 포인터 상위 비트에 작은 메타데이터를 싣는 기능입니다.
기본 주소는 하위 48비트로 유지하고, 태그 레이아웃은 `packed struct`로
정의합니다.

## 공통 태그

표준 라이브러리의 `BppObjectTag`는 객체와 컨테이너가 함께 쓸 수 있는 16비트
공통 태그입니다.

- `lifecycle`: `young`, `old`, `arena`, `borrowed`, `pinned`, `immortal`, `dead`
- `ownership`: `owned`, `borrowed`, `shared`, `weak`, `unique`, `escaped`, `stack`
- `storage`: `heap`, `stack`, `arena`, `static`, `foreign`, `inline`, `vector`
- `barrier`: `clean`, `dirty`, `skip`
- `shape`: 값 또는 컨테이너 원소 형태
- `profiled`: 프로파일 기반 빠른 경로 후보 여부

이 태그는 런타임에서 다음 판단에 사용됩니다.

- borrowed, arena, immortal, stack 포인터는 `delete`에서 해제하지 않습니다.
- unique, borrowed, weak, immortal 포인터는 참조 카운트 갱신을 생략할 수 있습니다.
- clean, skip, stack, static, immortal 포인터는 GC/write barrier를 생략할 수 있습니다.
- tagged slice는 shape와 profiled 비트로 벡터화/특수화 후보를 표시합니다.

## 객체 API

```bpp
var p: *Node = new Node{1};
var h: BppTaggedObject<Node> = bpp_tag_object_heap_owned<Node>(p);

bpp_tag_object_mark_old<Node>(&h);
delete h.ptr;
```

빌린 포인터는 같은 타입으로 표현하지만 소유권 태그가 다릅니다.

```bpp
var borrowed: BppTaggedObject<Node> = bpp_tag_object_borrowed<Node>(p);
delete borrowed.ptr; // 해제하지 않음
```

## 컨테이너 API

`Vec<T>`는 내부 버퍼를 tagged slice view로 노출할 수 있습니다.

```bpp
var values: Vec<u64> = Vec<u64>{4};
values.push(1);
values.push(2);

var s: BppTaggedSlice<u64> = values.profiled_tagged_slice(BPP_TAG_SHAPE_U64);
if (bpp_tag_slice_is_vector_candidate<u64>(&s) != 0) {
    // loop specialization 후보
}
```

## Fast Path와 Proof Layer

tagged metadata는 단순히 포인터에 예쁜 라벨을 붙이는 기능이 아닙니다. 현재 구현은
런타임 정책 함수와 SSA/LLVM prototype이 읽을 수 있는 optimization contract로
사용합니다.

주요 소비 지점:

- tagged delete: lifecycle/ownership/storage를 보고 destructor/free 가능 여부 판단
- refcount fast path: unique/borrowed/weak/immortal/stack 성격에 따라 retain/release 생략
- barrier fast path: clean/skip/static/stack/immortal 성격을 보고 write barrier 생략
- shape cache: slice/object shape와 epoch를 보고 빠른 경로 선택
- proof slice: stable nonnull, index/range bounds, vectorize 가능성을 별도 proof로 운반
- Vec/Number proven access: bounds check를 통과한 접근은 proven pointer/load/store로 낮춤

## LLVM Vector Lowering

tagged slice는 shape와 profiled bit가 맞을 때 LLVM prototype에서 vector lowering
후보가 됩니다.

현재 고정된 패턴:

- sum: `i64`/`f64` slice를 `<4 x i64>` 또는 `<4 x double>` load 중심으로 처리
- min/max: signed/unsigned/f64 비교를 vector compare로 처리
- count-eq: vector equality compare와 mask/select를 사용
- find-eq: vector compare 후 matching lane을 찾아 index를 반환하고, 없으면 `-1`

이 경로는 항상 켜지는 것이 아니라 guard 기반입니다. shape, length, profiled bit,
bounds proof가 맞지 않으면 scalar/cold path가 correctness를 책임져야 합니다.

## 현재 구현 범위

현재 구현은 공통 태그 레이아웃, 런타임 정책 함수, tagged delete, Vec tagged
slice, loop profile 후보 판정, shape/proof 기반 fast path, LLVM prototype vector
lowering metadata를 제공합니다. 완전한 GC나 production-grade 참조 카운터는 아직
이 태그 정보를 소비하는 다음 런타임/컴파일러 계층의 몫입니다.

## 벤치마크 기준

tagged metadata 최적화는 다음 기준으로 튜닝합니다.

- tagged delete: borrowed/arena/immortal 포인터가 destructor와 free를 건너뛰는지
- refcount 후보: unique/borrowed/weak/immortal 포인터가 카운터 갱신을 건너뛰는지
- barrier 후보: clean/skip/stack/static/immortal 포인터가 write barrier를
  건너뛰는지
- slice shape: 같은 shape가 유지되는 루프에서 generic 경로보다 빠른 특수화 후보가 선택되는지
- loop profile: 반복 횟수가 임계값을 넘은 뒤에만 fast path 후보가 켜지는지
- proof access: bounds proof가 있는 Vec/Number 접근에서 proven pointer/load/store가 선택되는지
- vector lowering: tagged slice sum/min/max/count/find가 기대한 LLVM vector marker를 남기는지

회귀 테스트는 현재 `test/source/39_tagged_metadata_runtime_bundle_success.bpp`가
대표 번들로 담당합니다. 그 안에는 예전 단일 케이스였던 tagged metadata, consumers,
slice vector lowering, fastpath reliability 테스트가 함께 묶여 있습니다.
성능 수치는 별도 벤치마크에서 같은 입력 크기, 같은 backend, 같은 최적화 옵션으로
비교해야 합니다.
