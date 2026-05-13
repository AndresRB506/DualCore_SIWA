set_fp_rail_constraints -set_global   -no_routing_over_hard_macros -no_routing_over_soft_macros

set_pnet_options -partial {METTP METTPL}
#Sintesis del ring de alimentacion del core

set MAX_RING [expr 5 * $CELL_HEIGHT]
set MIN_RING [expr 4 * $CELL_HEIGHT]
set MIN_SPACING [expr 3 * $BASIC_TRACK]
set MIN_WIDHT_STRAP [expr 3 * $BASIC_TRACK]
set MIN_SPACING_RINGS [expr 1 * $CELL_HEIGHT]

set_fp_rail_voltage_area_constraints  -voltage_area top_riscv_soc/PD_CORE -power_budget 150.000 -voltage_supply 1.8 -nets  {VDD_1V8 VSS}
set_fp_rail_voltage_area_constraints -voltage_area top_riscv_soc/PD_CORE -layer METTPL -direction vertical -max_strap 20 -min_strap 4 \
	-min_width $MIN_WIDHT_STRAP -spacing $MIN_SPACING_RINGS
set_fp_rail_voltage_area_constraints -voltage_area top_riscv_soc/PD_CORE -layer METTP -direction horizontal -max_strap 20 -min_strap 4 \
	-min_width $MIN_WIDHT_STRAP -spacing $MIN_SPACING_RINGS
set_fp_rail_voltage_area_constraints -voltage_area top_riscv_soc/PD_CORE -ring_nets  {VDD_1V8 VSS}  -ring_spacing $MIN_SPACING_RINGS \
	-horizontal_ring_layer { METTP } -vertical_ring_layer { METTPL } -ring_max_width $MAX_RING -ring_min_width $MIN_RING -extend_strap voltage_area_ring;  #-spacing 1.68

