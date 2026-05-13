##################################################################################
# Title:        const_vars.tcl
# Description:	Variables para las restricciones de la síntesis lógica y someter
#		el Codec de audio AC97 al flujo de síntesis lógica en DC -topo
# Dependencies: ac97_syn.tcl.
# Library:	XFAB-180nm
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		05 de Agosto de 2017
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.0
# Revision:	26/04/2018
#
###################################################################################

# Definicion de los modelos y variables a utilizar
set ALL_OUT_NAME [all_outputs]
set LIB_NAME "D_CELLS_LL_LP5MOS_fast_1_20V_25C";
set CLK_CNT "2";
set CLK_1 "clk_i";
set CLK_2 "bit_clk_pad_i";
set RST "rst_i";
set CLK_GEN_1 "clk";
set CLK_P_1 "5";
set CLK_GEN_2 "bit_clk";
set CLK_P_2 "500";
set UNCERTANITY "0.1";
set SETUP "0.1";
set HOLD "0.1";
set LATENCY "0.5";
set TRANSITION "0.5";
set FANOUT "10"
set MAX_AREA "0"
set IN_DELAY "1";
set OUT_DELAY "1";
set DRIVING_CELL "INLLX16";
set DRIVING_CELL_PORT_NAME "A";
set ALL_IN_EX_CLK_NAME_1 [remove_from_collection [all_inputs] [get_ports {$CLK_1 $CLK_2}]]

# Configuración de las condiciones de operación
set_operating_conditions -library $LIB_NAME WORST;

# Configuración de las señales de reloj/CLK
# !!! WISHBONE Clock !!!
create_clock -period $CLK_P_1 -name $CLK_GEN_1 [get_ports $CLK_1];
set_clock_skew -uncertainty $UNCERTANITY [get_clocks $CLK_GEN_1];
set_clock_transition $TRANSITION [get_clocks $CLK_GEN_1];
set_clock_uncertainty -setup $SETUP [get_clocks $CLK_GEN_1];
set_clock_uncertainty -hold $HOLD [get_clocks $CLK_GEN_1];
set_clock_latency $LATENCY [get_clocks $CLK_GEN_1];

# !!! BIT Clock !!!
create_clock -period $CLK_P_2 -name $CLK_GEN_2 [get_ports $CLK_2];
set_clock_skew -uncertainty $UNCERTANITY [get_clocks $CLK_GEN_2];
set_clock_transition $TRANSITION [get_clocks $CLK_GEN_2];
set_clock_uncertainty -setup $SETUP [get_clocks $CLK_GEN_2];
set_clock_uncertainty -hold $HOLD [get_clocks $CLK_GEN_2];
set_clock_latency $LATENCY [get_clocks $CLK_GEN_2];

# Configuración de las redes de propagación de reloj y reset
set_dont_touch_network [get_clocks $CLK_GEN_1];
set_dont_touch_network [get_clocks $CLK_GEN_2];
set_dont_touch_network [get_ports $RST];

# Configuración del retardo de las sañales de entrada, excepto el reloj
set_input_delay -max 1 -clock $CLK_GEN_1 $ALL_IN_EX_CLK_NAME;
set_input_delay -min 1 -clock $CLK_GEN_1 $ALL_IN_EX_CLK_NAME;

# Configuración del retardo de las sañales de salida, excepto el reloj
set_output_delay -max 1 -clock $CLK_GEN_1 $ALL_OUT_NAME;
set_output_delay -min 1 -clock $CLK_GEN_1 $ALL_OUT_NAME;

# Configuración de la celda que maneja todos los puertos de entrada
set_driving_cell -lib_cell $DRIVING_CELL -library $LIB_NAME  $ALL_IN_EX_CLK_NAMES;

# Configuración de la celda que maneja todos los puertos de entrada
set_driving_cell -lib_cell $DRIVING_CELL -library $LIB_NAME  $ALL_IN_EX_CLK_NAMES;

# Configuración de la celda que maneja todos los puertos de salida
set_load [expr [load_of $LIB_NAME/$DRIVING_CELL/$DRIVING_CELL_PORT_NAME] * 1] $ALL_OUT_NAMES;
set_max_fanout $FANOUT $current_design;
set_max_area $MAX_AREA;

