; bpp llvm ll skeleton v1
source_filename = "bpp-llvm-skeleton"
target triple = "x86_64-unknown-linux-gnu"

; bpp.ssa.blocks=17 insts=112 phis=0 entry=0 term_op=31
declare i64 @"std_str__str_eq"(i64 %p0, i64 %p1, i64 %p2, i64 %p3)
; bpp.ssa.blocks=5 insts=40 phis=0 entry=0 term_op=30
declare i64 @"std_str__str_copy"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=5 insts=25 phis=0 entry=0 term_op=30
declare i64 @"std_str__str_len"(i64 %p0)
; bpp.ssa.blocks=1 insts=23 phis=0 entry=0 term_op=32
declare i64 @"std_str__str_copy_segment"(i64 %p0, i64 %p1, i64 %p2, i64 %p3)
; bpp.ssa.blocks=1 insts=48 phis=0 entry=0 term_op=32
declare i64 @"std_str__str_concat"(i64 %p0, i64 %p1, i64 %p2, i64 %p3)
; bpp.ssa.blocks=1 insts=67 phis=0 entry=0 term_op=32
declare i64 @"std_str__str_concat3"(i64 %p0, i64 %p1, i64 %p2, i64 %p3, i64 %p4, i64 %p5)
; bpp.ssa.blocks=1 insts=2 phis=0 entry=0 term_op=32
define i64 @"std_os__os_host_is_windows"() {
entry:
  %r1 = add i64 0, 0
  ret i64 %r1
}
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_brk"(i64 %p0)
; bpp.ssa.blocks=1 insts=28 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_write"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=28 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_read"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=28 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_open"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_close"(i64 %p0)
; bpp.ssa.blocks=1 insts=20 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_fstat"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=4 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_fork"()
; bpp.ssa.blocks=1 insts=28 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_execve"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=36 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_wait4"(i64 %p0, i64 %p1, i64 %p2, i64 %p3)
; bpp.ssa.blocks=1 insts=11 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_exit"(i64 %p0)
; bpp.ssa.blocks=1 insts=20 phis=0 entry=0 term_op=32
declare i64 @"std_os__os_sys_dup2"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=7 insts=49 phis=0 entry=0 term_op=31
declare i64 @"std_os__os_execute"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_brk"(i64 %p0)
; bpp.ssa.blocks=1 insts=17 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_write"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=17 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_read"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=17 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_open"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_close"(i64 %p0)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_fstat"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=8 phis=0 entry=0 term_op=32
declare i64 @"std_io__sys_exit"(i64 %p0)
; bpp.ssa.blocks=1 insts=10 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_set_output_fd"(i64 %p0)
; bpp.ssa.blocks=3 insts=10 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_get_output_fd"()
; bpp.ssa.blocks=1 insts=15 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_write_out"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=18 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_ensure_out_buffer"()
; bpp.ssa.blocks=5 insts=26 phis=1 entry=0 term_op=31
declare i64 @"std_io__io_flush_out"()
; bpp.ssa.blocks=11 insts=64 phis=1 entry=0 term_op=31
declare i64 @"std_io__io_write_out_buffered"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=17 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_read"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_read_stdin"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=22 insts=126 phis=1 entry=0 term_op=31
declare i64 @"std_io__io_read_line"(i64 %p0, i64 %p1, ptr %p2)
; bpp.ssa.blocks=1 insts=13 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_read_line_stdin"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_io__input"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=16 insts=86 phis=2 entry=0 term_op=31
declare i64 @"std_io__io_parse_u64"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=23 insts=119 phis=2 entry=0 term_op=31
declare i64 @"std_io__io_parse_i64"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=13 insts=73 phis=0 entry=0 term_op=31
declare i1 @"std_io__io_parse_bool"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=37 insts=199 phis=4 entry=0 term_op=31
declare double @"std_io__io_parse_f64"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=32 phis=0 entry=0 term_op=31
declare void @"std_io__input_slice"(...)
; bpp.ssa.blocks=3 insts=33 phis=0 entry=0 term_op=31
declare i64 @"std_io__input_u64"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=3 insts=33 phis=0 entry=0 term_op=31
declare i64 @"std_io__input_i64"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i8 @"std_io__input_u8"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i16 @"std_io__input_u16"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i32 @"std_io__input_u32"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=18 phis=0 entry=0 term_op=32
declare i8 @"std_io__input_i8"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=18 phis=0 entry=0 term_op=32
declare i16 @"std_io__input_i16"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=18 phis=0 entry=0 term_op=32
declare i32 @"std_io__input_i32"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=3 insts=33 phis=0 entry=0 term_op=31
declare i1 @"std_io__input_bool"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=3 insts=34 phis=0 entry=0 term_op=31
declare double @"std_io__input_f64"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_io__input_read"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=24 phis=0 entry=0 term_op=32
declare i64 @"std_io__heap_align8"(i64 %p0)
; bpp.ssa.blocks=1 insts=13 phis=0 entry=0 term_op=32
declare i64 @"std_io__heap_block_get_size"(i64 %p0)
; bpp.ssa.blocks=1 insts=19 phis=0 entry=0 term_op=32
declare i64 @"std_io__heap_block_set_size"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=13 phis=0 entry=0 term_op=32
declare i64 @"std_io__heap_block_get_next"(i64 %p0)
; bpp.ssa.blocks=1 insts=19 phis=0 entry=0 term_op=32
declare i64 @"std_io__heap_block_set_next"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=6 insts=25 phis=0 entry=0 term_op=30
declare i64 @"std_io__heap_free_list_contains"(i64 %p0)
; bpp.ssa.blocks=10 insts=49 phis=0 entry=0 term_op=30
declare i64 @"std_io__heap_free_list_coalesce_adjacent"()
; bpp.ssa.blocks=12 insts=70 phis=2 entry=0 term_op=31
declare i64 @"std_io__heap_free_list_insert"(i64 %p0)
; bpp.ssa.blocks=15 insts=98 phis=0 entry=0 term_op=30
declare i64 @"std_io__heap_try_alloc_from_free_list"(i64 %p0)
; bpp.ssa.blocks=13 insts=102 phis=0 entry=0 term_op=31
declare i64 @"std_io__heap_alloc"(i64 %p0)
; bpp.ssa.blocks=15 insts=63 phis=1 entry=0 term_op=31
declare i64 @"std_io__heap_free"(i64 %p0)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_io__io_panic_invalid_cstr"(i64 %p0)
; bpp.ssa.blocks=5 insts=25 phis=1 entry=0 term_op=31
declare i64 @"std_io__io_guard_cstr_ptr"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=19 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_guard_required_cstr_ptr"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=20 phis=0 entry=0 term_op=32
define void @"std_io__emitln"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=19 phis=0 entry=0 term_op=31
define void @"std_io__emit"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=23 phis=0 entry=0 term_op=31
define void @"std_io__emit_len"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=22 phis=0 entry=0 term_op=31
define void @"std_io__print"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
define void @"std_io__print_nl"() {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=26 phis=0 entry=0 term_op=31
define void @"std_io__println"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
define void @"std_io__print_cstr"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
define void @"std_io__println_cstr"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=10 insts=98 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_u64_to_ascii"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=27 phis=0 entry=0 term_op=31
define void @"std_io__print_u64"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=8 insts=36 phis=1 entry=0 term_op=31
define void @"std_io__print_i64"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=28 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_alloc_cstr"(i64 %p0)
; bpp.ssa.blocks=3 insts=16 phis=0 entry=0 term_op=31
declare i64 @"std_io__io_hex_digit"(i64 %p0)
; bpp.ssa.blocks=3 insts=28 phis=0 entry=0 term_op=31
declare i64 @"std_io__to_str_u64"(i64 %p0)
; bpp.ssa.blocks=7 insts=39 phis=1 entry=0 term_op=31
declare i64 @"std_io__to_str_i64"(i64 %p0)
; bpp.ssa.blocks=3 insts=12 phis=0 entry=0 term_op=31
declare i64 @"std_io__to_str_bool"(i64 %p0)
; bpp.ssa.blocks=5 insts=30 phis=0 entry=0 term_op=31
declare i64 @"std_io__to_str_bytes"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=7 insts=74 phis=0 entry=0 term_op=31
declare i64 @"std_io__to_str_ptr_value"(i64 %p0)
; bpp.ssa.blocks=24 insts=196 phis=1 entry=0 term_op=31
declare i64 @"std_io__to_str_f64"(double %p0)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_slice_meta"(i64 %p0)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_array_meta"(i64 %p0)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_struct_meta"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=2 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_func_meta"()
; bpp.ssa.blocks=1 insts=2 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_null"()
; bpp.ssa.blocks=1 insts=15 phis=0 entry=0 term_op=32
declare i64 @"std_io__to_str_u8_slice"(...)
; bpp.ssa.blocks=5 insts=39 phis=0 entry=0 term_op=30
declare i64 @"std_mem__memset"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_mem__malloc"(i64 %p0)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_mem__free"(i64 %p0)
; bpp.ssa.blocks=11 insts=48 phis=2 entry=0 term_op=31
declare i64 @"std_char__is_alpha"(i64 %p0)
; bpp.ssa.blocks=5 insts=24 phis=1 entry=0 term_op=31
declare i64 @"std_char__is_digit"(i64 %p0)
; bpp.ssa.blocks=5 insts=22 phis=0 entry=0 term_op=31
declare i64 @"std_char__is_alnum"(i64 %p0)
; bpp.ssa.blocks=9 insts=40 phis=0 entry=0 term_op=31
declare i64 @"std_char__is_whitespace"(i64 %p0)
; bpp.ssa.blocks=11 insts=101 phis=1 entry=0 term_op=30
declare i64 @"std_path__path_dirname"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=23 insts=142 phis=1 entry=0 term_op=30
declare i64 @"std_path__path_basename_noext"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=17 phis=0 entry=0 term_op=31
define void @"std_util__init_stack_trace"() {
entry:
  ret void 
}
; bpp.ssa.blocks=9 insts=86 phis=1 entry=0 term_op=31
define void @"std_util__push_trace"(i64 %p0, i64 %p1, i64 %p2) {
entry:
  ret void 
}
; bpp.ssa.blocks=5 insts=19 phis=0 entry=0 term_op=31
define void @"std_util__pop_trace"() {
entry:
  ret void 
}
; bpp.ssa.blocks=9 insts=90 phis=0 entry=0 term_op=31
define void @"std_util__print_stack_trace"() {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=22 phis=0 entry=0 term_op=32
define void @"std_util__set_parsing_context"(i64 %p0, i64 %p1, i64 %p2) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=10 phis=0 entry=0 term_op=32
define void @"std_util__clear_parsing_context"() {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=19 phis=0 entry=0 term_op=31
define void @"std_util__begin_error_capture"() {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=4 phis=0 entry=0 term_op=32
define void @"std_util__end_error_capture"() {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=15 phis=0 entry=0 term_op=32
define void @"std_util__set_error_context"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
define void @"std_util__emit_error"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=7 insts=68 phis=0 entry=0 term_op=31
define void @"std_util__panic"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=26 phis=0 entry=0 term_op=32
define void @"std_util__debug_fail"(i64 %p0, i64 %p1, i64 %p2) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=14 phis=0 entry=0 term_op=31
define void @"std_util__emit_stderr"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=10 insts=62 phis=0 entry=0 term_op=31
define void @"std_util__emit_stderr_len"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
define void @"std_util__emit_stderr_nl"() {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=15 phis=0 entry=0 term_op=32
define void @"std_util__warn"(i64 %p0, i64 %p1) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=27 phis=0 entry=0 term_op=31
define void @"std_util__emit_char"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=27 phis=0 entry=0 term_op=31
define void @"std_util__emit_u64"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=3 insts=27 phis=0 entry=0 term_op=31
define void @"std_util__emit_u64_stderr"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=4 insts=19 phis=0 entry=0 term_op=31
define void @"std_util__emit_i64"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=4 insts=19 phis=0 entry=0 term_op=31
define void @"std_util__emit_i64_stderr"(i64 %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=4 phis=0 entry=0 term_op=32
define void @"std_util__emit_nl"() {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=18 phis=0 entry=0 term_op=32
define void @"std_string_builder__StringBuilder_constructor"(ptr %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=5 insts=40 phis=0 entry=0 term_op=30
declare i64 @"std_string_builder__sb_copy_bytes"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=13 insts=106 phis=0 entry=0 term_op=31
declare i64 @"std_string_builder__StringBuilder_ensure_cap"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=5 insts=59 phis=0 entry=0 term_op=31
declare i64 @"std_string_builder__StringBuilder_init"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=5 insts=35 phis=0 entry=0 term_op=31
declare i64 @"std_string_builder__StringBuilder_new"(i64 %p0)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_string_builder__StringBuilder_clear"(ptr %p0)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare i64 @"std_string_builder__StringBuilder_len"(ptr %p0)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_string_builder__StringBuilder_ptr"(ptr %p0)
; bpp.ssa.blocks=5 insts=61 phis=0 entry=0 term_op=31
declare i64 @"std_string_builder__StringBuilder_append_bytes"(ptr %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare i64 @"std_string_builder__StringBuilder_append_cstr"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=12 insts=109 phis=0 entry=0 term_op=31
declare i64 @"std_string_builder__StringBuilder_append_u64_dec"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=27 insts=289 phis=0 entry=0 term_op=31
declare i64 @"std_vec__vec_memcpy"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=13 insts=81 phis=0 entry=0 term_op=31
declare i64 @"std_hashmap__hm_memzero"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=21 insts=257 phis=0 entry=0 term_op=31
declare i64 @"std_hashmap__hm_memcpy"(i64 %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=13 insts=101 phis=0 entry=0 term_op=30
declare i64 @"std_hashmap__HashMap_hash"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=13 phis=0 entry=0 term_op=32
define void @"std_number__NumberBig_constructor"(ptr %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=8 phis=0 entry=0 term_op=32
declare i64 @"std_number__number_panic_null"(i64 %p0)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare void @"std_number__number_panic_number"(...)
; bpp.ssa.blocks=1 insts=8 phis=0 entry=0 term_op=32
declare ptr @"std_number__number_panic_big"(i64 %p0)
; bpp.ssa.blocks=1 insts=8 phis=0 entry=0 term_op=32
declare i64 @"std_number__number_panic_u64"(i64 %p0)
; bpp.ssa.blocks=1 insts=10 phis=0 entry=0 term_op=32
declare i64 @"std_number__number_small_encode"(i64 %p0)
; bpp.ssa.blocks=1 insts=8 phis=0 entry=0 term_op=32
declare i64 @"std_number__number_small_decode"(i64 %p0)
; bpp.ssa.blocks=1 insts=10 phis=0 entry=0 term_op=32
declare void @"std_number__number_make_small"(...)
; bpp.ssa.blocks=1 insts=1 phis=0 entry=0 term_op=32
declare void @"std_number__number_make_zero"()
; bpp.ssa.blocks=3 insts=11 phis=0 entry=0 term_op=31
declare void @"std_number__number_from_i64"(...)
; bpp.ssa.blocks=3 insts=10 phis=0 entry=0 term_op=31
declare void @"std_number__number_from_u64"(...)
; bpp.ssa.blocks=3 insts=18 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_is_small"(ptr %p0)
; bpp.ssa.blocks=3 insts=16 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_small_value"(ptr %p0)
; bpp.ssa.blocks=5 insts=22 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_big_ptr"(ptr %p0)
; bpp.ssa.blocks=3 insts=16 phis=0 entry=0 term_op=31
declare void @"std_number__number_make_big_handle"(...)
; bpp.ssa.blocks=7 insts=51 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_i64_abs_mag"(i64 %p0, ptr %p1)
; bpp.ssa.blocks=5 insts=18 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_fits_small_i64"(i64 %p0)
; bpp.ssa.blocks=3 insts=51 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_big_new"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=4 phis=0 entry=0 term_op=32
declare ptr @"std_number__number_big_zero"()
; bpp.ssa.blocks=18 insts=89 phis=1 entry=0 term_op=31
declare i64 @"std_number__number_big_trim_inplace"(ptr %p0)
; bpp.ssa.blocks=9 insts=63 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_big_copy"(ptr %p0)
; bpp.ssa.blocks=3 insts=18 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_big_abs_copy"(ptr %p0)
; bpp.ssa.blocks=6 insts=41 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_big_from_u64_raw"(i64 %p0)
; bpp.ssa.blocks=7 insts=41 phis=1 entry=0 term_op=31
declare ptr @"std_number__number_big_from_i64_raw"(i64 %p0)
; bpp.ssa.blocks=14 insts=101 phis=2 entry=0 term_op=31
declare i64 @"std_number__number_big_abs_to_u64_checked"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=17 insts=102 phis=1 entry=0 term_op=31
declare i64 @"std_number__number_big_try_to_i64"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=20 insts=115 phis=2 entry=0 term_op=31
declare i64 @"std_number__number_big_abs_cmp"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=21 insts=158 phis=2 entry=0 term_op=31
declare ptr @"std_number__number_big_add_abs"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=18 insts=137 phis=2 entry=0 term_op=31
declare ptr @"std_number__number_big_sub_abs"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=24 insts=209 phis=3 entry=0 term_op=31
declare ptr @"std_number__number_big_mul_abs"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=14 insts=112 phis=2 entry=0 term_op=31
declare ptr @"std_number__number_big_mul_small_abs"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=14 insts=110 phis=1 entry=0 term_op=31
declare ptr @"std_number__number_big_div_small_abs"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=10 insts=69 phis=1 entry=0 term_op=31
declare i64 @"std_number__number_big_mod_small_abs"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=9 insts=35 phis=0 entry=0 term_op=31
declare void @"std_number__number_from_big_normalized"(...)
; bpp.ssa.blocks=7 insts=38 phis=0 entry=0 term_op=31
declare ptr @"std_number__number_to_abs_big"(ptr %p0)
; bpp.ssa.blocks=15 insts=63 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_signum"(ptr %p0)
; bpp.ssa.blocks=9 insts=44 phis=1 entry=0 term_op=31
declare void @"std_number__number_negated"(...)
; bpp.ssa.blocks=18 insts=90 phis=1 entry=0 term_op=31
declare void @"std_number__number_abs_with_sign"(...)
; bpp.ssa.blocks=29 insts=158 phis=3 entry=0 term_op=31
declare i64 @"std_number__number_abs_cmp"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=29 insts=137 phis=2 entry=0 term_op=31
declare i64 @"std_number__number_cmp_ptr"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=11 insts=71 phis=0 entry=0 term_op=31
declare void @"std_number__number_add_values"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__number_sub_values"(...)
; bpp.ssa.blocks=5 insts=43 phis=1 entry=0 term_op=31
declare void @"std_number__number_mul_values"(...)
; bpp.ssa.blocks=24 insts=224 phis=3 entry=0 term_op=31
declare void @"std_number__number_divmod_values_nonzero"(...)
; bpp.ssa.blocks=7 insts=39 phis=0 entry=0 term_op=31
declare void @"std_number__number_div_values"(...)
; bpp.ssa.blocks=7 insts=41 phis=0 entry=0 term_op=31
declare void @"std_number__number_mod_values"(...)
; bpp.ssa.blocks=7 insts=40 phis=1 entry=0 term_op=31
declare void @"std_number__number_mul_small"(...)
; bpp.ssa.blocks=7 insts=36 phis=0 entry=0 term_op=31
declare void @"std_number__number_abs_clone"(...)
; bpp.ssa.blocks=9 insts=47 phis=0 entry=0 term_op=31
declare void @"std_number__number_div_small_abs"(...)
; bpp.ssa.blocks=9 insts=54 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_mod_small_abs"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=15 insts=97 phis=2 entry=0 term_op=31
declare ptr @"std_number__number_big_shift_limbs_abs"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=31 insts=265 phis=3 entry=0 term_op=31
declare void @"std_number__number_big_abs_divmod_long"(...)
; bpp.ssa.blocks=5 insts=33 phis=0 entry=0 term_op=30
declare void @"std_number__number_pow2"(...)
; bpp.ssa.blocks=6 insts=38 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_bit_length_abs"(ptr %p0)
; bpp.ssa.blocks=15 insts=80 phis=2 entry=0 term_op=31
declare void @"std_number__number_shl_values"(...)
; bpp.ssa.blocks=14 insts=120 phis=1 entry=0 term_op=30
declare void @"std_number__number_bitwise_nonneg_abs"(...)
; bpp.ssa.blocks=13 insts=130 phis=1 entry=0 term_op=31
declare void @"std_number__number_bitwise_values"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__number_bitand_values"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__number_bitor_values"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__number_bitxor_values"(...)
; bpp.ssa.blocks=1 insts=19 phis=0 entry=0 term_op=32
declare void @"std_number__number_bitnot_values"(...)
; bpp.ssa.blocks=9 insts=48 phis=0 entry=0 term_op=31
declare i64 @"std_number__number_shift_amount_from_number"(ptr %p0)
; bpp.ssa.blocks=18 insts=111 phis=1 entry=0 term_op=31
declare void @"std_number__number_shr_values"(...)
; bpp.ssa.blocks=3 insts=17 phis=0 entry=0 term_op=31
declare void @"std_number__number_clone"(...)
; bpp.ssa.blocks=24 insts=139 phis=3 entry=0 term_op=31
declare void @"std_number__number_from_str"(...)
; bpp.ssa.blocks=3 insts=29 phis=0 entry=0 term_op=31
declare void @"std_number__number_input"(...)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_number__Number_from_i64"(...)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_number__Number_from_u64"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number_from_str"(...)
; bpp.ssa.blocks=3 insts=20 phis=0 entry=0 term_op=31
declare i64 @"std_number__Number_set_i64"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=20 phis=0 entry=0 term_op=31
declare i64 @"std_number__Number_set_u64"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=3 insts=25 phis=0 entry=0 term_op=31
declare i64 @"std_number__Number_set_from_str"(ptr %p0, i64 %p1, i64 %p2)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_number__Number_clone"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_add__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_add__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_add__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_sub__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_sub__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_sub__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_sub__OL"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mul__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mul__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mul__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_div__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_div__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_div__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mod__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mod__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_mod__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitand__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitand__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitand__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitor__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitor__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitor__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitxor__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitxor__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitxor__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shl__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shl__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shl__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shr__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shr__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=16 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_shr__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_number__Number___op_bitnot"(...)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_eq"(...)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ne__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ne__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ne__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_lt__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_lt__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_lt__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_le__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_le__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_le__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_gt__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_gt__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_gt__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ge__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(...)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ge__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=21 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number___op_ge__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_number__Number_cmp"(...)
; bpp.ssa.blocks=7 insts=47 phis=0 entry=0 term_op=31
declare i64 @"std_number__Number_to_i64_checked"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=15 insts=79 phis=1 entry=0 term_op=31
declare i64 @"std_number__Number_to_u64_checked"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=15 insts=167 phis=0 entry=0 term_op=31
declare i64 @"std_number__Number_to_str"(ptr %p0)
; bpp.ssa.blocks=16 insts=92 phis=1 entry=0 term_op=31
declare i64 @"std_number__Number_to_i64_lossy"(ptr %p0)
; bpp.ssa.blocks=1 insts=29 phis=0 entry=0 term_op=32
declare void @"std_string__string_empty"()
; bpp.ssa.blocks=5 insts=90 phis=0 entry=0 term_op=31
declare void @"std_string__string_alloc"(...)
; bpp.ssa.blocks=7 insts=82 phis=1 entry=0 term_op=31
declare void @"std_string__string_from_bytes"(...)
; bpp.ssa.blocks=3 insts=14 phis=0 entry=0 term_op=31
declare void @"std_string__string_from_cstr"(...)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare void @"std_string__string_from_slice"(...)
; bpp.ssa.blocks=9 insts=95 phis=0 entry=0 term_op=31
declare void @"std_string__string_input"(...)
; bpp.ssa.blocks=3 insts=11 phis=0 entry=0 term_op=31
declare void @"std_string__string_copy"(...)
; bpp.ssa.blocks=3 insts=18 phis=0 entry=0 term_op=31
declare void @"std_string__string_view"(...)
; bpp.ssa.blocks=7 insts=40 phis=0 entry=0 term_op=31
declare i64 @"std_string__string_cstr"(ptr %p0)
; bpp.ssa.blocks=19 insts=125 phis=2 entry=0 term_op=31
declare i64 @"std_string__string_ensure_cap"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=7 insts=86 phis=0 entry=0 term_op=31
declare i64 @"std_string__string_append_slice"(...)
; bpp.ssa.blocks=3 insts=22 phis=0 entry=0 term_op=31
declare i64 @"std_string__string_append_raw_cstr"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=5 insts=63 phis=0 entry=0 term_op=31
declare i64 @"std_string__string_push_byte"(ptr %p0, i8 %p1)
; bpp.ssa.blocks=5 insts=34 phis=0 entry=0 term_op=31
declare i64 @"std_string__string_release"(ptr %p0)
; bpp.ssa.blocks=5 insts=38 phis=1 entry=0 term_op=31
declare i64 @"std_string__string_eq"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=18 phis=0 entry=0 term_op=32
define void @"std_string__string_constructor"(ptr %p0) {
entry:
  ret void 
}
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_len"(ptr %p0)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_ptr"(ptr %p0)
; bpp.ssa.blocks=1 insts=5 phis=0 entry=0 term_op=32
declare void @"std_string__string_as_slice"(...)
; bpp.ssa.blocks=1 insts=6 phis=0 entry=0 term_op=32
declare void @"std_string__string_clone"(...)
; bpp.ssa.blocks=1 insts=19 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_append"(...)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_append_cstr"(ptr %p0, ptr %p1)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_push"(ptr %p0, i8 %p1)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_free"(ptr %p0)
; bpp.ssa.blocks=1 insts=7 phis=0 entry=0 term_op=32
declare i64 @"std_string__string_to_str"(ptr %p0)
; bpp.ssa.blocks=1 insts=12 phis=0 entry=0 term_op=32
declare i64 @"std_string__string___op_eq"(...)
; bpp.ssa.blocks=1 insts=14 phis=0 entry=0 term_op=32
declare i64 @"std_string__string___op_ne"(...)
; bpp.ssa.blocks=3 insts=16 phis=0 entry=0 term_op=31
declare i64 @"_100_llvm_ll_params_branch_fixture_success__choose_big_100"(i64 %p0, i64 %p1)
; bpp.ssa.blocks=1 insts=2 phis=0 entry=0 term_op=32
define i64 @"_100_llvm_ll_params_branch_fixture_success__runtime_entry"() {
entry:
  %r1 = add i64 0, 0
  ret i64 %r1
}
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare i64 @"std_vec__Vec_len__G__T_u32"(ptr %p0)
; bpp.ssa.blocks=7 insts=84 phis=0 entry=0 term_op=31
declare i32 @"std_vec__Vec_get__G__T_u32"(ptr %p0, i64 %p1)
; bpp.ssa.blocks=9 insts=100 phis=0 entry=0 term_op=31
declare i32 @"std_vec__Vec_pop__G__T_u32"(ptr %p0)
; bpp.ssa.blocks=13 insts=146 phis=0 entry=0 term_op=31
declare i64 @"std_vec__Vec_push__G__T_u32"(ptr %p0, i32 %p1)
; bpp.ssa.blocks=7 insts=87 phis=0 entry=0 term_op=31
declare i64 @"std_vec__Vec_set__G__T_u32"(ptr %p0, i64 %p1, i32 %p2)
; bpp.ssa.blocks=13 insts=146 phis=0 entry=0 term_op=31
declare i64 @"std_vec__Vec_push__G__T_u8"(ptr %p0, i8 %p1)
; bpp.ssa.blocks=1 insts=9 phis=0 entry=0 term_op=32
declare i64 @"std_vec__Vec_len__G__T_u8"(ptr %p0)
; bpp.ssa.blocks=7 insts=84 phis=0 entry=0 term_op=31
declare i8 @"std_vec__Vec_get__G__T_u8"(ptr %p0, i64 %p1)
define i32 @"main"() {
entry:
  %entry_ret = call i64 @"_100_llvm_ll_params_branch_fixture_success__runtime_entry"()
  %entry_i32 = trunc i64 %entry_ret to i32
  ret i32 %entry_i32
}

!bpp.contract = !{
  !0,
  !1
}
!0 = !{ptr @"_100_llvm_ll_params_branch_fixture_success__runtime_entry", !"bpp.contract.surface", !"100_llvm_ll_params_branch_fixture_success", !"public-callable", !"public-callable", i64 8, i64 115, i64 10, i64 6, i64 0, i64 0, !"_100_llvm_ll_params_branch_fixture_success__runtime_entry"}
!1 = !{ptr @"_100_llvm_ll_params_branch_fixture_success__runtime_entry", !"bpp.contract.entry", !"100_llvm_ll_params_branch_fixture_success", !"public-callable", !"none", i64 8, i64 115, i64 10, i64 6, i64 0, i64 0, !"_100_llvm_ll_params_branch_fixture_success__runtime_entry"}
