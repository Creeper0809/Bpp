; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=4 insts=24 phis=0 entry=0 term_op=30 params=0 sig=1 body_params=1
; bpp.ssa.ops=10,26,10,26,30,25,10,103,31,51,25,25,11,26,51,25,10,11,26,30,25,10,12,32
define i64 @"_102_llvm_build_loop_fixture_success__runtime_entry"() {
entry:
  %var1 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387888 = alloca i64
  %loc4611686018427387896 = alloca i64
  %r1 = add i64 0, 0
  store i64 %r1, ptr %var1
  %r2 = add i64 0, 0
  store i64 %r2, ptr %var2
  br label %bb1
bb1:
  %r3 = load i64, ptr %var1
  %r4 = add i64 0, 5
  %r5 = icmp ult i64 %r3, %r4
  br i1 %r5, label %bb2, label %bb3
bb2:
  %r6 = ptrtoint ptr %loc4611686018427387888 to i64
  %r7 = load i64, ptr %var2
  %r8 = load i64, ptr %var1
  %r9 = add i64 %r7, %r8
  store i64 %r9, ptr %var2
  %r10 = ptrtoint ptr %loc4611686018427387896 to i64
  %r11 = load i64, ptr %var1
  %r12 = add i64 0, 1
  %r13 = add i64 %r11, %r12
  store i64 %r13, ptr %var1
  br label %bb1
bb3:
  %r14 = load i64, ptr %var2
  %r15 = add i64 0, 10
  %r16 = sub i64 %r14, %r15
  ret i64 %r16
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_102_llvm_build_loop_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_102_llvm_build_loop_fixture_success__runtime_entry", !"bpp.contract.surface", !"102_llvm_build_loop_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 4, i64 6, i64 0, i64 0, !"_102_llvm_build_loop_fixture_success__runtime_entry"}
!1 = !{ptr @"_102_llvm_build_loop_fixture_success__runtime_entry", !"bpp.contract.entry", !"102_llvm_build_loop_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 4, i64 6, i64 0, i64 0, !"_102_llvm_build_loop_fixture_success__runtime_entry"}
