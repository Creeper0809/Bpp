# v2 TODO (2-pass plan for v3 generic std)

## Goal
- Use 2-pass loading/parsing to guarantee generic template registration before full parse.

## Plan (2-pass)
1) **Pass1: Signature-only scan across modules**
   - Parse imports to build module graph.
   - For each module, run signature pass to register:
     - generic struct templates
     - generic function templates
     - struct type names (for type position)

2) **Pass2: Full parse with bodies**
   - Re-parse modules in topo order.
   - Resolve types with templates already registered.
   - Build AST with bodies.

3) **Monomorphization phase**
   - Instantiate generic structs/funcs from usage.
   - Ensure method name mangling uses instantiated struct names.

## Tests (must pass)
- Generic struct type usage: `Vec<u64>` in type position.
- Method call: `vec->len()` / `Vec<T>.len()` resolution.
- Generic function inference with args.
- Full `build_and_test.sh` in v2 should pass.
