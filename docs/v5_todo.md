# B Language v5 Development Plan

## Maintenance

- [x] v5 재생성: v4 최신 상태 복제 (2026-02-03)
- [x] v5 파서: 중첩 제네릭 `>>` 허용 (TOKEN_RSHIFT 분해 + pending GT) (2026-02-03)
- [x] v5 compiler.bpp 중첩 제네릭 `>>` 통일 (2026-02-03)
- [x] v5 src refactor: new keyword allocations (replace heap_alloc(sizeof(Type))) (2026-02-06)
- [x] v5 config VERSION=v5 PREV_VERSION=v4 + new/clone null guard + build_and_test pass (2026-02-06)
- [x] v5 literal init cleanup for small structs (NameInfo/ConstInfo/ConstResult/ExportEntry/StringEntry/PtrLen) (2026-02-06)
- [x] v5 const_find returns ConstResult (no u64 handle) (2026-02-06)
- [x] v5 emitter gen_expr method-name buffer uses slices (2026-02-06)
- [x] v5 typeinfo get_field_desc returns *FieldDesc (2026-02-06)
- [x] v5 TypeInfo.struct_def uses *AstStructDef end-to-end (2026-02-06)
- [x] v5 ast.bpp constructors return literal directly (2026-02-06)

