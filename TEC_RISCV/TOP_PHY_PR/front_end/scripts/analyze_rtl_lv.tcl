##################################################################################
# Title:        analyze_rtl.tcl
# Description:  Script de lectura de las unidades verilog 
# Dependencies: design_syn.tcl
# Library:	XFAB-180nm (xh018) HDLL
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		01 de Octubre de 2017
# Notes:	Basado en los scripts del Dr. Juan Agustín Rodríguez para la
#		integración del proyecto SiRPA. 2014
# Version:	2.0
# Revision:	31/07/2018 (ACR)
#
##################################################################################

# Analisis de los modulos/dependencias del disenno. Lluego se elabora el modulo principal que corresponde al  
# disenno en la variable $TOP_MODULE del script user_setup.tcl.

# En caso de estar corriendo en el modo topografico, se debe crear una biblioteca MW.
#------------------------------------------------------------------------------------

suppress_message {VER-130 LINT-1 LINT-28 LINT-29 LINT-31 LINT-33 LINT-52 OPT-112 TIM-134\
				 PWR-6 PWR-410 PWR-428 PWR-412 UID-401 PSYN-025};

# Para que no conecte redes de manera implicita y no deje sin conexion primaria a los Level Shifters de la UCU

set upf_create_implicit_supply_sets false
set_host_options -max_cores 8;
if {[shell_is_in_topographical_mode]} {
	# Se abre la biblioteca de trabajo Milkyway. En caso de que la misma no exista se crea.
	source -echo -verbose "$PROY_HOME_SYN/scripts/crear_mw.tcl";
}

# El siguiente proceso implementa un algoritmo recursivo el cual genera 2 listas, una para todos los directorios
# que se encuentran en la ruta de archivos fuente y otra para los archivos verilog en dichos directorios, con la
# segunda lista, se analizan los archivos fuente. Si el directorio base no contiene mas directorios, se leen los
# archivos fuente desde este.
# El readfile se genera con el gui para generar la lista completa
#------------------------------------------------------------------------------------


#Por ahora vamos a generar un modelos arbitratio del bloque del bloque de la UCU


#lappend link_library ./db/QTM/ucu_anlg.db

#SI vamos a trabajar con el archivo ya pre-mapeado, partimos de acá

if {$COMPLETE_COMPILE==1} {
	# Se abre la biblioteca de trabajo Milkyway. En caso de que la misma no exista se crea.

	read_file -format sverilog {/mnt/vol_NFS_Zener/WD_ESPEC/rgarcia/GIT/TEC_RISCV/TOP_PHY_PR/front_end/source/TOP_PADS/top_riscv_tec_pads.sv}
	#read_file -format sverilog {/mnt/vol_NFS_Zener/WD_ESPEC/rgarcia/GIT/REFRESH/TEC_RISCV/TOP_PHY_PR/front_end/source/TOP_PADS/top_riscv_tec_pads_lv.sv} > reports/results_read.txt;
       #set_dont_touch [ get_cells ucu* ];
       #get_cells -hier -filter "is_black_box==true";
	current_design $TOP_MODULE;
	analyze -library WORK -format sverilog $TOP_FILE > reports/results_analyze.txt;
	# RTL files are uniquified, linked and wrote on a pre-compiled GTECH  file
	uniquify;
	link  > reports/results_link.txt;
	check_design  > reports/results_check.txt;
        write -hierarchy -format ddc -output "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc";

    } else {

	read_file -format ddc "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc";
    }

current_design $TOP_MODULE;

# Este script hcho por RCG carga recursivamente todos los archivos .v en el directorio "source". Hay que probarlo (ACR)

#set directorios [ls -d "$SOURCE_HOME"];					# Lista 1: Directorios Fuente.
# -------------------------------------------------		  Ciclo 1: indexacion de directorios
#if {[string trimleft $directorios] != "$SOURCE_HOME"} {
#   	foreach i $directorios {			
#		set archivos [ls "$i/*.*v"]	;					# Lista 2: Archivos fuente verilog/system verilog.
#--------------------------------------------------		  Ciclo 2: indexacion de archivos.
#		foreach n $archivos {			
#	        analyze -format sverilog -library WORK "$n";	# Analisis de los archivos fuente.
#	    };												# Fin de Ciclo 2.
#	};													# Fin de Ciclo 1.
#} else {
#	set archivos [ls "$SOURCE_HOME/*.*v"];				# Lista 2: Archivos fuente verilog/system verilog.
#--------------------------------------------------		  Ciclo 2: indexacion de archivos.
#	foreach n $archivos {
#		analyze -format sverilog -library WORK "$n";		# Analisis de los archivos fuente.
#	};
#}

# Elaboracion del modulo principal del disenno
#elaborate $TOP_MODULE -architecture verilog -library WORK;
#elaborate -architecture verilog -library WORK;



# Definimos las direcciones de enrutamiento p

set_preferred_routing_direction -layers {MET1 MET3 METTP} -direction horizontal;
set_preferred_routing_direction -layers {MET2 MET4 METTPL} -direction vertical;





