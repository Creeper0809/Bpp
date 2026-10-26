#!/usr/bin/env python3
"""Correctness-checked Bpp/C++ algorithm comparisons on one Linux CPU.

Invoke through the repository's 4 GiB bash wrapper. Compilation is separate
from runtime. Never treats a failed/miscompiled variant as a timing sample.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import resource
import statistics
import subprocess
import time

from algorithm_cases import CASES, oracle, sources

SUPERVISOR = r'''
#define _GNU_SOURCE
#include <stdio.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
int main(int argc,char **argv){
 if(argc<3)return 120;
 struct timespec s,e; struct rusage r; int status;
 clock_gettime(CLOCK_MONOTONIC,&s);
 pid_t p=fork(); if(p<0)return 121;
 if(!p){execvp(argv[2],argv+2);_exit(127);}
 if(wait4(p,&status,0,&r)!=p)return 122;
 clock_gettime(CLOCK_MONOTONIC,&e);
 FILE *f=fopen(argv[1],"w");if(!f)return 123;
 fprintf(f,"{\"exitCode\":%d,\"cpuMs\":%.6f,\"wallMs\":%.6f,\"peakRssBytes\":%ld}",
 WIFEXITED(status)?WEXITSTATUS(status):-WTERMSIG(status),
 (r.ru_utime.tv_sec+r.ru_stime.tv_sec)*1000.0+(r.ru_utime.tv_usec+r.ru_stime.tv_usec)/1000.0,
 (e.tv_sec-s.tv_sec)*1000.0+(e.tv_nsec-s.tv_nsec)/1000000.0,r.ru_maxrss*1024L);
 fclose(f);return 0;
}
'''


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def command(argv, *, cwd, output=None, timeout=120):
    started = time.monotonic()
    if output:
        with open(output, 'wb') as stream:
            result = subprocess.run(argv, cwd=cwd, stdout=stream, stderr=subprocess.PIPE, timeout=timeout)
        stdout = ''
    else:
        result = subprocess.run(argv, cwd=cwd, capture_output=True, timeout=timeout)
        stdout = result.stdout.decode(errors='replace')
    row = {'argv': list(map(str, argv)), 'exitCode': result.returncode,
           'wallMs': (time.monotonic()-started)*1000, 'stderr': result.stderr.decode(errors='replace'), 'stdout': stdout}
    if result.returncode:
        raise RuntimeError(json.dumps(row))
    return row


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--compiler', required=True)
    parser.add_argument('--baseline-compiler')
    parser.add_argument('--out', required=True)
    parser.add_argument('--runs', type=int, default=5)
    parser.add_argument('--modes', default='gcc,clang,native,ssa,llvm')
    parser.add_argument('--cases', default=','.join(CASES))
    args = parser.parse_args()
    if not 3 <= args.runs <= 15:
        parser.error('Use 3 to 15 measured runs')
    resource.setrlimit(resource.RLIMIT_AS, (4*1024**3, 4*1024**3))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    allowed = sorted(os.sched_getaffinity(0))
    os.sched_setaffinity(0, {allowed[0]})
    root = Path(__file__).resolve().parents[1]
    compiler = Path(args.compiler).resolve()
    baseline_compiler = Path(args.baseline_compiler).resolve() if args.baseline_compiler else None
    out = Path(args.out).resolve()
    if out.exists():
        parser.error('Output directory already exists; preserve prior measurements')
    out.mkdir(parents=True)
    src = out / 'sources'; src.mkdir()
    # Generated sources may live outside the repository. Use the compiler's
    # supported manifest rather than relying on the source-directory heuristic.
    (src / 'bpp.toml').write_text('std_root=' + str(root / 'src') + '\n')
    (out / 'supervisor.c').write_text(SUPERVISOR)
    command(['gcc', '-O2', str(out/'supervisor.c'), '-o', str(out/'supervisor')], cwd=root)
    modes = args.modes.split(',')
    report = {'schemaVersion': 1, 'measuredAtUtc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
              'compiler': str(compiler), 'compilerSha256': sha(compiler),
              'baselineCompiler': str(baseline_compiler) if baseline_compiler else None,
              'baselineCompilerSha256': sha(baseline_compiler) if baseline_compiler else None,
              'platform': platform.platform(), 'cpuAffinity': [allowed[0]],
              'cpuModel': next((s.split(':',1)[1].strip() for s in Path('/proc/cpuinfo').read_text().splitlines() if s.startswith('model name')), 'unknown'),
              'addressSpaceBytes': 4*1024**3, 'runs': args.runs, 'warmups': 1,
              'cpuTarget': 'x86-64 baseline; no -march=native on either language',
              'metric': 'fresh native C wait4 supervisor: per-process CPU, wall and peak RSS; compile excluded',
              'scripts': {p.name: sha(p) for p in (Path(__file__), Path(__file__).with_name('algorithm_cases.py'))},
              'toolchains': {}, 'cases': []}
    for executable in ['g++', 'clang++', 'clang', 'nasm']:
        report['toolchains'][executable] = command([executable, '--version' if executable != 'nasm' else '-v'], cwd=root)['stdout'].splitlines()[0]
    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2))
    def run(binary, n, seed, expected, token):
        metrics_path = out / (token + '.metrics.json')
        result = subprocess.run([str(out/'supervisor'), str(metrics_path), str(binary)],
                                input=f'{n}\n{seed}\n'.encode(), capture_output=True, timeout=60)
        if result.returncode:
            raise RuntimeError('Measurement supervisor failed')
        value = json.loads(metrics_path.read_text())
        value.update(stdout=result.stdout.decode(errors='replace'), stderr=result.stderr.decode(errors='replace'))
        value['passed'] = value['exitCode'] == 0 and value['stdout'] == str(expected)+'\n' and not value['stderr']
        if not value['passed']:
            raise RuntimeError(json.dumps(value))
        return value
    for name in args.cases.split(','):
        n, small_n, _ = CASES[name]
        bpp, cpp = sources(name)
        bpp_path, cpp_path = src/(name+'.bpp'), src/(name+'.cpp')
        bpp_path.write_text(bpp); cpp_path.write_text(cpp)
        print('PREPARE', name, flush=True)
        seed = 12345
        checks = [(small_n, seed, oracle(name, small_n, seed)),
                  (small_n, 987654321, oracle(name, small_n, 987654321)),
                  (n, seed, oracle(name, n, seed))]
        row = {'name': name, 'n': n, 'seed': seed, 'expected': checks[-1][2],
               'sourceSha256': {'bpp': sha(bpp_path), 'cpp': sha(cpp_path)}, 'variants': {}}
        report['cases'].append(row); save()
        binaries = {}
        for mode in modes:
            variant = {'preparation': [], 'validation': [], 'samples': []}
            row['variants'][mode] = variant
            binary = out/(name+'_'+mode)
            try:
                if mode in ('gcc', 'clang'):
                    executable = 'g++' if mode == 'gcc' else 'clang++'
                    variant['preparation'].append(command([executable,'-std=c++17','-O3','-march=x86-64',str(cpp_path),'-o',str(binary)],cwd=root))
                elif mode in ('native','native_before','ssa'):
                    asm, obj = out/(name+'_'+mode+'.asm'), out/(name+'_'+mode+'.o')
                    backend = 'ssa' if mode == 'ssa' else 'legacy'
                    selected_compiler = baseline_compiler if mode == 'native_before' else compiler
                    if selected_compiler is None:
                        raise ValueError('native_before requires --baseline-compiler')
                    variant['preparation'].append(command([str(selected_compiler),'-O1','--backend',backend,'-asm',str(bpp_path)],cwd=root,output=asm))
                    variant['preparation'].append(command(['nasm','-felf64','-O1',str(asm),'-o',str(obj)],cwd=root))
                    variant['preparation'].append(command(['ld',str(obj),'-o',str(binary)],cwd=root))
                    variant['assemblySha256'] = sha(asm)
                elif mode == 'llvm':
                    ll = out/(name+'.ll')
                    variant['preparation'].append(command([str(compiler),'-O3','-dump-llvm-ll',str(bpp_path)],cwd=root,output=ll))
                    variant['preparation'].append(command(['clang','-O3','-march=x86-64','-x','ir',str(ll),'-o',str(binary)],cwd=root))
                    variant['llvmSha256'] = sha(ll)
                else:
                    raise ValueError('Unknown mode '+mode)
                variant['binarySha256'] = sha(binary)
                for index, (size, check_seed, expected) in enumerate(checks):
                    value = run(binary,size,check_seed,expected,name+'_'+mode+'_check'+str(index))
                    variant['validation'].append({'n':size,'seed':check_seed,**value})
                binaries[mode] = binary
                variant['status'] = 'validated'
            except (RuntimeError, subprocess.TimeoutExpired) as exc:
                variant['status'] = 'failed'; variant['error'] = str(exc)
                print('FAILED',name,mode,str(exc)[:500],flush=True)
            save()
        # Successful large validation is the one unmeasured warmup. Rotate order
        # on each repetition rather than measuring every Bpp process first.
        for repeat in range(args.runs):
            order = list(binaries)
            order = order[repeat % len(order):] + order[:repeat % len(order)] if order else []
            for mode in order:
                value = run(binaries[mode],n,seed,checks[-1][2],name+'_'+mode+'_run'+str(repeat))
                row['variants'][mode]['samples'].append({'repeat':repeat,**value})
            save()
        for mode, variant in row['variants'].items():
            samples = variant['samples']
            if samples:
                variant['summary'] = {key:{'median':statistics.median(s[key] for s in samples),
                                           'min':min(s[key] for s in samples),'max':max(s[key] for s in samples)}
                                      for key in ('cpuMs','wallMs','peakRssBytes')}
                print(name, mode, 'cpu_ms', round(variant['summary']['cpuMs']['median'],3),flush=True)
        save()
    print('REPORT',out/'report.json',flush=True)
    return 1 if any(v['status']=='failed' for c in report['cases'] for v in c['variants'].values()) else 0


if __name__ == '__main__':
    raise SystemExit(main())
