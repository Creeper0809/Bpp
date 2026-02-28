# B v10 Syntax (Implemented)

This document describes syntax that is implemented in the current `v10` compiler.

## Top-Level Declarations

- `import module.path;`
- `import symbol from module.path;`
- `import symbol as alias from module.path;`
- `const NAME = <const-expr>;`
- `var name: Type = expr;`
- `func name(params...) -> Type { ... }`
- `func name(params...) -> Type;` (signature/prototype)
- `struct Name { ... }`
- `union Name { ... }`
- `enum Name { A, B = 3, ... }`
- `trait Name { func ...; func ... { ... } }`
- `impl Type { ... }`
- `impl Trait for Type { ... }`

## Statements

- `var` declarations
- assignment and compound assignment (`=`, `+=`, `-=`, `*=`, `/=`, `%=`)
- expression statements
- `if / else` (block or single statement body)
- `while` (block or single statement body)
- `for (init; cond; update)` (block or single statement body)
- `switch / case / default`
- `break`, `continue`, `return`
- `defer <stmt>`
- `delete expr;`
- `asm { ... }`
- debug statements: `assert(...)`, `todo;`, `unreachable;`

## Expressions

- literals: integer, float, string, char, `true`, `false`, `null`
- unary: `-`, `!`, `~`, `*`, `&`
- binary: arithmetic, bitwise, shifts, comparisons, logical ops
- cast: `(Type)expr`
- call: `f(...)`, function pointer call
- member access: `.`, safe access `.?`
- indexing: `a[i]`
- `sizeof(Type)` and `sizeof(expr)`
- `new Type`, `new Type(...)`, `new Type{...}`
- struct/union literals
- generic calls and generic struct literals
- `try` postfix: `expr?`
- `super.member` / `super.method(...)` in impl context

## Type Syntax

- primitives: `u8`, `u16`, `u32`, `u64`, `i64`, `f64`, `char`
- pointers: `*T`
- tagged pointer: `*tagged T`, `*tagged(Layout) T`
- arrays: `[N]T`
- slices: `[]T`
- user types: `Name`, `Name<T, U, 8>`
- trait pointer type: `*TraitName`

## Current Constraints

- Function parameters may omit type; omitted type defaults to `u64`.
- Nested array/slice element types (for example `[2][3]u64`) are not supported yet.
- Value generic parameter type is currently limited to `u64`.
