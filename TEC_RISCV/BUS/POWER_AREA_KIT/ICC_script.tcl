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
#define_design_lib WORK -path "./work";

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
set proy_name "place_and_route_data_base";
set mw_path "$proy_home/db/$proy_name.mw"
create_mw_lib  -technology $technology -mw_reference_library $ref_lib -hier_separator {/}  $mw_path;
set_mw_lib_reference $ref_lib;
#Abrir la base de datos MIlkway
open_mw_lib "db/${proy_name}.mw";

#Importa el Gate-Level-Netlist obtenido en la Síntesis RTL
import_designs -format verilog {reports/mapped_gate_level_netlist.v} -top top_del_sistema

#Resolver múltiples instancias
uniquify_fp_mw_cel
current_design top_del_sistema
link

#da información básica del diseño cargado 
check_design;
#reporta las unidades usadas en los reportes
report_units;
#reporta los randgos en las bibliotecas cargadas
report_mw_lib -unit_range $mw_path

#Leer las especificaciones de temporizado. Archivo sdc "synopsys design constraints"
read_sdc {"db/mapped_gate_level_netlist.sdc"}
##################################################Floorplanning############################################################

# Para tomar en cuenta el consumo dinámico
set_scenario_options -dynamic_power true;
read_saif -input ./activity.saif  -instance_name Simulacion/uut -target_instance uut;


#Iniciar la etapa de descripción física (floorplan)
set_fp_strategy -unit_tile_name "ll"
create_floorplan

#Conectar los pines de alimentación del chip
derive_pg_connection -power_net "VDD" -ground_net "VSS"
derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie

#no se hace el ruteo de las líneas de poder ni tampoco el llenado final

create_fp_placement

##################### Sintesis del reloj #########################################
puts "Sintesis del arbol reloj"

check_legality

set_clock_tree_options -clock_trees clk -insert_boundary_cell true -ocv_clustering true -buffer_relocation true -buffer_sizing true -gate_relocation true -gate_sizing true
		
set cts_use_debug_mode true
set cts_do_characterization true

puts "stdcell_filler"

clock_opt -fix_hold_all_clocks

puts "Se termina la sintesis de la red de reloj"

##################################################Routing################################################################
#Ininicializa routing
route_opt;
verify_zrt_route;

puts "Se termina primer ruteo y se verifica"

#Guardar el diseño después del enrutado físico del árbol de reloj y las señales:
save_mw_cel

#Reportes Routing
report_qor > reports/place_route_qor.txt
report_power > reports/place_route_power.txt
report_area > reports/place_route_area.txt

exit
