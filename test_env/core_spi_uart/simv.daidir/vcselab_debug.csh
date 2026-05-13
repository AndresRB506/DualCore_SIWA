#!/bin/csh -f

cd /mnt/vol_NFS_rh003/profesores/rmolina/riscv_test_fpga_ver/Verificacion_RISCV_TEC/test_env/core_spi_uart

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/mnt/vol_NFS_Pivot/rmolina_installation_files/tools/synopsys/vcs/R-2020.12-SP2/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

