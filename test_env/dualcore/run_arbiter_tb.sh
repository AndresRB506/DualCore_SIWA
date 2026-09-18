#!/bin/bash

set -e

echo "=========================================="
echo "  Compilando mbc_smp_arbiter_tb"
echo "=========================================="

mkdir -p logs waves results

rm -rf simv simv.daidir csrc ucli.key *.vpd *.vcd *.log

vcs -sverilog -full64 -timescale=1ns/1ps \
    +vcs+flush+all +warn=all \
    mbc_smp_arbiter_tb.sv \
    -o simv \
    | tee logs/compile_arbiter.log

echo "=========================================="
echo "  Ejecutando simulación"
echo "=========================================="

./simv | tee logs/run_arbiter.log

echo "=========================================="
echo "  Fin"
echo "=========================================="
