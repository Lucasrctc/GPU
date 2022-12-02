#!/bin/bash
rm m2/*
for N in {99999..100000}; do for ((i=1;i<=N;i++)); do seq -s ' ' $(($N-$i)) $((2*$N - $i - 1))>>m2/$N.txt; done; done
