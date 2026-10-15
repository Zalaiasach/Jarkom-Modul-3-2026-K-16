#!/bin/bash
# Node: kusakabe (Audit Terminal)

echo "=== 1. Benchmark Root Web (http://jujutsu.k16.com/) ==="
ab -n 600 -c 30 http://jujutsu.k16.com/

echo ""
echo "=== 2. Benchmark API (/api) dengan Rate Limiting Aktif ==="
ab -n 600 -c 30 http://jujutsu.k16.com/api

