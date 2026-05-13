###################################################################################################
### Title:		crear_mw.tcl							 
### Description:	Script que crea la base de datos Milkyway para el Galaxy de Synopsys
### 			contiene las referenicas de las bibliotecas fisicas de la tecnologia	 
### Dependencies: 	Ninguna. 								 
### Project:		Microcontrolador RISCV							 
### Author:		Reinaldo Castro González						 
### Institution:	Instituto Tecnologico de Costa Rica. DCILab				 
### Date:		26 de Febrero de 2018							 
### Notes:											 
### Version:		1.0									 
### Revision:		26/02/2018								 
####################################################################################################

set proy_name "proyecto.mw"; #Reemplazar por el nombre del proyecto
set proy_home "$PDW"; # Reemplazar por la direccion del directorio de su proyecto. Por defecto se asume el directorio actual.
set design_home "$PWD"; #Reemplazar por la direccion del ditectorio de su diseno, que puede diferir de la del proyecto
set tech_home "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/xh018";
set search_path [concat $search_path $tech_home/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/ \
						$tech_home/synopsys/v6_0/TLUplus/v6_3_1_1/ \
						$tech_home/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/ \
						$tech_home/diglibs/D_CELLS_LL/v1_1/synopsys_ICC/v1_1_3/xh018-D_CELLS_LL-synopsys_ICC-v1_1_3/];

# Configurar el archivo de la tecnología
set mw_tech_file $tech_home/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/xh018_xx51_HD_MET5_METMID.tf;

# Configurar la biblioteca de referencia. Escoger alguno de los dos metodos siguientes

# Metodo 1. Definiendo la variable de biblioteca de referencia
set mw_reference_library [concat $tech_home/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx51_MET5_METMID_IO_CELLS_FC1V8\
$tech_home/diglibs/D_CELLS_LL/v1_1/synopsys_ICC/v1_1_3/xh018-D_CELLS_LL-synopsys_ICC-v1_1_3/xh018_xx51_MET5_METMID_D_CELLS_LL;

# Metodo 2. Referencia directa.
#set_mw_lib_reference [concat $tech_home/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx51_MET5_METMID_IO_CELLS_FC1V8\
#$tech_home/diglibs/D_CELLS_LL/v1_1/synopsys_ICC/v1_1_3/xh018-D_CELLS_LL-synopsys_ICC-v1_1_3/xh018_xx51_MET5_METMID_D_CELLS_LL;

# Notar que se concatenan 2 direcciones a bibliotecas, la primera es a la de celdas I/O y la segunda es para las celdas low leakage

# Especificar los archivos TLUplus son utilizados para extraer el archivo ".spef" (capacitancias parásitas)
set_tlu_plus_files -max_tluplus xh018_xx51_MET5_METMID_max.tlu -min_tluplus xh018_xx51_MET5_METMID_min.tlu -tech2itf_map xh018_xx51_MET5_METMID.map

set mw_design_library_name $design_home/$proy_name.mw

# Se comprueba si existe la biblioteca mw, si esta la abre, si no la crea.
set comprobar_lib [file exists $mw_design_library_name];
if {$comprobar_lib == 0} { 
# Se crea la db de cero
create_mw_lib -technology $mw_tech_file -mw_reference_library $mw_reference_library $mw_design_library_name
open_mw_lib $mw_design_library_name
} else { 
# Se abre la libreria
open_mw_lib $mw_design_library_name}
puts "Se abrio la base de datos"
