; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32 params=2 sig=1 body_params=1
; bpp.ssa.ops=27,26,51,66,27,26,51,66,25,25,11,32
define i32 @"_106_llvm_build_narrow_sig_fixture_success__sum_small_106"(i32 %p0, i32 %p1) {
entry:
  %var1 = alloca i64
  %loc4611686018427387900 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387896 = alloca i64
  %r1 = zext i32 %p1 to i64
  store i64 %r1, ptr %var1
  %r2 = ptrtoint ptr %loc4611686018427387900 to i64
  %store0_3 = trunc i64 %r1 to i32
  store i32 %store0_3, ptr %loc4611686018427387900
  %r3 = zext i32 %p0 to i64
  store i64 %r3, ptr %var2
  %r4 = ptrtoint ptr %loc4611686018427387896 to i64
  %store0_7 = trunc i64 %r3 to i32
  store i32 %store0_7, ptr %loc4611686018427387896
  %r5 = load i64, ptr %var2
  %r6 = load i64, ptr %var1
  %r7 = add i64 %r5, %r6
  %retcast0_11 = trunc i64 %r7 to i32
  ret i32 %retcast0_11
}
; bpp.ssa.blocks=1 insts=10 phis=0 entry=0 term_op=32 params=0 sig=1 body_params=1
; bpp.ssa.ops=10,10,34,10,10,34,28,10,12,32
define i64 @"_106_llvm_build_narrow_sig_fixture_success__runtime_entry"() {
entry:
  %r2 = add i64 0, 3
  %r3 = add i64 0, 4294967295
  %r4 = and i64 %r2, %r3
  %r5 = add i64 0, 4
  %r6 = add i64 0, 4294967295
  %r7 = and i64 %r5, %r6
  %argcast0_6_0 = trunc i64 %r4 to i32
  %argcast0_6_1 = trunc i64 %r7 to i32
  %callraw0_6 = call i32 @"_106_llvm_build_narrow_sig_fixture_success__sum_small_106"(i32 %argcast0_6_0, i32 %argcast0_6_1)
  %r1 = zext i32 %callraw0_6 to i64
  %r8 = add i64 0, 7
  %r9 = sub i64 %r1, %r8
  ret i64 %r9
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_106_llvm_build_narrow_sig_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_106_llvm_build_narrow_sig_fixture_success__runtime_entry", !"bpp.contract.surface", !"106_llvm_build_narrow_sig_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 9, i64 6, i64 0, i64 0, !"_106_llvm_build_narrow_sig_fixture_success__runtime_entry"}
!1 = !{ptr @"_106_llvm_build_narrow_sig_fixture_success__runtime_entry", !"bpp.contract.entry", !"106_llvm_build_narrow_sig_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 9, i64 6, i64 0, i64 0, !"_106_llvm_build_narrow_sig_fixture_success__runtime_entry"}
