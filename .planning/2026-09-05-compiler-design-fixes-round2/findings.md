# Findings: Compiler design fixes round 2

## Baseline
- Starting branch: `dev` at `958df8d`, synchronized with `origin/dev`.
- Pre-existing tracked state: `src/std/io.bpp` is marked modified only because of line-ending metadata and has no content diff.
- Pre-existing untracked state: `.planning/`, `docs/보고서.md`, and root `task_plan.md`, `findings.md`, `progress.md`.
- The nine prior design fixes are already merged; this plan addresses only the new round-two findings.

## Reproduced failures to preserve
- Legacy 4,096-byte local array: prologue reserves 2,080 bytes but accesses `[rbp-4096]`.
- Duplicate globals emit duplicate labels; duplicate structs/constants/fields are accepted.
- Windows default pipeline crashes in the process-spawn wrapper.
- Valid 700-level inheritance chain stack-overflows recursive validation.
- Invalid typing succeeds in AST-only and LLVM contract/prototype outputs while failing backend outputs.
- Strict SSA fails on the normal prelude in `std_str__str_concat3`.

## Phase 1 source map
- Duplicate validation belongs in `compiler/validation.bpp`, after module loading has populated the canonical declaration vectors. Globals and constants are appended in `compiler/loader.bpp`; structs and traits are appended through `compiler/symbol_runtime.bpp`.
- Legacy stack allocations have four meaningful sources: parameters (`codegen.bpp`), hidden sret storage (`codegen.bpp`), variable declarations (`emitter/gen/stmt.bpp`), and expression-created struct temporaries (`emitter/gen/expr.bpp`). A correct frame fix must cover all of them rather than only scanning explicit local declarations.
- `Symtab.stack_offset` already records the exact cumulative downward allocation, but the prologue is emitted before body emission. The implementation should either compute layout before emission or buffer/patch the prologue after the final offset is known.
- Legacy output is streamed through the global I/O file descriptor, so inserting or patching an already-emitted prologue is not a local operation. A layout prepass is the cleaner bootstrap-compatible option.
- Frame layout must include parameters and hidden sret storage in addition to body locals. The current symtab starts at `-8`, and nonvolatile register saves occupy a separate 32-byte suffix after the configurable/local reserve.
- Canonical declaration structs expose stable names directly (`GlobalInfo.name`, `AstConstDecl.name`, `AstStructDef.name`, `TraitDef.name`, `FieldDesc.name`), so one common duplicate-name helper can validate each namespace without touching loader insertion order.
- NASM permits a function-local forward `equ` symbol in memory displacements and immediates. This allows the compiler to stream the body normally, observe the final `Symtab.stack_offset`, and emit the exact frame-size constant after the function. Prologue and nonvolatile save/restore operands can all reference the forward local constant, avoiding an AST allocation mirror and covering compiler-generated temporaries automatically.
- The frame constant should be `max(annotation/default reserve, align16(actual symtab consumption))`; this preserves `@[config(stack=...)]` as a minimum while removing the previous correctness ceiling.
- The modified compiler self-builds through stage 0, and NASM resolves the generated local equate as intended. The focused local-array output now reserves exactly 4,096 local bytes plus the 32-byte nonvolatile-save area.
- Duplicate validation runs immediately after module/prelude loading and before synthetic trait/vtable globals are created, so checking canonical declaration vectors there does not reject backend-generated symbols.
- Removing recursion from the structural cycle check is necessary but not sufficient for deep inheritance: later virtual-dispatch and layout helpers also recurse through parent graphs. The first rerun still reaches a stack overflow after structural validation, so Phase 1 must cover all mandatory parent traversal, not just cycle detection.
- The first explicit-frame vdispatch rewrite fails inside its completion branch after several hundred ancestors. Generated assembly shows the value-typed frame is passed through generic `Vec<VdispatchCollectFrame>` helpers; this path is more complex than necessary. Replace it with parallel pointer/index stacks or a simpler topological collection to avoid aggregate generic ABI risk during bootstrap.
- Parallel pointer/index vectors avoid that bootstrap aggregate-ABI edge. With both structural and virtual-dispatch traversals iterative, the 700-level acyclic AST pipeline succeeds.
- The test runner discovers directive-driven `.bpp` fixtures and also supports multi-case bundle files. Existing round-one regressions occupy cases/files through 93, so round-two focused cases can be added without changing or removing existing tests.
- AST-only output can remain parse/lowering inspection, but LLVM contract/prototype and unified non-AST views need a pre-output semantic gate. `build_program` already performs SSA builder type checks without emitting textual IR, making it a reusable first common gate while a fully backend-independent checker is developed.
- `main_emit_unified_json_stdout` currently writes the AST portion before invoking IR/SSA/ASM validation, so invalid programs can also leave partial JSON. Prevalidating whenever the unified mask contains a non-AST view avoids that malformed-output behavior.
- The shared walker can cover all current expression and statement layouts directly: missing cases are ternary; do-while; try/throw; const declarations; and statement-position new/stack constructors. Unknown node kinds should produce an internal diagnostic instead of silently returning.
- Bpp also uses `AST_ASSIGN` directly in expression position for `for` updates. Exhaustive traversal must therefore cover that mixed-category representation; treating expression and statement numeric ranges as disjoint is incorrect.
- The semantic gate now prevents partial unified JSON: the invalid mixed AST+IR probe exits 1 with zero stdout bytes. AST-only modes still exit 0 and produce their inspection payload by design.
- At the Windows CreateProcess breakpoint, the command-line pointer is valid and contains the expected mutable string (`nasm -fwin64 ...`). The remaining failure concerns the six stack-passed arguments or structure pointers, not command construction.
- A breakpoint at the exported `CreateProcessA` address is not guaranteed to be the raw function entry; observed stack offsets were already shifted/rewritten by the system thunk. The next probe must inspect the caller immediately before `call CreateProcessA`, where Bpp-generated offsets are authoritative.
- At the compiler-side call instruction, all six stack arguments are present at the correct Win64 caller offsets: flags/environment/current-directory are zero and the `STARTUPINFOA`/`PROCESS_INFORMATION` pointers are valid-looking arena addresses. The wrapper's register and stack placement is therefore correct; inspect structure contents and heap commitment next.
- Structure inspection confirms `STARTUPINFOA.cb=104`, the remaining bytes are zero, and the 24-byte process-info buffer is valid. The decisive defect is stack alignment: immediately before `call CreateProcessA`, `rsp % 16 == 8`; Win64 requires the caller stack aligned to 16 bytes. Simpler APIs happened to tolerate it, while CreateProcess reaches code that does not.
- The alignment error is systemic in legacy Win64 calls rather than specific to CreateProcess argument packing. Repair should happen in the target-aware function/call frame convention, then the wrapper can remain a straightforward API adapter.
- Existing legacy and SSA call-padding logic assumes the function's steady-state `rsp` is already 16-byte aligned and preserves alignment with an even number of shadow/argument words. The legacy Win64 prologue violates that assumption. Adding a target-specific 8-byte frame alignment slot on Windows restores the invariant without changing local or nonvolatile-save offsets.
- The forward frame equate itself was correct, but NASM's default optimization mode repeatedly revisited the 26 MiB self-host source. Stable explicit operand widths plus `-O1` retain correct displacement sizing and reduce assembly to roughly 9–14 seconds with vendored NASM 2.16.03.
- The old SSA limits (`256` virtual registers and `900` instructions) were policy cutoffs rather than correctness bounds. Allocator selection now follows estimated graph memory/work, with interval allocation for oversized graphs and batch spilling when pressure exceeds available physical registers.
- Backend selection is now observable through `--backend-report`; strict mode fails rather than silently using legacy codegen, while auto mode reports the exact function and fallback reason.
- An instruction now carries `aux_kind`, stable `aux_id`, and its owning auxiliary table. Runtime consumers resolve the ID through `ssa_inst_aux_ptr`; serializers expose the stable ID instead of the process address.
- `CompilerCtx` is now a real selectable session object. Independent contexts retain separate target, generation, diagnostics, tables, and owned state; reset and destroy operate on an explicit context rather than replacing one global singleton's tables.
- Strict SSA's largest remaining performance defect was not LLVM or source parsing: reachability seeded every generated operator/property/trait helper, and emission bypassed that set for generated names. Using an exact closure for direct calls reduces the simple normal-prelude case from over two minutes to 0.81 seconds. Dynamic/method/function-pointer calls conservatively request whole-program handling.
- Virtual-dispatch thunks referenced by emitted vtable data are implicit roots even when no AST method-call node exists. Seeding `__thunk___Virt_` targets fixes strict SSA vtable linkage without broadly retaining all generated helpers.
- Struct names are intentionally short and module-local during parsing; `all_structs_vec` is therefore not a valid global duplicate-name namespace. File-scoped parser tracking catches real duplicates before registration while permitting the existing module model.
- Cycle-validation state must be keyed by definition identity, not short type name. An index-aligned state vector is both bootstrap-safe and correct for equal names from different modules.
- The language contract validates a zero-argument entry function, so Windows entry assembly should not retain `std_os__os_main_args` solely for an obsolete test expectation. The regression now asserts the 48-byte aligned entry frame and absence of the unused helper call.
- Final local evidence: Windows self-host reproducibility passed and the complete native suite passed 767/767 under a 4 GiB process limit in 266.9 seconds. The single LLVM-only fixture is explicitly unsupported by the Windows native runner; no WSL distribution is installed for the Linux runner.

## Completion audit evidence (both review rounds)
- The original review's type-compatibility bypass is covered by five negative cases in `85_type_compatibility_invariants_fail.bpp`: scalar width coincidence, unrelated pointers, nominal structs, arguments, and returns.
- Original module-prefix collision, O1 AST reachability gaps, duplicate functions/cyclic inheritance, strict-SSA fallback, unstable SSA serialization, context lifecycle, and `--views` contract each have dedicated numbered regression fixtures (86 through 93).
- The round-two additions have dedicated fixtures for large legacy frames (94), 700-level inheritance (95), parse-only AST semantics (96), strict SSA with normal prelude (97), fallback reporting (98), typed deterministic auxiliary IDs (99), duplicate declaration namespaces (fail 91), and semantic output gates (fail 92).
- The test files retain both positive and negative assertions; no case count was reduced to obtain the green result.
- Current source confirms collision-free module prefixes by escaping literal underscores as `__u` while canonical path separators remain `_`; this distinguishes `a/b` from `a_b` without changing separator ABI spelling.
- Current structural validation is iterative and definition-indexed, and all duplicate declaration namespaces emit tagged diagnostics before later passes.
- Current O1 reachability explicitly handles slice, ternary, try, and do-while AST forms that were missing in the original report.
- Completion audit found one residual implementation defect: the main compiler paths use the sound `typeinfo_is_assignable`, but the now-unused legacy `check_type_compat` API still accepts unrelated same-width scalar kinds and cannot represent nominal struct identity. It must be made conservative or removed before the original type-safety finding is fully closed.
- The residual helper is now conservative: exact scalar/pointer descriptors can match, same-width different kinds cannot, and nominal/container/function categories are rejected because the legacy signature lacks enough identity information. A direct four-mode regression was added as test 100.
- Source evidence confirms round-two backend work is present: strategy budgets choose graph versus interval allocation instead of correctness cutoffs; strict SSA diagnoses fallback; auto fallback is reportable; and auxiliary payloads use typed one-based IDs resolved through a context-owned table with explicit release.
- Source evidence confirms session state and diagnostics are selected through explicit `CompilerCtx` APIs, and compile-capable non-AST outputs invoke the semantic gate before writing their payload.

### Requirement-by-requirement verdict
| ID | Required implementation invariant | Authoritative source evidence | Regression evidence | Verdict |
|---|---|---|---|---|
| O1 | Types are nominal/structural by descriptor, never accepted by byte width | `typeinfo_is_assignable`; conservative legacy `check_type_compat`; initializer/assignment/argument/return gates | fail 85 plus success 100, all four modes | proven |
| O2 | Module mangling is collision-free for separators versus underscores | underscore escape in `module_util_module_prefix_from_id` | success 86, all four modes | proven |
| O3 | O1 reachability visits all AST call positions | complete call collector plus shared walker | success 87 ternary/do-while/slice cases, all modes | proven |
| O4 | Cyclic inheritance diagnoses without recursive overflow | iterative definition-indexed dependency resolution | fail 86 case 207 and success 95 depth 700 | proven |
| O5 | Duplicate functions are rejected before label emission | `validate_program_duplicate_functions` | fail 86 case 206 | proven |
| O6 | Strict SSA never silently mixes backends; auto decisions are observable | strict rejection branches and `--backend-report` | fail 89 and success 98 | proven |
| O7 | Serializable SSA contains stable typed auxiliary IDs, not process pointers | `aux_kind`, `aux_id`, owning `SSAAuxTable`, resolver and cleanup | success 90 and 99 deterministic output | proven |
| O8 | Compiler sessions own independent state and diagnostics | active `CompilerCtx*`, new/activate/reset/release/destroy APIs | success 91 lifecycle and isolation assertions | proven |
| O9 | `--views` validates names and emits only selected implemented views | parsed view mask and exact unified JSON dispatch | fail 90 plus success 92/93 | proven |
| R1 | Legacy frames cover actual generated and declared storage | final `Symtab.stack_offset` drives forward frame-size equate | success 94 with 4096-byte local, O0/O1 | proven |
| R2 | Globals, constants, structs, fields and traits have deterministic duplicate checks | global validators plus file-scoped struct-name tracking | fail 91 cases 211-214 and existing trait checks | proven |
| R3 | Windows hosted compile/assemble/link/run observes the ABI | 48-byte aligned entry frame and process wrapper | always-on default-pipeline smoke in every Windows suite run | proven |
| R4 | Deep valid inheritance and virtual ancestry are iterative | iterative structural validation and explicit vdispatch stacks | success 95 depth 700 | proven |
| R5 | Compile-capable outputs perform semantic validation before emission | `main_output_requires_semantic_gate` and `validate_program_semantics` | fail 92; AST-only success 96 | proven |
| R6 | SSA allocation scales beyond former fixed cutoffs and exposes policy fallback | budget-selected graph/interval allocators, dynamic spilling, strict/auto policy | success 97 and 98; fail 89 | proven |
| R7 | Context reset/recompile is real session ownership | context-owned tables, diagnostics and teardown | success 91 | proven |
| R8 | SSA auxiliary lifetime is explicit and deterministic | owned table registration/resolution/release | success 90 and 99 | proven |
| R9 | Shared AST traversal is exhaustive and unknown kinds diagnose | exhaustive expression/statement matches with diagnostic defaults | success 87 and full language matrix | proven |

- Final post-audit suite artifact reports 771/771 passed, 0 failed, 1 Windows-hosted LLVM-only skip, 266.0 seconds under a 4 GiB process limit.
- Current self-hosted Stage1 and Stage2 SHA-256 values are identical: `2BBEA772A9AAB08839159B6CE717B683F6BDEB1D887D55ABD38D6D214E13AF7D`.
- Querying the final timing manifest by requirement fixture found 70/70 mapped cases passed (including 20 type-invariant, 8 symbol/inheritance, 12 reachability, and all focused round-two cases); the manifest contains zero failed cases overall.
- Static residue checks find no former 256-vreg/900-instruction cutoff and no raw call-info pointer encoding in SSA operands. The only `check_type_compat` callers are the new direct regression; production decisions exclusively use the richer descriptor API.
