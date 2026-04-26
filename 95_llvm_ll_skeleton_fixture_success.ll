; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=1 insts=2 phis=0 entry=0 term_op=32
define i64 @"_95_llvm_ll_skeleton_fixture_success__runtime_entry"() {
entry:
  %r1 = add i64 0, 0
  ret i64 %r1
}
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_95_llvm_ll_skeleton_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_95_llvm_ll_skeleton_fixture_success__runtime_entry", !"bpp.contract.surface", !"95_llvm_ll_skeleton_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 7, i64 6, i64 0, i64 0, !"_95_llvm_ll_skeleton_fixture_success__runtime_entry"}
!1 = !{ptr @"_95_llvm_ll_skeleton_fixture_success__runtime_entry", !"bpp.contract.entry", !"95_llvm_ll_skeleton_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 7, i64 6, i64 0, i64 0, !"_95_llvm_ll_skeleton_fixture_success__runtime_entry"}
