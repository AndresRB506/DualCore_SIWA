########################################################################################################
# Title:        pad_insertion.tcl
# Description:  Script para la insercion de PADs de I/O
# Dependencies: Ninguna.
# Library:	XFAB-180nm (xh018) HDLL
# Tools:	DC L-2016.03-SP3 | ICC L-2016.03-SP3 | PT K-2015.06-SP3-3							
# Project:	TEC_RISCV								
# Author:       Reinaldo Castro Gonzalez
# Institution:  Instituto Tecnológico de Costa Rica. DCILab.
# Date:         29 de Enero de 2018
# Notes:        
#               
# Version:      1.0
# Revision:     30/01/2018
#
########################################################################################################

puts "RM-Info: Running script [info script]\n"

# Definicion las variables necesarias para ubicar y colocar los PADs
# Nombre de la biblioteca de I/O de la tecnologia. Esta debe estar asignada en las variables search_path
# y target_library.

set io_library "IO_CELLS_FC1V8_LPMOS_UPF_typ_1_80V_1_80V_25C"; # Nombre de la biblioteca de Pads de I/O
					#Utilizaremos el formato liberty UPF para poder crear dominios separados de voltaje
set input_pad "APR01PA";		# Nombre de la celda para los puertos de entrada(RPullUp/PullDown~1kohm)
set output_pad "BD1PA";			# Nombre de la celda para los puertos de salida	(Open Drain Buffer~1mA)
set in_pad_port "PAD";			# Nombre de la terminal de conexion del PAD de entrada
set out_pad_port "A";			# Nombre de la terminal de entrada de conexion para el PAD de salida


# Se debe crear una lista vacia para albergar los nombres de los puertos. Aunque las listas son mas ine-
# ficientes que las colecciones que maneja Synopsys. Con colecciones no es posible adquirir los  nombres 
# de los puertos e indexarlos en un bucle.
set port_list {};

# Bucle 1 que extrae los nombres de los puertos y los concatena en la lista creada. Se usa el comando
# "foreach_in_collection" pues "get_ports" devuelve una coleccion. El resto de comandos son transparentes

foreach_in_collection each_port [get_ports *] {
	set port_name [get_attribute [get_object_name $each_port] name];
	set port_list [concat $port_list $port_name];
}
unset each_port; # Se libera la variable, como una buena practica de programacion y para reutilizarla

# Bucle 2. Recorremos la lista que tiene los nombres de los puertos y de acuerdo con su direccion se crea
# una celda para el PAD de entrada y se establece la conexion con el respectivo puerto.
foreach each_port $port_list {
	set port_dir  [get_attribute $each_port direction];
	set cell_name "$each_port\_pad";
	if {$port_dir=="in"} {
			create_cell $cell_name $io_library/$input_pad;
			connect_pin -from $cell_name/$in_pad_port -to $each_port;
	} elseif {$port_dir=="out"} {
		create_cell  $cell_name $io_library/$output_pad;
		connect_pin -from $cell_name/$out_pad_port -to $each_port;
		}
}

puts "RM-Info: Completed script [info script]\n"
