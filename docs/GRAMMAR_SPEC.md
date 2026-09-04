# B++ (Bpp) Grammar Specification

> 코드 기반 역공학으로 작성된 문법 명세서 (2026-04-21)
> 컴파일러 소스: `src/lexer.bpp`, `src/parser/**/*.bpp`, `src/types.bpp`, `src/ast.bpp`

---

## 목차

1. [어휘 구조 (Lexical Structure)](#1-어휘-구조)
2. [타입 시스템 (Type System)](#2-타입-시스템)
3. [선언 (Declarations)](#3-선언)
4. [표현식 (Expressions)](#4-표현식)
5. [문장 (Statements)](#5-문장)
6. [특수 기능 (Special Features)](#6-특수-기능)
7. [문법 엄격 분석 & 문제점](#7-문법-엄격-분석--문제점)
8. [개선 제안](#8-개선-제안)

---

## 1. 어휘 구조

### 1.1 주석 (Comments)

```
// 한 줄 주석
/* 블록 주석 */
```

블록 주석은 중첩 **불가** (`/* /* */ */`는 에러).

### 1.2 키워드 (Keywords)

| 분류 | 키워드 |
|------|--------|
| **제어흐름** | `if`, `else`, `while`, `do`, `for`, `case`, `default`, `break`, `continue`, `return`, `match` |
| **선언** | `func`, `var`, `const`, `struct`, `enum`, `union`, `trait`, `impl`, `import`, `alias` |
| **타입 키워드** | `bool`, `u8`, `u16`, `u32`, `u64`, `i8`, `i16`, `i32`, `i64`, `f64`, `char` |
| **한정자** | `public`, `private`, `protected`, `static`, `abstract`, `packed`, `tagged` |
| **메모리** | `new`, `delete`, `sizeof` |
| **OOP** | `constructor`, `destructor`, `operator`, `super` |
| **에러 처리** | `try`, `catch`, `finally`, `throw` |
| **기타** | `from`, `as`, `where`, `defer`, `assert`, `todo`, `unreachable`, `true`, `false`, `null` |
| **매크로** | `__LINE__` |

### 1.3 리터럴 (Literals)

```
42              // 정수 리터럴 (TOKEN_NUMBER) — 10진수만 지원
3.14            // 부동소수점 리터럴 (TOKEN_FLOAT)
"hello\n"       // 문자열 리터럴 — 이스케이프 시퀀스 지원
'a'             // 문자 리터럴 — char (= u8)
'\n'            // 이스케이프 문자 리터럴
true / false    // 불리언
null            // 널 포인터
```

### 1.4 연산자 & 구분자 (Operators & Delimiters)

| 토큰 | 의미 |
|------|------|
| `+` `-` `*` `/` `%` | 산술 |
| `==` `!=` `<` `>` `<=` `>=` | 비교 |
| `&&` `\|\|` `!` | 논리 |
| `&` `\|` `^` `~` `<<` `>>` | 비트 |
| `=` `+=` `-=` `*=` `/=` `%=` | 대입 |
| `++` `--` | 증감 |
| `->` | 반환 타입 구분자 |
| `.` `.?` `.$` | 멤버 접근 / 안전 접근 / 원시 접근 |
| `?` | try 후위 연산자 / 삼항 연산자 |
| `?[` | 안전 인덱스 |
| `@` | 어노테이션 접두사 |
| `$` | (예약) |
| `( )` `{ }` `[ ]` | 계층 구분 |
| `;` `:` `,` | 문법 구분 |

---

## 2. 타입 시스템

### 2.1 원시 타입 & compiler-known prelude 타입 이름

```ebnf
PrimitiveType = "bool" | "u8" | "u16" | "u32" | "u64"
              | "i8" | "i16" | "i32" | "i64" | "f64"
              | "char"         (* u8의 별칭 *)
```

```ebnf
CompilerKnownPreludeType = "number" | "Number" | "string"
```

- `number`는 primitive가 아니라 `Number` 구조체로 해석되는 compiler-known prelude 타입 이름입니다.
- `string`도 ordinary identifier처럼 보이지만 compiler-known prelude 계층에서 특별취급되는 std 타입입니다.

### 2.2 포인터 타입 (Pointer Types)

```ebnf
PointerType = "*"+ ["tagged" ["(" IDENT ")"]] BaseType
```

```bpp
*u64                       // u64 포인터
**u8                       // 이중 포인터
*tagged(Meta) MyStruct     // 태그된 포인터 (정렬 비트에 메타데이터)
```

규칙: `tagged`는 **가장 바깥쪽 포인터에만** 허용.

### 2.3 배열 & 슬라이스 타입 (Array & Slice Types)

```ebnf
ArrayType = "[" Expression "]" Type    (* 고정 크기 배열 *)
SliceType = "[" "]" Type               (* 슬라이스 = ptr + len *)
```

```bpp
[10]u64         // 10개 u64 고정 배열
[]u8            // u8 슬라이스
[N]T            // 제네릭 크기 배열 (N은 const 제네릭 매개변수)
```

### 2.4 제네릭 타입 (Generic Types)

```ebnf
GenericType = IDENT "<" GenericArgList ">"
GenericArgList = GenericArg ("," GenericArg)*
GenericArg = Type | Expression | "true" | "false"
```

```bpp
Vec<*AstNode>
HashMap<u64, *String>
ModNumber<998244353>
```

### 2.5 함수 타입 (Function Types)

```ebnf
FuncType = "func" "(" [ParamTypeList] ")" "->" Type
ParamTypeList = Type ("," Type)* ["," "..." Type]
```

```bpp
func (u64, u64) -> u64
func (*u8, ...u64) -> u64    // 가변 인자
```

### 2.6 구조체/트레이트 타입

구조체 이름 / 트레이트 이름으로 참조. 포인터 형태로 사용:

```bpp
var obj: *MyStruct = new MyStruct();
var trait_ref: *Printable = obj;     // 트레이트 포인터
```

---

## 3. 선언 (Declarations)

### 3.1 함수 선언 (Function Declaration)

```ebnf
FuncDecl = [Annotations] "func" FuncName [GenericParams] "(" [ParamList] ")" ["->" Type] [WhereClause] (Block | ";")

FuncName = IDENT | "operator" OperatorSymbol | "new" | "delete"
OperatorSymbol = "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | ">" | "<=" | ">="
               | "<<" | ">>" | "&" | "|" | "^" | "!" | "~" | "[]" | "[]="

ParamList = Param ("," Param)*
Param = IDENT ":" Type ["=" DefaultExpr]
      | "..." IDENT ":" Type              (* 가변 인자 *)

GenericParams = "<" GenericParam ("," GenericParam)* ">"
GenericParam = IDENT                       (* 타입 매개변수 *)
             | "const" IDENT ":" Type      (* 값 매개변수 *)

WhereClause = "where" WhereConstraint ("," WhereConstraint)*
WhereConstraint = IDENT ":" TraitBound ["<" AssocBindings ">"]
```

```bpp
func add(a: u64, b: u64) -> u64 { return a + b; }
func id<T>(x: T) -> T { return x; }
func greet(name: *u8, times: u64 = 1) -> u64 { ... }
func sum(head: u64, ...rest: u64) -> u64 { ... }
func process<T>(x: T) -> u64 where T: Printable { ... }
func operator +(self: *Vec, rhs: *Vec) -> *Vec { ... }
```

### 3.2 구조체 선언 (Struct Declaration)

```ebnf
StructDecl = "struct" IDENT [GenericParams] [":" InheritanceList] "{" FieldList "}"

InheritanceList = (StructOrTraitName) ("," StructOrTraitName)*

FieldList = (FieldDecl)*
FieldDecl = [Annotations] AccessModifier IDENT ":" Type ";"

AccessModifier = "public" | "private" | "protected"
```

```bpp
struct Point {
    public x: u64;
    public y: u64;
}

struct Rect : Shape, Printable {
    public width: u64;
    public height: u64;
}
```

### 3.3 패킹된 구조체 (Packed Struct)

```ebnf
PackedStructDecl = "packed" "struct" IDENT "{" PackedFieldList "}"
PackedFieldList = (IDENT ":" PackedType ";")*
PackedType = PrimitiveType | IDENT     (* 비트폭 지정 가능, e.g. u3 *)
```

```bpp
packed struct TagMeta {
    flag: u1;
    tag: u2;
    padding: u5;
}
```

제한: 상속 불가, 트레이트 구현 불가.

### 3.4 유니온 선언 (Union Declaration)

```ebnf
UnionDecl = "union" IDENT "{" FieldList "}"
```

```bpp
union Value {
    public int_val: u64;
    public float_val: f64;
}
```

리터럴 초기화 시 최대 1개 필드만 허용. 상속/트레이트 불가.

### 3.5 열거형 선언 (Enum Declaration)

```ebnf
EnumDecl = "enum" IDENT "{" EnumVariantList "}"

EnumVariantList = EnumVariant ("," EnumVariant)* [","]
EnumVariant = IDENT ["=" ConstExpr]                    (* 단순 값 *)
            | IDENT "(" ParamList ")"                   (* 페이로드 변형 *)
```

```bpp
enum Color {
    Red,
    Green,
    Blue = 10,
}

enum Option {
    None,
    Some(value: u64),
}

enum Permission {
    Read = 1 << 0,
    Write = 1 << 1,
    Execute = 1 << 2,
}
```

### 3.6 트레이트 선언 (Trait Declaration)

```ebnf
TraitDecl = "trait" IDENT [GenericParams] "{" TraitBody "}"

TraitBody = (TraitItem)*
TraitItem = "func" FuncName "(" ParamList ")" ["->" Type] ";"              (* 추상 메서드 *)
          | "func" FuncName "(" ParamList ")" ["->" Type] Block            (* 기본 구현 *)
          | "alias" IDENT ";"                                               (* 연관 타입 *)
```

```bpp
trait Printable {
    func print(self: *Self) -> u64;
}

trait Iterator {
    alias Item;
    func next(self: *Self) -> *Item;
    func has_next(self: *Self) -> bool { return self.next() != null; }
}
```

### 3.7 Impl 블록 (Impl Block)

```ebnf
ImplBlock = "impl" TypeName "{" ImplBody "}"
          | "impl" TraitName [GenericArgs] "for" TypeName "{" ImplBody "}"

ImplBody = (ImplItem)*
ImplItem = [Annotations] [AccessModifier] ["static"] ["abstract"] MethodDecl
         | [Annotations] "constructor" "(" [ParamList] ")" Block
         | "destructor" Block
```

```bpp
impl Point {
    public constructor(x: u64, y: u64) {
        self.x = x;
        self.y = y;
    }

    public func distance(self: *Point) -> f64 { ... }

    public static func origin() -> *Point {
        return new Point(0, 0);
    }
}

impl Printable for Point {
    func print(self: *Point) -> u64 { ... }
}

impl Iterator<Item=u64> for Range {
    func next(self: *Range) -> u64 { ... }
}
```

### 3.8 임포트 선언 (Import Declaration)

```ebnf
ImportDecl = "import" ModulePath ["as" IDENT] ";"
           | "import" IDENT ["as" IDENT] "from" ModulePath ";"

ModulePath = IDENT ("." IDENT)*
```

```bpp
import std.io;
import std.vec as collections;
import HashMap from std.hashmap;
import Vec as DynArray from std.vec;
```

### 3.9 상수 선언 (Const Declaration)

```ebnf
ConstDecl = "const" IDENT "=" ConstExpr ";"
```

```bpp
const MAX_SIZE = 1024;
const PI = 3.14159;
const NEWLINE = 10;
```

상수 표현식: 정수 리터럴, 부동소수 리터럴, 문자열 리터럴, 문자 리터럴, `true`/`false`,
비트 연산 (`1 << 0`), 산술 (`+`, `-`, `*`, `/`, `%`), 부정 (`-expr`).

### 3.10 전역 변수 (Global Variable)

```ebnf
GlobalVarDecl = "var" IDENT ":" Type "=" Expression ";"
```

```bpp
var g_counter: u64 = 0;
var g_name: *u8 = "default";
```

### 3.11 별칭 (Alias)

```ebnf
AliasDecl = "alias" IDENT ":" IDENT ";"
```

주로 인라인 어셈블리의 레지스터 별칭에 사용.

```bpp
alias rax: result;
```

---

## 4. 표현식 (Expressions)

### 4.1 연산자 우선순위 (낮은 → 높은)

| 우선순위 | 연산자 | 결합성 | 설명 |
|------:|--------|--------|------|
| 1 | `? :` | 우결합 | 삼항 조건 |
| 2 | `\|\|` | 좌결합 | 논리 OR |
| 3 | `&&` | 좌결합 | 논리 AND |
| 4 | `\|` | 좌결합 | 비트 OR |
| 5 | `^` | 좌결합 | 비트 XOR |
| 6 | `&` | 좌결합 | 비트 AND |
| 7 | `== !=` | 좌결합 | 동등 비교 |
| 8 | `< > <= >=` | 좌결합 | 관계 비교 |
| 9 | `<< >>` | 좌결합 | 비트 시프트 |
| 10 | `+ -` | 좌결합 | 덧셈/뺄셈 |
| 11 | `* / %` | 좌결합 | 곱셈/나눗셈/나머지 |
| 12 | 단항: `* - ! ~ &` | 전위 | 역참조/부정/비트반전/주소 |
| 13 | 후위: `[] () . .? .$ ?[` `?` | 좌결합 | 인덱스/호출/멤버접근 등 |
| 14 | 기본 표현식 | — | 리터럴, 식별자, 괄호 |

### 4.2 기본 표현식 (Primary Expressions)

```ebnf
Primary = NUMBER | FLOAT | STRING | CHAR
        | "true" | "false" | "null"
        | "__LINE__"
        | IDENT [PostfixChain]
        | "(" Expression ")"
        | "(" Type ")" Expression          (* C-style 캐스트 *)
        | "sizeof" "(" Type ")"
        | "sizeof" "(" Expression ")"
        | "new" NewExpr
        | "super"
        | LambdaExpr
        | MatchExpr
```

### 4.3 호출 & 생성 (Calls & Construction)

```bpp
// 함수 호출
foo(1, 2, 3)
foo(a: 1, b: 2)                // 명명된 인수
Vec.new<u64>(8)                // 정적 제네릭 메서드 호출

// 구조체 리터럴 (값 타입)
Point{10, 20}

// 힙 할당
new Point{10, 20}              // 필드 초기화 → *Point 반환
new Point(10, 20)              // 생성자 호출 → *Point 반환
new [100]u8                    // 배열 힙 할당

// 스택 생성자 호출
Point(10, 20)                  // 생성자 호출 (값 의미론)

// 제네릭 호출
id<u64>(42)
Vec<u64>{1, 2, 3}
```

### 4.4 후위 연산자 (Postfix Operators)

```bpp
obj.field                      // 멤버 접근
obj.method(args)               // 메서드 호출
obj.?field                     // 안전 접근 (null이면 0 반환)
obj.?method(args)              // 안전 메서드 호출
obj.$field                     // 원시 접근 (property hook 우회)
obj.<Parent>field              // 스코프 지정 멤버 접근 (다중 상속)
arr[idx]                       // 인덱스
arr?[idx]                      // 안전 인덱스
expr++                         // 후위 증가
expr--                         // 후위 감소
expr?                          // try 연산자 (에러/None 시 조기 반환)
```

### 4.5 캐스트 (Cast)

```bpp
var x: u64 = (u64)ptr;        // C-style 캐스트
var p: *u8 = (*u8)addr;
```

`as` 키워드는 **캐스트에 사용되지 않음** (import 전용).

### 4.6 람다 (Lambda)

```ebnf
LambdaExpr = "func" [Captures] "(" [ParamList] ")" ["->" Type] Block

Captures = "[" CaptureList "]"
CaptureList = Capture ("," Capture)*
Capture = IDENT              (* 값 캡처 *)
        | "&" IDENT          (* 참조 캡처 *)
```

```bpp
var add = func (a: u64, b: u64) -> u64 { return a + b; };
var inc = func [base] (x: u64) -> u64 { return x + base; };
var mutate = func [&counter] () -> u64 { counter++; return counter; };
```

### 4.7 Match 표현식 (Match Expression)

```ebnf
MatchExpr = "match" "(" Expression ")" "->" Type "{" MatchArms "}"
MatchArms = MatchArm ("," MatchArm)*
MatchArm = "case" Pattern ":" Expression ";"
         | "case" "_" ":" Expression ";"
         | "default" ":" Expression ";"
```

```bpp
var name = match (color) -> *u8 {
    case Color.Red: "red";
    case Color.Blue: "blue";
    case _: "unknown";
};
```

---

## 5. 문장 (Statements)

### 5.1 세미콜론 규칙

| 문장 | 세미콜론 | 이유 |
|------|----------|------|
| `var` 선언 | **필요** | `var x: u64 = 0;` |
| 대입/표현식 문장 | **필요** | `x = 5;` / `foo();` |
| `return` | **필요** | `return x;` / `return;` |
| `break` / `continue` | **필요** | `break;` |
| `throw` / `delete` | **필요** | `throw err;` / `delete ptr;` |
| `assert` / `todo` / `unreachable` | **필요** | `assert(cond);` |
| `do-while` | **필요** | `do { } while (cond);` |
| `if` / `while` / `for` | **불필요** | 블록으로 종료 |
| `match` (문장) | **불필요** | 블록으로 종료 |
| `try` | **불필요** | 블록으로 종료 |
| `asm` | **불필요** | 블록으로 종료 |
| `defer` | **상속** | 내부 문장이 결정 |

### 5.2 변수 선언 (Variable Declaration)

```ebnf
VarDecl = "var" IDENT [":" Type] "=" Expression ";"
```

```bpp
var x: u64 = 10;
var name: *u8 = "hello";
var y = 42;                    // ⚠️ 타입 생략 시 i64로 기본값
```

### 5.3 대입 (Assignment)

```ebnf
AssignStmt = LValue "=" Expression ";"
           | LValue CompoundOp Expression ";"
           | LValue "++" ";"
           | LValue "--" ";"

CompoundOp = "+=" | "-=" | "*=" | "/=" | "%="
```

### 5.4 제어 흐름 (Control Flow)

```bpp
// if-else
if (cond) {
    ...
} else if (cond2) {
    ...
} else {
    ...
}

// while
while (cond) {
    ...
}

// do-while
do {
    ...
} while (cond);

// for (C-style)
for (var i: u64 = 0; i < n; i++) {
    ...
}

// match (표준 분기 문법, fallthrough 없음)
match (opt) {
    case Option.Some(value):
        use(value);
    case Option.None:
        handle_none();
}
```

### 5.5 에러 처리 (Error Handling)

```bpp
// try-catch-finally
try {
    risky_operation();
} catch (e: *Error) {
    handle_error(e);
} finally {
    cleanup();
}

// throw
throw new Error("something went wrong");

// try 후위 연산자
var result = operation()?;     // 에러 시 즉시 반환
```

### 5.6 리소스 관리 (Resource Management)

```bpp
defer close(fd);               // 스코프 종료 시 실행 (LIFO)
defer delete ptr;

delete obj;                    // 명시적 힙 해제
```

`defer`는 `break`, `continue`, `return` 시에도 실행됨.

### 5.7 특수 문장 (Special Statements)

```bpp
assert(x > 0);                // 런타임 어설션
todo;                          // 미구현 표시 (런타임 패닉)
unreachable;                   // 도달 불가 표시 (런타임 패닉)

asm {                          // 인라인 어셈블리
    mov rax, 7
    syscall
}
```

---

## 6. 특수 기능 (Special Features)

### 6.1 어노테이션 (Annotations)

```ebnf
Annotation = "@" "[" AnnotationItem ("," AnnotationItem)* "]"
AnnotationItem = IDENT ["(" AnnotationArgs ")"]
```

#### 함수/선언 수준 어노테이션

```bpp
@[entry]                                          // 진입점 지정
@[override]                                       // 가상 메서드 오버라이드
@[inline]                                         // 인라인 힌트

@[complexity(time="O(n)", space="O(1)")]          // 복잡도 명시
@[complexity_budget(time="O(n log n)")]            // 복잡도 제한
@[constraints(n=1000)]                             // 입력 크기 제약
@[time_limit(ms=20)]                              // 실행 시간 제한
@[complexity_debug]                                // 복잡도 디버그 출력
```

#### 프로퍼티 필드 규칙

```bpp
property(setter) public name: *u8;                       // setter hook 자동 생성
property(getter=get_name) public name: *u8;             // 명시적 getter 함수
```

#### 문장 수준 어노테이션

```bpp
@[complexity_ignore]                               // 이 문장 복잡도 무시
var cache = expensive_init();

@[symbolic_ignore]                                 // 기호 분석 무시
heavy_computation();
```

### 6.2 제네릭 (Generics)

```bpp
// 타입 매개변수
func swap<T>(a: *T, b: *T) -> u64 { ... }

// 값 매개변수
struct FixedArray<T, const N: u64> {
    public data: [N]T;
}

// 트레이트 바운드
func print_all<T>(items: *Vec<*T>) -> u64 where T: Printable { ... }

// 연관 타입 바인딩
impl Iterator<Item=u64> for Range { ... }
```

### 6.3 연산자 오버로딩 (Operator Overloading)

```bpp
impl Vec {
    public func operator +(self: *Vec, rhs: *Vec) -> *Vec { ... }
    public func operator [](self: *Vec, idx: u64) -> u64 { ... }
    public func operator []=(self: *Vec, idx: u64, val: u64) -> u64 { ... }
    public func operator ==(self: *Vec, rhs: *Vec) -> bool { ... }
}
```

지원 연산자: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `<<`, `>>`, `&`, `|`, `^`, `!`, `~`, `[]`, `[]=`

### 6.4 가상 디스패치 & 상속 (Virtual Dispatch & Inheritance)

```bpp
struct Animal {
    public name: *u8;
}

struct Dog : Animal {
    public breed: *u8;
}

impl Animal {
    public func speak(self: *Animal) -> u64 { ... }
}

impl Dog {
    @[override]
    public func speak(self: *Dog) -> u64 { ... }
    
    public func parent_speak(self: *Dog) -> u64 {
        return super.speak();    // 부모 메서드 호출
    }
}
```

### 6.5 태그된 포인터 (Tagged Pointers)

```bpp
packed struct Color3 { r: u1; g: u1; b: u1; }
var p: *tagged(Color3) Node = ...;
```

포인터의 정렬 비트에 메타데이터를 저장하는 최적화 기법.

### 6.6 원시 타입 네임스페이스 (Primitive Namespaces)

```bpp
i64.MIN          // i64 최솟값
u32.MAX          // u32 최댓값
u8.BITS          // u8 비트 수
```

---

## 7. 문법 엄격 분석 & 문제점

### 🔴 치명적 문제 (Critical Issues)

#### 7.1 `var` 타입 생략 시 `i64` 하드 디폴트

```bpp
var x = 5;                     // x는 i64
var y = get_struct();          // y도 i64가 됨 — ❌ 의도와 다를 가능성 높음
var z = 3.14;                  // z도 i64가 됨 — ❌ 부동소수점 잘림
```

**문제**: 이것은 "타입 추론"이 아니라 "기본값 할당"이다. 초기화 표현식의 타입을 전혀 참조하지 않으므로, 정수 리터럴이 아닌 모든 경우에 silent한 타입 불일치가 발생할 수 있다.

#### 7.2 제거된 `switch`는 진단 전용 호환 토큰으로만 유지

표면 문법은 `match`로 통일되어 있습니다. 남아 있는 `switch` 토큰/노드 처리는 기존 코드를 만나면 마이그레이션 진단을 주기 위한 compatibility layer로만 이해하는 것이 정확합니다.

### 🟡 중요 문제 (Important Issues)

#### 7.3 `as` 키워드 활용 부족

`as`는 예약어이지만 `import`의 별칭에만 사용됨. 캐스트는 C-style `(Type)expr`만 가능.

```bpp
// 현재: C-style 캐스트만 가능
var x: u64 = (u64)ptr;

// 불가능 (하지만 as가 예약어):
// var x: u64 = ptr as u64;
```

#### 7.4 16진수/8진수/2진수 리터럴 미지원

렉서에서 `0x`, `0o`, `0b` 접두사를 처리하지 않음. 시스템 프로그래밍 언어로서 비트 조작이 중요한데 10진수만 지원.

```bpp
// 불가능:
// const FLAG = 0xFF;
// const MASK = 0b1010_1010;

// 현재 방식:
const FLAG = 255;
const MASK = 170;
```

#### 7.5 숫자 리터럴 구분자 (`_`) 미지원

긴 숫자의 가독성이 떨어짐.

```bpp
// 불가능:
// const BIG = 1_000_000;
// const BITS = 0b1111_0000;

// 현재:
const BIG = 1000000;
```

#### 7.6 구조체 리터럴의 필드 이름 부재

구조체 리터럴이 **위치 기반**으로만 동작함 (`{val1, val2}`). 필드 이름을 지정할 수 없어 가독성이 떨어지고 필드 순서 변경 시 조용히 깨질 수 있음.

```bpp
// 현재: 위치 기반만 가능
var p = Point{10, 20};

// 불가능 (하지만 있어야 함):
// var p = Point{x: 10, y: 20};
```

함수 호출에는 `foo(a: 1, b: 2)` 명명된 인수가 있는데, 구조체 리터럴에는 없는 비대칭.

#### 7.7 `for` 루프가 C-style만 지원

range-based for나 iterator-based for가 없음.

```bpp
// 현재: C-style만 가능
for (var i: u64 = 0; i < arr.len(); i++) {
    use(arr[i]);
}

// 불가능:
// for (item in arr) { use(item); }
// for (i in 0..n) { ... }
```

### 🟢 경미한 문제 (Minor Issues)

#### 7.8 블록 주석 중첩 불가

```bpp
/* 외부 /* 내부 */ 여전히 주석 안 */   // ← 에러
```

대부분의 현대 언어는 중첩 블록 주석을 지원.

#### 7.9 `const` 표현식 범위 제한

상수 표현식은 산술, 비트 연산, 리터럴만 가능. `sizeof`, 함수 호출, 다른 상수 참조가 불가.

```bpp
const HEADER_SIZE = 8;
// const TOTAL = HEADER_SIZE + 4;    // 불가능 — 다른 const 참조 불가?
```

#### 7.10 후위 `?` 연산자와 삼항 `?:` 연산자 모호성

`expr?`(try)와 `expr ? a : b`(ternary)가 같은 `?` 토큰을 공유. 파서가 컨텍스트로 구분하지만, `result? ? a : b` 같은 패턴은 읽기 어려움.

#### 7.11 제네릭 `<>` vs `>>` 토큰 충돌

`Vec<Vec<u64>>`의 `>>`가 비트 시프트 연산자 `TOKEN_RSHIFT`로 렉싱됨. 파서가 이를 `depth -= 2`로 처리하지만, 이는 렉서-파서 경계를 넘는 해결책으로 취약함.

#### 7.12 `delete`가 포인터 타입 검사 부재 (구문 수준)

`delete 42;`와 같은 비포인터 delete는 구문적으로 허용되고 의미 분석(semantic analysis)에서만 잡힘. 구문 수준에서 최소한의 가드가 있으면 더 나은 에러 메시지를 줄 수 있음.

---

## 8. 개선 제안

### 8.1 단기 개선 (Low-hanging Fruit)

| 우선순위 | 제안 | 난이도 | 영향도 |
|------:|------|--------|--------|
| 1 | **16진수/2진수/8진수 리터럴** (`0xFF`, `0b1010`, `0o77`) | 낮음 | 높음 |
| 2 | **숫자 구분자** (`1_000_000`) | 낮음 | 중간 |
| 3 | **블록 주석 중첩** 허용 | 낮음 | 낮음 |
| 4 | **`var` 타입 생략 시 경고** 또는 에러 발생 (정수 리터럴 제외) | 낮음 | 높음 |

### 8.2 중기 개선 (Medium-term)

| 우선순위 | 제안 | 설명 |
|------:|------|------|
| 5 | **구조체 리터럴에 필드 이름 지원** | `Point{x: 10, y: 20}` 문법 추가. 기존 위치 기반도 유지 |
| 6 | **`as` 캐스트 문법 추가** | `expr as Type` 형태 지원. C-style 캐스트와 병행 |
| 7 | **removed-syntax compatibility 최소화 유지** | `switch`는 migration diagnostic용으로만 유지하고, 새 노드/문서는 `match` 중심으로 정규화 |
| 8 | **`for-in` 루프** | `for (item in iterable) { }` 형태 추가. Iterator trait 활용 |
| 9 | **const 표현식에서 다른 const 참조** 허용 | 컴파일 타임 상수 폴딩 확장 |

### 8.3 장기 개선 (Long-term / Design Evolution)

| 제안 | 설명 |
|------|------|
| **진정한 타입 추론** | Hindley-Milner 수준은 아니더라도, 이니셜라이저의 반환 타입에서 `var` 타입을 추론 |
| **패턴 매칭 확장** | `if let` / `while let` 패턴, guard 절 (`case Some(x) if x > 0:`) |
| **Result/Option 타입 통합** | `?` 연산자를 위한 공식 `Result<T, E>` / `Option<T>` 제네릭 타입 표준화 |
| **lifetime/borrow 검사** | `defer`/`delete` 수동 관리 대신 컴파일 타임 소유권 검증 (장기 목표) |
| **문자열 보간** | `"hello {name}"` 또는 `f"count = {n}"` 형태 |
| **멀티라인 문자열** | triple-quote `"""..."""` 또는 raw string `r"..."` |
| **모듈 내 가시성** | `pub(module)` 같은 세밀한 가시성 제어 |
| **`match` 중심 문법 유지** | 하나의 `match` 키워드로 표면 문법을 유지하고, `switch`는 제거된 surface syntax의 호환 진단으로만 제한 |

---

## 부록: EBNF 요약

```ebnf
Program       = (Declaration)*
Declaration   = FuncDecl | StructDecl | PackedStructDecl | UnionDecl
              | EnumDecl | TraitDecl | ImplBlock | ImportDecl
              | ConstDecl | GlobalVarDecl

Statement     = VarDecl | AssignStmt | ExprStmt
              | IfStmt | WhileStmt | DoWhileStmt | ForStmt
              | MatchStmt
              | ReturnStmt | BreakStmt | ContinueStmt
              | DeferStmt | DeleteStmt | ThrowStmt
              | TryCatchStmt | AsmBlock
              | AssertStmt | TodoStmt | UnreachableStmt
              | Block

Expression    = TernaryExpr
TernaryExpr   = LogicOrExpr ["?" Expression ":" Expression]
LogicOrExpr   = LogicAndExpr ("||" LogicAndExpr)*
LogicAndExpr  = BitOrExpr ("&&" BitOrExpr)*
BitOrExpr     = BitXorExpr ("|" BitXorExpr)*
BitXorExpr    = BitAndExpr ("^" BitAndExpr)*
BitAndExpr    = EqualityExpr ("&" EqualityExpr)*
EqualityExpr  = RelationExpr (("==" | "!=") RelationExpr)*
RelationExpr  = ShiftExpr (("<" | ">" | "<=" | ">=") ShiftExpr)*
ShiftExpr     = AddExpr (("<<" | ">>") AddExpr)*
AddExpr       = MulExpr (("+" | "-") MulExpr)*
MulExpr       = UnaryExpr (("*" | "/" | "%") UnaryExpr)*
UnaryExpr     = ("*" | "-" | "!" | "~" | "&") UnaryExpr | PostfixExpr
PostfixExpr   = Primary (PostfixOp)*
PostfixOp     = "." IDENT | ".?" IDENT | ".$" IDENT
              | "(" ArgList ")" | "[" Expression "]" | "?[" Expression "]"
              | "++" | "--" | "?"
Primary       = LITERAL | IDENT | "(" Expr ")" | Cast | NewExpr
              | SizeofExpr | LambdaExpr | MatchExpr | "super"

Type          = ["*"+ ["tagged" ["(" IDENT ")"]]] BaseType
BaseType      = PrimitiveType | IDENT [GenericArgs] | ArrayType | SliceType | FuncType
```
