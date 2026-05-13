## Comandos tcl para la definicion del modelo UPF

set_design_attributes -attribute suppress_iss "PD_TOP top_riscv_soc/PD_CORE pad_ring_inst/PD_PADS PD_UCU top_riscv_soc/TOP/PD_SRAM"
#

set UPF_TOP_SCOPE [set_scope .]
# Power Supply Domain SOC (TOP with PADS)
create_power_domain PD_TOP 
# se crea el dominio de alimentación del CORE, SRAM, PADS y el bloque de la UCU
set_scope /pad_ring_inst
#create_power_domain PD_PADS -elements {pad_ring_inst}
create_power_domain PD_PADS
set_scope $UPF_TOP_SCOPE

#create_power_domain PD_UCU
set_scope $UPF_TOP_SCOPE
set_scope /top_riscv_soc
create_power_domain PD_CORE -elements {TOP SPI UART}
set_scope $UPF_TOP_SCOPE
create_power_domain PD_UCU -elements {ucu_anlg1}

### Top level connections
## VDD_1V8, Bloques a 1.8 (TOP, CORE. RAM Va por aparte)

create_supply_port VDD_1V8
create_supply_net VDD_1V8   -domain PD_TOP
#Connectamos VDD 1.8  interno del core
create_supply_net VDD_1V8  -domain {top_riscv_soc/PD_CORE}
create_supply_port VDD_1V8 -domain {top_riscv_soc/PD_CORE}
create_supply_port VSS -domain {top_riscv_soc/PD_CORE}
create_supply_net VSS -domain {top_riscv_soc/PD_CORE}
connect_supply_net {top_riscv_soc/VDD_1V8} -ports {top_riscv_soc/VDD_1V8}
#Connectamos VDD 1.8  interno del Core
connect_supply_net top_riscv_soc/VSS -ports top_riscv_soc/VSS
#Connectamos VDD 1.8  superior Core
connect_supply_net VDD_1V8 -ports {VDD_1V8 top_riscv_soc/VDD_1V8}

## VDD_3V3, Bloque a 3.3V. PADS IO
#UCU, TOP, CORE
create_supply_port VDD_3V3_PADS
create_supply_port VDD_3V3_UCU
create_supply_net VDD_3V3_PADS -domain PD_TOP
create_supply_net VDD_3V3_UCU -domain PD_TOP
create_supply_net VDD_3V3_UCU -domain {PD_UCU} -reuse


#Ahora le definimos un puerto aparte aislado a 3.3 para los Level Shifters necesarios de la UCU
#Que comparta VDD_3V3 y VDD desde el top pasando por el core
create_supply_net VDD_3V3_UCU -domain {PD_UCU} -reuse
create_supply_port VDD_3V3_UCU -domain {top_riscv_soc/PD_CORE}
connect_supply_net {top_riscv_soc/VDD_3V3} -ports {top_riscv_soc/VDD_3V3}
#PADS
create_supply_port VDD_3V3 -domain {pad_ring_inst/PD_PADS}
create_supply_net VDD_3V3 -domain PD_TOP
create_supply_net VDD_3V3 -domain {pad_ring_inst/PD_PADS}
create_supply_port VSS -domain {pad_ring_inst/PD_PADS}
create_supply_net VSS -domain {pad_ring_inst/PD_PADS}
#Connectamos VDD 3.3 interno de los pads
connect_supply_net {pad_ring_inst/VDD_3V3} -ports {pad_ring_inst/VDD_3V3}
#Connectamos VSS interno de los pads
connect_supply_net {pad_ring_inst/VSS} -ports {pad_ring_inst/VSS}
#Volvemos al nivel superior
set_scope $UPF_TOP_SCOPE
#Conectamos la red superior de VDD_3V3
connect_supply_net VDD_3V3 -ports {VDD_3V3 pad_ring_inst/VDD_3V3 top_riscv_soc/VDD_3V3}

#Conectamos la red de la UCU


## VDD_1V8SRAM, Bloque SRAM 1.8
create_supply_net VDD_1V8SRAM   -domain PD_TOP
create_supply_port VDD_1V8SRAM
set_scope {top_riscv_soc/TOP}
create_power_domain PD_SRAM -elements {Memoria_8K}
create_supply_net VDD_1V8SRAM   -domain  PD_SRAM
create_supply_port VDD_1V8SRAM -domain  PD_SRAM
connect_supply_net VDD_1V8SRAM -ports VDD_1V8SRAM
## VSS SRAM
create_supply_port VSS -domain  PD_SRAM
create_supply_net VSS   -domain  PD_SRAM
connect_supply_net VSS -ports VSS
#create_supply_net VSS   -domain  PD_SRAM
#Dominios de potencia para las cajas negras
#Memory is instantiated in top_riscv_tec_pads/top_riscv_soc/TOP
set_scope $UPF_TOP_SCOPE
connect_supply_net VDD_1V8SRAM -ports {VDD_1V8SRAM top_riscv_soc/TOP/VDD_1V8SRAM}

## VSS (0.0) TOP
create_supply_port VSS
#create_supply_port VSS -domain PD_UCU -reuse
create_supply_net VSS -domain PD_TOP 
create_supply_net VSS -domain {top_riscv_soc/PD_UCU} -reuse
#create_supply_net VSS -domain top_riscv_soc/TOP/PD_SRAM; #-reuse
create_supply_net VSS -domain {pad_ring_inst/PD_PADS} -reuse
connect_supply_net VSS -ports {VSS top_riscv_soc/VSS top_riscv_soc/TOP/VSS pad_ring_inst/VSS}


#Definimos las redes de conexion
set_domain_supply_net pad_ring_inst/PD_PADS -primary_power_net pad_ring_inst/VDD_3V3 -primary_ground_net pad_ring_inst/VSS
set_domain_supply_net PD_TOP -primary_power_net VDD_1V8 -primary_ground_net VSS
set_domain_supply_net top_riscv_soc/PD_CORE -primary_power_net top_riscv_soc/VDD_1V8 -primary_ground_net top_riscv_soc/VSS
set_domain_supply_net top_riscv_soc/TOP/PD_SRAM -primary_power_net top_riscv_soc/TOP/VDD_1V8SRAM -primary_ground_net top_riscv_soc/TOP/VSS
set_domain_supply_net top_riscv_soc/PD_UCU -primary_power_net top_riscv_soc/VDD_3V3 -primary_ground_net top_riscv_soc/VSS
## Faltan conexiones SRAM, UCU


#-reuse option is used to share supply nets between power domains in te same scope

### Power State Table
add_port_state VDD_1V8 -state {LV 1.8}
add_port_state VDD_1V8SRAM -state {LV 1.8}
add_port_state top_riscv_soc/VDD_1V8 -state {LV 1.8}
add_port_state top_riscv_soc/TOP/VDD_1V8SRAM -state {LV 1.8}
add_port_state VDD_3V3 -state {HV 3.3}
add_port_state pad_ring_inst/VDD_3V3 -state {HV 3.3}
add_port_state top_riscv_soc/VDD_3V3 -state {HV 3.3}

add_port_state VSS -state {GND 0}
add_port_state top_riscv_soc/TOP/VSS -state {GND 0}
add_port_state top_riscv_soc/VSS -state {GND 0}
add_port_state pad_ring_inst/VSS -state {GND 0}
#####################
### Set Level Shifter Strategy
####################
set_level_shifter ls_1 -domain top_riscv_soc/PD_UCU  -applies_to inputs -location self -name_prefix PD_UCU
# level shifter de 3.3V a 1.8V  me parece que esta no se ocupa
#set_level_shifter LSHVT3VDHDX1 -domain COUT
#############
# SWITCH
#set_isolation gprs_iso_out #  -domain GPRS #  -isolation_power_net VDD -isolation_ground_net VSS #  -clamp_value 1 #  -applies_to outputs
#set_isolation_control gprs_iso_out #  -domain GPRS #  -isolation_signal PwrCtrl/gprs_iso #  -isolation_sense low #  -location parent
# RETAIN
## MULT SETUP
#############
# SWITCH
# ADD PORT STATE INFO
#####################
#edbab
###################################################################################################################################################
