
# Script generador de la caja negra donde se colocara por ahora la celda de la UCU
#Despues ellos deberan pasarnos esto en formato db o LEF para poderlo pasar a nuestro disenno

#Por ahora crearemos un modelo de temporizado y de tamano arbitrarios
#Debemos primero leer todo el disenno
#Nos movemos al diseno del topcore_tecriscv

current_design topcore_tecriscv
create_qtm_model ucu_anlg

#Parametros de carga
set LIB_NAME_STD_CELLS "D_CELLS_HDLL_LPMOS_typ_1_80V_25C";
set INPUT_CELL "INHDLLX2"; # Lo que deberia esperarse como carga en las entradas UCU
set INPUT_CELL_PORT_NAME "A" ; # Pin que suponemos al que se conectan entradas bloque UCU
set DRIVING_CELL "INHDLLX4"; # La celda que supuestamente maneja al bloque UCU
set DRIVE_PIN "$LIB_NAME_STD_CELLS/$DRIVING_CELL/Q" ; #Pin que maneja el bloque
set OUTPUT_CELL "INHDLLX4"; # La celda que supuestamente se maneja desde el bloque UCU
set OUTPUT_CELL_PORT_NAME "A" ;#Pin de la celda que maneja el bloque UCU
#Lo supuestamente maximo que deberiamos esperar en las entradas del bloque UCU
set MAX_LOAD_IN [expr [load_of $LIB_NAME_STD_CELLS/$INPUT_CELL/$INPUT_CELL_PORT_NAME] * 10]
#Lo maximo que supuestamente deberia estar en capacidad de manejar a su salida el bloque UCU
set MAX_LOAD_OUT [expr [load_of $LIB_NAME_STD_CELLS/$OUTPUT_CELL/$OUTPUT_CELL_PORT_NAME] * 1]

#Encontramos la maxima transicion en nuestra driving cell y ajustamos la maxima carga que puede colocar el DC

set MAX_TRANS [get_attribute $DRIVE_PIN max_transition]; 
set CONSERVATIVE_MAX_TRANS [expr $MAX_TRANS / 2.0];

set_qtm_technology -library D_CELLS_HDLL_LPMOS_typ_1_80V_25C
set_qtm_technology -max_transition $CONSERVATIVE_MAX_TRANS
set_qtm_technology -max_capacitance $MAX_LOAD_IN

#Parametros de setup, hold

set_qtm_global_parameter -param setup -value 0.1set_qtm_global_parameter -param hold -value  0.1set_qtm_global_parameter -param clk_to_output -value  0.1

# Se especifican los puertos
create_qtm_port  -type clock clk 
create_qtm_port  -type input reset

create_qtm_port { full_range_level_shifter[7:0] }  -type input 
#create_qtm_port -type input full_range_level_shifter
create_qtm_port -type input { IS_Val[31:0] }create_qtm_port  -type input { IS_Config[31:0] }
create_qtm_port  -type input { IS_Trigger[3:0] }


# Creamos los arcos de tiempo
#Por ahora todos de salida nada mes, respecto a reset y clock


create_qtm_delay_arc -name reset_full_range_level_shifter_R -from reset -from_edge rise -to full_range_level_shifter -value 1 -to_edge rise
create_qtm_delay_arc -name reset_full_range_level_shifter_F -from reset -from_edge fall -to full_range_level_shifter -value 1 -to_edge fall
create_qtm_delay_arc -name reset_IS_Val_R -from reset -from_edge rise -to IS_Val -value 1 -to_edge rise
create_qtm_delay_arc -name reset_IS_Val_F -from reset -from_edge fall -to IS_Val -value 1 -to_edge fall
create_qtm_delay_arc -name reset_IS_Config_R -from reset -from_edge rise -to IS_Config -value 1 -to_edge rise
create_qtm_delay_arc -name reset_IS_Config_F -from reset -from_edge fall -to IS_Config -value 1 -to_edge fall
create_qtm_delay_arc -name reset_IS_Trigger_R -from reset -from_edge rise -to IS_Trigger -value 1 -to_edge rise
create_qtm_delay_arc -name reset_IS_Trigger_F -from reset -from_edge fall -to IS_Trigger -value 1 -to_edge fall


#

report_qtm_modelsave_qtm_modelwrite_qtm_model -out_dir ./db/QTM

#estimate_fp_black_boxes -sm_size {200 200} -sm_util 0.7 [get_cells -filter "is_black_box==true" ucu_anlg1]




