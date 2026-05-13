#!/bin/bash

echo $(date)

echo "Bash"
cd /mnt/vol_NFS_Zener/WD_ESPEC/jmontero
source bash_snps_xt018-AMS_2017

echo "Redireccionando carpeta"
cd regresion/Verificacion_RISCV_TEC/test_env/regression/ALU

echo "Compilando"
vcs -l "file1.log" -full64 -ova_cov -cm line+cond+fsm+tgl+path+assert+branch+property_path -cm_pp -cm_report unencrypted_hierarchies+svpackages+noinitial -lca -debug_all -timescale=1ns/1ns +vcs+flush+all +warn=all -debug_access+r -sverilog +incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS design.sv testbench.sv

echo "Simulando"
./simv -l "file2.log" +ntb_random_seed=43285432 -cm line+cond+fsm+tgl+assert+branch+property_path +UVM_TESTNAME=test_alu
