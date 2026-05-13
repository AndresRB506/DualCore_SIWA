#set_fp_strategy -unit_tile_name "unit";
#set_fp_placement_strategy -virtual_IPO on



#Solo dos esquinas por ahora
create_cell {cornerlb cornerlu} CORNERSF;

#Creamos 6 PADs VSS
#Creamos 6 PADs VSS#create_cell {vss_1_left vss_1_up vss_1_bottom vss_2_left vss_2_up vss_2_bottom} GNDORPADF
#Creamos 4 PADs VSS (GND general del circuito)
create_cell {vss_left vss_up_1   vss_up_2 vss_bottom_1 vss_bottom_2} GNDORPADF;

#Creamos 2 PADs VDD 1.8 para PADs (alimentan VDD de los PADS)
create_cell {vdd_1v8_pad_up vdd_1v8_pad_down} VDDPADF;

#Creamos 3 PADs VDD 1.8 CORE
create_cell {vdd_1v8_core_left  vdd_1v8_core_up vdd_1v8_core_down_1 vdd_1v8_core_down_2} VDDCPADF;

#Creamos 1 PADs VDD 1.8 SRAM
create_cell {vdd_1v8_sram_left} VDDCPADF;

#Creamos 2 VDD 3.3 PADS (alimentan VDDO, VDDR de los pads)

create_cell {vdd_3v3_pad_up vdd_3v3_pad_down} VDDORPADF;

#Creamos 1 VDD 3.3 UCU. Este PAD de 3.3V entrega los 3.3V aislados del UCU
#create_cell {vdd_3v3_ucu_up vdd_3v3_ucu_down} VDDIPADF;
create_cell {vdd_3v3_ucu_down} VDDIPADF;


#Conectamos a los pines de alimentacion correctos
# Revisar esto con mucho cuidado

# Colocamos los corners
set_pad_physical_constraints -pad_name "cornerlu" -side 1
set_pad_physical_constraints -pad_name "cornerlb" -side 4

# Colocamos los PADs a la izquierda
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_7__inout_pad_inst" -side 1  -order 12
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_6__inout_pad_inst" -side 1  -order 11
set_pad_physical_constraints -pad_name "pad_ring_inst/maip_pad_inst"             -side 1  -order 10
set_pad_physical_constraints -pad_name "pad_ring_inst/MISO_pad_inst"             -side 1  -order 9
set_pad_physical_constraints -pad_name "vss_left"                                -side 1 -order 8
set_pad_physical_constraints -pad_name "vdd_1v8_sram_left"                       -side 1 -order 7
set_pad_physical_constraints -pad_name "pad_ring_inst/MOSI_pad_inst"     -side 1  -order 6
set_pad_physical_constraints -pad_name "pad_ring_inst/SCLK_pad_inst"    -side 1  -order 5
set_pad_physical_constraints -pad_name "pad_ring_inst/SCS_pad_inst"     -side 1  -order 4
set_pad_physical_constraints -pad_name "vdd_1v8_core_left"              -side 1  -order 3
set_pad_physical_constraints -pad_name "pad_ring_inst/RX_UART_pad_inst" -side 1 -order 2
set_pad_physical_constraints -pad_name "pad_ring_inst/TX_UART_pad_inst" -side 1 -order 1


# Colocamos los PADs de abajo
set_pad_physical_constraints -pad_name "vdd_3v3_pad_down"              -side 4 -order 1
set_pad_physical_constraints -pad_name "vdd_1v8_core_down_1"           -side 4  -order 2
set_pad_physical_constraints -pad_name "vss_bottom_2"                  -side 4  -order 3
set_pad_physical_constraints -pad_name "pad_ring_inst/clk_pad_inst"    -side 4  -order 4
set_pad_physical_constraints -pad_name "vdd_1v8_pad_down"              -side 4 -order 5
set_pad_physical_constraints -pad_name "pad_ring_inst/reset_pad_inst"   -side 4  -order 6
set_pad_physical_constraints -pad_name "vss_bottom_1"                  -side 4  -order 7 
set_pad_physical_constraints -pad_name "vdd_1v8_core_down_2"          -side 4 -order 8
### Conexiones a bloque UCU. Por ahora comenntadas
set_pad_physical_constraints -pad_name "vdd_3v3_ucu_down"             -side 4 -order 9

# Colocamos los PADs de arriba
set_pad_physical_constraints -pad_name "vss_up_1" -side 2  -order 1
set_pad_physical_constraints -pad_name "vdd_1v8_pad_up" -side 2 -order 2
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_5__inout_pad_inst" -side 2  -order 3 
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_4__inout_pad_inst" -side 2  -order 4
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_3__inout_pad_inst" -side 2  -order 5
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_2__inout_pad_inst" -side 2  -order 6
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_1__inout_pad_inst" -side 2  -order 7
set_pad_physical_constraints -pad_name "pad_ring_inst/pad_bit_0__inout_pad_inst" -side 2  -order 8
set_pad_physical_constraints -pad_name "vdd_1v8_core_up" -side 2 -order 9 
set_pad_physical_constraints -pad_name "vdd_3v3_pad_up" -side 2 -order 10
set_pad_physical_constraints -pad_name "vss_up_2" -side 2  -order 11
## Los pines los colocaremos abajo a la derecha para salir del circuito
get_ports *HV
set_pin_physical_constraints -pin_name "*HV" -side 3





