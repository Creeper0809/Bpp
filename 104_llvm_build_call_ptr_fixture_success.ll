; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32 params=2 sig=1 body_params=1
; bpp.ssa.ops=27,26,51,67,27,26,51,67,25,25,11,32
define i64 @"_104_llvm_build_call_ptr_fixture_success__add_104"(i64 %p0, i64 %p1) {
entry:
  %var1 = alloca i64
  %loc4611686018427387896 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387888 = alloca i64
  %r1 = add i64 0, %p1
  store i64 %r1, ptr %var1
  %r2 = ptrtoint ptr %loc4611686018427387896 to i64
  store i64 %r1, ptr %loc4611686018427387896
  %r3 = add i64 0, %p0
  store i64 %r3, ptr %var2
  %r4 = ptrtoint ptr %loc4611686018427387888 to i64
  store i64 %r3, ptr %loc4611686018427387888
  %r5 = load i64, ptr %var2
  %r6 = load i64, ptr %var1
  %r7 = add i64 %r5, %r6
  ret i64 %r7
}
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32 params=2 sig=1 body_params=1
; bpp.ssa.ops=27,26,51,67,27,26,51,67,25,25,12,32
define i64 @"_104_llvm_build_call_ptr_fixture_success__sub_104"(i64 %p0, i64 %p1) {
entry:
  %var1 = alloca i64
  %loc4611686018427387896 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387888 = alloca i64
  %r1 = add i64 0, %p1
  store i64 %r1, ptr %var1
  %r2 = ptrtoint ptr %loc4611686018427387896 to i64
  store i64 %r1, ptr %loc4611686018427387896
  %r3 = add i64 0, %p0
  store i64 %r3, ptr %var2
  %r4 = ptrtoint ptr %loc4611686018427387888 to i64
  store i64 %r3, ptr %loc4611686018427387888
  %r5 = load i64, ptr %var2
  %r6 = load i64, ptr %var1
  %r7 = sub i64 %r5, %r6
  ret i64 %r7
}
; bpp.ssa.blocks=3 insts=28 phis=0 entry=0 term_op=31 params=0 sig=1 body_params=1
; bpp.ssa.ops=53,26,10,10,25,29,26,25,10,16,31,10,32,51,53,26,51,25,10,10,25,29,11,26,25,10,12,32
define i64 @"_104_llvm_build_call_ptr_fixture_success__runtime_entry"() {
entry:
  %var1 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387896 = alloca i64
  %loc4611686018427387888 = alloca i64
  %r1 = ptrtoint ptr @"_104_llvm_build_call_ptr_fixture_success__add_104" to i64
  store i64 %r1, ptr %var1
  %r3 = add i64 0, 9
  %r4 = add i64 0, 1
  %r5 = load i64, ptr %var1
  %callptr0_5 = inttoptr i64 %r5 to ptr
  %r2 = call i64 %callptr0_5(i64 %r3, i64 %r4)
  store i64 %r2, ptr %var2
  %r6 = load i64, ptr %var2
  %r7 = add i64 0, 10
  %r8 = icmp ne i64 %r6, %r7
  br i1 %r8, label %bb1, label %bb2
bb1:
  %r9 = add i64 0, 1
  ret i64 %r9
bb2:
  %r10 = ptrtoint ptr %loc4611686018427387896 to i64
  %r11 = ptrtoint ptr @"_104_llvm_build_call_ptr_fixture_success__sub_104" to i64
  store i64 %r11, ptr %var1
  %r12 = ptrtoint ptr %loc4611686018427387888 to i64
  %r13 = load i64, ptr %var2
  %r15 = add i64 0, 9
  %r16 = add i64 0, 1
  %r17 = load i64, ptr %var1
  %callptr2_8 = inttoptr i64 %r17 to ptr
  %r14 = call i64 %callptr2_8(i64 %r15, i64 %r16)
  %r18 = add i64 %r13, %r14
  store i64 %r18, ptr %var2
  %r19 = load i64, ptr %var2
  %r20 = add i64 0, 18
  %r21 = sub i64 %r19, %r20
  ret i64 %r21
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_104_llvm_build_call_ptr_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_104_llvm_build_call_ptr_fixture_success__runtime_entry", !"bpp.contract.surface", !"104_llvm_build_call_ptr_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 14, i64 6, i64 0, i64 0, !"_104_llvm_build_call_ptr_fixture_success__runtime_entry"}
!1 = !{ptr @"_104_llvm_build_call_ptr_fixture_success__runtime_entry", !"bpp.contract.entry", !"104_llvm_build_call_ptr_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 14, i64 6, i64 0, i64 0, !"_104_llvm_build_call_ptr_fixture_success__runtime_entry"}
