###################################################################################################
### Title:		crear_mw.tcl							 
### Description:	Script que crea la base de datos Milkyway para el Galaxy de Synopsys
### 			contiene las referenicas de las bibliotecas fisicas de la tecnologia	 
### Dependencies: 	Ninguna. 								 
### Project:		Microcontrolador RISCV							 
### Author:		Reinaldo Castro Gonzalez						 
### Institution:	Instituto Tecnologico de Costa Rica. DCILab				 
### Date:		26 de Febrero de 2018							 
### Notes:		Se debe correr el script common_setup.tcl antes									 
### Version:		2.0									 
### Revision:		23/05/2018								 
####################################################################################################

source /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/implement/user.tcl
# Especificar los archivos TLUplus, que son utilizados para extraer el archivo ".spef" (capacitancias parasitas)
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE -min_tluplus $TLUPLUS_MIN_FILE -tech2itf_map $MAP_FILE

set mw_design_library_name "$PROY_HOME/db/be/$DESIGN_NAME/$DESIGN_NAME.mw"; # Esta ruta debe existir

# /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/mem/milk/XSPRAMLP_2048X32_M8P




# Se comprueba si existe la biblioteca mw, si esta la abre, si no la crea.
set comprobar_lib [file exists $mw_design_library_name];
if {$comprobar_lib == 0} { 
# Se crea la db de cero
create_mw_lib  -technology /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/xh018_xx43_HD_MET4_METMID_METTHK.tf -mw_reference_library {/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/synopsys_ICC/v2_1_0/xh018-D_CELLS_HDLL-synopsys_ICCompiler-v2_1_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HDLL /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC1V8/v1_0/synopsys_ICC/v1_0_1/xh018-IO_CELLS_FC1V8-synopsys_ICCompiler-v1_0_1/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_FC1V8 /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/mem/milk/XSPRAMLP_2048X32_M8P} -bus_naming_style {[%d]}  -open  /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.mw
#open_mw_lib $mw_design_library_name
} else { 
# Se abre la libreria
open_mw_lib $mw_design_library_name}
puts "Se abrio la base de datos $DESIGN_NAME.mw"

set_tlu_plus_files -max_tluplus /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK_max.tlu -min_tluplus /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK_min.tlu -tech2itf_map  /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/synopsys/v7_0/TLUplus/v7_0_1/xh018_xx43_MET4_METMID_METTHK.map
remove_design -designs

#saif_map -start

import_designs -format verilog -top CMB -cel CMB {/mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/source/CMB.v}

uniquify_fp_mw_cel


link


#reset_switching_activity
#read_saif -input /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/high_density/Back_end/source/controlador.saif -instance_name tb_controlador/inst_controller -auto_map_names

read_sdc {/mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/source/CMB.sdc}


set_fp_strategy -unit_tile_name "hdll"

create_floorplan -core_utilization 0.7 -left_io2core 40 -right_io2core 40 -top_io2core 40 -bottom_io2core 40

#En caso de necesitar crear algun ajuste  se uriliza este parametro
#adjust_fp_floorplan -core_utilization 0.7 -left_io2core 30 -right_io2core 30 -controlador_io2core 30 -bottom_io2core 30

create_fp_placement
#refine_placement
#psynopt -power

set mw_logic0_net VSS
set mw_logic1_net VDD

#Conectar los pines de alimentación del chip
derive_pg_connection -power_net "VDD" -ground_net "VSS"


set_fp_rail_constraints -add_layer -layer METTPL -min_width 3 -max_width 10 -min_strap 3 -max_strap 30
set_fp_rail_constraints -add_layer -layer METTP -min_width 3 -max_width 10 -min_strap 3 -max_strap 30

create_fp_virtual_pad -nets {VSS} -point {20 20}
create_fp_virtual_pad -nets {VDD} -point {40 40}

synthesize_fp_rail -nets {VDD VSS} -voltage_supply 1.8 -synthesize_power_plan; #Crea los rieles y reporte sobre IR Drop pero tipo plan
#Remueve los paths virtuales que sirvieron como guias 
remove_fp_virtual_pad -nets {VSS} -point {20 20}  
remove_fp_virtual_pad -nets {VDD} -point {40 40}

synthesize_fp_rail -nets {VDD VSS} -voltage_supply 1.8 -use_strap_ends_as_pads; #Ejecuta dicho plan buscando najar IRDrop

commit_fp_rail; # Satisfecho con el plan de alimentacion le dice que lo ejecute


preroute_standard_cells -nets VDD -connect horizontal; #Conecta las celdas al plano de alimentacion
preroute_standard_cells -nets VSS -connect horizontal

#Este proximo comando va encontrar los puntos donde esta red conecta con las celdas, la idea es posteriormente quitar la matriz y poner vias de alimentacion en ellas.
set puntosVP_VDD  "[regexp  -all -inline {[0-9]+\.[0-9]+ 676.050} [ get_attribute [ get_vias * -hierarchical ] center ]] [regexp  -all -inline {[0-9]+\.[0-9]+ 5.75} [ get_attribute [ get_vias * -hierarchical ] center ]]"
set puntosVP_VSS  "[regexp  -all -inline {[0-9]+\.[0-9]+ 666.3} [ get_attribute [ get_vias * -hierarchical ] center ]] [regexp  -all -inline {[0-9]+\.[0-9]+ 11.46} [ get_attribute [ get_vias * -hierarchical ] center ]]"

#Este comando buscara aquellos lugares donde puso vias de alimentacion con el fin de poder quitar el power plan antes hecho y solo colocar vias de alimentacion en estos puntos

foreach a $puntosVP_VDD { create_fp_virtual_pad -nets {VDD} -point "$a" }
foreach a $puntosVP_VSS { create_fp_virtual_pad -nets {VSS} -point "$a" }


#En rutamiento


#Reglas antena

set lib [current_mw_lib]
remove_antenna_rules $lib
# metal rules
define_antenna_rule $lib -mode 4 -diode_mode 4 -metal_ratio 400 -cut_ratio 0
define_antenna_layer_rule $lib -mode 4 -layer "MET1"   -ratio 400 -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 4 -layer "MET2"   -ratio 400 -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 4 -layer "MET3"   -ratio 400 -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 4 -layer "MET4"   -ratio 400 -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 4 -layer "METTP"  -ratio 400 -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 4 -layer "METTPL" -ratio 200 -diode_ratio {0 0 0 1e+07}
# cut rules
define_antenna_rule $lib -mode 1 -diode_mode 4 -metal_ratio 0 -cut_ratio 20
define_antenna_layer_rule $lib -mode 1 -layer "VIA1"   -ratio 20  -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 1 -layer "VIA2"   -ratio 20  -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 1 -layer "VIA3"   -ratio 20  -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 1 -layer "VIATP"  -ratio 20  -diode_ratio {0 0 0 1e+07}
define_antenna_layer_rule $lib -mode 1 -layer "VIATPL" -ratio 20  -diode_ratio {0 0 0 1e+07}


#Configuracion del ruteo
set_route_zrt_common_options -plan_group_aware all_routing; #Herramienta

route_zrt_global -effort ultra

#Primer se optimiza para timing 
optimize_fp_timing

report_timing -nets -capacitance -transition_time -input_pin

set_route_zrt_detail_options -drc_convergence_effort_level high

set_buffer_opt_strategy -effort low



set_route_zrt_detail_options -diode_libcell_names {ANTENNACELLN2HDLL ANTENNACELLNP2HDLL ANTENNACELLP2HDLL} -insert_diodes_during_routing true


#Reloj
set_clock_tree_options -clock_trees reloj -insert_boundary_cell true -ocv_clustering true -buffer_relocation true -buffer_sizing true -gate_relocation true -gate_sizing true
set cts_use_debug_mode true
set cts_do_characterization true
clock_opt -fix_hold_all_clocks
report_timing -nets -capacitance -transition_time -input_pin
set_dont_touch_network reloj


#Ruteo compuertas
route_zrt_auto -max_detail_route_iterations 10

save_mw_cel  -design "CMB.CEL";

write_verilog /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.v

#insert_stdcell_filler  -cell_without_metal "FILLER01FA FILLER02FA FILLER05FA FILLER100FA FILLER10FA FILLER20FA FILLER40FA FILLER50FA FILLER84FA"

extract_rc

 write_parasitics -output {/mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.spef}
 write_sdf /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.sdf
 write_sdc /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.sdc
 write_def -output "/mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.def"


 
set string_replace "sed -i \"s/endmodule/initial\ \\\$sdf\_annotate\(\\\"CMB.sdf\\\"\)\\\\; \\n endmodule/g\" /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/db/be/CMB/CMB.v"


save_mw_cel -as CMB_routing


report_power -hierarchy > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_power.txt
report_area -hierarchy > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_area.txt
report_cell > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_cell.txt
report_qor > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_qor.txt
report_timing > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_timing.txt
report_port > /mnt/vol_NFS_Zener/WD_ESPEC/fonsecam/Mem_HD/Back_end/reports/CMB_port.txt


report_constraint -all_violators

redirect reports/CMB.rpt {report_constraint -all_violators}
