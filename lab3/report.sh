#!/bin/bash
# usage: ./report.sh access.log
log=$1

if [ ! -f "$log" ]; then
    echo "no such file: $log" >&2
    exit 1
fi

total=$(wc -l < "$log")
fails=$(grep -c FAIL "$log")
echo "$total requests, $fails failed"

for i in {0..6}; do
    count=$(grep FAIL "$log" | grep -c "user$i")
    echo "user$i: $count failures"
done
