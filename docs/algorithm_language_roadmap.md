# Bpp Algorithm Language Roadmap (Commercial Plan v1.0)

이 문서는 실험용 MVP가 아니라 **상용 릴리즈 가능한 수준**을 목표로 한 계획이다.
핵심 방향은 다음 3가지다.

- 기본 사용성: 일반 코드는 `string` 중심으로 쉽게 작성
- 성능 제어: 핫패스는 `str`로 무할당 경로를 명시
- 운영 신뢰성: 호환성/성능/진단 품질을 CI 게이트로 강제

## 1. 제품 목표와 성공 기준

### 1.1 제품 목표

- 알고리즘/수학 문제 풀이와 서비스 코드에 동시에 사용할 수 있는 네이티브 언어 제공
- 언어 코어, 표준 라이브러리, 도구 체인을 하나의 제품으로 제공
- 문법 편의성과 성능 예측 가능성을 동시에 보장

### 1.2 상용 성공 기준 (Release Gate)

- 컴파일러 크래시 프리율: 99.99% 이상 (CI + nightly fuzz 기준)
- 회귀 테스트 통과율: 100%
- 성능 회귀 허용 한도: 기준 벤치 대비 -5% 이내
- 호환성 정책 준수율: SemVer 규약 위반 0건
- 문서-구현 정합성: 공개 스펙 대비 동작 불일치 0건

## 2. 문자열 시스템 상용 설계 (`string` 기본, `str` 선택)

## 2.1 타입 정책

- 기본 문자열 타입은 `string`
- 최적화 타입은 `str`
- 암묵 변환은 `string -> str`만 허용
- `str -> string`은 `to_owned()` 같은 명시 API만 허용

## 2.2 타입 정의와 ABI

- `str`: `ptr:*u8, len:u64` (borrowed view)
- `string`: `ptr:*u8, len:u64, cap:u64` (owned buffer)
- ABI 버전 태그를 도입해 구조 레이아웃 변경 시 링크/런타임 오류를 조기 감지

## 2.3 수명/안전 규칙

- `str`는 원본 버퍼 수명을 초과할 수 없음
- `string`이 재할당되면 기존 `str`는 무효
- 로컬 `string` 기반 `str` 반환/전역 저장 금지
- 위반 시 컴파일 에러 또는 `-Wstr-lifetime` 경고를 정책 기반으로 선택

## 2.4 성능 정책

- `string -> str` 변환은 무할당 100% 보장
- `str` 연산(`slice/find/starts_with/eq/cmp`)은 무할당 경로 우선
- `string`은 SSO + growth policy(1.5x 또는 2x) + allocator 추상화 지원
- 할당 추적기(alloc counter) 기본 탑재

## 2.5 API 정책

- `str` API: 읽기/검색/비교 중심
- `string` API: 생성/변경/소유권 이동 중심
- C interop API는 명시 경계(`from_cstr`, `to_cstr`)로 분리
- `to_str: u64` 같은 포인터 우회 API는 단계적 폐기

## 2.6 진단 정책

- `-Wstring-alloc`: 숨은 문자열 할당 지점 경고
- `-Wstr-lifetime`: 무효 뷰 사용/escape 경고
- `-Wapi-deprecated`: 구식 문자열 API 사용 경고
- 진단 메시지는 “원인 + 수정 방법 + 대체 API”를 함께 제공

## 3. 컴파일러 아키텍처 요구사항

## 3.1 프론트엔드

- `str/string` 타입 파싱과 타입 추론 규칙 분리
- 오버로드 해석에서 `string` 정확 일치 우선, 이후 `string -> str` 적용
- 수명 제약 위반을 AST 단계에서 가능한 한 조기 검출

## 3.2 미들엔드(IR/SSA)

- `str`를 fat value로 lowering (`ptr,len`)
- `string` 변경 연산의 재할당 가능성 플래그 추적
- borrow invalidation 지점 추론
- escape analysis로 불필요 복사/할당 제거

## 3.3 백엔드/런타임

- `string` 런타임을 allocator 인터페이스로 분리
- 디버그 빌드에서 경계 검사/이중 해제 방지 가드 활성화
- 릴리즈 빌드에서 분기/검사 비용 최소화

## 4. 표준 라이브러리 상용 기준

## 4.1 문자열

- 필수: `split`, `join`, `replace`, `find`, `trim`, `starts_with`, `ends_with`
- 입력 파서: `tokens<T>`, `line`, `grid<T>`
- 유니코드 정책:
  - v1: 바이트 문자열 우선
  - UTF-8 검증/순회는 별도 모듈로 분리

## 4.2 알고리즘 라이브러리

- 자료구조: Fenwick, Segment Tree, DSU, Heap, Deque, Bitset
- 그래프: BFS/DFS, Dijkstra, SCC, Topological Sort
- 수학: gcd/modexp, 조합론, FFT/NTT, matrix exponentiation
- 모든 템플릿은 성능 기준 벤치와 함께 제공

## 5. 호환성/릴리즈 정책

## 5.1 버전 정책

- SemVer 준수
- `string`/`str` 관련 breaking change는 minor 금지, major만 허용
- 폐기 정책: 최소 2개 minor 동안 deprecation 경고 후 삭제

## 5.2 마이그레이션 정책

- 자동 변환 스크립트 제공 (`to_str:u64 -> to_str:str` 등)
- 릴리즈마다 “변경 영향 보고서” 제공
- 기존 코드가 깨지는 경우 대체 코드 예시 필수 제공

## 5.3 플랫폼 정책

- Linux x86_64 우선 안정화
- Windows/macOS는 동등 테스트 매트릭스로 품질 보증
- ABI/런타임 차이는 플랫폼별 문서로 명시

## 6. 테스트/품질 보증 체계

## 6.1 테스트 레이어

- 단위 테스트: 파서/타입체커/런타임
- 통합 테스트: 언어 기능 조합 시나리오
- 회귀 테스트: 과거 버그 재발 방지
- 퍼즈 테스트: 파서/타입체커/IR 변환
- 성능 테스트: micro + macro 알고리즘 벤치

## 6.2 필수 게이트

- PR 머지 전:
  - 전체 테스트 green
  - 문자열 벤치 회귀 허용치 내
  - 신규 진단 메시지 스냅샷 갱신
- nightly:
  - 장시간 fuzz
  - sanitizer 모드
  - 메모리 누수/UB 검사

## 7. 개발 단계 (상용 로드맵)

## Phase A: 문자열 코어 고정 (4주)

- `TYPE_STR`, `TYPE_STRING` 도입
- 기본 변환 규칙/수명 규칙 구현
- `std.str`, `std.string` 1차 API 완성
- `to_str:u64` 폐기 경고 시작

완료 조건:
- 문자열 코어 테스트 100% 통과
- `string -> str` 무할당 검증 완료

## Phase B: 진단/도구 상용화 (4주)

- `-Wstr-lifetime`, `-Wstring-alloc`, `-Wapi-deprecated` 구현
- 에러 코드/진단 카탈로그 정리
- 자동 마이그레이션 도구 초안 제공

완료 조건:
- 대표 오류 시나리오 진단 정확도 95% 이상
- 마이그레이션 샘플 프로젝트 3종 통과

## Phase C: 성능/런타임 고도화 (4주)

- SSO + allocator 추상화
- escape analysis 기반 복사/할당 제거
- 핫패스 문자열 API 최적화

완료 조건:
- 문자열 벤치 alloc/op 50% 이상 개선
- 기준 벤치 성능 회귀 0건

## Phase D: 에코시스템/안정화 (4주)

- 라이브러리 확장(그래프/DS/수학)
- 문서/예제/운영 가이드 완성
- 릴리즈 후보(RC) 생성 및 하드닝

완료 조건:
- 전체 테스트/퍼즈/벤치 게이트 통과
- RC 기간 블로킹 이슈 0건

## 8. 리스크와 대응

- 리스크: `str` 수명 분석 오탐/누락
- 대응: 보수적 규칙 + escape annotation + 경고/에러 모드 분리

- 리스크: `string` API 확장 중 성능 저하
- 대응: 벤치 게이트 강제, alloc counter 기본 적용

- 리스크: 기존 코드 마이그레이션 비용 증가
- 대응: 자동 변환 도구 + deprecation 기간 보장

## 9. 비목표 (v1.x)

- 대규모 symbolic manipulation 엔진 내장
- CAS 전체 호환성 추구
- 범용 과학 컴퓨팅 플랫폼 완전 대체

v1.x의 목표는 “알고리즘 실무에서 신뢰하고 쓸 수 있는 문자열/수치/성능 기반 언어 코어” 완성이다.

## 10. 별도 트랙: SSA 결합 Symbolic Manipulation 엔진 (v2+)

이 트랙은 v1.x 범위 밖의 별도 투자 항목이다.  
목표는 “수식 의미를 잃지 않으면서 SSA 최적화와 결합 가능한 심볼릭 엔진” 구축이다.

### 10.1 제품 목표

- 컴파일러가 루프/분기/재귀 코드를 **기호식(수식)** 으로 보존/변형 가능하게 만든다.
- 복잡도 추정, 강도 감소(strength reduction), 수학적 동치 최적화를 SSA와 함께 수행한다.
- `unknown` 비율을 줄이고, 분석 신뢰도를 `proven/heuristic/unknown`으로 구분한다.

### 10.2 핵심 아키텍처

1. Dual IR 모델
- 기존 SSA는 실행 의미/최적화용으로 유지
- 병행해서 Symbolic IR(SIR) 도입:
  - 다항식, 유리식, 지수/로그, 점화식 노드
  - 부등식 제약(예: `0 <= A < B < N`) 보존
- SSA value <-> SIR node 매핑 테이블 유지

2. 도메인 분리
- `Value Domain`: 상수/범위/타입 정보 (기존 분석)
- `Symbolic Domain`: 수식/제약/점화식
- `Cost Domain`: 시간/공간 비용식
- 고정점 계산은 세 도메인 동시 수렴으로 수행

3. 제약 엔진
- 선형 제약 우선(Polyhedral-lite)
- 비선형은 보수 근사 + 선택적 SMT offload
- 타임아웃/복잡도 상한으로 분석 비용 제어

### 10.3 SSA 결합 포인트

1. Phi-aware 식 병합
- `phi`에서 분기별 식을 `piecewise` 형태로 병합
- 조건식 제약을 함께 저장해 과도한 `unknown` 방지

2. 루프 식 추론
- induction variable + 경계식을 수식화
- 중첩 루프는 다변수 비용식(`O(n*m)`)으로 유지
- 불완전 케이스는 상한 근사로 강등

3. 호출/재귀 요약
- 함수별 symbolic summary(`output expr`, `cost expr`, `constraints`)
- 재귀 SCC는 점화식 템플릿으로 변환 후 해석
- 해석 실패 시 보수 상한 + 신뢰도 하향

4. 최적화 연동
- SIR 동치성으로 SSA 패턴 최적화 강화:
  - 불필요 계산 제거
  - 연산 순서 재배치
  - 상수/공통식 상승(hoist/CSE)

### 10.4 사용자 기능

- `--symbolic-report`:
  - 함수별 식 요약
  - 복잡도 식 + 제약 + 신뢰도
- `@symbolic_assume(...)`:
  - 입력 제약/관계식 명시
- `@symbolic_expect(expr=\"...\")`:
  - 기대 수식/비용식을 CI에서 검증
- `@symbolic_ignore(reason=\"...\")`:
  - 비결정/외부효과 구간 제외

### 10.5 구현 단계 (v2+)

#### Stage S1: 기반 구축 (6주)
- SIR 노드/파서/직렬화 포맷 정의
- SSA value <-> SIR 매핑 구축
- 선형 제약 엔진 1차

완료 조건:
- 단순 산술/분기 함수에서 식 재구성 성공률 90%+

#### Stage S2: 루프/다변수 추론 (8주)
- 루프 바운드 해석 고도화
- 다변수 비용식 유지 및 비교기 구현
- 제약 전파(분기/루프/함수 경계)

완료 조건:
- 대표 알고리즘 벤치(BFS/DFS/DP/정렬)에서 `unknown` 30% 이하

#### Stage S3: 재귀/점화식 해석 (8주)
- call graph SCC + 점화식 추출
- Master Theorem subset + 수치 fallback 해석기
- 실패 시 보수 상한 자동 강등

완료 조건:
- merge sort/quick sort/분할정복 계열 자동 판정 성공

#### Stage S4: 최적화/도구 통합 (6주)
- symbolic 기반 SSA 최적화 패스 연결
- 보고서/진단/CI 게이트 통합
- 성능 오버헤드 튜닝

완료 조건:
- 컴파일 시간 증가 10% 이내
- 최적화 벤치 평균 3~8% 개선(목표)

### 10.6 품질 게이트

- 분석 정확도:
  - 골든셋 대비 식 일치율 90%+
  - 과소추정(unsound) 0건
- 성능:
  - 기본 빌드에서 symbolic off 시 오버헤드 0에 수렴
  - symbolic on 빌드 시간 오버헤드 15% 이내
- 안정성:
  - 분석 타임아웃/메모리 상한 강제
  - 무한 루프/폭발 케이스 자동 중단

### 10.7 리스크와 대응

- 리스크: 식 폭발(expression blow-up)
- 대응: DAG 공유, 식 크기 상한, 정규화 캐시

- 리스크: 비선형 제약 처리 난항
- 대응: 선형 우선 + SMT 선택적 사용 + 보수 근사

- 리스크: 컴파일 시간 급증
- 대응: 단계별 캐시, 모듈 증분 분석, 난도 기반 early-cut

### 10.8 v1.x와의 경계

- v1.x에서는 symbolic 엔진을 구현하지 않는다.
- 단, v1.x 설계 시 다음 호환 포인트를 보존한다:
  - SSA 메타데이터 확장 슬롯
  - 진단 포맷(JSON/SARIF) 확장 가능성
  - 복잡도 어노테이션과의 키 스키마 일관성

### 10.9 `unknown` 최소화 목표 (현실 상한 포함)

`unknown`을 0%로 만드는 것은 불가능하다.  
중단성/등가성/경로폭발/동적 디스패치/FFI/확률성 때문에, 전체 언어 기준 하한이 존재한다.

상용 목표는 “0%”가 아니라 “예측 가능한 낮은 비율 + 명확한 원인 분류”다.

1. 전체 언어(FFI/함수포인터/동적호출 포함)
- 목표: `unknown <= 10~15%`
- 하한: `8~20%` 구간이 현실적

2. 알고리즘/PS 코드(표준 라이브러리 중심, 동적호출 제한)
- 목표: `unknown <= 5~10%`
- 공격적 목표: `3~8%`

3. 안전 기준
- 과소추정(unsound) 0건 유지
- `unknown` 감소보다 soundness를 우선
- `unknown`은 반드시 원인 코드와 함께 보고:
  - `dynamic_call`
  - `ffi_external`
  - `nonlinear_unresolved`
  - `path_explosion_timeout`
  - `randomized_expected_only`

### 10.10 `unknown <= 10%` 달성 실행 계획

#### U1. 라이브러리 비용 요약 강제 (가장 큰 효과)
- `std` 핵심 함수(입출력 제외)에 비용 요약을 의무화
- 누락 시 CI 실패
- 호출 그래프에서 요약 없는 외부 호출은 기본 `unknown`으로 분류

완료 조건:
- 표준 라이브러리 호출의 95% 이상이 요약 존재
- 라이브러리 기인 `unknown` 50% 이상 감소

#### U2. 인터프로시저 요약 안정화
- 함수별 `cost_expr`, `constraints`, `confidence`를 캐시
- SCC 단위 고정점 해석(재귀 포함)
- 모듈 증분 빌드에서 요약 캐시 재사용

완료 조건:
- 동일 코드 재빌드 시 요약 재사용률 80%+
- 재귀 함수군에서 `unknown` 30% 이상 감소

#### U3. SSA 루프 바운드 강화
- induction variable 패턴 확장:
  - affine (`i += c`)
  - geometric (`i *= c`, `i <<= k`)
  - guarded update(분기 내부 업데이트)
- 루프 경계식에 제약 전파(`A < B < N`) 직접 적용

완료 조건:
- 루프 기반 알고리즘 벤치에서 바운드 추론 성공률 90%+
- 루프 미해석 원인 비중 40% 이상 감소

#### U4. 동적 호출 분해
- 함수포인터/가상호출에 대해 가능한 callee 집합 추정
- 다중 후보면 상한 합성 + confidence 하향
- callee 집합이 공집합/과대이면 즉시 `unknown` 원인 태깅

완료 조건:
- 동적 호출 포함 코드에서 `unknown` 20% 이상 감소
- 잘못된 단일 타깃 확정(unsound) 0건

#### U5. 확률 알고리즘 모드 분리
- `worst`, `expected`, `high_prob`, `amortized`를 완전 분리
- 랜덤 호출 감지 시 기본 `expected` 경로 생성
- `worst` 추정이 불가능해도 `expected/high_prob`은 계속 제공

완료 조건:
- 확률 알고리즘군에서 “전부 unknown” 케이스 50% 이상 감소
- 모드 충돌 진단 정확도 95%+

#### U6. 타임아웃/폭발 제어 + 설명 가능성
- 식 DAG 공유, 항 수 상한, 분기 머지 휴리스틱 적용
- 타임아웃 시 무조건 `unknown`으로 떨어뜨리되 원인 코드/노드 출력
- `--symbolic-report`에 원인별 집계 비율 출력

완료 조건:
- symbolic on 컴파일 시간 오버헤드 15% 이내 유지
- timeout 기인 `unknown`의 원인 누락 0건

### 10.11 운영 게이트 (반복 사이클)

매 릴리즈 사이클은 아래를 반복한다.

1. 분석
- `unknown` 원인별 Pareto 상위 3개 추출
- 도메인별 정확도/신뢰도 리포트 생성

2. 수정
- 상위 원인 1개 이상 제거하는 패치만 우선
- 동일 원인 재등장 시 새 휴리스틱 추가 금지(근본 수정 우선)

3. 디버그
- 골든셋 + 회귀셋 + 스트레스셋 동시 실행
- confidence 분포 변화 확인

4. 재분석
- 이전 사이클 대비 `unknown` 감소폭 검증
- 감소폭 < 1%면 전략 전환(다음 원인군으로 이동)

### 10.12 최종 KPI

- 전체 언어 기준:
  - `unknown <= 15%` (GA)
  - `unknown <= 10%` (GA+1 목표)
- 알고리즘 도메인 기준:
  - `unknown <= 8%` (GA)
  - `unknown <= 5%` (GA+1 목표)
- 공통:
  - unsound 0건
  - 회귀 테스트 100% 유지
