set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/rgarcia/GIT/TEC_RISCV/TOP_PHY_PR";
#set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/achacon/imd/micro_hdl/FIRST_SPIN_RDY/TEC_RISCV/TOP_PHY_PR";
#Definimos una variable para cuando queremos recompilar desde cero
set COMPLETE_COMPILE 1
set CHECK_ONLY 0 
source $PROY_HOME/common_setup_typ_no_hv.tcl;
#source $PROY_HOME/common_setup_typ.tcl;
source $PROY_HOME/user_setup.tcl;
source ./scripts/dc_setup.tcl;
#source ./scripts/analyze_rtl.tcl;
source ./scripts/analyze_rtl_lv.tcl;
#source ./scripts/dc_syn.tcl;
source ./scripts/dc_syn_lv.tcl;
#source ./scripts/dc_syn_no_upf.tcl;


