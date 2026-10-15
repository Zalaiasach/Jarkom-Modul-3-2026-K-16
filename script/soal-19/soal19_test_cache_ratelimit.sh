#!/bin/bash
# Verifikasi Soal 19 dari Klien (kusakabe)

echo "--- Uji Caching Frontend ---"
echo "Request 1:"
curl -i http://jujutsu.k16.com/ | grep "X-Cache-Status"

echo "Request 2:"
curl -i http://jujutsu.k16.com/ | grep "X-Cache-Status"

echo ""
echo "--- Uji Rate Limiting 10 r/s (Burst Request ke /api) ---"
for i in $(seq 1 15); do curl -s -o /dev/null -w "%{http_code} " http://jujutsu.k16.com/api; done
echo ""

