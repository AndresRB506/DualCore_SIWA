####################################################################################################
# Title:	dc_setup.tcl
# 
# Description:	Restricciones y configuracion del entorno para que la herramienta Design Compiler
# 		pueda ubicar las bibliotecas 
# 				
# Dependencies: Ninguna.
# Library:	XFAB-180nm (xh018)
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
#
# Date:		20 de Febrero de 2018
# Notes: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Version:	3.01
# Revision:	18/05/2018
# 		Se parte del script .synopsys_dc.setup al cual se le eliminan las variables
#		tech_home y proy_home para que el script sea genérico para cualquier usuario.
# 		Siempre y cuando, este haya configurado de forma correcta los scripts common_setup.tcl
#		user_setup.tcl y se haya ejecutado el script: synopsys_tools.sh
#
#  Revision:	31/07/2018
#               Se apunta a un common_setup, user_setup conjunto para DC e ICC
#
####################################################################################################

set cache_read ""
set cache_write ""
 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Configuracion de las bibliotecas: Library Setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Modificacion del serch path: las "" definen una lista y permiten substitucion de varaibles
# $nombre_variable -> valor. 

#Invocar al DC desde la carpeta <proyecto>/front_end

#source $PROY_HOME/common_setup.tcl;
#source $PROY_HOME/user_setup.tcl;

set search_path "$PROY_HOME_SYN";# El comando siguente concatena al search path los directorios listados
set search_path [concat $search_path $ADDITIONAL_SEARCH_PATH];

# El comando set establece un valor para una variable. 

# Solicitud de las licencias complementarias a Design-Vision
set_app_var synlib_wait_for_design_license "DesignWare"
get_license -quantity 1 {DesignWare DC-Ultra-Opt DC-Ultra-Features DC-Expert Design-Compiler}
list_licenses

set symbol_library "$SYMBOL_LIBRARY_FILES";
set target_library "$TARGET_LIBRARY_FILES";
set synthetic_library "dw_foundation.sldb";
set link_library "* $target_library $symbol_library $synthetic_library"; #$ADDITIONAL_LINK_LIB_FILES";

set LIB_NAME_STD_CELLS "D_CELLS_HDLL_LPMOS_typ_1_80V_25C";
set LIB_NAME_PADS "IO_CELLS_F3V_LPMOS_UPF_typ_1_80V_3_30V_25C"

# Ubicacion de la biblioteca de trabajo (Work)
define_design_lib WORK -path "$PROY_HOME_SYN/work";

############ NO editar desde aqui para abajo ######## 
####################################################

echo "\n\nSettings:"
echo "search_path:       $search_path"
echo "link_library:      $link_library"
echo "target_library:    $target_library"
echo "symbol_library:    $symbol_library"
# enable_write_lib_mode; # Este comando se usa para habilitar DC para escribir bibliotecas.
# No debe ser usado, si se pretende optimizar un diseño.

# define_design_lib DEFAULT -path ./analyzed

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#  History
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

history keep 2000

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Alib for compile_ultra - Carpeta para archivos temporales para Alib
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set alib_library_analysis_path "$PROY_HOME_SYN/work"

echo "\n\n\t\tI am ready...\n"
