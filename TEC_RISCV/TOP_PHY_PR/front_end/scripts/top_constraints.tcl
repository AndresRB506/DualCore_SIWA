##################################################################################
# Title:        alu_constraints.tcl
# Description:	Variables para las restricciones de la sintesis logica y someter
#		a la ALU al flujo de síntesis lógica en DC -topo
# Dependencies: alu_syn.tcl.
# Library:	XFAB-180nm
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		05 de Agosto de 2017
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.0 Revision:	26/04/2018
#		1.1 Revision: 24-7-18 ACR. Se ajusta a tiempos para RISC-V. 20MHz
#
###################################################################################

#create a collection of all the clock nets
set ALL_IN_EX_CLK_NAME [remove_from_collection [all_inputs] [get_ports clk]]
#create a collection of all outputs
set ALL_OUT_NAME [all_outputs]
#name of the library characterization to be used 1.8V 25°C
set LIB_NAME_STD_CELLS "D_CELLS_HDLL_LPMOS_typ_1_80V_25C";
set LIB_NAME_IO_CELLS "IO_CELLS_FC1V8_LPMOS_UPF_typ_1_80V_1_80V_25C";

# Create a clock with a period in ns
set CLK_PER 50
create_clock -period $CLK_PER -name CLK [get_ports clk]
set_clock_uncertainty -setup 0.1 [get_clocks CLK]
set_clock_uncertainty -hold 0.1 [get_clocks CLK]
set_clock_transition 0.05 [get_clocks CLK]
//set_clock_latency -source 2 [get_clocks CLK]
set_clock_latency 1 [get_clocks CLK]

# Configuración de las redes de propagación de reloj y reset
set_dont_touch_network [get_clocks CLK]
#set_dont_touch_network [get_ports reset]

# Configuración del retardo de las sañales de entrada, excepto el reloj
set_input_delay -max [expr $CLK_PER * 0.4] -clock CLK $ALL_IN_EX_CLK_NAME
set_input_delay -min 0.1 -clock CLK $ALL_IN_EX_CLK_NAME

# Configuración del retardo de las sañales de salida, excepto el reloj
set_output_delay -max [expr $CLK_PER * 0.4] -clock CLK $ALL_OUT_NAME
set_output_delay -min -0.1 -clock CLK $ALL_OUT_NAME

set DRIVING_CELL_INPUT "ICFA";
set DRIVING_CELL_PORT_NAME "Y";

# Configuración de la celda que maneja todos los puertos de entrada
set_driving_cell -lib_cell $DRIVING_CELL -library $LIB_NAME  $ALL_IN_EX_CLK_NAME

#Suponemos a la entrada que no se podran manejar mas de 10 puertos A de un INVHDLL2X
set MAX_LOAD [expr [load_of $LIB_NAME/$DRIVING_CELL/$DRIVING_CELL_PORT_NAME] * 10]

#Encontramos la maxima transicion en nuestra driving cell

set DRIVE_PIN $LIB_NAME/$DRIVING_CELL/Q;
set MAX_TRANS [get_attribute $DRIVE_PIN max_transition]; 
set CONSERVATIVE_MAX_TRANS [expr $MAX_TRANS / 2.0];
set_max_transition $CONSERVATIVE_MAX_TRANS $ALL_IN_EX_CLK_NAME; 

# Configuración de la celda que maneja todos los puertos de salida
set_load [expr $MAX_LOAD *4 ] $ALL_OUT_NAME
set_max_capacitance $MAX_LOAD $ALL_OUT_NAME;
set_max_fanout 10 $current_design


# Configuracion de las condiciones de operacion
set_operating_conditions TYPICAL -library $LIB_NAME

if {![shell_is_in_topographical_mode]} {
	set_wire_load_model -name 1k -library $LIB_NAME;
	set_wire_load_mode top;
}


if {![shell_is_in_topographical_mode]} {
	set_switching_activity -toggle_rate 0.25 -static_probability 0.5 -base_clock clk $ALL_IN_EX_CLK_NAMES;
}
