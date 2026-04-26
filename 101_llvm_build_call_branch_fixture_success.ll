; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=3 insts=16 phis=0 entry=0 term_op=31 params=2 sig=1 body_params=1
; bpp.ssa.ops=27,26,51,67,27,26,51,67,25,25,104,31,25,32,25,32
define i64 @"_101_llvm_build_call_branch_fixture_success__choose_big_101"(i64 %p0, i64 %p1) {
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
  %r7 = icmp ugt i64 %r5, %r6
  br i1 %r7, label %bb1, label %bb2
bb1:
  %r8 = load i64, ptr %var2
  ret i64 %r8
bb2:
  %r9 = load i64, ptr %var1
  ret i64 %r9
}
; bpp.ssa.blocks=1 insts=6 phis=0 entry=0 term_op=32 params=0 sig=1 body_params=1
; bpp.ssa.ops=10,10,28,10,12,32
define i64 @"_101_llvm_build_call_branch_fixture_success__runtime_entry"() {
entry:
  %r2 = add i64 0, 3
  %r3 = add i64 0, 5
  %r1 = call i64 @"_101_llvm_build_call_branch_fixture_success__choose_big_101"(i64 %r2, i64 %r3)
  %r4 = add i64 0, 5
  %r5 = sub i64 %r1, %r4
  ret i64 %r5
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_101_llvm_build_call_branch_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_101_llvm_build_call_branch_fixture_success__runtime_entry", !"bpp.contract.surface", !"101_llvm_build_call_branch_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 10, i64 6, i64 0, i64 0, !"_101_llvm_build_call_branch_fixture_success__runtime_entry"}
!1 = !{ptr @"_101_llvm_build_call_branch_fixture_success__runtime_entry", !"bpp.contract.entry", !"101_llvm_build_call_branch_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 10, i64 6, i64 0, i64 0, !"_101_llvm_build_call_branch_fixture_success__runtime_entry"}
