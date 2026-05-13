###################################################################################################
### Title:		crear_mw.tcl							 
### Description:	Script que crea la base de datos Milkyway para el Galaxy de Synopsys
### 			contiene las referenicas de las bibliotecas fisicas de la tecnologia	 
### Dependencies: 	Ninguna. 								 
### Project:		Microcontrolador RISCV							 
### Author:		Reinaldo Castro Gonzalez						 
### Institution:	Instituto Tecnologico de Costa Rica. DCILab				 
### Date:		26 de Febrero de 2018							 
### Notes:		Se debe correr el script common_setup.tcl antes									 
### Version:		2.0									 
### Revision:		23/05/2018								 
####################################################################################################

# Especificar los archivos TLUplus, que son utilizados para extraer el archivo ".spef" (capacitancias parasitas)
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE -min_tluplus $TLUPLUS_MIN_FILE -tech2itf_map $MAP_FILE

set MW_DESIGN_LIBRARY_NAME $PROY_HOME_PHY/libs/$DESIGN_NAME.mw; # Esta ruta debe existir

# Se comprueba si existe la biblioteca mw, si esta la abre, si no la crea.
set comprobar_lib [file exists $MW_DESIGN_LIBRARY_NAME];
if {$comprobar_lib == 0} { 
# Se crea la db de cero
create_mw_lib -technology $TECH_FILE -mw_reference_library $MW_REFERENCE_LIB_DIRS -hier_separator {/}  -bus_naming_style {[%d]} $MW_DESIGN_LIBRARY_NAME;
open_mw_lib $MW_DESIGN_LIBRARY_NAME
} else { 
# Se abre la libreria
open_mw_lib $MW_DESIGN_LIBRARY_NAME}
puts "Se abrio la base de datos $DESIGN_NAME.mw"
