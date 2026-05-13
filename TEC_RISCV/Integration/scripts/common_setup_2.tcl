##################################################################################
# Title:	common_setup.tcl
# Description:	Script que contiene definidas las variables para configurar el 	
# 		proceso 
# Dependencies: Ninguna.
# Library:	XFAB-180nm (xh018)
# Tools:	DC L-2016.03-SP3 | ICC II L-2016.03-SP3 | PT K-2015.06-SP3-3							
# Project:	TEC_RISCV								
# Author:	Reinaldo Castro Gonzalez					
# Institution:	Instituto Tecnológico de Costa Rica. DCILab.			
# Date:		23 de Febrero de 2018						
# Notes:	Basado en los scripts de la metodologia sugerida por Synopsys	
#	
# Version:	1.0								
# Revision:	16/05/2022 Update after crash by RMR 							
#										
##################################################################################

puts "RM-Info: Running script [info script]\n"

##########################################################################################
## Library Setup Variables
###########################################################################################

###
# Para las siguientes variables, use un espacio en blanco para separar los nombres que ingresa.
###

# Directorio raiz del arbol de directorios de la tecnologia
#set TECH_ROOT			"/mnt_vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/xh018";
set TECH_ROOT			"/mnt/vol_NFS_rh003/xfab_pdks/design/xkit/xh018";

# Rutas adicionales que seran concatenadas a la variable search_path
#set ADDITIONAL_SEARCH_PATH	"$TECH_ROOT/diglibs/D_CELLS_LL/v2_0/dc_shell_symb/v2_0_0 \
#				$TECH_ROOT/diglibs/D_CELLS_LL/v2_0/liberty_LP5MOS/v2_0_3/PVT_1_80V_range \
#				$TECH_ROOT/diglibs/IO_CELLS_C1V8/v1_2/liberty_LP5MOS/v1_2_1/PVT_1_80V_1_80V_range \
#				$TECH_ROOT/diglibs/IO_CELLS_C1V8/v1_2/dc_shell_symb \
#				$TECH_ROOT/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1 \
#				$TECH_ROOT/synopsys/v6_0/TLUplus/v6_3_1_1 ";
set ADDITIONAL_SEARCH_PATH	"$TECH_ROOT/diglibs/D_CELLS_LL/v2_0/dc_shell_symb/v2_0_0 \
				$TECH_ROOT/diglibs/D_CELLS_LL/v2_0/liberty_LP5MOS/v2_0_3/PVT_1_80V_range \
				$TECH_ROOT/diglibs/IO_CELLS_C1V8/v1_2/liberty_LP5MOS/v1_2_1/PVT_1_80V_1_80V_range \
				$TECH_ROOT/diglibs/IO_CELLS_C1V8/v1_2/dc_shell_symb \
				$TECH_ROOT/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1 \
				$TECH_ROOT/synopsys/v6_0/TLUplus/v6_3_1_1 ";

# Target technology logical libraries
set TARGET_LIBRARY_FILES	"D_CELLS_LL_LP5MOS_typ_1_80V_25C.db";
# Extra link logical libraries not included in TARGET_LIBRARY_FILES
set ADDITIONAL_LINK_LIB_FILES	"D_CELLS_LL.sdb";

set MIN_LIBRARY_FILES		""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

# Milkyway reference libraries (include IC Compiler ILMs here)
set MW_REFERENCE_LIB_DIRS	"$TECH_ROOT/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx51_MET5_METMID_IO_CELLS_FC1V8 \
				$TECH_ROOT/diglibs/D_CELLS_LL/v1_1/synopsys_ICC/v1_1_3/xh018-D_CELLS_LL-synopsys_ICC-v1_1_3/xh018_xx51_MET5_METMID_D_CELLS_LL";

set MW_REFERENCE_CONTROL_FILE     "";	# Reference Control file to define the Milkyway reference libs

set TECH_FILE                     "xh018_xx51_MET5_METMID.tf" ;	# Milkyway technology file
set MAP_FILE                      "xh018_xx51_MET5_METMID.map";		# Mapping file for TLUplus
set TLUPLUS_MAX_FILE              "xh018_xx51_MET5_METMID_max.tlu";	# Max TLUplus file
set TLUPLUS_MIN_FILE              "xh018_xx51_MET5_METMID_min.tlu";	# Min TLUplus file

set MIN_ROUTING_LAYER            "MET1";	# Min routing layer
set MAX_ROUTING_LAYER            "METTP";	# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

puts "RM-Info: Completed script [info script]\n"

