##################################################################################
# Title:        dc_syn.tcl
# Description:	Flujo de sintesis logica en Design Compiler
# Dependencies: Ninguna.
# Library:	XFAB-180nm xh018 High Density Low Leakage
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		23 de Mayo de 2018
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.01 
# Revision:	30-07-18 ACR
#
###################################################################################

puts "RM-Info: Running script [info script]\n"

# Se suprimen algunos mensajes de alarmas los cuales se considera, pueden dejarse pasar.
# para ver mas detalles sobre los mensajes suprimidos, se recomienda ejecutar el comando:
# man <CODIGO>

## se llama al UPF
#source -echo -verb ./scripts/create_UPF.tcl
set_operating_conditions TYPICAL -library $LIB_NAME_STD_CELLS;
load_upf ./scripts/create_UPF_fab.tcl > reports/result_load_upf.txt
#load_upf ./scripts/create_UPF_fab_no_hv.tcl > reports/result_load_upf.txt

# set_ungroup [get_cells {u12 u13 u14 u15 u16}] false; 
# Ignorar, el comando anterior, se uso a modo de exploracion para no romper la jerarquia.
# Cosa que se puede hacer con un interruptor del comando compile_ultra

#########Si vamos a cargar el archivo ya pre-compilado, mas bien lo cargamos antes ########
#write -hierarchy -format ddc -output "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc"
# La ruta anterior debe existir!

#------------------------------------------------------------------------------
# Cargar las restricciones de disenno
#------------------------------------------------------------------------------
#source ./scripts/alu_constraints.tcl;
current_design topcore_tecriscv

source -verbose -echo "$PROY_HOME_SYN/scripts/$DESIGN_NAME\_constraints.tcl" > ./reports/source_contraints.txt;

propagate_constraints > ./reports/propagate_contraints.txt;

# El siguiente comando controla si la compilacion agrega logica extra al disenno para garantizar que
# no hayan avances (feedthroughs) o que no hay dos puertos de salida conectados a la misma red en 
# ningun nivel de jerarquia los interruptores -feedthroughs y -buffer_constants; respectivamente, 
# insertan bufers para: aislar los puertos de entrada de los puertos de salida en todos los niveles
# de la jerarquia, y para las constantes logicas en lugar de duplicarlas

## Vamos a crear la caja negra para el modulo de la UCU
## Notar que se debe haber creado y enlazado un modelo de temporizado anes (ver Analyze_RTL.tcl)
##estimate_fp_black_boxes -sm_size {500 750} -sm_util 0.7 [get_cells -filter "is_black_box==true" ucu_anlg1];


set_fix_multiple_port_nets -feedthroughs -buffer_constants; # Para este ejemplo en particular

#------------------------------------------------------------------------------
#				Activar el analisis del factor de actividad
#------------------------------------------------------------------------------

if {[shell_is_in_topographical_mode]} {

#	saif_map -start; 			
#	set_power_prediction; 		

} else {
	propagate_switching_activity; # Este comando no se recomienda usar mas. Quedara obsoleto pronto 
	# Se usaba con el constraint de set_switching_activity
}

#La sintesis se debe hacer sobre el modulo TOP sin los pads (que son instanciados como primitivas y son los que manejan el circuito)


#------------------------------------------------------------------------------
#								Compilacion
#------------------------------------------------------------------------------
#Multi-core
set_host_options -max_cores 6;
set_preferred_routing_direction -layers {MET1 MET3 METTP} -direction horizontal;
set_preferred_routing_direction -layers {MET2 MET4 METTPL} -direction vertical;

# El interruptor en el comando de compilacion indica que se preservan los niveles jerarquicos en el 
# disenno. Ello permite que luego se pueda hacer una exploracion de planos de grupo y las jerarquias
#  se implementen como bloques de unidades funcionales (FUBs) en la implementacion fisica con ICC.
if {$CHECK_ONLY==1} {
	compile_ultra -check_only > ./reports/check_environment.txt;
   } else {
#       set_optimize_registers -justification_effort high;
#    	compile_ultra -no_autoungroup -exact_map -retime > ./reports/compiler_results.txt;
    	compile_ultra -no_autoungroup -exact_map  > ./reports/compiler_results.txt;
        optimize_netlist -area > ./reports/optimize_netlist_area.txt;
        set verilogout_no_tri true;
        change_names -hierarchy -rules verilog;
        write -format verilog -hierarchy -output "$TOP_FILE_SYN";

# Lectura del saif, unicamente funcional en el modo topografico
#	if {[shell_is_in_topographical_mode]} {
#	read_saif -input "$PROY_HOME/front_end/$DESIGN_NAME.saif" \

# 	-instance_name $TEST_INST_NAME/$UUT_INST_NAME -target_instance $UUT_INST_NAME;
#Escribir la lista de nodos a nivel de compuertas (Gate Level Netlist) que se utiliza para:
#- Verificar el funcionamiento lógico del sistema digital después de la Síntesis RTL.
#- Como una de las entradas para el sintetizador físico (IC Compiler).

#read_saif -input top.saif -instance_name test_top -auto_map_names
#	}

	current_design $TOP_MODULE
        source ./scripts/correct_pg_connections.tcl
	set verilogout_no_tri true;
	change_names -hierarchy -rules verilog ;

#Indicamos que todas las celdas en el bloque UCU son level_shifters
#Ver pagina 
set_attribute [get_cells -of_objects ucu_anlg1] is_level_shifter true
set_attribute [get_cells -of_objects ucu_anlg1] size_only true
#------------------------------------------------------------------------------
# 							Generacion de Reportes
#------------------------------------------------------------------------------

# Las rutas de los archivos de salida deben existir


#	report_power -analysis_effort high > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_power.txt";
	report_area -hierarchy>  "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_area.txt";
	report_qor > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_qor.txt";
	report_timing > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_timing.txt";
	report_port > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_port.txt";

#------------------------------------------------------------------------------
# 						Generacion de archivos de salida
#------------------------------------------------------------------------------
# Guardamos un formato ddc para leerlo mas rapido de vuelta en el ICC


	write -hierarchy -format ddc -output "$TOP_FILE_DDC";
	write -format verilog -hierarchy -output "$TOP_FILE_SYN";
        write -pg -format verilog -hierarchy -output "$TOP_FILE_SYN_PG";

#Guardamos info de restricciones para leerlo en ICC

	write_sdc "$TOP_FILE_SDC";

#Guardamos info de temporizado en sdf para simulaciones 

	write_sdf "$TOP_FILE_SDF";
        save_upf "$PROY_HOME_SYN/db/$DESIGN_NAME\_upf.upf"


	} ; # Se cierra el Else de la compilacion
puts "RM-Info: Completed script [info script]\n";
