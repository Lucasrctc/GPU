#!/bin/bash
rm m1/*
for N in {2..10}; do for ((i=1;i<=N;i++)); do seq -s ' ' $(($i-$N)) $(($i-1))>>m1/$N.txt; done; done
