# B Language v6 Development Plan

## Maintenance

- [x] v6 created from v5 baseline (2026-02-06)
- [x] v6 re-created from v5 and rebuilt cleanly (2026-02-06)
- [x] v6 remove emitter_force_vec_instantiations and pass build (blocked: missing Vec<*ConstInfo/StringEntry> symbols; resolved-name aliasing added)
- [x] v6 remove compiler_force_hashmap_instantiations and pass build (pending previous step)
- [x] v6 compiler.bpp `>>` generic nesting test with v5_stage1 (pass: v6 build_and_test.sh OK, 2026-02-06)
- [x] v6 compiler globals declaration-time init (HashMap.new/Vec.new) (2026-02-07)
- [x] v6 Vec.new removed; use new Vec (2026-02-07)
- [x] v6 constructor generic template registration in impl parser (2026-02-07)
- [x] v6 new generic constructor instantiation uses base struct name (2026-02-07)
- [x] v6 HashMap.new removed; use new HashMap (2026-02-07)
- [x] v6 HashMap zero-capacity guards for bootstrap (2026-02-07)
