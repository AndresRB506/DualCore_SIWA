##################################################################################
# Title:	common_setup.tcl
# Description:	Script que contiene definidas las variables para configurar el 	
# 		proceso 
# Dependencies: dc_setup.tcl icc_setup.tcl pt_setup.tcl.
# Library:	XFAB-180nm (xh018)
# Tools:	DC L-2016.03-SP3 | ICC L-2016.03-SP3 | PT K-2015.06-SP3-3							
# Project:	TEC_RISCV								
# Author:	Reinaldo Castro Gonzalez					
# Institution:	Instituto Tecnológico de Costa Rica. DCILab.			
# Date:		23 de Febrero de 2018						
# Notes:	Basado en los scripts de la metodologia sugerida por Synopsys	
#	
# Version:	2.0								
# Revision:	17/05/2018 							
#										
##################################################################################

#puts "RM-Info: Running script [info script]\n"

##########################################################################################
## Library Setup Variables
###########################################################################################

###
# Para las siguientes variables, use un espacio en blanco para separar los nombres que ingresa.
###

# Directorio raiz del arbol de directorios de la tecnologia
set tech_home [getenv FTK_KIT_DIR]; 
set home_base "/mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end";
# Rutas adicionales que seran concatenadas a la variable search_path

#set ADDITIONAL_SEARCH_PATH "$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/dc_shell_symb/v2_1_0/ \  
#			$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_range/ \  
#			$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL/ \ 
#			$TECH_ROOT/xh018/diglibs/IO_CELLS_FC1V8/v1_0/liberty_LPMOS/v1_0_1/PVT_1_80V_1_80V_range/PVT_1_80V_1_80V_range/ \  
#			$TECH_ROOT/xh018/diglibs/IO_CELLS_FC1V8/v1_0/dc_shell_symb/v1_0_0/ \ 
#			$TECH_ROOT/xh018/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_FC1V8/ \  
#			$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/ \ 
#			$TECH_ROOT/xh018/synopsys/v7_0/TLUplus/v7_0_1";

# Target technology logical libraries
set TARGET_LIBRARY_FILES	"D_CELLS_HDLL_LPMOS_typ_1_80V_25C.db IO_CELLS_FC1V8_LPMOS_typ_1_80V_1_80V_25C.db";

# Symbol technology logical libraries
set SYMBOL_LIBRARY_FILES	"D_CELLS_HDLL.sdb IO_CELLS_FC1V8.sdb";

# Extra link logical libraries not included in TARGET_LIBRARY_FILES
set ADDITIONAL_LINK_LIB_FILES	""

# set MIN_LIBRARY_FILES		""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

# Milkyway reference libraries (include IC Compiler ILMs here)
set MW_REFERENCE_LIB_DIRS	"$tech_home/xh018/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_FC1V8/ $tech_home/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL";

# set MW_REFERENCE_CONTROL_FILE     "";	# Reference Control file to define the Milkyway reference libs

set TECH_FILE                     "xh018_xx43_HD_MET4_METMID_METTHK.tf" ;	# Milkyway technology file
set MAP_FILE                      "xh018_xx43_MET4_METMID_METTHK.map";		# Mapping file for TLUplus
set TLUPLUS_MAX_FILE              "xh018_xx43_MET4_METMID_METTHK_max.tlu";	# Max TLUplus file
set TLUPLUS_MIN_FILE              "xh018_xx43_MET4_METMID_METTHK_min.tlu";	# Min TLUplus file

set MIN_ROUTING_LAYER            "MET1";	# Min routing layer
set MAX_ROUTING_LAYER            "METTPL";	# Max routing layer

# set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

#puts "RM-Info: Completed script [info script]\n"
