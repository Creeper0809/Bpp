; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=1 insts=6 phis=0 entry=0 term_op=32 params=0 sig=1 body_params=1
; bpp.ssa.ops=89,89,90,89,91,32
define double @"_105_llvm_build_float_fixture_success__runtime_entry"() {
entry:
  %r1 = fadd double 0.0, 1.5
  %r2 = fadd double 0.0, 1.5
  %r3 = fadd double %r1, %r2
  %r4 = fadd double 0.0, 3.0
  %r5 = fsub double %r3, %r4
  ret double %r5
}
define i32 @"main"() {
entry:
  %entry_ret = call double @"_105_llvm_build_float_fixture_success__runtime_entry"()
  %entry_i32 = fptosi double %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_105_llvm_build_float_fixture_success__runtime_entry", !"bpp.contract.surface", !"105_llvm_build_float_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 4, i64 6, i64 0, i64 0, !"_105_llvm_build_float_fixture_success__runtime_entry"}
!1 = !{ptr @"_105_llvm_build_float_fixture_success__runtime_entry", !"bpp.contract.entry", !"105_llvm_build_float_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 4, i64 6, i64 0, i64 0, !"_105_llvm_build_float_fixture_success__runtime_entry"}
