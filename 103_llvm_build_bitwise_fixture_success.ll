; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=1 insts=24 phis=0 entry=0 term_op=32 params=2 sig=1 body_params=1
; bpp.ssa.ops=27,26,51,67,27,26,51,67,25,10,34,25,10,37,35,26,25,10,36,10,39,26,25,32
define i64 @"_103_llvm_build_bitwise_fixture_success__mix_bits_103"(i64 %p0, i64 %p1) {
entry:
  %var1 = alloca i64
  %loc4611686018427387896 = alloca i64
  %var2 = alloca i64
  %loc4611686018427387888 = alloca i64
  %var3 = alloca i64
  %var4 = alloca i64
  %r1 = add i64 0, %p1
  store i64 %r1, ptr %var1
  %r2 = ptrtoint ptr %loc4611686018427387896 to i64
  store i64 %r1, ptr %loc4611686018427387896
  %r3 = add i64 0, %p0
  store i64 %r3, ptr %var2
  %r4 = ptrtoint ptr %loc4611686018427387888 to i64
  store i64 %r3, ptr %loc4611686018427387888
  %r5 = load i64, ptr %var2
  %r6 = add i64 0, 15
  %r7 = and i64 %r5, %r6
  %r8 = load i64, ptr %var1
  %r9 = add i64 0, 2
  %r10 = shl i64 %r8, %r9
  %r11 = or i64 %r7, %r10
  store i64 %r11, ptr %var3
  %r12 = load i64, ptr %var3
  %r13 = add i64 0, 3
  %r14 = xor i64 %r12, %r13
  %r15 = add i64 0, 1
  %r16 = ashr i64 %r14, %r15
  store i64 %r16, ptr %var4
  %r17 = load i64, ptr %var4
  ret i64 %r17
}
; bpp.ssa.blocks=1 insts=6 phis=0 entry=0 term_op=32 params=0 sig=1 body_params=1
; bpp.ssa.ops=10,10,28,10,12,32
define i64 @"_103_llvm_build_bitwise_fixture_success__runtime_entry"() {
entry:
  %r2 = add i64 0, 10
  %r3 = add i64 0, 5
  %r1 = call i64 @"_103_llvm_build_bitwise_fixture_success__mix_bits_103"(i64 %r2, i64 %r3)
  %r4 = add i64 0, 14
  %r5 = sub i64 %r1, %r4
  ret i64 %r5
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_103_llvm_build_bitwise_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_103_llvm_build_bitwise_fixture_success__runtime_entry", !"bpp.contract.surface", !"103_llvm_build_bitwise_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 11, i64 6, i64 0, i64 0, !"_103_llvm_build_bitwise_fixture_success__runtime_entry"}
!1 = !{ptr @"_103_llvm_build_bitwise_fixture_success__runtime_entry", !"bpp.contract.entry", !"103_llvm_build_bitwise_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 11, i64 6, i64 0, i64 0, !"_103_llvm_build_bitwise_fixture_success__runtime_entry"}
