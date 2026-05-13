remove_design -designs
#Vamos a correr multicore
set_host_options -max_cores 6;


#Para corregir error en los handles de las redes de alimentacion
#Debe correrse antes de cargar el netist compilado

set upf_create_implicit_supply_sets false

######################################3 Creamos biblioteca MilkyWay ############################


source -echo -verbose "$PROY_HOME_PHY/scripts/crear_mw.tcl"
saif_map -start 

# Definir VSS y VDD
#set mw_logic0_net VSS
#set mw_logic1_net VDD


#------------------------------------------------------------------------------
########################### Crear o Cargar el Diseño ###############################
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Importar el Gate-Level-Netlist obtenido en la Síntesis RTL o el DDC. 
#------------------------------------------------------------------------------

# Se eliminan los siguientes warnings para disminuir el ruído visual que provocan (ver nota 2)

suppress_message {UID-401 SDC-3 SDC-4 HDUEDIT-104 ZRT-038 ZRT-311}

#Estos archivos vienen en formato ddc del directorio $PROY_HOME_SYN/db
import_designs -format ddc -top $TOP_MODULE $TOP_FILE_DDC;
current_design $TOP_MODULE;
#Vamos a cargar la estrategia UPF


# Resolución de múltiples instancias y enlaze a las bibliotecas físicas.
uniquify_fp_mw_cel
link -force

##################################################################################################
##### Si el diesnno viene en DDC no hace falta cargar el ambiente UPF
####################################################################################################
#load_upf $PROY_HOME_SYN/db/Tec_Riscv_pads_upf.upf
################################################################################################

##################################################################################################
##              Conexiones a VDD y GND de todos los dominios ##################
##################################################################################################
set_attribute [get_cells -of_objects ucu_anlg1] is_level_shifter true

save_mw_cel -as pre_power

# Este script genera el plan de piso con el anillo de pads y pines

source ./scripts/create_pads_mv.tcl
# Le indicamos a la herramienta que fije y de atributos a los pads y celdas de IO
source ./scripts/set_pad_attributes_on_cells.tcl

save_mw_cel  pre_power
#close_mw_cel pre_power

save_mw_cel -as pad_ring_unplaced.CEL
open_mw_cel pad_ring_unplaced
close_mw_cel top_riscv_tec_pads

derive_pg_connection -create_nets


#Revisamos cuales se han creado

#report_cell_physical -connections

#Ahora pegamos los pines y lo sties

source ./scripts/fix_vdd_ports_mv.tcl

#derive_pg_connection
derive_pg_connection
derive_pg_connection -tie
check_mv_design -verbose > ./reports/mv_check.txt
report_power_pin_info [get_cells * -hier] > ./reports/report_power_pin.txt

## Este script deberia remendar todas las malas conexiones a las alimentaciones
## Revisar cuidadosamente. Salvar para que nos quede todo armadito y conectado
## Todas las reds PG armadas y conectadas, incluyendo PADS VDD, VSS

save_mw_cel -as pg_derived_ok

#verify_pg_connections
##############################################################################################
#derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
#derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie
# Lectura del archivo de restricciones de temporizado

read_sdc -version Latest $TOP_FILE_SDC;
##############################################################################################
###################### Creacion del plano de piso y anillo de pads ###########################
##############################################################################################
#Usaremos la estrategia para las celdas compactas

set_fp_strategy -unit_tile_name "hdll";
set physopt_heterogeneous_site_array true
set_fp_placement_strategy -virtual_IPO on
create_floorplan   -start_first_row -control_type width_and_height -core_width 1600 -core_height 1120 \
     -core_utilization 0.8 -left_io2core 20 -bottom_io2core 30 -right_io2core 30 -top_io2core 30;

adjust_fp_floorplan -die_height 1480 -die_origin {0 0} -die_width 1600 -left_io2core 20 -bottom_io2core 30 -right_io2core 30 -top_io2core 30
#set_die_area -coordinate {0 0 1600 1500}
adjust_fp_io_placement -side r -spacing 5.0

save_mw_cel -as pad_ring_placed.CEL
close_mw_cel pad_ring_unplaced.CEL
open_mw_cel  pad_ring_placed
