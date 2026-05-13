#####################################################################################################

#Institución:	Instituto Tecnológico de Costa Rica

#Realizado por:	Jairo Mauricio Valverde Cruz	jmvc04@gmail.com
#Corregido por:	Reinaldo Castro González	leinardo.soctra@gmail.com

#Proyecto:	Detector de secuencia: 1101. Proyecto creado con fines didácticos.

#Herramienta:	Design Compiler  Version L-2016.03-SP3 for linux64 - Jul 18, 2016

#Fecha de creación:  27 Agosto 2011  editado en 21 Noviembre 2017

#Refrencias (detalladas en el Manual - Wiki):
# 1. A. Chacón, 2009.  
# 2. Manuales de Design Compiler.
# 3. Bindu, 2009. 
#####################################################################################################


########Definición de las variables a utilizar###########

set LIB_NAME "D_CELLS_HDLL_LPMOS_typ_1_80V_25C.db"; 
#set LIB_NAME scx3_cmos8rf_lpvt_tt_lp2v_25c.db 
# CLK en nanosegundos
set CLK_PERIOD "50";
# nombre de mi clock
set CLK_NAME "CLK_sys";
set CLK_UNCERTAINTY_SETUP "0.5";
set CLK_UNCERTAINTY_HOLD "0.5";
set CLK_TRANSITION "0.4";
set CLK_LATENCY_SOURCE "2";
set CLK_LATENCY "1";

set INPUT_DELAY_MAX "2";
set INPUT_DELAY_MIN "1";
set OUTPUT_DELAY_MAX "2";
set OUTPUT_DELAY_MIN "1";

set MAX_AREA "0";
set FANOUT "10";
set ALL_IN_EX_CLK_NAME [remove_from_collection [all_inputs] [get_ports {$CLK_NAME}]];
set ALL_OUT_NAME [all_outputs];
#set ALL_IN [all_inputs]
#set ALL_IN_EX_CLK_NAME [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set INPUT_CELL "DFRRQHDLLX0"; 
#set DRIVING_CELL_PORT_NAME "D";
#set MAX_TRANS [get_attribute $LIB_NAME/$INPUT_CELL/$DRIVE_PIN max_transition];
#set INPUT_CELL TBUFX20TS
#########################################################################################################


##########################Configuación del reloj clk   ##################################################
#Se configura el clock a una frecuencia de 50 Khz                                        -> page 5-8
create_clock -period $CLK_PERIOD [get_ports $CLK_NAME];

#No colocar buffers en la red del reloj siempre y cuando los flip-flops cargen en alto
set_dont_touch_network [get_clocks $CLK_NAME];

#Configuración de clock skew (retardos entre las diferentes ramificaciones del reloj)    -> page 5-11, 7-21
set_clock_uncertainty -setup $CLK_UNCERTAINTY_SETUP [get_clocks $CLK_NAME];
set_clock_uncertainty -hold $CLK_UNCERTAINTY_HOLD [get_clocks $CLK_NAME];

#Configuración del retardo de transición del clock					 -> page 5-13
set_clock_transition $CLK_TRANSITION [get_clocks $CLK_NAME];

#Configuración del retardo del clock en la entrada                                       -> page 5-12
set_clock_latency -source $CLK_LATENCY_SOURCE [get_clocks $CLK_NAME];
set_clock_latency $CLK_LATENCY [get_clocks $CLK_NAME];
##########################################################################################################

####port_constraint -all_violators

##########################Configuación del los relojes generados internamente ############################

## reloj clk_2 
#create_generated_clock -name $CLK_2_NAME -divide_by 2 -source [get_ports $CLK_NAME] [get_pins $CLK_2_NAME]                                   
#set_dont_touch_network [get_clocks $CLK_2_NAME]
                                   
########################################################################################################## 
                         

#Configuración del retardo de todas las señales de entrada, excepto la del clock         -> page 5-19, 7-
set_input_delay -max $INPUT_DELAY_MAX -clock $CLK_NAME $ALL_IN_EX_CLK_NAME;
set_input_delay -min $INPUT_DELAY_MIN -clock $CLK_NAME $ALL_IN_EX_CLK_NAME;

#Configuración del retardo en las señales de salida				         -> page 5-26, 7-18
set_output_delay -max $OUTPUT_DELAY_MAX -clock $CLK_NAME $ALL_OUT_NAME;
set_output_delay -min $OUTPUT_DELAY_MIN -clock $CLK_NAME $ALL_OUT_NAME;



#Configuración de la celda que maneja todas las entradas (cell driving inputs)   ------   pg -6-22 Chip Synthesis
set_driving_cell -lib_cell $INPUT_CELL -pin Q $ALL_IN_EX_CLK_NAME;
set_load  0.0201 $ALL_OUT_NAME;
set_max_fanout $FANOUT $current_design;
set_max_area $MAX_AREA;
#set_max_transition 2 $current_design;
#[set_fix_hold $CLK_NAME]
compile -incremental -only_design_rule;

#redirect top.rpt {report_constraint -all_violators}
