source /mnt/vol_synopsys2023/scripts/synopsys_tools.sh;

python3.9 memory.py /mnt/vol_NFS_rh003/estudiantes/Javier_Espinoza/Verificacion_RISCV_TEC/test_env/core_spi_uart/Test_Files/Assembly_Code/Aritmeticas/add.o.txt

vcs -kdb -ova_cov -cm line+cond+fsm+tgl+assert+branch+property_path -ntb_opts uvm-1.2 -cm_report unencrypted_hierarchies+svpackages+noinitial -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 -P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a +incdir+../../Verificacion_RISCV_TEC/TEC_RISCV/TOP +incdir+../../TEC_RISCV/SPI +incdir+../../TEC_RISCV/UART -CFLAGS -DVCS testbench.svh -o salida +UVM_VERBOSITY=UVM_DEBUG
