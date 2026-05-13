####################################################################################################################################
#Institución:                          Instituto Tecnológico de Costa Rica

#Realiza por:		   Jairo Mauricio Valverde Cruz           jmvc04@gmail.com
#Corregido por:		Reinaldo Castro González	shidarimo@gmail.com

#Proyecto:   estimador de secuencia: 1101. Proyecto creado con fines didácticos.

#Herramienta:        IC Compiler   Version L-2016.03-SP3 for linux64 - Jan 11, 2016

#Fecha de creación:  01 Marzo 2011, editado 20 Agosto 2016

#Refrencias (detalladas en el Manual - Wiki):
# 1. Bindu, 2009.
# 2. Manuales de IC Compiler.            
####################################################################################################################################
set home_base {/home/local/ESTUDIANTES/rcastro/dcilab/tutorial_synopsys_ibm/estimador/integracion_fisica/back_end}
set tech_home {/media/datos/IBM/TECH/ibm130_lp/}

# El siguente comando concatena al search path los directorios listados

set search_path    "$home_base ./libs ./db ./source ./scripts"
set search_path [concat $search_path $tech_home/libs/milkyway $tech_home/physical $tech_home/digital]
set search_path  "$search_path $tech_home"

# Configuración de las bibliotecas de síntesis. 
set link_library  "* scx3_cmos8rf_lpvt_tt_1p2v_25c.db"
set target_library "scx3_cmos8rf_lpvt_tt_1p2v_25c.db"
set symbol_library "iogpil_cmrf8sf_rvt.sdb"

#Muestra la configuración de las biliotecas de síntesis.
echo "\n\nSettings:"
echo "search_path:       $search_path"
echo "link_library:      $link_library"
echo "target_library:    $target_library"
echo "symbol_library:    $symbol_library"
echo "home_base:	 $home_base"

#remover diseños anteriores
remove_design -designs

#Definir VSS y VDD
set mw_logic0_net VSS
set mw_logic1_net VDD

#Especificar los archivos TLUplus:Son utilizados para extraer el archivo ".spef" (capacitancias parásitas)
set_tlu_plus_files -max_tluplus cmos8rf_8MA_32_FuncCmax.tluplus -min_tluplus cmos8rf_8MA_32_FuncCmin.tluplus -tech2itf_map  cmos8rf_8MA_32.icc_maskname.map


set lib_name $home_base/libs/ibm130nm_fr/estimador.mw

create_mw_lib -technology $tech_home/physical/ibm13_8lm_2thick_3rf.tf -bus_naming_style {[%d]} $lib_name

set_mw_lib_reference -mw_reference_library $tech_home/libs/milkyway/IBM130_lef_2 $lib_name

#Abrir la base de datos MIlkway

open_mw_lib $lib_name

puts "Se abrio la base de datos"

#Importa el Gate-Level-Netlist obtenido en la Síntesis RTL

import_designs -format verilog {estimador_syn.v} -top top_linear_est_pad
puts "Se leyo el netlist"
#Resolver múltiples instancias
uniquify_fp_mw_cel
link

#Leer las especificaciones de temporizado. Archivo sdc "synopsys design constraints"
read_sdc {estimador_syn.sdc}
puts "se leyeron restricciones"
##################################################Floorplanning############################################################

#Iniciar la etapa de descripción física (floorplan)
create_floorplan -control_type width_and_height -core_width 160 -core_height 160 -no_double_back -left_io2core 20 -bottom_io2core 20 -right_io2core 20 -top_io2core 20

#Conectar los pines de alimentación del chip
derive_pg_connection -power_net "VDD" -ground_net "VSS"
derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie

#Crear los anillos de alimentación para VSS y VDD

create_rectangular_rings  -nets  {VSS}  -around rectangle -within {{10.000 10.000} {190.000 185.000}} -left_segment_layer E1 -left_segment_width 4 -extend_ll -extend_lh -right_segment_layer E1 -right_segment_width 4 -extend_rl -extend_rh -bottom_segment_layer MA -bottom_segment_width 4 -extend_bl -extend_bh -top_segment_layer MA -top_segment_width 4 -extend_tl -extend_th

create_rectangular_rings  -nets  {VDD}  -around rectangle -within {{20.000 20.000} {180.000 175.000}} -left_segment_layer E1 -left_segment_width 4 -extend_ll -extend_lh -right_segment_layer E1 -right_segment_width 4 -extend_rl -extend_rh -bottom_segment_layer MA -bottom_segment_width 4 -extend_bl -extend_bh -top_segment_layer MA -top_segment_width 4 -extend_tl -extend_th

create_power_strap -nets { VDD } -layer E1 -direction vertical -width 4
create_power_strap -nets { VSS } -layer E1 -direction vertical -width 4

#Iniciar la etapa de colocación física (placement)
create_fp_placement

##################### Sintesis del reloj #########################################
puts "Sintesis del arbol reloj"

check_legality

set_clock_tree_options -clock_trees clk -insert_boundary_cell true -ocv_clustering true -buffer_relocation true -buffer_sizing true -gate_relocation true -gate_sizing true
		
set cts_use_debug_mode true
set cts_do_characterization true

puts "stdcell_filler"

clock_opt -fix_hold_all_clocks

# DEFINING POWER/GROUND NETS AND PINS			 
derive_pg_connection -power_net VDD -ground_net VSS -power_pin VDD -ground_pin VSS	
			 
preroute_standard_cells -nets VSS -connect horizontal
preroute_standard_cells -nets VDD -connect horizontal

verify_pg_nets
verify_pg_nets  -pad_pin_connection all


puts "Se termina la sintesis de la red de reloj"


#Guardar el diseño de la colocación física
save_mw_cel -as estimador_placement

##################################################Routing################################################################
#Ininicializa routing
route_zrt_auto -max_detail_route_iterations 10

#Verificar el Routing 
verify_zrt_route

puts "Se termina primer ruteo y se verifica"

#Extraer el netlist
write_verilog ./db/estimador_phy.v

#Se insertan vias redundantes y los rellenos 

insert_stdcell_filler  -cell_without_metal "FILL64TS FILL32TS FILL16TS FILL8TS FILL4TS FILL2TS FILL1TS"

insert_well_filler -layer NWELL -higher_edge max -lower_edge min

	
# Se verifican conecciones a los rieles	
preroute_standard_cells -nets VDD -connect horizontal
preroute_standard_cells -nets VSS -connect horizontal

verify_pg_nets
verify_pg_nets  -pad_pin_connection all

puts "Se termina verificacion de alimentaciones y de los rellenos"
#Se reparan problemas por la insercion de los rellenos

route_search_repair -loop 10 -rerun_drc 

save_mw_cel -as estimador_placement


puts "Se termina el enrutamiento"

#write_verilog ./db/estimador_phy.v

#########################################################################################################################

#Extraer las capcitancias parásitas

extract_rc
write_parasitics -output {./db/estimador_phy.spef}

#Escribir el archivo con los datos de retado del layout. Standard Delay Format (SDF)
write_sdf ./db/estimador_phy.sdf

#Extraer el archivo con las especificaciones de temporizado. sdc (Synopsys Design Constraints)
write_sdc ./db/estimador_phy.sdc

#Escribir el archivo .ddc y el .def
write -format ddc -output {./db/estimador_phy.ddc}
write_def -output "$home_base/db/estimador_phy.def"

#Guardar el diseño después del enrutado físico:
save_mw_cel -as estimador_routing

#Crear el GSDII

write_stream -format gds -cells {estimador_routing } ./db/GDSII_estimador

#Reportes Routing
report_qor > reports/estimador_phy_qor.txt
report_power > reports/estimador_phy_power.txt



