"""Shared imperative workloads emitted as both Bpp and C++.

Only declarations, signatures and I/O spelling differ. Arithmetic is unsigned
64-bit in both languages, with identical loops, layout, input and checksums.
Independent Python oracles validate small and measured inputs.
"""
import bisect
from collections import deque
import math
import re

PREFIX = '''import std.io;
var a: [2100001]u64;
var b: [1000001]u64;
var c: [65536]u64;
func next_random(x: u64) -> u64 { return (x * 1664525 + 1013904223) & 4294967295; }
'''

CASES = {
    'array_sum': (1000000, 32, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0; var total: u64 = 0;
    while (i < n) { seed = next_random(seed); a[i] = seed & 65535; i += 1; }
    i = 0;
    while (i < n) { total += a[i]; i += 1; }
    return total;
}
'''),
    'dot_product': (500000, 32, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0; var total: u64 = 0;
    while (i < n) {
        seed = next_random(seed); a[i] = seed & 65535;
        seed = next_random(seed); b[i] = seed & 65535; i += 1;
    }
    i = 0;
    while (i < n) { total += a[i] * b[i]; i += 1; }
    return total;
}
'''),
    'binary_search': (262144, 64, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0; var total: u64 = 0;
    while (i < n) { a[i] = i * 3 + 7; i += 1; }
    i = 0;
    while (i < n) {
        seed = next_random(seed); var key: u64 = seed % (n * 3 + 11);
        var lo: u64 = 0; var hi: u64 = n;
        while (lo < hi) {
            var mid: u64 = lo + (hi - lo) / 2;
            if (a[mid] < key) { lo = mid + 1; } else { hi = mid; }
        }
        total += lo; i += 1;
    }
    return total;
}
'''),
    'heap_sort': (200000, 64, '''
func sift(end: u64, root: u64) -> u64 {
    while (root * 2 + 1 < end) {
        var child: u64 = root * 2 + 1;
        if (child + 1 < end && a[child] < a[child + 1]) { child += 1; }
        if (a[root] >= a[child]) { return 0; }
        var tmp: u64 = a[root]; a[root] = a[child]; a[child] = tmp; root = child;
    }
    return 0;
}
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i < n) { seed = next_random(seed); a[i] = seed & 65535; i += 1; }
    i = n / 2;
    while (i > 0) { i -= 1; sift(n, i); }
    i = n;
    while (i > 1) { i -= 1; var tmp: u64 = a[0]; a[0] = a[i]; a[i] = tmp; sift(i, 0); }
    var total: u64 = 0; i = 0;
    while (i < n) { total += a[i] * (i + 1); i += 1; }
    return total;
}
'''),
    'sieve': (2000000, 64, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i <= n) { a[i] = 0; i += 1; }
    i = 2;
    while (i * i <= n) {
        if (a[i] == 0) { var j: u64 = i * i; while (j <= n) { a[j] = 1; j += i; } }
        i += 1;
    }
    var total: u64 = 0; i = 2;
    while (i <= n) { if (a[i] == 0) { total += 1; } i += 1; }
    return total;
}
'''),
    'union_find': (100000, 64, '''
func find_root(x: u64) -> u64 {
    while (a[x] != x) { a[x] = a[a[x]]; x = a[x]; }
    return x;
}
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i < n) { a[i] = i; b[i] = 1; i += 1; }
    i = 0;
    while (i < n * 8) {
        seed = next_random(seed); var x: u64 = find_root(seed % n);
        seed = next_random(seed); var y: u64 = find_root(seed % n);
        if (x != y) {
            if (b[x] < b[y]) { var tmp: u64 = x; x = y; y = tmp; }
            a[y] = x; b[x] += b[y];
        }
        i += 1;
    }
    var total: u64 = 0; i = 0;
    while (i < n) { total += (i + 1) * (find_root(i) + 1); i += 1; }
    return total;
}
'''),
    'bfs': (500000, 64, '''
func visit(v: u64, distance: u64, tail: u64) -> u64 {
    if (a[v] == 0) { a[v] = distance; b[tail] = v; return tail + 1; }
    return tail;
}
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i < n) { a[i] = 0; i += 1; }
    var start: u64 = seed % n; a[start] = 1; b[0] = start;
    var head: u64 = 0; var tail: u64 = 1;
    while (head < tail) {
        var x: u64 = b[head]; head += 1; var distance: u64 = a[x] + 1;
        tail = visit((x + 1) % n, distance, tail);
        tail = visit((x + n - 1) % n, distance, tail);
        tail = visit((x * 17 + 13) % n, distance, tail);
    }
    var total: u64 = 0; i = 0;
    while (i < n) { total += a[i] * (i + 1); i += 1; }
    return total;
}
'''),
    'knapsack': (4096, 32, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i <= n) { a[i] = 0; i += 1; }
    i = 0;
    while (i < 2048) {
        seed = next_random(seed); var weight: u64 = seed % 31 + 1;
        seed = next_random(seed); var value: u64 = seed % 1000 + 1;
        var j: u64 = n;
        while (j >= weight) {
            var candidate: u64 = a[j - weight] + value;
            if (candidate > a[j]) { a[j] = candidate; }
            j -= 1;
        }
        i += 1;
    }
    return a[n];
}
'''),
    'gcd': (500000, 32, '''
func euclid(x: u64, y: u64) -> u64 {
    while (y != 0) { var tmp: u64 = x % y; x = y; y = tmp; }
    return x;
}
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0; var total: u64 = 0;
    while (i < n) {
        seed = next_random(seed); var x: u64 = seed + 1;
        seed = next_random(seed); var y: u64 = seed + 1;
        total += euclid(x, y); i += 1;
    }
    return total;
}
'''),
    'matrix_multiply': (192, 8, '''
func algorithm(n: u64, seed: u64) -> u64 {
    var i: u64 = 0;
    while (i < n * n) {
        seed = next_random(seed); a[i] = seed & 255;
        seed = next_random(seed); b[i] = seed & 255; c[i] = 0; i += 1;
    }
    i = 0;
    while (i < n) {
        var k: u64 = 0;
        while (k < n) {
            var value: u64 = a[i * n + k]; var j: u64 = 0;
            while (j < n) { c[i * n + j] += value * b[k * n + j]; j += 1; }
            k += 1;
        }
        i += 1;
    }
    var total: u64 = 0; i = 0;
    while (i < n) {
        var j: u64 = 0;
        while (j < n) { total += c[i * n + j] * (i + 1) * (j + 1); j += 1; }
        i += 1;
    }
    return total;
}
'''),
}


def sources(name):
    body = PREFIX + CASES[name][2] + '''
func main() -> u64 {
    var n: u64 = input_u64(); var seed: u64 = input_u64();
    print_u64(algorithm(n, seed)); print_nl(); return 0;
}
'''
    cpp = body.replace('import std.io;', '#include <cstdint>\n#include <cstdio>\n#include <cinttypes>\nstatic uint64_t input_u64(){uint64_t x=0; if(std::scanf("%" SCNu64, &x)!=1) std::abort(); return x;}\nstatic void print_u64(uint64_t x){std::printf("%" PRIu64,x);}\nstatic void print_nl(){std::puts("");}')
    cpp = cpp.replace('#include <cstdio>', '#include <cstdio>\n#include <cstdlib>')
    cpp = re.sub(r'var (\w+): \[(\d+)\]u64;', r'uint64_t \1[\2];', cpp)
    cpp = re.sub(r'var (\w+): u64', r'uint64_t \1', cpp)
    cpp = re.sub(r'(\w+): u64', r'uint64_t \1', cpp)
    cpp = re.sub(r'func (\w+)\(([^)]*)\) -> u64', r'uint64_t \1(\2)', cpp)
    cpp = cpp.replace('uint64_t main()', 'int main()')
    return body, cpp


def randoms(n, seed):
    for _ in range(n):
        seed = (seed * 1664525 + 1013904223) & 0xffffffff
        yield seed


def oracle(name, n, seed):
    if name == 'array_sum': return sum(x & 65535 for x in randoms(n, seed))
    if name == 'dot_product':
        data = iter(randoms(n * 2, seed))
        return sum((x & 65535) * (next(data) & 65535) for x in data)
    if name == 'binary_search':
        data = [i * 3 + 7 for i in range(n)]
        return sum(bisect.bisect_left(data, x % (n * 3 + 11)) for x in randoms(n, seed))
    if name == 'heap_sort': return sum((i + 1) * x for i, x in enumerate(sorted(x & 65535 for x in randoms(n, seed))))
    if name == 'sieve':
        flags = bytearray(b'\x01') * (n + 1); flags[:2] = b'\0\0'
        for p in range(2, math.isqrt(n) + 1):
            if flags[p]: flags[p*p:n+1:p] = b'\0' * ((n-p*p)//p + 1)
        return sum(flags)
    if name == 'union_find':
        parent = list(range(n)); size = [1] * n
        def find(x):
            while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
            return x
        data = iter(randoms(n * 16, seed))
        for x in data:
            x, y = find(x % n), find(next(data) % n)
            if x != y:
                if size[x] < size[y]: x, y = y, x
                parent[y] = x; size[x] += size[y]
        return sum((i + 1) * (find(i) + 1) for i in range(n))
    if name == 'bfs':
        distances = [0] * n; start = seed % n; distances[start] = 1; queue = deque([start])
        while queue:
            x = queue.popleft()
            for v in ((x+1)%n, (x+n-1)%n, (x*17+13)%n):
                if not distances[v]: distances[v] = distances[x] + 1; queue.append(v)
        return sum((i + 1) * x for i, x in enumerate(distances))
    if name == 'knapsack':
        dp = [0] * (n + 1); data = iter(randoms(4096, seed))
        for weight in data:
            weight, value = weight % 31 + 1, next(data) % 1000 + 1
            for j in range(n, weight-1, -1): dp[j] = max(dp[j], dp[j-weight] + value)
        return dp[n]
    if name == 'gcd':
        data = iter(randoms(n*2, seed))
        return sum(math.gcd(x+1, next(data)+1) for x in data)
    if name == 'matrix_multiply':
        data = iter(randoms(n*n*2, seed)); aa = []; bb = []
        for x in data: aa.append(x & 255); bb.append(next(data) & 255)
        # Independent O(n^2) oracle using distributivity for the weighted checksum.
        return sum(sum(aa[i*n+k]*(i+1) for i in range(n)) * sum(bb[k*n+j]*(j+1) for j in range(n)) for k in range(n))
    raise ValueError(name)
