##################################################################################
# Title:	user_setup.tcl
# Description:	Script que contiene definidas las variables para configurar el 	
# 		proyecto de sintesis de un usuario 
# Dependencies: dc_setup.tcl, analyze_rtl.tcl.
# Library:	XFAB-180nm (xh018)
# Tools:	DC L-2016.03-SP3 | ICC L-2016.03-SP3 | PT K-2015.06-SP3-3							
# Project:	TEC_RISCV								
# Author:	Reinaldo Castro Gonzalez					
# Institution:	Instituto Tecnológico de Costa Rica. DCILab.			
# Date:		17 de Mayo de 2018						
# Notes:	Basado en los scripts de la metodologia sugerida por Synopsys	
#	
# Version:	1.01								
# Revision:	31/07/2018 ACR							
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

# Ingrese la direccion absoluta al directorio base del proyecto
# Primero las variables generales
# Ejemplo: set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/$user_name/repositorios/TEC_RISCV/Integration";
#set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/achacon/imd/micro_hdl/TEC_RISCV/ALU_Phy"; 
set PROY_HOME_SYN "$PROY_HOME/front_end";		
set DESIGN_NAME "Tec_Riscv_pads";	# Ingrese el nombre del proyecto. Ejemplo "ac97";
set SOURCE_HOME_SYN "$PROY_HOME_SYN/source";
set TOP_FILE "$SOURCE_HOME_SYN/TOP_PADS/top_riscv_tec_pads.sv";
set TOP_MODULE "top_riscv_tec_pads";
set TEST_INST_NAME "top_riscv_tec_pads"; ## Revisar. Corregir para generar SAIF
set UUT_INST_NAME "uut";

# Variables para el ICC
set PROY_HOME_PHY "$PROY_HOME/back_end";
set SOURCE_HOME_PHY "$PROY_HOME_PHY/source";
set DB_HOME_PHY "$PROY_HOME_PHY/db"

## El <design>.ddc, <design>.v y <design>.sdc los traemos directamente de las carpetas de sintesis logica
set TOP_FILE_SYN "$SOURCE_HOME_SYN/$DESIGN_NAME\_syn.v";
set TOP_FILE_SYN_PG "$SOURCE_HOME_SYN/$DESIGN_NAME\_syn_pg.v";
set TOP_FILE_DDC "$PROY_HOME_SYN/db/$DESIGN_NAME.ddc";
set TOP_FILE_SDC "$PROY_HOME_SYN/db/$DESIGN_NAME\_syn.sdc";
set TOP_FILE_SDF "$PROY_HOME_SYN/db/$DESIGN_NAME\_syn.sdf";

## Archivos de diseno fisico final
set TOP_FILE_PHY "$DB_HOME_PHY/$DESIGN_NAME\_phy.v";
set TOP_FILE_PHY_NO_PG "$DB_HOME_PHY/$DESIGN_NAME\_phy_no_pg.v";
set TOP_FILE_PHY_DDC "$DB_HOME_PHY/$DESIGN_NAME.ddc";
set TOP_FILE_PHY_SDC "$DB_HOME_PHY/$DESIGN_NAME\_phy.sdc";
set TOP_FILE_PHY_SDF "$DB_HOME_PHY/$DESIGN_NAME\_phy.sdf";
set TOP_FILE_PHY_SPEF "$DB_HOME_PHY/$DESIGN_NAME\_phy.spef";
set TOP_FILE_PHY_DEF "$DB_HOME_PHY/$DESIGN_NAME\_phy.def";
set TOP_FILE_GDS "$PROY_HOME_PHY/$DESIGN_NAME\_phy.gds"


#Vamos a colocar los archivos de mapee MW-gds y de reglas en el directorio donde correra el ICV
#set TECH_GDS_MAP_FILE "$PROY_HOME_PHY/db/signoff_drc_run/xh018_out.map"; #Archivo mapeo MW GDS
set TECH_GDS_MAP_FILE "$TECH_ROOT/xh018/synopsys/v7_0/techMW/v7_0_1/xh018-synopsys-techMW-v7_0_1/xh018_out.map"; #Archivo mapeo MW GDS
#set TECH_RUNSET_FILE "$PROY_HOME_PHY/db/signoff_drc_run/xh018_1143_DRC_MET4_METMID_METTHK.rs" ;#Archivo reglas proceso ICV
set TECH_RUNSET_FILE "$TECH_ROOT/xh018/synopsys/v7_1/ICValidator/v7_1_1/xh018_1143_DRC_MET4_METMID_METTHK.rs" 
set TECH_RUNSET_DIR "$TECH_ROOT/xh018/synopsys/v7_1/ICValidator/v7_1_1" 


#EOF
