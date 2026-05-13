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
# Revision:	23/08/2018 (ACR)
#
####################################################################################################

set cache_read ""
set cache_write ""

#source $PROY_HOME/common_setup.tcl;
#source $PROY_HOME/user_setup.tcl;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Configuracion de las bibliotecas: Library Setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Modificacion del serch path: las "" definen una lista y permiten substitucion de varaibles
# $nombre_variable -> valor. 

set search_path "$PROY_HOME_PHY";# El comando siguente concatena al search path los directorios listados
set search_path [concat $search_path $ADDITIONAL_SEARCH_PATH];

# El comando set establece un valor para una variable. 

# Solicitud de las licencias complementarias a Design-Vision
#set_app_var synlib_wait_for_design_license "DesignWare"
#get_license -quantity 1 {DesignWare DC-Ultra-Opt DC-Ultra-Features DC-Expert Design-Compiler}
#list_licenses

set symbol_library "$SYMBOL_LIBRARY_FILES";
set target_library "$TARGET_LIBRARY_FILES";
set synthetic_library "dw_foundation.sldb";

#Anadimos la biblioteca con la SRAM
set link_library "* $target_library $symbol_library $synthetic_library";
#set link_library "* $target_library $symbol_library $synthetic_library $ADDITIONAL_LINK_LIB_FILES";


# Ubicacion de la biblioteca de trabajo (Work)
#define_design_lib WORK -path "$PROY_HOME_PHY/work";

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
