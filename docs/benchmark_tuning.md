# 벤치마크 기반 최적화 튜닝

이 문서는 O1 최적화의 PGO 후보와 threshold 변경을 같은 입력, 같은 backend,
같은 opt level 기준으로 비교하기 위한 운용 규칙이다.

## 실행 방법

기본 실행:

```bash
COMPILER=./bin/stage1 RUNS=3 bash bench/run_microbench.sh
```

전후 비교:

```bash
BASELINE_COMPILER=./bin/stage1 COMPILER=/tmp/bpp_candidate RUNS=5 bash bench/run_microbench.sh
```

주요 환경 변수:

- `COMPILER`: 후보 컴파일러
- `BASELINE_COMPILER`: 비교 기준 컴파일러
- `BENCH_SOURCES`: 공백으로 구분한 benchmark 입력 목록
- `OPT_LEVEL`: 단일 최적화 단계. 기본값은 `O1`
- `OPT_LEVELS`: 공백으로 구분한 최적화 단계 행렬. 예: `O1 O2 O3`
- `BACKEND`: 현재 `llvm`
- `RUNS`: 실행 반복 횟수
- `OUT_DIR`: 결과 디렉터리
- `THRESHOLD_FILE`: threshold 기록 파일

## 결과 파일

`bench/run_microbench.sh`는 기본적으로 `build/microbench` 아래에 다음 파일을 만든다.

- `bench_report.tsv`: compile, LLVM build, 실행 best/avg 시간, 최대 RSS
- `optimization_report.tsv`: LLVM 덤프에서 추출한 O1 metadata 카운터
- `comparison_report.tsv`: `BASELINE_COMPILER`가 있을 때 전후 delta
- `optimization_thresholds.tsv`: 실행 당시 threshold 복사본

증분 컴파일 캐시 준비 상태는 다음 probe로 확인한다.

```bash
COMPILER=./bin/stage1 bash bench/run_incremental_cache_probe.sh
```

이 probe는 source hash, option hash, cache key, 동일 입력의 deterministic SSA 출력을 기록한다.

## Threshold 기록 규칙

threshold를 바꾸는 변경은 반드시 `bench/optimization_thresholds.tsv`와 benchmark
결과를 함께 남긴다. 현재 기록 대상은 다음 축이다.

- inline: small/trivial instruction limit
- bigint: Karatsuba, Toom-3, NTT, divide-and-conquer 전환점
- allocator: GC 기본 threshold와 profile hot threshold
- vector: vector/unroll 최소 길이

## CI 분리

빠른 CI는 기존 Linux/Windows 검증만 실행한다. full benchmark는 GitHub Actions의
수동 실행에서 `full_benchmarks=true`로 켜는 별도 `performance` job으로 분리한다.
짧은 differential fuzz smoke는 `full_fuzz=true`로 켜는 별도 job에서 실행한다.
