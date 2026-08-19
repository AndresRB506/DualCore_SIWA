#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "  Compilando shared_memory_smoke_tb"
echo "=========================================="

mkdir -p logs waves results

rm -rf simv simv.daidir csrc ucli.key *.vpd *.vcd *.log

vcs -sverilog -full64 -timescale=1ns/1ps \
    +vcs+flush+all +warn=all \
    +incdir+../../TEC_RISCV/CPU \
    +incdir+../../TEC_RISCV/MBC \
    +incdir+../../TEC_RISCV/BUS_Micro \
    +incdir+../../TEC_RISCV/TOP \
    +incdir+../../TEC_RISCV/DECO_INSTR \
    +incdir+../../TEC_RISCV/ALU \
    +incdir+../../TEC_RISCV/Register_File \
    shared_memory_smoke_tb.sv \
    -o simv \
    | tee logs/compile_shared_memory_smoke.log

echo "=========================================="
echo "  Ejecutando simulación"
echo "=========================================="

./simv | tee logs/run_shared_memory_smoke.log

echo "=========================================="
echo "  Fin"
echo "=========================================="
