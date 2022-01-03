#!/bin/sh

for i in $(seq 1 13); do
    n=$(printf "%02d" $i)
    mkdir reading$n
    cat > reading$n/README.md <<EOF
# Reading $n
EOF
done

for p in $(seq 1 9); do
    n=$(printf "%02d" $p)
    mkdir homework$n
    cat > homework$n/README.md <<EOF
# Homework $n
EOF
done

for i in $(seq 1 3); do
    n=$(printf "%02d" $i)
    mkdir exam$n
    cat > exam$n/README.md <<EOF
# Exam $n
EOF
done
