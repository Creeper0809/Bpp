#!/usr/bin/env python3
"""Summarize real paired samples, preserving raw evidence and uncertainty."""
import argparse
import csv
import json
import math
from pathlib import Path
import shutil


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--report', required=True)
    parser.add_argument('--out', required=True)
    parser.add_argument('--chart', action='store_true')
    args = parser.parse_args()
    report_path = Path(args.report)
    report = json.loads(report_path.read_text())
    out = Path(args.out)
    if out.exists():
        parser.error('Preserve existing results: choose a new output directory')
    out.mkdir(parents=True)
    rows = []
    for case in report['cases']:
        variants = case['variants']
        if any(v['status'] != 'validated' or len(v['samples']) != report['runs']
               or not all(s['passed'] for s in v['samples']) for v in variants.values()):
            raise ValueError('Incomplete or incorrect comparison: '+case['name'])
        med = {mode: value['summary']['cpuMs']['median'] for mode, value in variants.items()}
        cpp_mode = min(('gcc','clang'), key=lambda mode: med[mode])
        cpp = med[cpp_mode]
        rows.append({'algorithm':case['name'], 'n':case['n'], 'gcc_ms':med['gcc'],
                     'clang_ms':med['clang'], 'cpp_best':cpp_mode,
                     'before_ms':med['native_before'], 'after_ms':med['native'],
                     'native_time_reduction_percent':(1-med['native']/med['native_before'])*100,
                     'native_speedup':med['native_before']/med['native'],
                     'native_vs_cpp_time_ratio':med['native']/cpp,
                     'ssa_ms':med['ssa'], 'llvm_ms':med['llvm'],
                     'llvm_vs_cpp_time_ratio':med['llvm']/cpp})
    with (out/'summary.tsv').open('w',newline='',encoding='utf-8') as stream:
        writer = csv.DictWriter(stream,fieldnames=list(rows[0]),delimiter='\t')
        writer.writeheader(); writer.writerows(rows)
    overall = {'cases':len(rows), 'runsPerVariant':report['runs'],
               'measuredSamples':sum(len(v['samples']) for c in report['cases'] for v in c['variants'].values()),
               'nativeGeomeanSpeedup':math.exp(sum(math.log(r['native_speedup']) for r in rows)/len(rows)),
               'nativeImprovedCases':sum(r['native_speedup']>1 for r in rows),
               'scope':'Equal weight across these fixed workloads, not a universal performance claim'}
    (out/'summary.json').write_text(json.dumps(overall,indent=2))
    shutil.copyfile(report_path,out/'report.json')
    if args.chart:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
        fig, ax = plt.subplots(figsize=(13,8),layout='constrained')
        positions = np.arange(len(rows))
        for index,(mode,label,color) in enumerate([
                ('native_before','Bpp native O1 before','#94a3b8'),
                ('native','Bpp native O1 after','#2563eb'),
                ('llvm','Bpp LLVM + Clang O3','#0d9488')]):
            values, low, high = [],[],[]
            for case,row in zip(report['cases'],rows):
                cpp = min(row['gcc_ms'],row['clang_ms'])
                stat = case['variants'][mode]['summary']['cpuMs']
                values.append(stat['median']/cpp)
                low.append((stat['median']-stat['min'])/cpp)
                high.append((stat['max']-stat['median'])/cpp)
            ax.barh(positions+(index-1)*0.24,values,height=0.22,label=label,color=color,
                    xerr=[low,high],error_kw={'elinewidth':0.8,'capsize':2})
        ax.set_yticks(positions,[r['algorithm'] for r in rows]); ax.invert_yaxis()
        ax.axvline(1,color='#ea580c',linestyle='--',label='Faster C++ compiler per case = 1')
        ax.set_xlabel('CPU time / faster of GCC O3 and Clang O3 (lower is better)')
        ax.set_title('Equivalent algorithms: Bpp before / after and optimized C++',loc='left',fontweight='bold')
        ax.grid(axis='x',alpha=0.15); ax.set_axisbelow(True)
        ax.legend(loc='upper right',fontsize=9)
        fig.supxlabel(f"One pinned logical CPU | {report['runs']} rotating-order measured runs per variant\nBars: median CPU time. Error bars: observed min/max, not confidence intervals. Compilation excluded.\nFixed dataset generation/initialization and process startup included; not isolated inner kernels.",fontsize=10)
        fig.savefig(out/'comparison.png',dpi=170)
        fig.savefig(out/'comparison.svg')
        plt.close(fig)
    print(json.dumps(overall,indent=2))
    for row in rows:
        print(row['algorithm'],f"{row['before_ms']:.3f} -> {row['after_ms']:.3f} ms",
              f"{row['native_time_reduction_percent']:.1f}% less time",
              f"{row['native_vs_cpp_time_ratio']:.2f}x C++ time")


if __name__ == '__main__':
    main()
