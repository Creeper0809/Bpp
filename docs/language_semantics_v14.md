# v14 compatibility notes

This revision tightens existing syntax. Rebuild callers and callees together;
the variadic and safe-result changes are not ABI-compatible with v13.

- A parameter declared `...values: T` is a borrowed `[]T` inside the function.
  An empty tail has length zero. Every tail argument is checked against `T` and
  evaluated once, in source order. Do not retain the caller-owned slice after
  the call. Function-valued calls use the same rule.
- Fixed-arity positional calls also evaluate arguments from left to right on
  both native backends. Named/default arguments are normalized into parameter
  order first; outgoing stack layout does not reverse that evaluation order.
- Value-producing safe member access, indexing and calls return `Option<T>`.
  Inspect `is_some` before `value`; a present zero or null payload is distinct
  from absence. Receivers are evaluated once, and an absent receiver skips
  argument/index evaluation. Safe void calls remain void.
- Function types preserve parameter and result types, including nested slices,
  records and callbacks. Captured lambdas retain their public call signature.
  An integer is not implicitly a typed function; low-level handle conversion
  requires an explicit cast. A decorator's `next` parameter must match the
  decorated function's full signature.
- In value-returning lambdas, only a final expression without a semicolon is
  an implicit return. A semicolon makes it a statement. Empty or statement-only
  void lambdas are valid; a bare return cannot supply a non-void result.
  Captured match results retain their declared type.
- `$field` bypasses property hooks, not visibility checks. Parent-scoped raw
  fields follow the same rule. An explicit parent-constructor call must be the
  constructor's first statement and occur exactly once.
- Brace initialization zeros omitted storage before evaluating fields. Plain
  declarations without an initializer are unchanged. The runtime protects
  construction and argument temporaries through their evaluation, then releases
  that temporary protection; ordinary live locals and parameters remain roots.
- Contract reports distinguish `checked`, `unproven`, and `declaration-only`.
  Complexity analysis reports its scope and `proof=none`; source metadata such
  as effect/condition annotations is not presented as a proof of the body.

Windows verification passed under a 4 GiB per-process limit: self-host Stage1
and Stage2 match in both generated assembly and executable bytes; the final
unfiltered suite passed 959/959 checks. The Windows runner skipped one
LLVM-only fixture. Separate strict SSA checks also covered variadics, lambdas,
safe access and struct/slice returns. Linux validation remains deferred.
