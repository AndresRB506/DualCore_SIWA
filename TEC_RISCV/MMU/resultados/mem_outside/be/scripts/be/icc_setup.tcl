
####################################################################################################
# Title:	icc_setup.tcl
# 
# Description:	Restricciones y configuracion del entorno para que la herramienta IC Compiler
# 		pueda ubicar las bibliotecas 
# 				
# Dependencies: Ninguna.
# Library:	XFAB-180nm (xh018)
# Tools:	ICC L-2016.03-SP3
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
#
# Date:		23 de Mayo de 2018
# Notes: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Version:	1.0
# Revision:	23/05/2018
#
####################################################################################################

set cache_read ""
set cache_write ""
 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Configuracion de las bibliotecas: Library Setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Modificacion del serch path: las "" definen una lista y permiten substitucion de varaibles
# $nombre_variable -> valor. 

set search_path "$home_base";

set search_path [concat $search_path ./scripts ./db ./sources ./reports \
				        "$tech_home/xh018/diglibs/D_CELLS_HDLL/v2_1/dc_shell_symb/v2_1_0\ 
					$tech_home/xh018/diglibs/D_CELLS_HDLL/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_range\
					$tech_home/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL
					$tech_home/xh018/diglibs/IO_CELLS_FC1V8/v1_0/liberty_LPMOS/v1_0_1/PVT_1_80V_1_80V_range\
					$tech_home/xh018/diglibs/IO_CELLS_FC1V8/v1_0/dc_shell_symb/v1_0_0/\
					$tech_home/xh018/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_FC1V8\
					$tech_home/xh018/synopsys/v6_3/techMW/v6_3_1_1\
					$tech_home/xh018/synopsys/v7_0/TLUplus/v7_0_1"];

# El comando siguente concatena al search path los directorios listados
#set search_path [concat $search_path $ADDITIONAL_SEARCH_PATH];

# El comando set establece un valor para una variable. 

set target_library "$TARGET_LIBRARY_FILES";
set link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#  Aliases
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

alias h history
alias rc "report_constraint -all_violators"
alias rt report_timing
alias ra report_area
alias page_on {set sh_enable_page_mode true}
alias page_off {set sh_enable_page_mode false}
alias fr "remove_design -designs"

echo "\n\n\t\tI am ready...\n"
