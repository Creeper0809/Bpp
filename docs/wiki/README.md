# Wiki Source

`docs/wiki`는 GitHub Wiki 원고 소스 디렉터리입니다.  
중요: 이 폴더에 파일을 추가해도 GitHub Wiki에는 자동 반영되지 않습니다.

## 왜 자동 반영이 안 되나?

GitHub Wiki는 메인 저장소와 별도의 git 저장소를 사용합니다.

- main repo: `Bpp.git`
- wiki repo: `Bpp.wiki.git`

즉, 위키 반영은 `Bpp.wiki.git`으로 별도 push가 필요합니다.

## 반영 방법

```bash
scripts/publish_wiki.sh <owner/repo> [source_dir]
```

예시:

```bash
scripts/publish_wiki.sh Creeper0809/Bpp docs/wiki
```

## 인증 방식

스크립트는 아래 순서로 인증 정보를 찾습니다.

1. `GITHUB_TOKEN` 환경변수
2. `GH_TOKEN` 환경변수
3. `gh auth token` (GitHub CLI 로그인 상태)
4. 로컬 git credential helper/session

권장:

```bash
gh auth login
scripts/publish_wiki.sh Creeper0809/Bpp docs/wiki
```

## 포함 파일

- `Home.md`
- `_Sidebar.md`
- `Getting-Started.md`
- `Language-Reference.md`
- `Language-Scope.md`
- `Lexical-Rules.md`
- `Type-System.md`
- `Declarations.md`
- `Functions-and-Calls.md`
- `Expressions.md`
- `Statements-and-Control-Flow.md`
- `Struct-Impl-and-Inheritance.md`
- `Traits-and-Virtual-Dispatch.md`
- `Generics.md`
- `Annotations-and-Decorators.md`
- `Modules-and-Name-Resolution.md`
- `Diagnostics-and-Errors.md`
- `Current-Limitations.md`
- `Compiler-Internals.md`
- `Testing-and-CI.md`
- `Contributing.md`
