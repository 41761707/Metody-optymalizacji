#!/bin/bash
for FILENAME in instancias1a100/*; do 
    arrIN=(${FILENAME//// })
    number=(${arrIN[1]//./ })
    SOLUTION="solutions/${number[0]}CPLEX.txt"
    echo "${FILENAME}"
    julia zad.jl $FILENAME $SOLUTION >> results.txt
done