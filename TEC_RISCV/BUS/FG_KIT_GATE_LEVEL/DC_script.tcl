#path to the technology directory
set tech_home [getenv xfab_tech];
#path to the top sv file
set top_file [getenv top_file];
#name of the top sv hierarchy synthesized
set top_name [getenv top_name];
#path to the saif file
#set saif_file [getenv saif_file];
#path to the proyect base location
set proy_home [getenv dc_work_area];
#name of the proyect
set proy_name [getenv proy_name];

set technology "$tech_home/synopsys/v6_0/techMW/v6_0_1_1/xt018-synopsys-techMW-v6_0_1_1/xt018_xx52_MET5_METTHK.tf";
set ref_lib_1 "$tech_home/diglibs/D_CELLS_LL/v2_0/synopsys_ICC/v2_0_0_1/xt018-D_CELLS_LL-synopsys_ICC-v2_0_0_1/xt018_xx52_MET5_METTHK_D_CELLS_LL";
set ref_lib_2 "$tech_home/diglibs/IO_CELLS_FC1V8/v1_2/synopsys_ICC/v1_2_0/xt018-IO_CELLS_FC1V8-synopsys_ICC-v1_2_0/xt018_xx52_MET5_METTHK_IO_CELLS_FC1V8";
set ref_lib [concat $ref_lib_1 $ref_lib_2];
set max_tlu "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK_max.tlu";
set min_tlu "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK_min.tlu";
set tech_itf_map "$tech_home/synopsys/v6_0/TLUplus/v6_0_1/xt018_xx52_MET5_METTHK.map";
set mw_path "$proy_home/db/$proy_name.mw"

#############################################
# Mw data base generation and design read
#############################################

create_mw_lib  -technology $technology -mw_reference_library $ref_lib -hier_separator {/}  -bus_naming_style {%d}  $mw_path;
set_mw_lib_reference [concat $ref_lib_1 $ref_lib_2]; 
open_mw_lib "db/${proy_name}.mw";
set_tlu_plus_files   -max_tluplus $max_tlu  -min_tluplus $min_tlu  -tech2itf_map $tech_itf_map 
analyze -library WORK -format sverilog $top_file 
elaborate $top_name -architecture verilog -library WORK
check_design > reports/check_design_output.log
link > reports/link_output.log

#############################################
# restrictions to the design and compilation
#############################################

set_preferred_routing_direction -layers {MET1 MET3 MET5} -direction horizontal
set_preferred_routing_direction -layers {MET2 MET4 METTPL} -direction vertical
#create a collection of all the clock nets
set ALL_IN_EX_CLK_NAME [remove_from_collection [all_inputs] [get_ports clk]]
#create a collection of all outputs
set ALL_OUT_NAME [all_outputs]
#name of the library characterization to be used 1.8V 25°C
set lib_name "D_CELLS_LL_LP5MOS_typ_1_80V_25C";
set_operating_conditions -library $lib_name;

# Create a clock with a period in ns
create_clock -period 10 -name CLK [get_ports clk]

set_clock_uncertainty -setup 0.5 [get_clocks CLK]
set_clock_uncertainty -hold 0.5 [get_clocks CLK]
set_clock_transition 0.25 [get_clocks CLK]
set_clock_latency -source 4 [get_clocks CLK]
set_clock_latency 2 [get_clocks CLK]

# Configuración de las redes de propagación de reloj y reset
set_dont_touch_network [get_clocks CLK]
#set_dont_touch_network [get_ports reset]

# Configuración del retardo de las sañales de entrada, excepto el reloj
set_input_delay -max 3 -clock CLK $ALL_IN_EX_CLK_NAME
set_input_delay -min 1 -clock CLK $ALL_IN_EX_CLK_NAME

# Configuración del retardo de las sañales de salida, excepto el reloj
set_output_delay -max 3 -clock CLK $ALL_OUT_NAME
set_output_delay -min 1 -clock CLK $ALL_OUT_NAME

# Configuración de la celda que maneja todos los puertos de entrada
set_driving_cell -lib_cell INLLX16 -library $lib_name  $ALL_IN_EX_CLK_NAME

# Configuración de la celda que maneja todos los puertos de salida
set_load [expr [load_of $lib_name/INLLX16/A] * 1] $ALL_OUT_NAME
set_max_fanout 10 $current_design

propagate_constraints
#saif_map -start
#set_power_prediction
compile_ultra  -no_autoungroup
uniquify

#############################################
# report_generation
#############################################

write -format verilog -hierarchy -output mapped_gate_level_netlist.v;
write -hierarchy -format ddc -output reports/mapped_gate_level_netlist.ddc;
#read_saif -input ./activity.saif  -instance_name Simulacion/uut -target_instance uut;
#report_power -analysis_effort high -hierarchy -levels 2 > reports/hier_power_reporst.txt;
#report_timing -path_type full -nets -input_pins -capacitance -transition_time -max_paths 10 -significant_digits 3 > reports/timing_max_report.txt;
#report_timing -path_type full -nets -input_pins -capacitance -transition_time -min_paths 10 -significant_digits 3 > reports/timing_min_report.txt;
#report_area -hierarchy > reports/area_report.txt;
close_mw_lib;
exit
