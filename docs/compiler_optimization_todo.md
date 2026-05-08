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
- [ ] spill/reload 생성을 안정화한다.
- [ ] live range splitting을 추가한다.
- [ ] register coalescing을 추가한다.
- [ ] phi-copy coalescing을 SSA destroy와 연결한다.
- [ ] rematerialization 후보를 const/lea/tag strip 중심으로 만든다.
- [ ] caller-saved/callee-saved 비용 모델을 만든다.
- [ ] instruction constraint aware allocation을 추가한다.
- [ ] XMM register allocation을 별도 축으로 분리한다.
- [ ] stack slot coloring으로 spill slot을 재사용한다.

DoD:
- [ ] 큰 함수에서 regalloc 실패 없이 빌드되는 테스트 추가
- [ ] 불필요한 move가 줄어드는 dump/metadata 확인
- [ ] fast 전체 회귀 통과

### 7. Codegen Peephole과 Instruction Selection

- [x] O1 roadmap pass에서 mov/lea/test/zero-idiom/immediate/mem-fold/call-save 후보를 `peephole` 카운터와 LLVM 메타데이터로 노출한다.
- [ ] redundant `mov`를 제거한다.
- [ ] `add`/`mul` 주소 계산을 `lea`로 합친다.
- [ ] `cmp reg, 0`을 가능한 경우 `test reg, reg`로 낮춘다.
- [ ] zero idiom은 `xor reg, reg`를 사용한다.
- [ ] immediate form을 우선 선택한다.
- [ ] memory operand folding을 안전한 load에만 적용한다.
- [ ] branch inversion과 fallthrough layout을 추가한다.
- [ ] call 전후 save/restore를 live register 기반으로 줄인다.
- [ ] 작은 memcpy/memset inline lowering을 추가한다.

DoD:
- [ ] ASM dump 기반 peephole 테스트 추가
- [ ] 기존 inline asm 테스트 회귀 없음
- [ ] fast 전체 회귀 통과

### 8. Stack/Object SROA 확장

- [x] O1 roadmap pass에서 field scalarization, struct copy, dead field store, slice header 추적 후보를 `sroa2` 카운터와 LLVM 메타데이터로 노출한다.
- [ ] stack object를 field별 SSA 값으로 쪼갠다.
- [ ] struct copy를 field copy 또는 scalar copy로 낮춘다.
- [ ] dead field store를 제거한다.
- [ ] escaped field만 heap/object 경로로 유지한다.
- [ ] aggregate return scalarization을 검토한다.
- [ ] slice header의 `ptr`과 `len`을 별도 SSA 값으로 추적한다.
- [ ] stack-new SROA와 일반 local object SROA를 같은 증명 체계로 합친다.

DoD:
- [ ] struct field store/load 제거 테스트 추가
- [ ] stack-new bundled 테스트 회귀 없음
- [ ] fast 전체 회귀 통과

### 9. Tagged Pointer 최적화 확장

- [x] O1 roadmap pass에서 block/phi tag state, MemorySSA alias, lifecycle, shape, hot path 후보를 `tag2` 카운터와 LLVM 메타데이터로 노출한다.
- [ ] tag state를 block/phi 경계로 전파한다.
- [ ] tagged pointer 기반 alias analysis를 MemorySSA와 연결한다.
- [ ] lifecycle tag로 free/barrier/refcount 제거를 더 공격적으로 수행한다.
- [ ] shape tag로 devirtualization과 container fast path를 선택한다.
- [ ] profile/hot tag로 hot path specialization을 선택한다.
- [ ] tag metadata verifier를 만든다.
- [ ] tag state invalidation 규칙을 call/memory effect와 연결한다.
- [ ] tagged slice/vector loop specialization을 loop optimizer와 연결한다.

DoD:
- [ ] tagged metadata bundle에 phi/block 경계 케이스 추가
- [ ] O1 LLVM dump에서 tagged alias/shape metadata 확인
- [ ] fast 전체 회귀 통과

### 10. Number 전용 IR lowering

- [x] O1 roadmap pass에서 small-int, float/complex, overflow/bigint slow path, vector 후보를 `number_ir` 카운터와 LLVM 메타데이터로 노출한다.
- [ ] `number` literal range를 기반으로 small integer 표현을 선택한다.
- [ ] `number` 연산을 i8/i16/i32/i64/u*/f*/complex fast path로 specialize한다.
- [ ] overflow path와 bigint slow path를 분리한다.
- [ ] bigint slow path는 cold block으로 outline한다.
- [ ] complex 연산은 실수부/허수부 scalar SSA 값으로 쪼갠다.
- [ ] `number` constant folding을 O1에 추가한다.
- [ ] number array/vector path를 loop/vector optimizer와 연결한다.
- [ ] stack slot 크기와 tagged representation 정책을 type/range proof와 연결한다.

DoD:
- [ ] Number 문서와 실제 compiler metadata가 일치
- [ ] number runtime bundle에 IR specialization 확인 케이스 추가
- [ ] fast 전체 회귀 통과

### 11. PGO와 벤치마크 기반 튜닝

- [x] O1 roadmap pass에서 benchmark report, inline/bigint/allocator/vector threshold 후보를 `pgo` 카운터와 LLVM 메타데이터로 노출한다.
- [ ] microbenchmark runner를 만든다.
- [ ] compile-time optimization report를 만든다.
- [ ] inlining threshold를 벤치마크 기반으로 조정한다.
- [ ] bigint 곱셈/나눗셈 threshold를 벤치마크 기반으로 조정한다.
- [ ] allocator threshold를 벤치마크 기반으로 조정한다.
- [ ] vector/unroll threshold를 벤치마크 기반으로 조정한다.
- [ ] CI에서 성능 회귀를 기록하는 별도 job을 만든다.
- [ ] 빠른 CI와 full benchmark CI를 분리한다.

DoD:
- [ ] 같은 입력, 같은 backend, 같은 opt level 기준으로 전후 성능 비교 가능
- [ ] threshold 변경이 문서와 benchmark 결과에 함께 기록됨
