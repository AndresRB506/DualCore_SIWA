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
# Version:	2.1								
#  Revision:	17/08/2018. ACR. Incorporacion versiones 7.0.3 IC Validator, 6.3.2.1 Milkyway. Ajuste a estructura nueva archivos. 
#  Revision:	02/09/2018. ACR, MO, Incorporacion bibliotecas PADs, 3.3, celdas HDMV para level shifters. 						
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
set TECH_ROOT [getenv FTK_KIT_DIR]; 
# Se solicita la variable de sistema creada en el script synopsys_tools.sh

# Rutas adicionales que seran concatenadas a la variable search_path

set ADDITIONAL_SEARCH_PATH "$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/dc_shell_symb/v2_1_0 \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_range \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL \
$TECH_ROOT/xh018/diglibs/IO_CELLS_F3V/v2_1/dc_shell_symb/v2_1_0  \
$TECH_ROOT/xh018/diglibs/IO_CELLS_F3V/v2_1/liberty_UPF_LPMOS/v2_1_0/PVT_1_80V_3_30V_range \
$TECH_ROOT/xh018/diglibs/IO_CELLS_F3V/v2_1/synopsys_ICC/v2_1_0/xh018-IO_CELLS_F3V-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_F3V \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDMV/v2_1/dc_shell_symb/v2_1_0 \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDMV/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDMV/v2_1/liberty_LPMOS/v2_1_0/PVT_3_30V_1_80V_range \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDMV/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDMV-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDMV \
$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_2/xh018-synopsys-techMW-v6_3_1_2 \
$TECH_ROOT/xh018/synopsys/v7_0/TLUplus/v7_0_1 \
$TECH_ROOT/xh018/synopsys/v7_0/ICValidator/v7_0_3 \
$PROY_HOME/back_end/db";# \
#$PROY_HOME/front_end/db/QTM/";

#En la ultima direccion tenemos los archivos Liberty para la SRAM

# Target technology logical libraries 
# Incluir las direcciones a los db de la memoria
#Falta meter los casos esquina
set TARGET_LIBRARY_FILES "D_CELLS_HDLL_LPMOS_typ_1_80V_25C.db \
D_CELLS_HDMV_LS3VD_LPMOS_typ_1_80V_3_30V_25C.db  \
D_CELLS_HDMV_LSU3V_LPMOS_typ_1_80V_3_30V_25C.db \
IO_CELLS_F3V_LPMOS_UPF_typ_1_80V_3_30V_25C.db \
XSPRAMLP_2048X32_M8P_UPF_typ_1_80V_25C.db";# \
#ucu_anlg.db";

# Symbol technology logical libraries
set SYMBOL_LIBRARY_FILES       "D_CELLS_HDLL.sdb IO_CELLS_F3V.sdb D_CELLS_HDMV.sdb";

# Extra link logical libraries not included in TARGET_LIBRARY_FILES
#Incluimos la SRAM

#set ADDITIONAL_LINK_LIB_FILES   "XSPRAMLP_2048X32_M8P_UPF_typ_1_80V_25C.db"

# set MIN_LIBRARY_FILES		""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

# Milkyway reference libraries (include IC Compiler ILMs here)
# Deben colocarse los casos esquina
set MW_REFERENCE_LIB_DIRS "$TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL \
$TECH_ROOT/xh018/diglibs/D_CELLS_HDMV/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDMV-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDMV \
$TECH_ROOT/xh018/diglibs/IO_CELLS_F3V/v2_1/synopsys_ICC/v2_1_0/xh018-IO_CELLS_F3V-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_F3V \
$PROY_HOME/back_end/db/XSPRAMLP_2048X32_M8P_UPF_typ_1_80V_25C.mw";


# set MW_REFERENCE_CONTROL_FILE     "";	# Reference Control file to define the Milkyway reference libs

set TECH_FILE "$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_2/xh018-synopsys-techMW-v6_3_1_2/xh018_xx43_HD_MET4_METMID_METTHK.tf" ;# Milkyway technology file
set MAP_FILE  "$TECH_ROOT/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK.map";		# Mapping file for TLUplus
set TLUPLUS_MAX_FILE "$TECH_ROOT/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK_max.tlu";	# Max TLUplus file
set TLUPLUS_MIN_FILE "$TECH_ROOT/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK_min.tlu";	# Min TLUplus file

set GDS_MAP_FILE "$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_2/xh018-synopsys-techMW-v6_3_1_2/xh018_out.map"


set MIN_ROUTING_LAYER   "MET1";	# Min routing layer
set MAX_ROUTING_LAYER    "METTPL";	# Max routing layer

# set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

puts "RM-Info: Completed script [info script]\n"

