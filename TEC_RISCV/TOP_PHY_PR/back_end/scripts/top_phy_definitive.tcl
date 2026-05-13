#################################################################################
# Title:		ac97_phy.tcl
# Description:	Script de sintesis fisica para IC Compiler
#				
# Dependencies: Ninguna.
# Project:		RISCV
# Author:		Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:			28 de Marzo de 2018
# Notes:		Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#				integracion del proyecto SiRPA. 2014
# Version:		1.1
# Revision:		28/05/2018 Original
#
#                       31/07/2018 ACR
#			Se ajustan directorios y variables para compartir con las usadas para la sintesis logica
#
###############################################################################################################.

# Creamos el floorplan basico
source ./scripts/create_basic_design_def.tcl

source ./scripts/create_voltage_areas_def.tcl

save_mw_cel -as voltage_domains_created

close_mw_cel pad_ring_placed

open_mw_cel  voltage_domains_created

## Generamos el halo alrededor de la SRAM (el unico hard macro)
#set_fp_macro_options top_riscv_soc/TOP/Memoria_8K -legal_orientations N -anchor_bound tl
set_fp_macro_options top_riscv_soc/TOP/Memoria_8K -legal_orientations N
set_keepout_margin -type hard -all_macros -outer {2 10 10 2};

#set_keepout_margin               [-type hard | soft] [-outer {lx by rx ty}]
# Bloquemos ruteo y la colocamos dentro de su zona de voltaje como un macro fijo
#La SRAM queda fija en la esquina superior del core
#Hay que estar seguros de que la SRAM queda totalmente dentro de la zona de voltaje que le definimos
#Esto lista los puntos de anclaje del area del core
#get_attribute [get_core_area] points

#Tenemos la SRAM mirando al ESTE, la colocamos con pines hacia abajdo
#set_fp_macro_options top_riscv_soc/TOP/Memoria_8K -legal_orientations N -anchor_bound tl

#El bounidng box lo obtenemos del BB definido de la macro
#set BBOX_SRAM [get_attribute [get_cells -hierarchical Memoria_8K] bbox]

#Tenemos que ver donde queda la SRAM primero para definir este BBOX

#create_routing_blockage -layers {metal1Blockage metal2Blockage metal3Blockage \
#                     metal4Blockage metal5Blockage metal6Blockage  } -bbox $BBOX_SRAM {RB_1037824 RB_1037825 RB_1037826 RB_1037827 RB_1037828 RB_1037829}



# Esta colocacion es temporal, solo para analisis de congestion
#create_fp_placement -timing_driven -no_legalize ;
#Nos aseguramos de los pines a la UCU esten todos a la derecha
close_mw_cel pre_power

#Partimos de la esquina superior del area de core, que se puede obtener asi
#get_attribute [get_core_area] bbox

set base_coordinates {1503.320 1342.120}

#set base_coordinates {1569.960 1304.480}
#set spacing 0.025;
#Daremos un espaciado de 4 tracks
set spacing [expr 4 * $BASIC_TRACK];
set index 1;
set file [open ./scripts/allocate_ports.tcl w 0755]
foreach_in_collection each_port [get_ports] {
    set x_pos [format {%0.3f} [expr [lindex $base_coordinates 0] + 0]];
    set y_pos [format {%0.3f} [expr [lindex $base_coordinates 1] - [expr $spacing * $index]]];
    set port_name [get_attribute -class port $each_port name];
    puts $file "set_port_location -coordinate {$x_pos $y_pos} $port_name;"
    incr index;
}
close $file;
source ./scripts/allocate_ports_rdy.tcl


#
create_fp_placement -timing_driven -no_hier;
set_undoable_attribute [get_cells -all top_riscv_soc/TOP/Memoria_8K] is_fixed true
refine_placement -congestion_effort low;
legalize_placement;

#set_undoable_attribute [get_cells -all top_riscv_soc/TOP/Memoria_8K] is_fixed true


#GUardamos en una celda intermedia

save_mw_cel -as floorplan_ends;

copy_mw_cel -from  floorplan_ends -to floorplan_ends1;
close_mw_cel  voltage_domains_created
close_mw_cel floorplan_ends;
## Vamos por aca
open_mw_cel floorplan_ends1;

#Trabajamos sobre otra celda y verificamos librerias

#check_library;
#check_tlu_files;
#list_libs;

#########################################################################################################
############################### Creacion de los anillos y pads de VDD y VSS ############################
###############################    Basados en dominios UPF                 ############################

 
##(Si no se usa UPF, estas son las directivas)
##derive_pg_connection -power_pin VDD -power_net VDD -ground_net VSS -ground_pin VSS
derive_pg_connection
derive_pg_connection -tie
#derive_pg_connection -power_net VDD -ground_net VSS -tie

set pns_commit_lower_layer_first true


source ./scripts/power_nets_syn.tcl
#para prevenir que los straps no queden alineados con las correas de alimentacion

#set_fp_rail_strategy -align_strap_with_m1_rail true ; #-std_cell_rail_connect_layer MET1 -put_strap_in_std_cell_row true

#
set_pnet_options -partial {METTP METTPL}
#set_pnet_options -complete {METTP METTPL}
set_fp_rail_strategy -align_strap_with_m1_rail true 
synthesize_fp_rail  -synthesize_voltage_areas -voltage_areas  {top_riscv_soc/PD_CORE}  -power_budget 1000 -pad_masters { VDD_1V8:VDDCPADF.FRAM VSS:GNDORPADF.FRAM }

#save_mw_cel -as fp_rail_synthesized_not_committed

commit_fp_rail
save_mw_cel -as power_rail_rdy

#create_routing_blockage -layers {metal1Blockage metal2Blockage metal3Blockage metal4Blockage metal6Blockage} -boundary {{180.320 1304.200} {904.400 1304.200} {904.400 581.800} {866.880 581.800} {866.880 598.600} {180.320 598.600}}

#create_routing_blockage -layers {metal1Blockage metal2Blockage metal3Blockage metal4Blockage metal5Blockage metal6Blockage} -bbox {{875.280 580.680} {906.640 1304.200}}
create_routing_blockage -layers {metal1Blockage metal2Blockage metal3Blockage metal4Blockage metal5Blockage metal6Blockage} -bbox {{883.680 615.520} {896.000 1342.400}}
save_mw_cel -as power_rail_rdy_metal_blockage
set_preroute_drc_strategy -treat_fat_blockage_as_fat_wire -report_fail -min_layer MET1 -max_layer METTPL
preroute_instances
preroute_standard_cells -nets VDD_1V8 -fill_empty_rows -remove_floating_pieces -connect horizontal; # -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect horizontal; # -extend_to_boundaries_and_generate_pins


save_mw_cel -as first_preroute_std_cells

#analyze_fp_rail

#set_pnet_options ...; # (en caso que sea necesario bloquear algo)

create_fp_placement -timing_driven -no_hierarchy_gravity -incremental all;
refine_placement -congestion_effort high;
legalize_placement;
preroute_instances
preroute_standard_cells -nets VDD_1V8 -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins

#######Save_Milkyway_Cell
save_mw_cel -as powerplan_rail_ends

#preroute_standard_cells -nets VDD -mode net -connect horizontal

#######################
#  Place and Routing  #
#######################

## Abrimos otra celda MW temporal 

copy_mw_cel -from  powerplan_rail_ends -to powerplan_ends1
close_mw_cel floorplan_ends1
open_mw_cel powerplan_ends1


################################################################################Place_Optimization
set compile_instance_name_prefix place
place_opt -effort high
legalize_placement -effort medium

#Hasta aca todo bien. Celdas conectadas a VDD VSS
################################################################################Reports
create_qor_snapshot -timing -constraint -congestion -name Place
report_qor_snapshot  > $PROY_HOME_PHY/reports/place.qor_snapshot.rpt
report_qor > $PROY_HOME_PHY/reports/place.qor
report_constraint -all > $PROY_HOME_PHY/reports/place.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > $PROY_HOME_PHY/reports/place.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > $PROY_HOME_PHY/reports/place.min.tim
################################################################################Save_Milkyway_Cel
save_mw_cel -as clock_tree_placed
################################################################################
close_mw_cel powerplan_ends1
open_mw_cel clock_tree_placed

derive_pg_connection
derive_pg_connection -tie

preroute_instances
preroute_standard_cells -nets VDD_1V8 -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins

#ANTENNATS configuration 
#source xx018.ante.rules
source $TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/xx018.ante.rules
report_antenna_rules
#set_route_zrt_detail_options -diode_libcell_names ANTENNATS -insert_diodes_during_routing true

#Estime el retardo de cada path usando el comando route_zrt_global y utilice el comando set_route_zrt para asegurar que se tomen en cuenta los path groups
set_route_zrt_common_options -plan_group_aware all_routing

set_route_zrt_common_options -read_user_metal_blockage_layer true

#Genere un estimado del retarso de los cables en el diseño usando el comando route_zrt_global -effort ultra
route_zrt_global -effort ultra
#optimize el posicionamiento de las celdas para mejorar los resultados de timing usando el comando optimize_fp_timing
optimize_fp_timing
#verifique nuevamente cuál es el peor camino Max en el diseño usando el comando report_timing ¿Nota algún cambio?
#report_timing -nets -capacitance -transition_time -input_pin;

#Hasta aca todo bien. Celdas conectadas a VDD VSS

#Vamos a definir las opciones para el Z Router

set_route_zrt_common_options -default true
set_route_zrt_global_options -timing_driven true
set_route_zrt_global_options -effort high
set_route_zrt_track_options -timing_driven true
set_route_zrt_detail_options -drc_convergence_effort_level high

####
#Reducir la cantidad de buffers e inversores, sin afectar la calidad del resultado
###
set_buffer_opt_strategy -effort low
set_route_zrt_detail_options -default_gate_size 0.1

## Preparamos y ejecutamos la sintesis del arbol de reloj
#create_clock -period 50 -name CLK [get_ports clk_pad]
#create_clock -period $CLK_PER -name CLK [get_ports clk_pad]

set_clock_tree_options -clock_trees [get_clocks] -insert_boundary_cell true -ocv_clustering true -buffer_relocation true -buffer_sizing true -gate_relocation true -gate_sizing true
set cts_use_debug_mode true
set cts_do_characterization true
clock_opt -fix_hold_all_clocks -congestion

save_mw_cel clock_tree_placed

copy_mw_cel -from clock_tree_placed  -to routed_cell
close_mw_cel clock_tree_placed

open_mw_cel routed_cell 
######

#report_timing -nets -capacitance -transition_time -input_pin;

set_dont_touch_network [get_clocks]
route_zrt_auto -max_detail_route_iterations 40 ; #30
verify_zrt_route
verify_zrt_route > ./reports/report_first_zroute.txt;

psynopt -congestion
route_zrt_auto -max_detail_route_iterations 40; #30
route_opt -incremental

route_zrt_detail -incremental true -max_number_iterations 30; #30
focal_opt -drc_nets all

remove_zrt_redundant_shapes -report_changed_nets true
verify_zrt_route -antenna true
# Insertamos diodos si hay errores aun de Antena

#insert_diode -prefix fixAntx
#Vamos a verificar DRC de ruteo
verify_zrt_route -antenna true  > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_drc_route.txt"
verify_pg_nets > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_pg_nets.txt"
## Vamos a correr DRC y LVS antes de rellenar
#Definimos opciones para el ICV


# change_names  -rule  verilog  -hierarchy
#write_verilog "$PROY_HOME_PHY/db/$DESIGN_NAME\_phy_sim.v"


derive_pg_connection
derive_pg_connection -tie
#Volvemos a revisar el ruteo de las celdas estandar
set_preroute_drc_strategy -max_layer MET1
preroute_instances
preroute_standard_cells -nets VDD_1V8 -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins
## Hasta aca no hay errores de conexion VDD, VSS (verify_pg_nets correcto)

 change_names  -rule  verilog  -hierarchy
write_verilog "$PROY_HOME_PHY/db/$DESIGN_NAME\_phy_sim.v"

## Guardames celda ruteada, faltan rellenos finales e insertar vias redundantes. revision DRC y LVS final
save_mw_cel routed_cell
copy_mw_cel -from  routed_cell -to design_routed_ends
close_mw_cel routed_cell
open_mw_cel design_routed_ends

verify_pg_nets -pad_pin_connection all > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_pg_nets_pad_pin_connection.txt"

## Colocamos vias redundantes
#derive_pg_connection
#insert_redundant_vias -auto_mode insert 


## Insertamos las celdas de relleno. Segun man page, deben conectarse de mayor a menor
#Segun ICC Implementation Guide. Se colocan luego de los ruteos

insert_stdcell_filler  -cell_with_metal FEED25HDLL -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED15HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED10HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED7HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal  FEED5HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED3HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED2HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED1HDLL -connect_to_power VDD -connect_to_ground VSS

####Rellenos de NWELL
insert_well_filler -layer NWELL -higher_edge max -lower_edge min



#derive_pg_connection
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd -tie
#Volvemos a revisar el ruteo de las celdas estandar
set_preroute_drc_strategy -max_layer MET1
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; # -extend_to_boundaries_and_generate_pins


#Verificamos que nada se rompiera
verify_pg_nets
verify_pg_nets -pad_pin_connection all

# Revisamos el diseno
check_mv_design -verbose > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_chk_phy.txt"
change_names  -rule  verilog  -hierarchy
write_verilog -pg \
             -unconnected_ports \
             -no_cover_cells \
             -no_io_pad_cells \
             -no_unconnected_cells \
             -no_flip_chip_bump_cells \
             -no_physical_only_cells \
             -supply_statement  none $TOP_FILE_PHY
# write_verilog $TOP_FILE_PHY
extract_rc
write_parasitics -output $TOP_FILE_PHY_SPEF
write_sdc $TOP_FILE_PHY_SDC
write_sdf $TOP_FILE_PHY_SDF
#corregir qui
write_def -output $TOP_FILE_PHY_DEF

save_mw_cel -as top
save_mw_cel -as top.FILL


save_mw_cel design_routed_ends
close_mw_cel design_routed_ends

close_mw_cel top
open_mw_cel -readonly top
## Escribimos GDS
set_write_stream_options \
             -child_depth 99 \
             -output_filling fill \
             -output_pin {text geometry} \
             -map_layer $TECH_GDS_MAP_FILE \
             -pin_name_mag 0.5 \
             -output_polygon_pin \
             -keep_data_type

## Recordar cambiar el diseno antes de sacar
current_design top
#write_stream -lib_name $TOP_CEL -format gds ../../results/${TOP_CEL_NAME}.gds

#SOlo guardamos la celda completa final
write_stream  -cells top.CEL -format gds $TOP_FILE_GDS
report_power -analysis_effort high > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_power.txt"
report_area > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_area.txt"
report_cell > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_cell.txt"
report_qor > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_qor.txt"
report_timing > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_timing.txt"
report_port > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_port.txt"
#set anotar "\$asic/db/be/alu/add_subt/Francis/$design_name\_phy.sdf"
#set string_replace "sed -i \"s/endmodule/initial\ \\\$sdf\_annotate\(\\\"$anotar\\\"\)\\\\; \\n endmodule/g\" $design_home/$design_name\_phy_sim.v"
#exec /bin/sh -c "$string_replace"
save_mw_cel design_routed_ends
#------------------------------------------------------------------------------
# Nota 2: Mensajes suprimidos
#------------------------------------------------------------------------------

# SDC-3: 		La restricción "set_wire_load_mode", no es compatible con icc_shell.
# SDC-4: 		La restricción "set_wire_load_model", es ignorada.
# UID-401: 		Los atributos de regla de diseño de la celda de conducción se establecerán en el puerto
# HDUEDIT-104: 	Se ingresó un comando que cambió la base de datos pero no tiene soporte para deshacer,
# 				por lo que se borró la pila de deshacer actual.
