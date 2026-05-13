#set_fp_strategy -unit_tile_name "unit";
#set_fp_placement_strategy -virtual_IPO on

save_mw_cel -as pad_ring_unplaced.CEL
open_mw_cel pad_ring_unplaced
close_mw_cel top_riscv_tec_pads

#Solo dos esquinas por ahora
create_cell {cornerlb cornerlu} CORNERSF

#Creamos 6 PADs VSS
#Creamos 6 PADs VSS#create_cell {vss_1_left vss_1_up vss_1_bottom vss_2_left vss_2_up vss_2_bottom} GNDORPADF
#Creamos 5 PADs VSS
create_cell {vss_1_left vss_1_up vss_1_bottom vss_2_up vss_2_bottom} GNDORPADF
#Creamos 3 PADs VDD 1.8 CORE
create_cell {vdd_1v8_1_left  vdd_1v8_1_up vdd_1v8_1_down} VDDCPADF

#Creamos 1 PADs VDD 1.8 SRAM
create_cell {vdd_1v8_1_sram_left} VDDCPADF

#Creamos 2 VDD 3.3 PADS
create_cell {vdd_3v3_1_pad_up vdd_3v3_1_pad_down} VDDORPADF

#Creamos 2 VDD 3.3 UCU. Este PAD de 3.3 está aislado de los 3.3 del UCUcreate_cell {vdd_3v3_1_ucu_up vdd_3v3_1_ucu_down} VDDIPADF
# Colocamos los cornersset_pad_physical_constraints -pad_name "cornerlu" -side 1set_pad_physical_constraints -pad_name "cornerlb" -side 4
# Colocamos los PADs VSSset_pad_physical_constraints -pad_name "vss_1_left" -side 1;# -order 1#set_pad_physical_constraints -pad_name "vss_2_left" -side 1;# -order 8
set_pad_physical_constraints -pad_name "vss_1_up" -side 2;# -order 1
set_pad_physical_constraints -pad_name "vss_2_up" -side 2;# -order 2set_pad_physical_constraints -pad_name "vss_1_bottom" -side 4;#  -order 1
set_pad_physical_constraints -pad_name "vss_2_bottom" -side 4;#  -order 2

# Colocamos los PADs VDD 1.8 COREset_pad_physical_constraints -pad_name "vdd_1v8_1_left" -side 1;# -order 1
set_pad_physical_constraints -pad_name "vdd_1v8_1_up" -side 2;# -order 1set_pad_physical_constraints -pad_name "vdd_1v8_1_down" -side 4;# -order 1

# Colocamos los PADs VDD 1.8 SRAM
set_pad_physical_constraints -pad_name "vdd_1v8_1_sram_left" -side 1 -order 1

# Colocamos los PADs VDD 3.3 PADs
set_pad_physical_constraints -pad_name "vdd_3v3_1_pad_up" -side 2;# -order 1
set_pad_physical_constraints -pad_name "vdd_3v3_1_pad_down" -side 4;# -order 1

# Colocamos los PADs VDD 3.3 UCU
set_pad_physical_constraints -pad_name "vdd_3v3_1_ucu_up" -side 2;# -order 1
set_pad_physical_constraints -pad_name "vdd_3v3_1_ucu_down" -side 4;# -order 1

# Colocamos los PADs IO por lado, libremente
set_pad_physical_constraints	-pad_name "pad_ring_inst/clk_pad_inst" -side 1;# -order 5
set_pad_physical_constraints	-pad_name "pad_ring_inst/MISO_pad_inst" -side 1;# -order 6
set_pad_physical_constraints	-pad_name "pad_ring_inst/RX_UART_pad_inst" -side 1;# -order 7
set_pad_physical_constraints	-pad_name "pad_ring_inst/maip_pad_inst" -side 4;# -order 3
set_pad_physical_constraints	-pad_name "pad_ring_inst/reset_pad_inst" -side 4;# -order 3
set_pad_physical_constraints	-pad_name "pad_ring_inst/MOSI_pad_inst" -side 1;# -order 9
set_pad_physical_constraints	-pad_name "pad_ring_inst/SCLK_pad_inst" -side 1;# -order 10
set_pad_physical_constraints	-pad_name "pad_ring_inst/SCS_pad_inst" -side 1;# -order 11
set_pad_physical_constraints	-pad_name "pad_ring_inst/TX_UART_pad_inst" -side 1;# -order 12
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_7__inout_pad_inst" -side 2;# -order 3
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_6__inout_pad_inst" -side 2;# -order 4
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_5__inout_pad_inst" -side 2;# -order 5
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_4__inout_pad_inst" -side 2;# -order 6
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_3__inout_pad_inst" -side 2;# -order 7
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_2__inout_pad_inst" -side 2;# -order 8
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_1__inout_pad_inst" -side 2;# -order 9
set_pad_physical_constraints	-pad_name "pad_ring_inst/pad_bit_0__inout_pad_inst" -side 2;# -order 10

## Los pines los colocaremos abajo a la derecha para salir del circuito
get_ports *HVset_pin_physical_constraints -pin_name "*HV" -side 3



