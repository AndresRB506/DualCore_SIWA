# reset
set_fp_rail_constraints -remove_all_layers
remove_fp_virtual_pad -all              
set_fp_rail_strategy -reset             
set_fp_block_ring_constraints -remove_all
set_fp_rail_region_constraints  -remove 
# global constraints
set_fp_rail_constraints -set_global 

# layer constraints
set_fp_rail_constraints -add_layer  -layer METTPL -direction vertical -max_strap 30 -min_strap 3 -max_width 10.000000 -min_width 3.000000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer METTP -direction horizontal -max_strap 30 -min_strap 3 -max_width 10.000000 -min_width 3.000000 -spacing minimum 

# ring and strap constraints
set_fp_rail_constraints  -set_ring -nets { VDD VSS } -horizontal_ring_layer { METTP } -vertical_ring_layer { METTPL } -extend_strap core_ring 

# strategies
set_fp_rail_strategy  -use_tluplus true 

# block ring constraints

# regions

# virtual pads

# synthesize_fp_rail 
synthesize_fp_rail -nets { VDD VSS } -voltage_supply 1.800000 -power_budget 1000.000000  -use_strap_ends_as_pads  
