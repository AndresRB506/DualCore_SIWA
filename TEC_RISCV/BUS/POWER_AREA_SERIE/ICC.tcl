set proy_home [getenv dc_work_area];
set tech_home /mnt/vol_NFS_Zener/tools/synopsys/pdks/xt018-ams/xt018;
set search_path "$proy_home"
set search_path [concat $search_path $proy_home/scripts $proy_home/db $proy_home/source/* \
$tech_home/diglibs/D_CELLS_LL/v2_0/dc_shell_symb/v2_0_0  $tech_home/diglibs/D_CELLS_LL/v2_0/liberty_LP5MOS/v2_0_3/PVT_1_80V_range \
$tech_home/diglibs/IO_CELLS_FC1V8/v1_2/dc_shell_symb/v1_2_0 $tech_home/diglibs/IO_CELLS_FC1V8/v1_2/liberty_LP5MOS/v1_2_1/PVT_1_80V_1_80V_range];

set synthetic_library "D_CELLS_LL.sdb"
set target_library "D_CELLS_LL_LP5MOS_typ_1_80V_25C.db";
set link_library "* $target_library $synthetic_library";
set symbol_library [concat "D_CELLS_LL.sdb"];
#Work Library Location
define_design_lib WORK -path "./work";

#Muestra la configuración de las biliotecas de síntesis.
echo "\n\nSettings:"
echo "search_path:       $search_path"
echo "link_library:      $link_library"
echo "target_library:    $target_library"
echo "symbol_library:    $symbol_library"
echo "proy_home:	 $proy_home"

#remover diseños anteriores
remove_design -designs

#Definir VSS y VDD
set mw_logic0_net VSS
set mw_logic1_net VDD

#Especificar los archivos TLUplus:Son utilizados para extraer el archivo ".spef" (capacitancias parásitas)
set max_tlu "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK_max.tlu";
set min_tlu "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK_min.tlu";
set tech_itf_map "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK.map";
set_tlu_plus_files   -max_tluplus $max_tlu  -min_tluplus $min_tlu  -tech2itf_map $tech_itf_map

#habre un mw para la base de datos ruteada.
set technology "$tech_home/synopsys/v6_0/techMW/v6_0_1_1/xt018-synopsys-techMW-v6_0_1_1/xt018_xx52_MET5_METTHK.tf";
set ref_lib_1 "$tech_home/diglibs/D_CELLS_LL/v2_0/synopsys_ICC/v2_0_0_1/xt018-D_CELLS_LL-synopsys_ICC-v2_0_0_1/xt018_xx52_MET5_METTHK_D_CELLS_LL";
set ref_lib_2 "$tech_home/diglibs/IO_CELLS_FC1V8/v1_2/synopsys_ICC/v1_2_0/xt018-IO_CELLS_FC1V8-synopsys_ICC-v1_2_0/xt018_xx52_MET5_METTHK_IO_CELLS_FC1V8";
set ref_lib [concat $ref_lib_1 $ref_lib_2];
set proyname "place_and_route_data_base";
set mw_path "$proy_home/db/$proy_name.mw"
create_mw_lib  -technology $technology -mw_reference_library $ref_lib -hier_separator {/}  -bus_naming_style {%d}  $mw_path;
set_mw_lib_reference $ref_lib;

#Abrir la base de datos MIlkway
open_mw_lib "db/${proy_name}.mw";

#Importa el Gate-Level-Netlist obtenido en la Síntesis RTL
import_designs -format verilog {"reports/mapped_gate_level_netlist.v"} -top top_del_sistema

#Resolver múltiples instancias
uniquify_fp_mw_cel
link

#Leer las especificaciones de temporizado. Archivo sdc "synopsys design constraints"
read_sdc {"db/mapped_gate_level_netlist.sdc"}
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
write_def -output "$proy_home/db/estimador_phy.def"

#Guardar el diseño después del enrutado físico:
save_mw_cel -as estimador_routing

#Crear el GSDII

write_stream -format gds -cells {estimador_routing } ./db/GDSII_estimador

#Reportes Routing
report_qor > reports/estimador_phy_qor.txt
report_power > reports/estimador_phy_power.txt



