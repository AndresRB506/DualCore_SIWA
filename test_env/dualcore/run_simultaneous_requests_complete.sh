#!/bin/bash

set -euo pipefail

echo "=============================================="
echo "  Compilando simultaneous_requests_complete_tb"
echo "=============================================="

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
    simultaneous_requests_complete_tb.sv \
    -o simv \
    | tee logs/compile_simultaneous_requests_complete.log

echo "=============================================="
echo "  Ejecutando simulacion"
echo "=============================================="

./simv | tee logs/run_simultaneous_requests_complete.log

echo "=============================================="
echo "  Fin"
echo "=============================================="

