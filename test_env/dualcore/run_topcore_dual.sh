#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "  Compilando topcore_dual_tb"
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
    +incdir+../../TEC_RISCV/SPI \
    +incdir+../../TEC_RISCV/UART \
    +incdir+../../TEC_RISCV/UART/scrs \
    topcore_dual_tb.sv \
    -o simv \
    | tee logs/compile_topcore_dual.log

echo "=========================================="
echo "  Ejecutando simulación"
echo "=========================================="

./simv +RUNTIME_CYCLES=1000 \
    | tee logs/run_topcore_dual.log

echo "=========================================="
echo "  Fin"
echo "=========================================="
