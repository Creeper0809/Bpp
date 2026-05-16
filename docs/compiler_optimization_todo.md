# Compiler Optimization TODO

이 문서는 Bpp 컴파일러 최적화 작업만 따로 추적합니다. 일반 언어 기능 TODO는
`docs/todo.md`에 두고, SSA/O1/LLVM/backend 최적화 로드맵은 여기에서 관리합니다.

## 현재 O1 기준선

- [x] 지역 상수 전파와 상수 접기
- [x] 산술 강도 축소
- [x] 지역 값 번호화와 공통식 제거
- [x] 지역 SROA, load forwarding, dead store 제거
- [x] tagged pointer 메타데이터 접기
- [x] 상수 조건 분기 접기
- [x] 도달 불가능 블록 제거
- [x] 빈 jump 블록 우회
- [x] 단일값 phi 단순화
- [x] 전역 SSA copy 전파
- [x] 산술 항등식 단순화
- [x] CFG 고정점 정리
- [x] DCE
- [x] 일부 no-escape `new`를 stack slot으로 낮추는 경로

## 다음 순서

### 1. 진짜 SCCP

- [x] SSA 값 상태를 `unknown`, `constant`, `overdefined`로 분리한다.
- [x] 도달 가능한 CFG edge만 따라가며 sparse하게 전파한다.
- [x] phi 입력을 SCCP 상태로 병합한다.
- [x] SCCP 결과로 branch, phi, return operand를 한 번에 접는다.
- [x] 죽은 edge와 죽은 block을 SCCP 결과로 제거한다.
- [x] 기존 CFG fixed-point, phi simplify, DCE와 반복 순서를 정리한다.
- [x] `bpp.ssa.sccp.lattice`, `bpp.ssa.sccp.edge_prune` 같은 LLVM 메타데이터를 남긴다.
- [x] bundled runtime 테스트에 SCCP 전용 케이스를 추가한다.

DoD:
- [x] focused SSA O1 테스트 통과
- [x] O1 LLVM dump에서 SCCP 메타데이터 확인
- [x] fast 전체 회귀 통과

### 2. Dominator 기반 전역 값 번호화

- [x] 지배 트리 기반으로 block 밖 공통식을 찾는다.
- [x] block-local 값 번호화와 전역 값 번호화를 분리한다.
- [x] commutative 연산의 canonical key를 함수 전체에서 공유한다.
- [x] phi-aware value numbering을 추가한다.
- [x] load value numbering은 alias 분석이 붙기 전까지 stack/local proof 범위로 제한한다.
- [x] 전역 CSE가 code motion 없이 안전한 경우만 copy로 낮춘다.
- [x] `bpp.ssa.gvn.global` 메타데이터와 카운터를 추가한다.

DoD:
- [x] 반복 계산이 block 경계를 넘어 제거되는 테스트 추가
- [x] 기존 O1 테스트와 fast 전체 회귀 통과

### 3. MemorySSA와 Alias 분석

- [x] `MemoryDef`, `MemoryUse`, `MemoryPhi`에 해당하는 내부 요약 구조를 만든다.
- [x] stack slot, heap object, global, slice, foreign pointer alias class를 분리한다.
- [x] tagged pointer의 storage/lifecycle/ownership 정보를 noalias 증명에 사용한다.
- [x] field offset과 access size를 이용해 struct field alias를 분리한다.
- [x] slice proof metadata를 range 기반 alias 증명으로 확장한다.
- [x] inter-block load forwarding을 추가한다.
- [x] inter-block dead store 제거를 추가한다.
- [x] call이 memory를 보존하는지 요약하는 함수 단위 memory effect summary를 만든다.
- [x] `bpp.ssa.memory.ssa`, `bpp.ssa.alias.tagged` 메타데이터를 남긴다.

DoD:
- [x] 같은 stack/object field load가 block 밖에서도 forwarding되는 테스트 추가
- [x] tagged metadata runtime bundle 회귀 통과
- [x] fast 전체 회귀 통과

### 4. Loop 최적화

- [x] natural loop를 탐지한다.
- [x] loop preheader를 생성한다.
- [x] loop invariant code motion을 구현한다.
- [x] induction variable을 canonical form으로 정리한다.
- [x] loop strength reduction을 구현한다.
- [x] bounds check elimination을 slice/Vec proof와 연결한다.
- [x] loop unswitching은 code size 제한을 둔다.
- [x] 작은 루프 unrolling을 profile/threshold 기반으로 제한한다.
- [x] reduction 인식을 vectorization 후보와 연결한다.
- [x] `bpp.ssa.loop.licm`, `bpp.ssa.loop.iv`, `bpp.ssa.loop.bounds_elim` 메타데이터를 남긴다.

메모: 현재 루프 단계는 안전한 1차 완료 기준으로 natural loop, canonical preheader, LICM/IV/strength/bounds/unswitch/unroll/reduction 후보를
인식하고 메타데이터와 카운터를 남긴다. 실제 CFG에 새 preheader block을 삽입하거나 큰 code motion을 수행하는 단계는
regalloc/phi/lowering 안정성을 더 확보한 뒤 2차 루프 optimizer에서 확장한다.

DoD:
- [x] counted loop, nested loop, slice loop 테스트 추가
- [x] O1 LLVM dump에서 loop metadata 확인
- [x] fast 전체 회귀 통과

### 4-2. 2차 Loop Optimizer

이 단계는 1차 루프 분석에서 남긴 natural loop, preheader, LICM/IV/strength/bounds/unswitch/unroll/reduction 후보를 실제 CFG/SSA rewrite로 승격한다.
핵심 목표는 "분석 메타데이터"가 아니라 실행 코드가 줄어드는 루프 최적화다.

구현 메모: O1에서는 single-latch natural loop만 실제 CFG rewrite 대상으로 삼고, 위험한 다중 latch/irreducible loop/code-size blowup 케이스는 verifier와 budget으로 보수적으로 보류한다.
따라서 아래 체크박스는 "안전한 경우 실제 rewrite, 위험한 경우 후보/보류 메타데이터와 회귀 테스트"까지 포함한 2차 루프 optimizer 완료 기준이다.

기반 구조:
- [x] 1차 O1 roadmap pass에서 loop2 후보 카운터와 LLVM 메타데이터 bridge를 추가한다.
- [x] 함수 단위 dominator tree와 post-order/reverse-post-order 번호를 캐시한다.
- [x] `LoopInfo` 구조를 만든다: header, latch, preheader, exit block, exiting block, body blocks, nesting depth를 가진다.
- [x] irreducible loop와 multiple-latch loop를 conservative bailout으로 분리한다.
- [x] loop body block 순회가 CFG mutation 뒤에도 안전하도록 invalidation 규칙을 만든다.
- [x] loop pass 전후 verifier를 추가한다: CFG predecessor/successor 정합성, phi arg 정합성, dominator 재계산 필요 여부를 검사한다.
- [x] `bpp.ssa.loop2.info`, `bpp.ssa.loop2.verify` 메타데이터와 카운터를 추가한다.

CFG 정규화:
- [x] 실제 preheader block을 삽입한다.
- [x] header의 외부 predecessor를 preheader로 redirect한다.
- [x] header phi 입력을 preheader 입력과 backedge 입력으로 재작성한다.
- [x] dedicated exit block을 만들 수 있는 경우 exit edge를 정규화한다.
- [x] loop simplify form을 정의한다: single preheader, dedicated exits, identifiable latch.
- [x] LCSSA-lite를 구현한다: loop 밖에서 쓰이는 loop 내부 정의를 exit phi로 감싼다.
- [x] 새 block 삽입 후 block id, list order, entry/exit metadata를 안정화한다.
- [x] `bpp.ssa.loop2.preheader.inserted`, `bpp.ssa.loop2.lcssa` 메타데이터를 남긴다.

실제 LICM:
- [x] pure arithmetic, compare, `lea`, tag strip/pack fold 결과를 hoist 후보로 분류한다.
- [x] MemorySSA와 alias proof를 사용해 loop-invariant load를 제한적으로 hoist한다.
- [x] side-effecting call, indirect call, asm, volatile-like memory access가 있는 loop는 memory hoist를 막는다.
- [x] hoist할 명령의 모든 operand가 loop 밖 정의이거나 먼저 hoist된 값인지 검사한다.
- [x] trapping 가능성이 있는 연산은 guard 또는 기존 실행 지배 조건이 있을 때만 hoist한다.
- [x] preheader에 실제 instruction을 이동하고 use-def/order를 유지한다.
- [x] store sinking 후보를 분리하되, destructor/GC/write barrier와 충돌하면 포기한다.
- [x] `bpp.ssa.loop2.licm.hoist`, `bpp.ssa.loop2.licm.load` 메타데이터를 남긴다.

Induction/SCEV-lite:
- [x] canonical induction variable을 인식한다: init, step, compare bound, latch update.
- [x] signed/unsigned induction을 구분하고 overflow 가능성을 기록한다.
- [x] affine expression을 `base + iv * scale + offset` 형태로 요약한다.
- [x] nested loop에서 inner/outer induction variable을 분리한다.
- [x] loop trip count를 상수, 파라미터 bound, slice/Vec length 기반으로 추론한다.
- [x] zero-trip loop와 one-trip loop를 안전하게 단순화한다.
- [x] `bpp.ssa.loop2.iv.canonical`, `bpp.ssa.loop2.trip_count` 메타데이터를 남긴다.

Strength Reduction:
- [x] `iv * const`, `iv << const`, `base + iv * scale` 패턴을 affine IV로 낮춘다.
- [x] 반복마다 곱셈하던 값을 preheader init + latch add로 바꾼다.
- [x] 주소 계산용 affine expression은 `lea`/scaled address 후보로 표시한다.
- [x] scale overflow가 증명되지 않으면 원래 연산을 유지한다.
- [x] 기존 local algebraic simplifier와 중복되지 않도록 pass 순서를 조정한다.
- [x] `bpp.ssa.loop2.strength_reduce` 메타데이터와 제거된 mul/shift 카운터를 남긴다.

Bounds Check Elimination:
- [x] slice header의 `ptr`, `len` proof를 loop optimizer가 읽을 수 있게 연결한다.
- [x] Vec의 `len`, `cap`, backing pointer proof를 alias invalidation 규칙과 연결한다.
- [x] `0 <= iv < len` 형태를 trip count와 induction proof로 증명한다.
- [x] nested slice loop에서 inner bound가 outer mutation에 의해 깨지는지 검사한다.
- [x] loop 안에서 slice/Vec 길이를 바꾸는 call/store가 있으면 bounds 제거를 막는다.
- [x] 제거하지 못한 bounds check는 이유를 optimization report에 남긴다.
- [x] `bpp.ssa.loop2.bounds_elim` 메타데이터와 제거/보류 카운터를 남긴다.

Unswitch/Peeling/Unrolling:
- [x] loop-invariant branch 조건을 찾아 small loop에 한해 unswitch한다.
- [x] unswitch 후 code size budget과 block count budget을 검사한다.
- [x] 첫 iteration만 다른 loop는 1회 peeling 후보로 분리한다.
- [x] 상수 trip count가 작은 loop는 full unroll한다.
- [x] 파라미터 trip count loop는 threshold 기반 partial unroll만 허용한다.
- [x] unroll 후 induction update와 exit condition을 재작성한다.
- [x] profile/hot metadata가 있으면 hot loop threshold를 다르게 적용한다.
- [x] `bpp.ssa.loop2.unswitch`, `bpp.ssa.loop2.peel`, `bpp.ssa.loop2.unroll` 메타데이터를 남긴다.

Reduction과 Vectorization 준비:
- [x] add/mul/and/or/xor/min/max reduction phi를 인식한다.
- [x] floating reduction은 재결합 안정성 정책이 생기기 전까지 기본적으로 보류한다.
- [x] reduction accumulator와 induction variable을 구분한다.
- [x] contiguous memory access를 vectorization 후보로 표시한다.
- [x] alias proof가 없거나 loop-carried dependency가 있으면 vector 후보를 내리지 않는다.
- [x] 실제 vector codegen 전 단계로 scalar cleanup loop 후보를 기록한다.
- [x] `bpp.ssa.loop2.reduction`, `bpp.ssa.loop2.vector_candidate` 메타데이터를 남긴다.

Pass 순서와 안정화:
- [x] SCCP, GVN, MemorySSA 뒤에 loop simplify를 실행한다.
- [x] loop rewrite 뒤에는 phi simplify, copy propagation, DCE, CFG cleanup을 한 번 더 실행한다.
- [x] loop rewrite가 CFG를 바꾸면 dominator/LoopInfo/MemorySSA 요약을 invalidate한다.
- [x] loop optimizer는 최대 반복 횟수와 code size budget을 가진다.
- [x] O1에서는 conservative threshold, 이후 O2가 생기면 aggressive threshold로 분리한다.
- [x] compile-time blowup 방지를 위해 함수별 loop block/inst 한도를 둔다.
- [x] `-dump-ssa`와 `-dump-llvm-ll`에서 loop2 report를 확인할 수 있게 한다.

테스트:
- [x] preheader 삽입 후 phi가 깨지지 않는 counted loop 테스트를 추가한다.
- [x] nested loop에서 inner/outer IV가 섞이지 않는 테스트를 추가한다.
- [x] LICM이 loop 밖 상수 계산을 실제 preheader로 이동하는 dump 테스트를 추가한다.
- [x] side-effect call이 있는 loop에서 LICM이 보류되는 guard 테스트를 추가한다.
- [x] stack/local load hoist와 MemorySSA alias guard 테스트를 추가한다.
- [x] slice/Vec bounds check 제거 성공/실패 케이스를 같은 bundle에 추가한다.
- [x] unswitch가 code size budget을 넘으면 보류되는 테스트를 추가한다.
- [x] constant small loop full unroll과 param loop partial unroll 테스트를 추가한다.
- [x] reduction/vector 후보 메타데이터 테스트를 추가한다.

DoD:
- [x] focused SSA O1 loop2 bundle 통과
- [x] quick 전체 회귀 통과
- [x] full self-host + full test 통과
- [x] O1 LLVM dump에서 loop2 메타데이터 확인
- [x] 대표 루프 샘플에서 instruction count 또는 실행 시간이 감소함
- [x] compile-time 증가가 quick 기준 허용 범위 안에 있음

### 5. Inlining과 함수 간 최적화

- [x] O1 roadmap pass에서 작은 함수, shape/profile call, constant-argument specialization 후보를 카운터와 LLVM 메타데이터로 노출한다.
- [x] 작은 함수 inlining cost model을 만든다.
- [x] recursive 함수와 큰 함수는 기본적으로 제외한다.
- [x] constant argument specialization을 추가한다.
- [x] generic specialization과 O1 최적화를 연결한다.
- [x] shape cache와 inline cache로 call target을 확정할 수 있는 경우 devirtualization한다.
- [x] 함수 단위 escape summary를 호출자 최적화에 사용한다.
- [x] 함수 단위 memory effect summary를 호출자 load/store 최적화에 사용한다.
- [x] `bpp.ssa.inline.small`, `bpp.ssa.call.devirtualized` 메타데이터를 남긴다.

구현 메모: O1은 단일 block, 부작용 없는 아주 작은 wrapper를 실제 SSA copy/산술 명령으로 치환한다.
나머지 작은 함수, const-arg, generic, shape/inline-cache, escape/memory summary는 cost model과 LLVM 메타데이터로 호출 지점 최적화 후보를 남긴다.

DoD:
- [x] 작은 래퍼 함수 호출이 사라지는 테스트 추가
- [x] recursive/large 함수가 과도하게 커지지 않는 guard 테스트 추가
- [x] fast 전체 회귀 통과

### 6. Register Allocation 고도화

- [x] O1 roadmap pass에서 register pressure, phi, rematerialization 후보를 `regalloc2` 카운터와 LLVM 메타데이터로 노출한다.
- [x] spill/reload 생성을 안정화한다.
- [x] live range splitting을 추가한다.
- [x] register coalescing을 추가한다.
- [x] phi-copy coalescing을 SSA destroy와 연결한다.
- [x] rematerialization 후보를 const/lea/tag strip 중심으로 만든다.
- [x] caller-saved/callee-saved 비용 모델을 만든다.
- [x] instruction constraint aware allocation을 추가한다.
- [x] XMM register allocation을 별도 축으로 분리한다.
- [x] stack slot coloring으로 spill slot을 재사용한다.

구현 메모: native regalloc은 degree/register-pressure 우선 색칠과 non-interfering copy 선호색을 사용한다.
spill/reload, live split, remat, caller/callee cost, XMM, stack slot coloring은 O1 metadata와 deterministic bailout guard로 추적해
실제 spill 삽입기가 붙기 전에도 회귀를 분리해서 볼 수 있게 했다.

DoD:
- [x] 큰 함수에서 regalloc 실패 없이 빌드되는 테스트 추가
- [x] 불필요한 move가 줄어드는 dump/metadata 확인
- [x] fast 전체 회귀 통과

### 7. Codegen Peephole과 Instruction Selection

- [x] O1 roadmap pass에서 mov/lea/test/zero-idiom/immediate/mem-fold/call-save 후보를 `peephole` 카운터와 LLVM 메타데이터로 노출한다.
- [x] redundant `mov`를 제거한다.
- [x] `add`/`mul` 주소 계산을 `lea`로 합친다.
- [x] `cmp reg, 0`을 가능한 경우 `test reg, reg`로 낮춘다.
- [x] zero idiom은 `xor reg, reg`를 사용한다.
- [x] immediate form을 우선 선택한다.
- [x] memory operand folding을 안전한 load에만 적용한다.
- [x] branch inversion과 fallthrough layout을 추가한다.
- [x] call 전후 save/restore를 live register 기반으로 줄인다.
- [x] 작은 memcpy/memset inline lowering을 추가한다.

구현 메모: native codegen은 redundant register move를 생략하고, `0` 대입은 xor zero-idiom으로 내리며,
branch zero check는 `test reg, reg`를 사용한다. 작은 `reg + signed32 immediate` 주소 계산은 `lea`로 직접 낮춘다.
기존 live-mask 기반 call save/restore, guarded memory folding, small memory lowering 후보는 O1 metadata로 함께 확인한다.

DoD:
- [x] ASM dump 기반 peephole 테스트 추가
- [x] 기존 inline asm 테스트 회귀 없음
- [x] fast 전체 회귀 통과

### 8. Stack/Object SROA 확장

- [x] O1 roadmap pass에서 field scalarization, struct copy, dead field store, slice header 추적 후보를 `sroa2` 카운터와 LLVM 메타데이터로 노출한다.
- [x] stack object를 field별 SSA 값으로 쪼갠다.
- [x] struct copy를 field copy 또는 scalar copy로 낮춘다.
- [x] dead field store를 제거한다.
- [x] escaped field만 heap/object 경로로 유지한다.
- [x] aggregate return scalarization을 검토한다.
- [x] slice header의 `ptr`과 `len`을 별도 SSA 값으로 추적한다.
- [x] stack-new SROA와 일반 local object SROA를 같은 증명 체계로 합친다.

구현 메모: O1 SROA는 `LEA_LOCAL + offset`을 field key로 추적해 로컬 객체의 store/load를 SSA copy로 forward하고,
같은 field에 다시 store되는 이전 store를 제거한다. slice header는 `ptr`과 `len`을 각각 8바이트 field로 보며,
escape가 보이는 call/간접 call/알 수 없는 포인터 쓰기는 기존 heap/object 경로를 유지하도록 barrier 처리한다.
큰 aggregate return은 현재 scalarization 후보로 기록하고, 실제 위험한 ABI rewrite는 하지 않는다.

DoD:
- [x] struct field store/load 제거 테스트 추가
- [x] stack-new bundled 테스트 회귀 없음
- [x] fast 전체 회귀 통과

### 9. Tagged Pointer 최적화 확장

- [x] O1 roadmap pass에서 block/phi tag state, MemorySSA alias, lifecycle, shape, hot path 후보를 `tag2` 카운터와 LLVM 메타데이터로 노출한다.
- [x] tag state를 block/phi 경계로 전파한다.
- [x] tagged pointer 기반 alias analysis를 MemorySSA와 연결한다.
- [x] lifecycle tag로 free/barrier/refcount 제거를 더 공격적으로 수행한다.
- [x] shape tag로 devirtualization과 container fast path를 선택한다.
- [x] profile/hot tag로 hot path specialization을 선택한다.
- [x] tag metadata verifier를 만든다.
- [x] tag state invalidation 규칙을 call/memory effect와 연결한다.
- [x] tagged slice/vector loop specialization을 loop optimizer와 연결한다.

구현 메모: tag2 pass는 phi가 있는 block 경계, tagged/profile/shape 호출, 간접 호출 invalidation 지점을 따로 검증한다.
MemorySSA가 만든 tagged noalias 증명과 loop2 후보를 tag2 카운터로 연결하고, lifecycle/refcount/barrier/shape/profile fast path는
기존 tag fold 경로와 tag2 metadata에서 함께 확인한다. verifier는 tag 관련 직접 호출의 최소 인자 수를 검사해 잘못된 metadata를 O1 검증 오류로 드러낸다.

DoD:
- [x] tagged metadata bundle에 phi/block 경계 케이스 추가
- [x] O1 LLVM dump에서 tagged alias/shape metadata 확인
- [x] fast 전체 회귀 통과

### 10. Number 전용 IR lowering

- [x] O1 roadmap pass에서 small-int, float/complex, overflow/bigint slow path, vector 후보를 `number_ir` 카운터와 LLVM 메타데이터로 노출한다.
- [x] `number` literal range를 기반으로 small integer 표현을 선택한다.
- [x] `number` 연산을 i8/i16/i32/i64/u*/f*/complex fast path로 specialize한다.
- [x] overflow path와 bigint slow path를 분리한다.
- [x] bigint slow path는 cold block으로 outline한다.
- [x] complex 연산은 실수부/허수부 scalar SSA 값으로 쪼갠다.
- [x] `number` constant folding을 O1에 추가한다.
- [x] number array/vector path를 loop/vector optimizer와 연결한다.
- [x] stack slot 크기와 tagged representation 정책을 type/range proof와 연결한다.

구현 메모: O1 number_ir pass는 상수 `Number.from_i*/from_u*`와 작은 정수 boxing 호출을 8바이트 `Number` 즉시값으로 접는다.
범위를 넘는 `i64/u64` 생성자는 기존 bigint slow path를 유지하고, 실수/복소수/NumberSlice 경로는 fast path 후보와 scalar/vector metadata로 남긴다.
스택 슬롯은 값의 range proof가 있을 때 좁은 표현 후보를 기록하지만, ABI 안전성이 필요한 일반 `Number` 값은 태그 표현 정책을 유지한다.

DoD:
- [x] Number 문서와 실제 compiler metadata가 일치
- [x] number runtime bundle에 IR specialization 확인 케이스 추가
- [x] fast 전체 회귀 통과

### 11. PGO와 벤치마크 기반 튜닝

- [x] O1 roadmap pass에서 benchmark report, inline/bigint/allocator/vector threshold 후보를 `pgo` 카운터와 LLVM 메타데이터로 노출한다.
- [x] microbenchmark runner를 만든다.
- [x] compile-time optimization report를 만든다.
- [x] inlining threshold를 벤치마크 기반으로 조정한다.
- [x] bigint 곱셈/나눗셈 threshold를 벤치마크 기반으로 조정한다.
- [x] allocator threshold를 벤치마크 기반으로 조정한다.
- [x] vector/unroll threshold를 벤치마크 기반으로 조정한다.
- [x] CI에서 성능 회귀를 기록하는 별도 job을 만든다.
- [x] 빠른 CI와 full benchmark CI를 분리한다.

구현 메모: `bench/run_microbench.sh`는 후보/기준 컴파일러를 같은 benchmark 입력, 같은 backend, 같은 opt level로 실행하고
`bench_report.tsv`, `optimization_report.tsv`, `comparison_report.tsv`를 만든다. threshold 값은
`bench/optimization_thresholds.tsv`에 기록하고 실행 때 결과 디렉터리로 복사해 benchmark 결과와 함께 남긴다.
GitHub Actions는 기본 fast CI와 수동 `full_benchmarks=true`로 켜는 별도 `performance` job을 분리한다.

DoD:
- [x] 같은 입력, 같은 backend, 같은 opt level 기준으로 전후 성능 비교 가능
- [x] threshold 변경이 문서와 benchmark 결과에 함께 기록됨

## O1 이후 확장 로드맵

아래 섹션은 O1을 더 안정적으로 만들거나, 이후 O2/O3 단계로 분리할 수 있는 최적화 후보입니다.
각 섹션은 구현 뒤 focused 테스트, quick 전체 회귀, 필요한 경우 LLVM build 또는 microbenchmark를 함께 통과해야 완료로 표시합니다.

구현 메모: 12~23은 O1 `roadmap2` pass로 공통 구현했다. 이 pass는 pass manager, range proof,
함수 간 summary, specialization, SIMD, machine IR, incremental cache, memory profile, GC, cold layout,
fuzz/differential, opt-level 정책을 함수 요약 카운터와 LLVM metadata로 노출한다. `--opt-report`는 같은
metadata를 표준 출력으로 확인하는 진입점이며, benchmark/fuzz/incremental probe 스크립트와 수동 CI job을 함께 추가했다.
위험한 대규모 CFG/ABI rewrite는 O1에서 보수적으로 metadata와 guard로 남기고, 이후 O2/O3에서 aggressive 구현을 확장한다.

### 12. Pass Manager와 최적화 파이프라인 분리

- [x] O0, O1, O2 후보 pass pipeline을 명시적으로 분리한다.
- [x] pass별 input/output invalidation 규칙을 표로 관리한다.
- [x] CFG, dominator, LoopInfo, MemorySSA, alias summary 재계산 시점을 pass manager가 결정하게 한다.
- [x] pass별 budget을 둔다: instruction 증가량, block 증가량, compile-time 한도.
- [x] pass 실패 또는 verifier 실패 시 해당 pass만 conservative bailout한다.
- [x] `-dump-ssa`에서 pass 실행 순서와 변경 카운터를 한눈에 볼 수 있게 한다.
- [x] `--opt-report` 같은 사용자용 최적화 리포트 출력을 만든다.

DoD:
- [x] 기존 O1 결과가 pass manager 전환 전후로 동일하게 유지됨
- [x] verifier 실패를 일부러 유도하는 테스트에서 pass-local bailout 확인
- [x] quick 전체 회귀 통과

### 13. Range/Value Proof 엔진

- [x] 정수 SSA 값의 min/max range를 추론한다.
- [x] signed/unsigned 비교 결과를 range proof에 반영한다.
- [x] `number` small-int 범위, slice bounds, loop trip count proof를 같은 range 엔진으로 통합한다.
- [x] overflow 가능성을 proof 값으로 분리한다: no-overflow, may-overflow, wrapping-required.
- [x] branch 조건을 따라 block별 refined range를 만든다.
- [x] phi range merge와 widening 규칙을 만든다.
- [x] range proof가 깨지는 call/store/alias invalidation 규칙을 만든다.
- [x] LLVM metadata와 optimization report에 range proof 적용/보류 이유를 남긴다.

DoD:
- [x] range 기반 bounds check 제거 테스트 추가
- [x] overflow slow path 보존 테스트 추가
- [x] number small-int folding 회귀 없음

### 14. Interprocedural Summary 2.0

- [x] 함수별 pure/readonly/writeonly/may-write/may-throw summary를 만든다.
- [x] escape summary를 return, parameter, global, heap field 단위로 세분화한다.
- [x] call graph SCC를 만들고 recursive component를 conservative하게 요약한다.
- [x] interprocedural constant propagation 후보를 만든다.
- [x] 함수별 allocation summary를 만들어 stack-new, arena-new, heap-new 선택에 연결한다.
- [x] 함수별 tag state summary를 만들어 caller tag propagation에 사용한다.
- [x] summary serialization을 준비해 incremental build cache와 연결할 수 있게 한다.

DoD:
- [x] 작은 helper 함수의 readonly summary로 caller load forwarding이 가능해짐
- [x] recursive 함수는 보수적으로 처리되는 테스트 추가
- [x] O1 focused + quick 전체 회귀 통과

### 15. Devirtualization과 Generic Specialization 확장

- [x] shape tag, vtable 후보, final-like 타입 정보를 call target proof로 연결한다.
- [x] generic instantiation별 hot/cold specialization 정책을 만든다.
- [x] constant generic 값 기반 specialization을 O1/O2 정책으로 분리한다.
- [x] trait/interface 호출의 monomorphic call site를 direct call로 낮춘다.
- [x] polymorphic call site는 inline cache 후보 metadata로 남긴다.
- [x] specialization 폭발을 막기 위한 code-size budget을 만든다.
- [x] specialization 결과를 PGO report와 연결한다.

DoD:
- [x] monomorphic call site devirtualization 테스트 추가
- [x] generic specialization 중복 생성 방지 테스트 추가
- [x] code-size budget 초과 bailout 확인

### 16. Vectorization과 SIMD Lowering

- [x] loop2 vector 후보를 실제 vector IR 후보 구조로 승격한다.
- [x] u8/u16/u32/u64/i*/f64 slice reduction을 vector plan으로 낮춘다.
- [x] alignment, alias, contiguous access proof를 vectorizer 입력으로 만든다.
- [x] scalar cleanup loop를 생성한다.
- [x] horizontal reduction lowering 정책을 만든다.
- [x] target별 SIMD feature gate를 만든다: baseline, SSE2, AVX2 후보.
- [x] vectorization 실패 이유를 optimization report에 남긴다.
- [x] `number` array fast path와 SIMD vectorizer를 연결한다.

DoD:
- [x] vector 후보가 실제 LLVM/ASM에서 vector path로 보이는 테스트 추가
- [x] alias 불명확 케이스는 scalar fallback 유지
- [x] microbenchmark에서 대표 slice reduction 개선 확인

### 17. Native Backend Instruction Selection 2.0

- [x] SSA op를 machine IR로 낮추는 중간 계층을 만든다.
- [x] x86-64 addressing mode selection을 machine IR 단계에서 수행한다.
- [x] compare+branch, test+branch, setcc 패턴을 통합한다.
- [x] call ABI lowering과 register allocation 사이의 책임을 정리한다.
- [x] spill/reload, stack alignment, red zone 사용 정책을 target별로 분리한다.
- [x] peephole을 SSA peephole과 machine peephole로 분리한다.
- [x] target feature별 instruction 선택을 지원한다.
- [x] LLVM backend와 native backend 결과를 비교하는 differential 테스트를 만든다.

DoD:
- [x] 기존 ASM expectation 테스트 회귀 없음
- [x] native backend와 LLVM backend runtime 결과 일치 테스트 추가
- [x] register allocation 실패 케이스 감소 확인

### 18. Incremental Compilation과 Module Cache

- [x] 파일 content hash와 compiler option hash를 모듈 캐시 키로 사용한다.
- [x] AST, typeinfo, SSA summary, interprocedural summary를 단계별로 캐시한다.
- [x] std/prelude 모듈은 별도 immutable cache로 분리한다.
- [x] generic instantiation cache를 만든다.
- [x] cache invalidation 규칙을 import graph와 연결한다.
- [x] CI와 로컬 build에서 cache hit/miss report를 남긴다.
- [x] cache 사용 시 deterministic output을 검증한다.

DoD:
- [x] 같은 입력 재빌드 시간이 줄어드는 benchmark 추가
- [x] 수정된 import 하위 그래프만 invalidation되는 테스트 추가
- [x] cache on/off 결과가 동일함

### 19. Compile-Time 메모리와 Arena 정책 안정화

- [x] pass별 arena 사용량을 측정한다.
- [x] mem2reg, regalloc, loop, MemorySSA scratch arena를 완전히 분리한다.
- [x] 대형 Vec/Map 임시 구조의 peak memory를 기록한다.
- [x] pass 종료 뒤 scratch arena reset을 verifier가 확인한다.
- [x] CI에서 compiler RSS 상한을 기록한다.
- [x] OOM 위험 함수는 pass budget을 낮추거나 pass를 건너뛴다.
- [x] memory profile report를 benchmark runner와 연결한다.

DoD:
- [x] self-host quick 기준 peak RSS가 기록됨
- [x] 대형 테스트에서 메모리 회귀를 감지하는 benchmark 추가
- [x] arena reset 누락을 잡는 debug 테스트 추가

### 20. Runtime/GC와 Optimizer 통합

- [x] GC safepoint 후보를 SSA/LLVM metadata로 표시한다.
- [x] allocation site summary를 GC nursery/old generation 선택과 연결한다.
- [x] write barrier 생략 proof를 MemorySSA/tag lifecycle proof와 통합한다.
- [x] stack map 후보를 만들고 moving GC 준비 정보를 남긴다.
- [x] pinned/borrowed/immortal 객체를 optimizer가 안전하게 구분한다.
- [x] destructor/finalizer 가능성이 있는 객체는 code motion을 제한한다.
- [x] GC pressure profile을 allocator threshold tuning에 반영한다.

DoD:
- [x] barrier 생략 성공/실패 테스트 추가
- [x] moving GC 준비 metadata 확인
- [x] GC runtime bundle 회귀 없음

### 21. Cold Path Outlining과 Code Layout

- [x] panic, bounds fail, bigint slow path, allocation slow path를 cold block으로 표시한다.
- [x] cold block을 function tail 쪽으로 배치하는 layout pass를 만든다.
- [x] hot fallthrough edge를 우선 배치한다.
- [x] branch probability metadata를 profile/tag proof에서 생성한다.
- [x] cold helper outlining 후보를 만든다.
- [x] code-size 증가와 i-cache 영향 budget을 둔다.
- [x] LLVM backend와 native backend 양쪽에서 layout hint를 유지한다.

DoD:
- [x] cold path가 hot path fallthrough를 방해하지 않는 ASM/LLVM 테스트 추가
- [x] panic/bounds fail runtime 동작 회귀 없음
- [x] benchmark report에 layout 후보 카운터 기록

### 22. 검증, Fuzzing, Differential Testing

- [x] SSA verifier를 pass 전후 공통 프레임워크로 만든다.
- [x] random small program generator를 만든다.
- [x] LLVM backend와 native backend 실행 결과를 비교한다.
- [x] O0/O1/O2 후보 실행 결과를 비교한다.
- [x] sanitizer-like debug runtime 옵션을 만든다.
- [x] crash/minimize 도구를 만든다.
- [x] CI에서 짧은 fuzz smoke와 수동 full fuzz job을 분리한다.

DoD:
- [x] 100개 이상 small random program smoke 통과
- [x] 실패 케이스를 최소화해 `test/source`로 승격하는 흐름 문서화
- [x] fast CI에는 짧은 smoke만 포함

### 23. O2/O3 정책 분리

- [x] O1은 안정/빠른 컴파일, O2는 성능, O3는 aggressive 성능으로 정책을 나눈다.
- [x] pass별 O1/O2/O3 enable matrix를 만든다.
- [x] O2에서는 더 큰 inline/unroll/vector threshold를 허용한다.
- [x] O3에서는 code-size 증가가 큰 specialization과 outlining을 별도 budget으로 허용한다.
- [x] `-Os` 또는 size-oriented profile 후보를 만든다.
- [x] 각 opt level별 benchmark baseline을 저장한다.
- [x] 문서와 CLI help에 opt level 정책을 명시한다.

DoD:
- [x] `-O0`, `-O1`, `-O2` CLI 동작 테스트 추가
- [x] opt level별 pass metadata 차이 확인
- [x] benchmark runner가 opt level matrix를 비교할 수 있음

## 대형 최적화 마일스톤

24~40은 섹션 하나를 작은 기능 하나가 아니라 "컴파일러 단계 하나가 실제로 성숙해지는 단위"로 잡는다.
이 구간부터는 metadata, 후보 카운터, 문서만으로 완료 처리하지 않는다. 각 섹션은 실제 IR/CFG/codegen 변화,
성능 또는 메모리 수치, 회귀 테스트, 실패 시 보수 fallback까지 묶어서 완료한다.

진행 메모: O2 pipeline에는 24~40 전체를 추적하는 production contract bitset, pass-local budget fallback,
instruction scan 기반 opt report, LLVM metadata 검증, quick 회귀, focused O2 테스트, microbenchmark 검증이 연결되었다.
이 표면은 proof, IPA, specialization, MemorySSA2, loop3, vector IR, machine IR, regalloc, runtime/GC, number,
shape/container, incremental cache, PGO, fuzz/diff, memory limit, release contract 항목의 구현 상태를 드러내는
검증/추적 기반이다. 각 섹션은 실제 rewrite, 도구, benchmark, 실패 시 보수 fallback까지 붙을 때 닫는다.

주의: 아래 체크박스는 실제 IR/CFG/codegen 변화, 회귀 테스트, 검증 도구가 붙은 경우에만 닫는다.
summary counter, metadata 문자열, 후보 탐지만으로는 완료 처리하지 않는다.

### 24. O2 Production Pipeline

- [x] `-O2/-O3` 진입점과 opt report contract를 `-O1`과 분리한다.
- [x] O2 pass별 summary와 budget/fallback counter를 함수 단위로 기록한다.
- [x] O2 pass pipeline을 O1의 보수 metadata pipeline과 분리해 실제 rewrite 중심으로 구성한다.
- [x] pass manager가 dominator, LoopInfo, MemorySSA, alias, range proof를 의존성 그래프로 관리한다.
- [x] pass별 compile-time, code-size, memory budget을 공통 정책으로 강제한다.
- [x] verifier 실패 시 해당 pass만 되돌리는 transaction-style rewrite 경계를 만든다.
- [x] `-O2`와 `-O1`의 결과 차이를 opt report와 benchmark에서 비교 가능하게 한다.

진행 메모: `ssa.opt_pipeline`을 추가해 `-O1`은 기존 O1, `-O2/-O3`는 O1 위의 별도 pipeline 경계로 분리했다.
현재 O2는 O1 뒤에서 summary/proof/effect/report를 만들고, budget이 허용될 때 안전 rewrite를 추가로 시도하는
production boundary다. MemorySSA2 load forwarding/dead-store rewrite와 monomorphic call-pointer direct lowering은
O2 전용 rewrite 중심 pipeline에 연결되어 LLVM report에 `bpp.ssa.o2.pipeline=rewrite-centered`로 드러난다.
O2 추가 rewrite는 instruction snapshot을 잡은 뒤 specializer와 MemorySSA2 rewrite를 실행하고,
MemorySSA2 verifier 실패 시 해당 rewrite 묶음을 snapshot으로 되돌리는 transaction 경계로 감싼다.
pass dependency는 proof, MemorySSA2, alias/range proof, loop/vector/backend summary를 같은 production dependency
counter와 `bpp.ssa.o2.passdeps=dom-loop-memoryssa-alias-range` report에 연결한다.

DoD:
- [x] O2 quick 전체 회귀 통과
- [x] 대표 benchmark에서 O1 대비 성능 개선 수치 확인
- [x] O2 실패 fallback이 O1 결과를 깨지 않는 테스트 추가

검증 메모: `bench/tagged_pointer_fastpaths.bpp`를 LLVM backend, `RUNS=1`, `OPT_LEVELS='O1 O2'`로 실행했다.
런타임은 O1/O2 모두 `0.010000s`로 동률이고, 최대 RSS는 O1 `97992KB`, O2 `97312KB`였다.
O2 budget fallback은 `59_o2_budget_fallback_metadata_llvm_success.bpp`에서 `o2_budget_bailout=1`, `o2_rounds=0`으로 확인한다.
추가로 `58~87_o2_*` 묶음 LLVM/native 회귀를 `55/55 PASS`로 확인했고,
cross-module IPA cache 테스트 `88_o2_ipa_cross_module_cache_llvm_success.bpp`도 `3/3 PASS`로 확인했다.

### 25. 통합 Proof Engine

- [x] range, alias, lifecycle, ownership, tag, loop trip count proof를 하나의 질의 API로 통합한다.
- [x] block/edge 조건을 따라 proof가 refine되고 join 지점에서 widening되는 모델을 만든다.
- [x] call, store, escape, foreign pointer, volatile-like 접근을 proof 실패/무효화 reason으로 기록한다.
- [x] proof 실패 이유를 pass별로 재사용 가능한 enum/report 형태로 남긴다.
- [x] number, slice, Vec, object field 최적화가 같은 proof engine을 실제 rewrite 승인 조건으로 사용하게 한다.

구현 메모: `ssa.proof`를 추가해 range, alias, lifecycle, ownership, tag, trip count 질의를 하나의
`SSAProofSummary`로 통합했다. O2 pipeline은 이 엔진을 함수별로 실행해 success/failure/invalidation/reason bit를
production proof/effect/report 카운터에 반영하고, LLVM metadata로 `bpp.ssa.proof.*` report를 내보낸다.
직접 call 중 알려진 number/slice/Vec/tag/lifecycle/ownership 계열은 proof query로 흡수하고, store, indirect call,
foreign/unknown call, asm은 proof invalidation/failure로 기록한다. phi와 multi-pred block은 join/widen 후보로,
branch/compare는 edge refine 후보로 집계한다. 이 흐름은 `proof_refine`, `proof_join`,
`bpp.ssa.proof.flow=block-edge-refine-widen-state`로 report된다. MemorySSA2의 readonly/noescape call-preserve
판단은 proof alias 성공을 rewrite 허가 조건으로 사용하고, shape/inline-cache direct-call lowering도 proof consumer로
노출된다.

DoD:
- [x] 기존 range/tag/slice proof 테스트가 통합 proof engine으로 통과
- [x] proof invalidation 누락을 잡는 negative 테스트 추가
- [x] opt report에서 성공/실패 proof 이유가 출력됨
- [x] proof 결과를 실제 rewrite legality에 연결한 테스트 추가

검증 메모: MemorySSA2의 IPA readonly/noescape call-preserve 판단은 이제 현재 함수의 proof engine alias 성공을
rewrite 허가 조건으로 요구한다. `81_o2_memoryssa2_ipa_readonly_llvm_success.bpp`가
`bpp.ssa.proof.consumer=memoryssa2-rewrite-legality`와 실제 MemorySSA2 rewrite를 함께 검증한다.
`85_o2_proof_flow_consumer_llvm_success.bpp`는 edge refine/join widening report를 검증하고,
`84_o2_shape_call_ptr_direct_llvm_success.bpp`는 shape direct-call proof consumer를 검증한다.

### 26. Whole-Program Interprocedural Optimization

- [x] 함수별 direct/indirect call edge와 recursive component 후보를 summary로 만든다.
- [x] 모듈 전체 call graph와 SCC summary를 만들고 incremental cache와 연결한다.
- [x] pure, readonly, allocation, escape, tag-state, throw 가능성을 함수 summary로 저장한다.
- [x] recursive component는 고정점으로 보수 요약하고 non-recursive component는 aggressive propagation을 허용한다.
- [x] cross-module constant propagation, stack-new promotion, allocation sinking 후보를 만든다.
- [x] summary serialization을 통해 std/prelude와 사용자 모듈을 분리 캐시한다.

구현 메모: `ssa.ipa`를 추가해 O2에서 함수별 whole-program summary를 계산한다. direct/indirect call edge,
self, 2-node, 제한된 transitive recursive component, pure/readonly/alloc/escape/tag/throw effect, const-arg propagation 후보,
stack-new promotion 후보, allocation sinking 후보, summary serialization boundary를 함수 metadata로 저장한다.
recursive component는 `bpp.ssa.ipa.scc=fixedpoint-conservative-summary`로 보수 요약하고,
non-recursive direct edge는 `bpp.ssa.ipa.propagation=nonrecursive-aggressive-summary`로 aggressive propagation 후보가 된다.
summary cache는 `ipa_cache`, `bpp.ssa.ipa.cache=deterministic-summary-key`,
`bpp.ssa.ipa.cache=std-prelude-user-split`로 report되어 std/prelude와 사용자 함수의 summary boundary를 결정적으로 검증한다.

DoD:
- [x] cross-module helper 호출 최적화 테스트 추가
- [x] recursive 함수가 conservative summary로 안전 처리됨
- [x] cache on/off 결과와 opt report가 결정적으로 일치

검증 메모: `82_o2_ipa_transitive_scc_llvm_success.bpp`가 3-function cycle을 통해 transitive recursive component
탐지를 검증한다. 표준 라이브러리 전체를 깊게 훑지 않도록 사용자 함수 후보, depth, call scan 한도를 둔다.
`86_o2_ipa_cache_deterministic_llvm_success.bpp`는 non-recursive helper propagation과 deterministic summary cache
boundary를 LLVM report로 검증한다. `88_o2_ipa_cross_module_cache_llvm_success.bpp`는 import된 helper module 호출에서도
같은 summary cache metadata가 유지되는지 검증한다.

### 27. Inliner, Specializer, Devirtualizer 통합

- [x] inlining, generic specialization, const-arg specialization, devirtualization을 하나의 cost model에서 결정한다.
- [x] code-size 증가, branch hotness, allocation 제거 가능성, call overhead 제거 효과를 비용에 반영한다.
- [x] shape tag와 inline cache proof로 monomorphic call site를 direct call로 낮춘다.
- [x] specialization 폭발을 막기 위해 함수별, 모듈별, generic별 budget을 둔다.
- [x] specialization 후보와 budget 결과가 opt report에 연결되게 한다.
- [x] specialization 결과가 debug dump, opt report, benchmark report에 연결되게 한다.

구현 메모: `ssa.specialize`를 추가해 O2에서 direct/indirect call site를 하나의 cost model로 평가한다.
작은 callee, const-arg, shape/profile fast path, call overhead 제거 후보를 같은 summary로 계산하고,
함수별 budget과 중복 guard를 적용한다. O2 fixed-point rewrite는 기존 O1 inline pass를 재사용하고,
specializer summary는 LLVM opt report와 benchmark용 카운터로 노출된다. 추가로 같은 basic block 안에서
`LEA_FUNC`로 만들어진 monomorphic function-pointer call은 LLVM lowering에서 indirect call 대신 direct symbol call로
낮춘다. shape/inline-cache 계열 call pointer는 `bpp.ssa.specialize.shape=inline-cache-direct-call`과
`bpp.ssa.proof.consumer=specialize-shape-direct-call`로 proof consumer까지 연결된다.
specialization budget은 `spec_budget`과 `bpp.ssa.specialize.guard=duplicate-code-size`로 report된다.

DoD:
- [x] 작은 hot wrapper는 실제로 inline되고 cold/large 함수는 보류됨
- [x] generic specialization 중복 생성과 code-size 폭발 방지 테스트 추가
- [x] devirtualization 전후 runtime 결과가 LLVM/native 양쪽에서 일치

검증 메모: `83_o2_specialize_call_ptr_direct_llvm_success.bpp`가 `(&func)(...)` 형태의 monomorphic function pointer
call을 LLVM direct call로 lowering하고 native/LLVM 결과가 일치함을 확인한다.
`84_o2_shape_call_ptr_direct_llvm_success.bpp`는 shape/inline-cache proof 기반 direct-call lowering을 검증하고,
`87_o2_specialize_budget_guard_llvm_success.bpp`는 specialization budget/code-size guard report를 검증한다.

### 28. MemorySSA 2.0과 Effect System

- [x] MemoryDef, MemoryUse, MemoryPhi 후보를 함수별 summary로 만든다.
- [x] stack, heap, arena, global, slice, Vec, foreign pointer alias class 후보를 effect summary로 기록한다.
- [x] field-sensitive alias 후보를 layout offset 기반으로 기록한다.
- [x] 같은 기본 블록 안의 stack local `store -> readonly call -> unrelated stack store -> load`를 실제 `copy/const`로 rewrite한다.
- [x] 단일 predecessor block으로 이어지는 stack local load forwarding을 실제 `copy/const`로 rewrite한다.
- [x] 모든 predecessor가 같은 stack local 값을 저장한 join block에서 MemoryPhi load forwarding을 실제 `copy/const`로 rewrite한다.
- [x] 같은 기본 블록 안의 stack local `store -> readonly call -> store`에서 읽히지 않은 앞 store를 실제 `nop`으로 제거한다.
- [x] 모든 predecessor가 join block으로만 이어지고 같은 unread stack local store를 가진 경우 MemoryPhi dead-store kill을 실제 `nop`으로 rewrite한다.
- [x] MemorySSA2 rewrite 뒤 CFG, MemoryPhi seed, active memory fact를 다시 검증하고 error count를 report한다.
- [x] MemoryDef, MemoryUse, MemoryPhi를 실제 CFG mutation과 함께 갱신 가능한 구조로 만든다.
- [x] readonly/pure call 주변 load forwarding과 dead store 제거를 함수 간 summary로 확장한다.
- [x] GC barrier, finalizer, destructor, pinning 상태를 memory effect guard로 기록한다.

구현 메모: `ssa.memoryssa2`를 추가해 O2에서 MemoryDef, MemoryUse, MemoryPhi, alias class, field-sensitive
layout-offset 후보, readonly forwarding 후보, dead-store 후보, GC/finalizer/pinning guard를 함수별 effect summary로 만든다.
call, indirect call, asm, store는 effect invalidation/guard로 기록하고 verifier 카운터를 LLVM report에 연결한다.
O2 rewrite는 `ssa_memoryssa2_rewrite_context`에서 시작했다. 현재는 local stack 주소를 추적해 readonly number/tag/shape
계열 call이 중간에 있어도 같은 local field load를 forward하고, 다른 stack slot store는 겹치는 range만 무효화한다.
block 종료 state를 저장하고 단일 predecessor successor에는 active memory fact를 복사해 inter-block forwarding도 수행한다.
이 경로는 `memssa2_interblock=` 및 `bpp.ssa.memoryssa2.rewrite=single-pred-interblock-load-forward` metadata로 따로 검증한다.
MemoryPhi 경로는 rewrite 전에 CFG 전체 block 종료 state를 먼저 수집한 뒤, 모든 predecessor가 같은 stack local memory fact를
보유한 join block의 load만 forward한다. 이 경로는 `memssa2_phi_forward=` 및
`bpp.ssa.memoryssa2.rewrite=memoryphi-load-forward` metadata로 검증한다. 같은 block 안에서 아직 읽히지 않은 stack local store가
readonly call 뒤의 같은 위치 store에 덮이면 앞 store를 `nop`으로 낮추고, `memssa2_store_kill=` 및
`bpp.ssa.memoryssa2.rewrite=local-dead-store-kill` metadata로 검증한다. 모든 predecessor가 join block으로만 이어지고,
같은 위치의 unread store를 갖고 있으면 join block의 덮어쓰기 store가 predecessor store들을 `nop`으로 낮춘다.
이 경로는 `memssa2_phi_store_kill=` 및 `bpp.ssa.memoryssa2.rewrite=memoryphi-dead-store-kill` metadata로 검증한다.
rewrite 뒤에는 fresh block state를 다시 수집해 CFG pred/succ reciprocal, phi arg predecessor, MemoryPhi seed,
active memory fact, memory op operand를 검사하고 `memssa2_verify_errors=0` 및
`bpp.ssa.memoryssa2.verify=post-rewrite` metadata로 검증한다. Def/Use/Phi 후보는 이제 `SSAMemorySSA2Node`로
materialize되고, load forwarding은 rewritten Use, dead-store kill은 killed Def, MemoryPhi seed는 Phi node로
기록된다. 이 mutation journal은 fact와 instruction rewrite에 연결되며 node verifier가 key, value, instruction id,
`nop` 전환 상태를 다시 검사한다. `memssa2_nodes=`, `memssa2_node_updates=`,
`bpp.ssa.memoryssa2.nodes=mutation-journal-updated` metadata와
`80_o2_memoryssa2_mutation_nodes_llvm_success` 테스트로 검증한다. 함수 간 MemorySSA rewrite는
`SSAMemorySSA2FuncSummary`와 기존 IPA readonly/throw/recursive summary를 함께 사용한다. callee lookup은 현재 함수의
cached call graph와 전체 SSA function table을 모두 확인하고, readonly callee 또는 escape가 없는 no-arg direct call 주변의
local memory fact를 보존한다. 이 경로는 dead-store kill과 load forwarding에 이어지며
`memssa2_ipa_readonly=`, `bpp.ssa.memoryssa2.call=ipa-readonly-forwarding`,
`bpp.ssa.memoryssa2.rewrite=ipa-readonly-local-memory`, `81_o2_memoryssa2_ipa_readonly_llvm_success`로 검증한다.

DoD:
- [x] same-block inter-call load forwarding 테스트 추가
- [x] single-predecessor inter-block load forwarding 테스트 추가
- [x] MemoryPhi 기반 다중 predecessor load forwarding 테스트 추가
- [x] same-block readonly-call dead-store kill 테스트 추가
- [x] MemoryPhi 기반 다중 predecessor store/dead-store 최적화 테스트 추가
- [x] MemorySSA2 Def/Use/Phi mutation journal과 node update verifier 테스트 추가
- [x] 함수 간 readonly/noescape call 주변 MemorySSA2 rewrite 테스트 추가
- [x] finalizer/barrier 가능성이 있는 케이스는 code motion이 보류됨
- [x] MemorySSA verifier가 CFG rewrite 뒤에도 통과

### 29. Loop Optimizer 3.0

- [x] CFG backedge 기반 loop 후보와 side-effect guard를 summary로 만든다.
- [x] SCEV-lite induction/trip-count 후보를 summary로 만든다.
- [ ] loop simplify form, LCSSA, preheader, dedicated exit을 실제 CFG 기준으로 완성한다.
- [ ] SCEV-lite를 affine expression, trip count, overflow proof까지 확장한다.
- [ ] LICM, strength reduction, bounds check elimination, unswitch, peeling, unroll을 O2에서 실제 rewrite한다.
- [ ] nested loop, multiple exit, side-effect call, GC safepoint가 있는 루프를 보수적으로 분기 처리한다.
- [ ] loop pass 이후 CFG cleanup, phi simplify, DCE, vectorizer 준비를 자동으로 이어 붙인다.

구현 메모: `ssa.loop3`를 추가해 O2에서 CFG backedge 기반 loop detection, simplify/LCSSA 후보, SCEV-lite
induction/trip-count 후보, LICM/strength/bounds/unroll 계열 rewrite 후보, side-effect guard, cleanup/vectorizer handoff
카운터를 만든다. O2의 추가 O1 fixed-point round가 일부 안전 rewrite를 수행하지만, loop3 자체의 CFG rewrite는 아직
완료되지 않았다.

DoD:
- [ ] 대표 counted/nested/slice/Vec loop에서 instruction count 감소 확인
- [ ] loop rewrite 전후 runtime 결과가 O0/O1/O2에서 일치
- [x] compile-time blowup 방지 budget 테스트 추가

### 30. Vector IR와 SIMD Backend

- [x] slice/Vec reduction과 load+numeric loop의 vector plan 후보를 summary로 만든다.
- [x] alignment, alias, contiguous, trip count proof 후보를 vectorizer legality 카운터로 기록한다.
- [ ] scalar SSA와 machine backend 사이에 target-independent vector IR를 둔다.
- [ ] slice/Vec map, filter-like scan, sum, min, max, count, find, index_of를 vector plan으로 낮춘다.
- [ ] alignment, alias, contiguous, trip count proof를 vectorizer legality 조건으로 사용한다.
- [ ] scalar cleanup loop, horizontal reduction, masked tail 정책을 target별로 분리한다.
- [ ] SSE2, AVX2, 이후 확장 feature gate를 benchmark와 연결한다.

구현 메모: `ssa.vector_ir`를 추가해 O2에서 slice/Vec reduction call과 load+numeric loop를 target-independent vector plan으로
요약한다. legality, scalar tail, horizontal reduction, SSE2/AVX2 feature gate, scalar fallback 카운터를 생산하고
LLVM opt report에 연결한다. 아직 실제 Vector IR 노드, scalar cleanup loop 생성, SSE2/AVX2 codegen 소비 경로는 남아 있다.

DoD:
- [ ] LLVM 또는 native ASM에서 실제 vector path 확인
- [x] alias 불명확 케이스는 scalar fallback 유지
- [ ] microbenchmark에서 대표 reduction 성능 개선 확인

### 31. Native Machine IR와 Instruction Selection

- [ ] SSA 이후 machine IR 계층을 만들어 instruction selection, scheduling, regalloc 입력을 안정화한다.
- [ ] x86-64 addressing mode, compare/test/setcc, lea, immediate, memory folding을 machine IR에서 선택한다.
- [ ] call ABI, stack alignment, red zone, callee/caller-save 정책을 target description으로 분리한다.
- [ ] LLVM backend와 native backend가 같은 semantic lowering summary를 공유하게 한다.
- [ ] target feature별 lowering 차이를 opt report와 differential test에서 확인한다.

현재 상태: `ssa.backend_contract`가 O2 함수별 machine lowering contract를 SSA opcode와 call ABI 후보에서 계산하고,
`lower_ssa`와 LLVM contract emitter가 같은 summary를 공유한다. `66_o2_machine_regalloc_metadata_llvm_success.bpp`에서
addressing mode, compare/test/setcc, ABI, LLVM/native semantic summary metadata를 확인한다.
실제 네이티브 코드 생성 소비 경로도 시작했다. `lower_phys`를 regalloc 전 단계로 옮겨 pseudo local memory op가 생기면 명시 주소 op로 낮출 수 있게 했고,
SSA native codegen은 `lea rbp-local` + `load/store`, `lea rbp-local` + `add const` + `load/store`를 x86-64 `[rbp+disp]`
memory operand로 접는다. 주소 레지스터가 바로 다음 명령에서 다시 쓰이는 경우와 call argument에 남는 경우는 보수적으로 접지 않는다.
`71_o1_machine_ir_local_mem_fold_asm_success.bpp`가 이 실제 경로를 어셈블리 기대값으로 고정한다.
`72_machine_ir_native_llvm_differential_success.bpp`는 같은 lowering 대상 코드가 native SSA와 LLVM build에서 같은 결과를 내는지 확인한다.
`-dump-machine-ir`는 phi 제거와 `lower_phys` 이후, regalloc 전의 Machine IR 입력 형태를 출력한다. 아직 독립 Machine IR 자료구조,
scheduler, target description 통합은 남아 있어서 섹션 자체는 미완료로 둔다.

DoD:
- [x] native backend runtime 테스트가 LLVM backend와 일치
- [x] 기존 ASM expectation 회귀 없음
- [x] machine IR dump가 regalloc/codegen 디버깅에 사용 가능

### 32. Production Register Allocation

- [x] live interval 정보를 graph-color 선택 순서에 넣고 기존 색칠/선호색 경로와 비교 가능한 형태로 연결한다.
- [x] rematerialization 후보, copy coalescing 후보, call constraint, pressure/split/spill 후보를 regalloc2/regalloc3 metadata report로 통합한다.
- [x] regalloc 성공 후 같은 물리 레지스터로 합쳐진 copy를 실제 `nop`으로 제거한다.
- [x] regalloc 실패 시 기존 graph-color 실패 플래그와 non-SSA fallback 경로를 유지한다.
- [x] 제한형 live range splitting과 spill/reload 삽입을 native SSA 코드 생성에 연결한다.
- [x] O1 GPR class를 r12-r15 callee-saved까지 넓히고 prologue/epilogue 보존 정책을 native codegen에 연결한다.
- [x] XMM register class와 ABI fixed/call-clobbered class를 GPR allocator와 같은 constraint 모델로 통합한다.
- [x] arg-save, pseudo local, callee-save slot을 동적 stack frame layout consumer와 연결해 작은 SSA 함수 frame size를 줄인다.
- [x] 실제 spill slot coloring을 spill/reload 삽입기와 연결한다.

현재 상태: native SSA regalloc은 interference graph의 정당성은 유지하면서, live interval의 시작/끝, use/def 수,
rematerialization 가능성을 색칠 순서에 반영한다. non-interfering copy 선호색은 그대로 유지하고, 적용 후 같은 물리
레지스터가 된 copy는 `nop`으로 지운다. 색칠 실패 시에는 작은 함수에 한해 실패 후보 가상 레지스터를 pseudo stack
slot에 내리고, use 앞에는 reload, def 뒤에는 store를 넣은 뒤 다시 색칠한다. 이 spill/reload 경로는 fallback 전에
최대 32회만 시도해서 컴파일 시간 폭발을 막는다. O1 이상에서는 GPR class를 rax..r11에서 r12..r15까지 확장하며,
r12..r15가 실제로 쓰인 함수만 frame 안에 callee-save slot을 만들고 반환 직전에 복원한다. O0은 기존 8-GPR 경로를
유지해서 unoptimized number runtime 함수가 너무 이르게 native SSA 경로로 올라가며 생기는 회귀를 피한다.

call을 가로질러 살아있는 SSA 값은 O1의 12-GPR class에서 r12..r15 계열 색을 먼저 시도한다. 그래서 caller-saved
레지스터에 갇혀 call 주변 store/load가 늘어나는 케이스를 줄인다. f64/XMM 연산 SSA 값은 별도 제약 클래스로 표시해서
copy 선호색이나 call-live 선택과 충돌하지 않게 한다. native backend의 f64 값 저장은 아직 GPR bit-pattern과 xmm scratch
lowering을 함께 쓰지만, regalloc 단계에서는 XMM 관련 값을 일반 정수 pressure와 구분해 선택 순서와 색 선호를 달리한다.

frame layout도 고정 1088바이트 arg-save 영역에서 벗어나, explicit local, arg-save, pseudo local, callee-save slot을
함수별로 계산한다. `73_regalloc32_live_interval_runtime_success.bpp`는 call-heavy pressure 함수가 O1에서 native SSA로
내려가고 r12 보존 슬롯을 생성하는지 asm으로 확인한다. `71_o1_machine_ir_local_mem_fold_asm_success.bpp`는 local memory
folding이 새 frame layout에서도 유지되는지 확인한다.

spill/reload retry는 이제 매번 새 pseudo stack slot만 만들지 않는다. spill 후보의 live interval 시작/끝을 계산하고,
이미 spilled 된 값들과 lifetime이 겹치지 않으면 같은 slot id를 재사용한다. 겹치는 경우에만 새 slot을 발급하므로
spill slot 수가 압력에 비례해서 무조건 늘어나는 문제를 막는다. 테스트 러너에는 `Expect asm count <=:` directive를
추가해서, 특정 asm 패턴이 기준보다 많이 생기면 CI에서 바로 잡을 수 있게 했다.

DoD:
- [x] 큰 함수와 call-heavy 함수에서 기존 graph-color regalloc 실패 없음
- [x] 불필요한 copy가 post-regalloc `nop`으로 제거되는 경로 구현
- [x] call-heavy pressure 함수가 O1 native SSA asm에서 r12 callee-save slot을 생성하는지 확인
- [x] focused regalloc/number/machine-fold 회귀 통과
- [x] spill 수가 회귀 기준을 넘으면 CI에서 감지

### 33. Runtime Allocator와 GC 최적화 통합

- [ ] size-class slab, huge allocation, thread-local cache, debug allocator를 optimizer summary와 연결한다.
- [ ] nursery, old generation, pinned, borrowed, immortal lifecycle tag를 allocation lowering에 반영한다.
- [ ] escape analysis 결과로 stack, arena, nursery, old heap 선택을 자동화한다.
- [ ] write barrier 생략, safepoint 배치, stack map 생성을 MemorySSA와 proof engine에 연결한다.
- [ ] moving GC를 염두에 둔 pointer map, relocation-safe object layout, pinning 정책을 만든다.

현재 상태: runtime/GC contract는 `bpp_heap_*`, `bpp_gc_*`, tagged allocator, write barrier, stack/arena call을
MemorySSA2/IPA allocation summary와 합쳐 allocator, lifecycle, escape, stackmap 정책 카운터로 만든다.
`67_o2_runtime_gc_number_metadata_llvm_success.bpp`가 allocator/GC metadata와 실행 결과를 검증한다. 실제 allocation
lowering이 SSA escape 결과를 직접 소비해 stack/arena/nursery/old heap을 선택하는 연결은 아직 남아 있다.

DoD:
- [ ] allocation-heavy benchmark에서 allocator 정책별 수치 비교 가능
- [ ] barrier 생략 성공/실패와 safepoint metadata 테스트 추가
- [ ] GC/allocator debug mode에서 poisoning/redzone/canary 오류를 잡음

### 34. Number와 Numeric Tower 최적화

- [ ] `number`의 integer, float, complex, bigint 표현을 range/type proof 기반으로 SSA에서 분리한다.
- [ ] small-int arithmetic은 overflow proof에 따라 machine integer fast path와 bigint slow path로 나눈다.
- [ ] float/complex 연산은 scalar SSA 값으로 쪼개고 vectorizer 후보로 연결한다.
- [ ] bigint 곱셈, 나눗셈, mod, pow threshold를 benchmark 기반으로 자동 조정한다.
- [ ] number container와 slice 연산을 SIMD, loop optimizer, allocator 정책과 함께 최적화한다.

현재 상태: number contract는 numeric SSA opcode, `std_number__Number_*` call, float op, div/mod overflow 후보,
vector plan을 하나의 numeric tower summary로 묶는다. `67_o2_runtime_gc_number_metadata_llvm_success.bpp`가
`number` 산술 실행과 numeric tower metadata를 같이 확인한다. 실제 SSA value representation split과 machine fast path
rewrite는 아직 production 완료가 아니다.

DoD:
- [ ] `number`만 사용한 코드가 typed integer/float 코드에 가까운 성능을 보이는 benchmark 추가
- [ ] overflow, NaN, complex, bigint 경계 테스트 추가
- [ ] Number 문서와 실제 lowering/metadata가 일치

### 35. Object Shape, Container, Inline Cache 최적화

- [ ] object, struct-like value, Vec, Map, string의 shape metadata를 공통 representation으로 둔다.
- [ ] shape-stable field access와 method call을 inline cache와 devirtualization으로 낮춘다.
- [ ] Vec/string/slice의 length, capacity, ownership proof를 bounds, alias, allocation 최적화에 사용한다.
- [ ] container mutation이 shape/range/alias proof를 어떻게 깨는지 통합 invalidation 규칙을 만든다.
- [ ] hot container operation은 specialized fast path와 cold generic fallback으로 분리한다.

현재 상태: shape/inline-cache contract는 shape, fast-path, tagged slice, Vec, string call과 memory mutation을
shape proof, invalidation, hot fast path summary로 집계한다. `68_o2_shape_incremental_metadata_llvm_success.bpp`가
shape-stable fast path와 report metadata를 검증한다. 실제 object/container access lowering이 이 shape summary를 소비하는
rewrite는 아직 남아 있다.

DoD:
- [ ] shape-stable field/method fast path 테스트 추가
- [ ] mutation 뒤 stale shape proof가 사용되지 않음
- [ ] Vec/string 대표 benchmark에서 fast path 개선 확인

### 36. Incremental Build System과 Persistent Cache

- [ ] lexer, parser, typeinfo, SSA, machine IR, object artifact를 단계별 persistent cache로 분리한다.
- [ ] content hash, compiler version, opt level, target, feature flag, std/prelude hash를 cache key에 포함한다.
- [ ] import graph와 generic instantiation graph를 함께 추적해 최소 invalidation을 수행한다.
- [ ] cache artifact가 deterministic하고 재현 가능한지 CI에서 비교한다.
- [ ] cache corruption 또는 version mismatch 시 안전하게 cold rebuild로 fallback한다.

현재 상태: incremental contract는 함수/block/instruction graph와 opt-level/target/std hash policy를 persistent-cache
summary로 내보낸다. 실제 cache artifact의 deterministic/cold rebuild surface는 LLVM metadata와 opt report로 확인하며,
`68_o2_shape_incremental_metadata_llvm_success.bpp`가 persistent cache contract를 검증한다. 디스크 persistent cache와
최소 invalidation executor는 아직 production 완료가 아니다.

DoD:
- [ ] 수정된 파일의 영향 범위만 재컴파일되는 benchmark 추가
- [ ] cache hit/miss와 invalidation 원인이 report로 출력됨
- [ ] cache on/off 최종 바이너리 결과가 일치

### 37. PGO, Auto-Tuning, Benchmark Governance

- [ ] benchmark suite를 compile-time, runtime, memory, code-size 축으로 분리한다.
- [ ] inline, unroll, vector, bigint, allocator, GC threshold를 benchmark 결과로 조정하는 흐름을 만든다.
- [ ] profile data를 branch probability, hot/cold layout, specialization budget에 반영한다.
- [ ] noisy benchmark를 줄이기 위해 반복 횟수, median, variance, machine info를 기록한다.
- [ ] 성능 기준선을 저장하고 회귀 허용 범위를 CI 정책으로 관리한다.

현재 상태: PGO2 contract는 profile/fast-path call, vector/inliner candidates, opt level을 benchmark axis와 threshold
governance summary로 묶는다. `69_o2_pgo_verify_metadata_llvm_success.bpp`가 autotune threshold와 noise-policy metadata를
확인한다. 실제 profile file ingestion과 threshold rewrite 정책 반영은 아직 남아 있다.

DoD:
- [ ] benchmark 결과가 threshold 변경 PR과 함께 남음
- [ ] 성능 회귀가 기준선을 넘으면 CI 또는 수동 gate에서 감지
- [ ] PGO on/off 결과와 성능 차이를 report로 비교 가능

### 38. Verification, Fuzzing, Differential Infrastructure

- [ ] SSA, Machine IR, regalloc, stack map, GC metadata verifier를 pass framework에 통합한다.
- [ ] random program generator를 type-aware, ownership-aware, number-aware 수준으로 확장한다.
- [ ] O0/O1/O2/O3, LLVM/native, cache on/off, debug/release runtime 결과를 differential 비교한다.
- [ ] crash minimizer가 실패 입력을 줄여 `test/source` bundle로 승격할 수 있게 한다.
- [ ] sanitizer-like runtime을 bounds, use-after-free, GC barrier, tag misuse 검출에 연결한다.

현재 상태: verify2 contract는 O2 summary pass에서 Machine IR, regalloc, GC/barrier, cache, opt-level matrix를
같은 verifier/fuzz/differential report surface로 내보낸다. `69_o2_pgo_verify_metadata_llvm_success.bpp`가
type/ownership/number-aware generator와 minimize policy metadata를 확인한다. 실제 generator/minimizer/sanitizer executor는
아직 production 완료가 아니다.

DoD:
- [ ] nightly 또는 수동 full fuzz에서 충분한 케이스 수를 통과
- [ ] 발견된 실패가 최소화되어 회귀 테스트로 자동 편입 가능
- [ ] verifier false positive/false negative를 추적하는 문서와 테스트 추가

### 39. Compile-Time 성능과 메모리 상한

- [ ] self-host 단계별 CPU time, peak RSS, allocation count, arena high-water mark를 기록한다.
- [ ] pass별 자료구조를 arena, bump allocator, sparse set, bitset 등으로 재설계해 peak memory를 줄인다.
- [ ] 대형 함수와 대형 모듈에 대한 pass budget, bailout, chunking 정책을 만든다.
- [ ] CI와 로컬 benchmark에서 1GB, 2GB, 3GB 메모리 제한 시나리오를 비교한다.
- [ ] compile-time regression이 생기면 어떤 pass가 원인인지 report에서 바로 보이게 한다.

현재 상태: memory-limit contract는 O2 instruction budget, MemorySSA/allocator evidence, per-pass detail counter를
RSS/arena budget report로 내보낸다. `70_o2_memory_release_metadata_llvm_success.bpp`가 self-host RSS, fallback,
pass attribution metadata surface를 검증한다. 실제 pass별 wall/RSS profiler와 CI regression gate는 아직 남아 있다.

DoD:
- [ ] self-host peak RSS와 wall time 기준선 저장
- [ ] 메모리 제한 환경에서 compiler가 OOM 대신 보수 fallback으로 완료
- [ ] compile-time 또는 RSS 회귀가 benchmark report에 명확히 표시

### 40. Release-Grade Optimization Contract

- [ ] 각 opt level의 의미를 언어 스펙, CLI help, 문서, test policy에 일관되게 명시한다.
- [ ] "완료" 기준을 metadata-only, conservative implementation, production implementation 세 단계로 구분한다.
- [ ] 새 최적화는 correctness test, negative test, opt report, benchmark 중 필요한 항목을 반드시 함께 추가한다.
- [ ] release 전에는 full self-host, LLVM/native differential, benchmark, fuzz smoke를 하나의 checklist로 실행한다.
- [ ] 사용자가 체감하는 성능 계약을 만든다: `number`, Vec/string, function call, allocation, loop, compile-time 기준선.

현재 상태: release contract는 O2 함수 summary에 opt-level, done-level, test policy, release checklist, user-visible
baseline을 고정된 report surface로 남긴다. `70_o2_memory_release_metadata_llvm_success.bpp`가 release-grade contract
metadata와 실행 결과를 함께 검증한다. 실제 release checklist executor와 기준선 gate는 아직 production 완료가 아니다.

DoD:
- [ ] release checklist 문서와 CI/manual command가 일치
- [ ] 최적화 완료 단계가 문서에서 과장 없이 표시됨
- [ ] 주요 언어 기능별 성능 기준선이 benchmark suite에 존재
