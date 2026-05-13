#!/bin/bash

g++ test.cpp -o test
./test
source bash_snps_xt018-AMS_2017

cd /mnt/vol_NFS_Zener/WD_ESPEC/jmontero/regresion/Verificacion_RISCV_TEC/test_env/regression
git pull origin master

cd /mnt/vol_NFS_Zener/WD_ESPEC/jmontero/regresion/Verificacion_RISCV_TEC/test_env/regression/ALU
vcs -full64 -ova_cov -cm line+cond+fsm+tgl+path+assert+branch+property_path -cm_pp -cm_report unencrypted_hierarchies+svpackages+noinitial -lca -debug_all -timescale=1ns/1ns +vcs+flush+all +warn=all -debug_access+r -sverilog +incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS design.sv testbench.sv
./simv +ntb_random_seed=43285432 -cm line+cond+fsm+tgl+assert+branch+property_path +UVM_TESTNAME=alu_crazy_test
