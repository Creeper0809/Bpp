# Task Plan: Compiler design fixes round 2

## Goal
Fix all nine remaining compiler implementation/design problems identified by the 2026-09-05 re-audit, add regression coverage, run the complete relevant test matrix, and integrate the verified work into `dev` without disturbing pre-existing user changes.

## Current Phase
Complete

## Requirements
1. Derive legacy stack reservation from actual local storage and prevent out-of-frame accesses.
2. Reject duplicate globals, structs, constants, and struct fields deterministically.
3. Repair Windows process spawning for the default compile/assemble/link/run path and test it.
4. Make inheritance-cycle/depth validation iterative and safe for deep valid graphs.
5. Establish a mandatory semantic-validation contract across compile-capable output modes, with explicitly parse-only AST behavior if retained.
6. Remove impractically small SSA allocation cutoffs, improve fallback observability, and make strict SSA usable with the normal prelude.
7. Make compiler sessions genuinely context-scoped/reentrant or remove misleading pseudo-context behavior; verify compile/reset/recompile lifecycle.
8. Replace raw-pointer SSA auxiliary payload encoding with typed IDs/owned tables and explicit cleanup/lifetime rules.
9. Consolidate AST traversal behind an exhaustive shared visitor with coverage that fails when node kinds are omitted.

## Phases

### Phase 0: Baseline and branch isolation
- [x] Preserve and inventory pre-existing dirty files.
- [x] Create a new branch from current `dev`.
- [x] Map tests/build commands and establish focused failing probes.
- **Status:** complete

### Phase 1: Front-end invariants and safe layout
- [x] Fix duplicate declaration validation.
- [x] Fix legacy stack-frame sizing.
- [x] Replace recursive inheritance validation.
- [x] Add focused regression tests.
- **Status:** complete

### Phase 2: Mandatory semantic contract and AST traversal
- [x] Separate parse-only output from semantically validated outputs.
- [x] Move or invoke common semantic validation before compile-capable outputs.
- [x] Make shared AST traversal exhaustive and migrate relevant consumers.
- [x] Add output-mode and visitor coverage tests.
- **Status:** complete

### Phase 3: Windows host execution
- [x] Diagnose and repair CreateProcess invocation.
- [x] Add default-pipeline regression coverage.
- [x] Verify assemble/link/run with vendored tools.
- **Status:** complete

### Phase 4: SSA scalability, observability, and ownership
- [x] Replace fixed allocator cutoffs with dynamic/scalable behavior.
- [x] Expose auto-backend fallback decisions and make strict SSA compile the normal prelude.
- [x] Replace raw pointer auxiliary payloads with typed owned identifiers.
- [x] Add cleanup and deterministic lifetime tests.
- **Status:** complete

### Phase 5: Compiler session ownership
- [x] Move diagnostic and runtime compilation state behind an active `CompilerCtx`.
- [x] Add explicit owned-buffer teardown using a bootstrap-compatible common container adapter.
- [x] Add reset/recompile and independent-session lifecycle coverage.
- **Status:** complete

### Phase 6: Verification and integration
- [x] Run focused regressions for all nine requirements.
- [x] Run full Linux/Windows/self-host/LLVM-relevant suites available locally.
- [x] Review diff for unintended behavior and preserve user-owned changes.
- [x] Commit, merge into `dev`, and remove the completed work branch.
- **Status:** complete

### Phase 7: Completion audit across both design-review rounds
- [x] Map the original nine findings and the round-two nine findings to current source invariants.
- [x] Confirm regression coverage for every mapped requirement on current `dev`.
- [x] Revalidate self-host identity, complete-suite results, branch integration, and preservation of user-owned changes.
- [x] Record authoritative evidence and close the active goal only if every requirement is proven.
- **Status:** complete

## Constraints
- Do not overwrite, stage, or normalize the pre-existing `src/std/io.bpp` line-ending-only change.
- Preserve the user's root planning/report files and `docs/보고서.md`.
- Treat this strictly as compiler implementation work, not security-vulnerability research.
- Do not weaken tests or reduce their count to obtain green results.

## Errors Encountered
| Error | Attempt | Resolution |
|---|---:|---|
| PowerShell rejected comma-containing GCC linker argument | 1 | Retry with an explicit argument array rather than inline tokenization. |
| Deep acyclic inheritance still stack-overflows after structural DFS removal | 1 | Capture a native backtrace and remove/bound the remaining recursive pass rather than assuming the first recursion was the only one. |
| Deep inheritance changed from stack overflow to access violation after vdispatch rewrite | 1 | Re-run under GDB against the new stage and isolate whether the iterative collector or a subsequent deep-layout consumer is failing. |
| Aggregate frame stack in iterative vdispatch crashes at depth | 2 | Replace value-aggregate stack frames with parallel `Vec<*AstStructDef>` and `Vec<u64>` stacks to avoid generic aggregate ABI/codegen complexity. |
| Initial semantic-entry search referenced non-existent `src/ir.bpp` and used a Windows-invalid `src/*` glob | 1 | Search actual `src/ssa.bpp` and repository `.bpp` files with `-g` filters. |
| Exhaustive expression walker diagnosed `AST_ASSIGN` used as a for-loop update expression | 1 | Treat assignment as a supported expression-position AST shape and recurse through both sides. |
| Stage 4 cannot compile the walker fix because its own strict walker lacks `AST_ASSIGN` | 1 | Re-bootstrap the corrected source from stage 3, the last known-good compiler before the strict-walker change. |
| GDB could not install an absolute caller breakpoint before the PE image was loaded | 1 | Use a symbol-relative breakpoint so GDB applies PE relocation automatically. |
| Planning status patch mismatched the Markdown status marker | 1 | Retry with the exact `- **Status:**` lines from the current plan. |
| Combined NASM retry command was rejected by command policy | 1 | Avoid deletion and script-scoped interpolation; write to a fresh object path with a simple invocation. |
| Default-pipeline smoke wrote a relative NASM override into its isolated manifest | 1 | Resolve compiler, assembler, and linker paths to absolute paths before changing the child working directory. |
| Static initialization of the active `CompilerCtx*` from `&g_compiler_default_ctx` failed semantic typing | 1 | Use a null-initialized pointer and lazily bind it in `compiler_ctx_current()` before any state access. |
| Bootstrap compiler could not instantiate nested generic container release helpers | 1 | Use an explicit common owned-buffer header adapter; all affected `Vec`/`HashMap` layouts share that header and the adapter avoids unsupported deep generic instantiation. |
| NASM 2.16 rejected a forward frame equate forced to `strict dword` | 1 | Encode the prologue immediate and save-slot displacements as `strict qword`/explicit dword-address forms accepted by both the vendored assembler and current NASM. |
| Automatic `-dump-ssa` still compiled the entire O0 prelude and timed out | 1 | Give every SSA-requesting mode the same exact reachable-closure contract and reserve whole-program fallback for dynamic calls whose targets cannot be proven. |
| Global duplicate-struct validation rejected equal short names in different modules | 1 | Move duplicate struct-name detection into each source file's parse scope; retain global field validation. |
| Pointer values were passed directly to a string-keyed `HashMap` while repairing inheritance identity | 1 | Replace the invalid key encoding with a vector indexed by canonical struct-definition identity. |
| A bundled runtime fixture contained two unrelated `Pair` declarations in one source file | 1 | Rename the stack-constructor fixture's local type without reducing coverage. |
| WSL command exposed installation help instead of a distribution list | 1 | Record Linux as unavailable locally and run the complete Windows native/self-host suite. |
