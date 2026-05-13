###################################################################################
# Title:	xfab_mw_rams.tcl
# Description:	Script de compilacion en la herramienta Milkyway de Synopsys para 
# 		generar la biblioteca fisica de las memorias SRAM para el microcon-
#		trolador RISC-V 
# Dependencies: Ninguna.
# Project:	Microcontrolador RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		20 de Junio de 2018
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.1
# Revision:	20/06/2018
#Revision:	23/08/2018 ACR Se ajusta a proyecto TOP del RISC-V
###################################################################################

###################################################################################
# Variables y punteros para la compilacion y generacion de la biblioteca Milkyway #
###################################################################################

# Directorio raiz del arbol de directorios de la tecnologia
set TECH_ROOT [getenv FTK_KIT_DIR]; # Se solicita la variable de sistema creada en el script synopsys_tools.sh

set  TECH_FILE "$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_2/xh018-synopsys-techMW-v6_3_1_2/xh018_xx43_HD_MET4_METMID_METTHK.tf"

set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/achacon/imd/micro_hdl/TEC_RISCV/Top_Phy"

# Ruta para ubicar las bibliotecas logicas (.db) de las memorias RAM. Si no se han generado, deben
# ser compiladas a partir del archivo liberty (.lib) mediante la herramienta library_compiler
set DB_HOME "$PROY_HOME/back_end/db";

# Ruta relativa, generica, para ubicar o guardar la base de datos (mw) sintetizada.
# Conviene algo como: /.../db/be/rams 
set LIB_HOME "$PROY_HOME/back_end/db";
set LIB_NAME "XSPRAMLP_2048X32_M8P_UPF_typ_1_80V_25C.mw";
# Nombre de la biblioteca. Se recomienda algo como: XFAB_TEC_RISCV_RAMS.mw.

# Ruta relativa para ubicar el archivo de la informacion de layout de la tecnologia empleada.
# Debe construirse a partir del archivo de tecnologia .tf


#set TECH_LEF $TECH_ROOT/xh018/diglibs/D_CELLS_HDLL/v2_1/LEF/v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL_mprobe.lef;

# Ruta relativa de la ubicacion de los archivos del layout de las memorias generadas, ver nota 1.
set LEF_HOME "$TECH_ROOT/xh018/spram/XSPRAMLP_2048X32_M8P/v3_1_1/xh018_1143_LPMOS_MET4_METMID_METTHK/LEF";

# Ruta relativa al archivo que valida la nominación de las capas de metales, ver nota 1.
##### 
#   OJOJOJOJOJO Arreglar para version con script pearl. Revisar final de nota 1 (ACR 23-8-2018)
#####
set LAYER_MAP "$PROY_HOME/back_end/db/xh018_xx43_HD_MET4_METMID_METTHK_lef_in_layer_map.txt"

# Pequenna rutina de validacion y creacion de la biblioteca fisica de las memorias. Se maneja la excepcion
# de que ya exista la biblioteca.

set CHECK_LIB [file exists "$LIB_HOME/$LIB_NAME"];

if {$CHECK_LIB == 0} {
	# Se crea la biblioteca pues no existe, y luego se abre para ser escrita. 
	create_mw_lib "$LIB_HOME/$LIB_NAME" -technology $TECH_FILE;
	open_mw_lib "$LIB_HOME/$LIB_NAME";
} else {
	# La biblioteca ya existe; por lo tanto, solo se abre.
	open_mw_lib "$LIB_HOME/$LIB_NAME";
}

# Se leen los archivos *.lef para ser integrados a la nueva biblioteca, validados de acuerdo con la
# biblioteca fisica de la tecnología que se usa.

#### OJO 
## Primero necesitamos crear los TECH_LEF_FILES 
## Al rato el LEF que da XFAB ya viene con esos. Probamos primero con ese

#read_lef -lib_name $LIB_NAME -cell_version overwrite -tech_lef_files $TECH_LEF -cell_lef_files \
read_lef -lib_name $LIB_NAME -cell_version overwrite -tech_lef_files $LEF_HOME/XSPRAMLP_2048X32_M8P.lef -cell_lef_files \
$LEF_HOME/XSPRAMLP_2048X32_M8P.lef -layer_mapping $LAYER_MAP;

# Repetir el comando anterior para tantas rams como se hayan creado

# Una vez integrados los layouts de las rams generadas a la biblioteca, se deben actualizar los puertos
# de las mismas para que al ser invocadas las celdas como hardmacros en un diseño posterior sea posible
# conectarlas.

update_mw_port_by_db -mw_lib $LIB_NAME -db_file "$DB_HOME/XSPRAMLP_2048X32_M8P_UPF_typ_1_80V_25C.db";

# Repetir el comando anterior para tantas rams como se hayan creado


#######################################################################################################

# Nota 1: Es importante editar los archivos *.lef de las rams para que los nombres de los metales 
# coincidan con los del  *_lef_in_map_layer.txt, por ejemplo el .lef de las memorias podria nombrar al 
# metal del nivel 4 como "M4", pero en la tecnología este metal se llama "MET4", por lo que cada
# aparición de M4 debe ser remplazada por MET4.Lo mismo en el caso de las vias.

# El archivo *_lef_in_map_layer.txt fue creado por el Ing. Reinaldo Castro. Abstrayendo la informacion
# del archivo de la tecnologia (.tf). Este archivo consiste en una tabla con el nombre de la capa y su
# numero de identificacion en la biblioteca de la tecnologia.

# (ACR = Agosto 2018) Para crear el archivo este archuvo utilice el script pearl provisto por SolvNet
#Llamado lef_layer_tf_number mapper.pl <tech_file_name>.tf lef_file_name.lef
#Para detalles, ver Library Data Preparation for IC Compiler User Guide 

#######################################################################################################


