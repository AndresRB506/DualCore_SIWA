## Comandos tcl para la definicion del modelo UPF

#set_design_attributes -attribute suppress_iss "PD_TOP top_riscv_soc/PD_CORE pad_ring_inst/PD_PADS PD_UCU top_riscv_soc/TOP/PD_SRAM"
#
#Vamos siempre a la raiz
set_scope
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
set_scope {TOP}
create_power_domain PD_SRAM -elements {Memoria_8K}
set_scope $UPF_TOP_SCOPE
#set_scope /ucu_anlg1
#create_power_domain PD_UCU
set_scope $UPF_TOP_SCOPE
### Top level connections
## VDD_1V8, Bloques a 1.8 (TOP, CORE. SRAM Va con propia fuente)

create_supply_port VDD_1V8
create_supply_port VDD_1V8SRAM
create_supply_net VDD_1V8   -domain PD_TOP
#create_supply_net VDD_1V8   -domain {ucu_anlg1/PD_UCU}
create_supply_net VDD_1V8SRAM   -domain PD_TOP

#Connectamos VDD 1.8  interno del core y LS 1.8 para salir a la UCU
# Segun manual, la celda 
#es una celda que debe colocarse en el dominio destino, de donde saldra la alimentacion
#VEr pagina 15 del Application Note MultiVoltage Libraries for XH018
create_supply_net VDD_1V8  -domain {top_riscv_soc/PD_CORE}
create_supply_port VDD_1V8 -domain {top_riscv_soc/PD_CORE}
create_supply_net VDD_1V8SRAM  -domain {top_riscv_soc/PD_CORE}
create_supply_port VDD_1V8SRAM -domain {top_riscv_soc/PD_CORE}
create_supply_port VSS -domain {top_riscv_soc/PD_CORE}
create_supply_net VSS -domain {top_riscv_soc/PD_CORE}
connect_supply_net {top_riscv_soc/VDD_1V8} -ports {top_riscv_soc/VDD_1V8}
connect_supply_net {top_riscv_soc/VDD_1V8SRAM} -ports {top_riscv_soc/VDD_1V8SRAM}
#Connectamos VDD 1.8  interno del Core
connect_supply_net {top_riscv_soc/VSS} -ports {top_riscv_soc/VSS}
#Connectamos VDD 1.8  superior Core
connect_supply_net VDD_1V8 -ports {VDD_1V8 top_riscv_soc/VDD_1V8}
#Conectando a puerto interno de 1.8 al bloque de la ucu
#connect_supply_net VDD_1V8 -ports {VDD_1V8 top_riscv_soc/VDD_1V8 ucu_anlg1/VDD_1V8}

## VDD_3V3_PADS, Bloque a 3.3V PADS
## VDD_3V3_UCU, Bloque a 3.3V Level Shifters 1.8 a 3.3 pra la UCU
## VDD_18V_PADS, Alimentacions 1.8V para los Level Shifters en los PADs
#UCU, TOP, CORE
create_supply_port VDD_3V3_PADS; #-domain PD_TOP
create_supply_port VDD_1V8_PADS; # -domain PD_TOP
#create_supply_port VDD_3V3_UCU;
create_supply_net VDD_3V3_PADS -domain PD_TOP
create_supply_net VDD_1V8_PADS -domain PD_TOP
#create_supply_net VDD_3V3_UCU -domain PD_TOP
#set_scope /ucu_anlg1
#Conexiones locales
#
#create_supply_port VDD_1V8  -domain {ucu_anlg1/PD_UCU};
#create_supply_port VDD_3V3_UCU  -domain {ucu_anlg1/PD_UCU};
#create_supply_net VDD_3V3_UCU -domain {ucu_anlg1/PD_UCU}
#create_supply_net VSS       -domain {ucu_anlg1/PD_UCU}
#create_supply_port VSS       -domain {ucu_anlg1/PD_UCU}
#connect_supply_net ucu_anlg1/VDD_3V3_UCU -ports {ucu_anlg1/VDD_3V3_UCU}
#connect_supply_net ucu_anlg1/VDD_1V8 -ports {ucu_anlg1/VDD_1V8}
#connect_supply_net ucu_anlg1/VSS -ports {ucu_anlg1/VSS}
#connect_supply_net VDD_1V8 -ports {ucu_anlg1/VDD_1V8}
#Ahora le definimos un puerto aparte aislado a 3.3 para los Level Shifters necesarios de la UCU
#Que comparta VDD_3V3_UCU y VDD_1V8 desde el top pasando por el core

#connect_supply_net {top_riscv_soc/VDD_3V3} -ports {top_riscv_soc/VDD_3V3}
###### Conexiones para los PADS
create_supply_port VDD_3V3_PADS -domain {pad_ring_inst/PD_PADS}
create_supply_net VDD_3V3_PADS -domain {pad_ring_inst/PD_PADS}
create_supply_port VDD_1V8_PADS -domain {pad_ring_inst/PD_PADS}
create_supply_net VDD_1V8_PADS -domain {pad_ring_inst/PD_PADS}
create_supply_port VSS -domain {pad_ring_inst/PD_PADS}
create_supply_net VSS -domain {pad_ring_inst/PD_PADS}
#Connectamos VDD 3.3 interno de los pads
connect_supply_net {pad_ring_inst/VDD_3V3_PADS} -ports {pad_ring_inst/VDD_3V3_PADS}
#Connectamos VDD 1.8 interno de los pads
connect_supply_net {pad_ring_inst/VDD_1V8_PADS} -ports {pad_ring_inst/VDD_1V8_PADS}
#Connectamos VSS interno de los pads
connect_supply_net {pad_ring_inst/VSS} -ports {pad_ring_inst/VSS}
#Volvemos al nivel superior
set_scope $UPF_TOP_SCOPE
#Conectamos la red superior de VDD_3V3_PADS, VDD_1V8_PADS y VDD_3V3_UCU
connect_supply_net VDD_3V3_PADS -ports {VDD_3V3_PADS pad_ring_inst/VDD_3V3_PADS}
connect_supply_net VDD_1V8_PADS -ports {VDD_1V8_PADS pad_ring_inst/VDD_1V8_PADS}
#connect_supply_net VDD_3V3_UCU -ports {VDD_3V3_UCU ucu_anlg1/VDD_3V3_UCU}
######## Conectamos la red de la UCU (Level Shifters de 1.8 a 3.3) #########3


## VDD_1V8SRAM, Bloque SRAM 1.8
set_scope {top_riscv_soc/TOP}
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
connect_supply_net VDD_1V8SRAM -ports {VDD_1V8SRAM top_riscv_soc/VDD_1V8SRAM top_riscv_soc/TOP/VDD_1V8SRAM}

## VSS (0.0) Terminamos de conectar todos los VSS
create_supply_port VSS
#create_supply_port VSS -domain PD_UCU -reuse
create_supply_net VSS -domain PD_TOP 
#connect_supply_net VSS -ports {VSS top_riscv_soc/VSS top_riscv_soc/TOP/VSS pad_ring_inst/VSS ucu_anlg1/VSS}
connect_supply_net VSS -ports {VSS top_riscv_soc/VSS top_riscv_soc/TOP/VSS pad_ring_inst/VSS}

#Definimos las redes de conexion
#set_domain_supply_net {ucu_anlg1/PD_UCU} -primary_power_net {ucu_anlg1/VDD_1V8}  -primary_ground_net {ucu_anlg1/VSS};
set_domain_supply_net {pad_ring_inst/PD_PADS} -primary_power_net {pad_ring_inst/VDD_1V8_PADS} -primary_ground_net {pad_ring_inst/VSS}
set_domain_supply_net PD_TOP -primary_power_net {VDD_1V8} -primary_ground_net {VSS}
set_domain_supply_net {top_riscv_soc/PD_CORE} -primary_power_net {top_riscv_soc/VDD_1V8} -primary_ground_net {top_riscv_soc/VSS}
set_domain_supply_net {top_riscv_soc/TOP/PD_SRAM} -primary_power_net {top_riscv_soc/TOP/VDD_1V8SRAM} -primary_ground_net {top_riscv_soc/TOP/VSS};
#set_voltage 3.3 -object_list {ucu_anlg1/VDD_3V3_UCU pad_ring_inst/VDD_3V3_PADS};
set_voltage 3.3 -object_list {pad_ring_inst/VDD_3V3_PADS};
#set_voltage 1.8 -object_list {ucu_anlg1/VDD_1V8 top_riscv_soc/TOP/VDD_1V8SRAM pad_ring_inst/VDD_1V8_PADS};
set_voltage 1.8 -object_list {top_riscv_soc/TOP/VDD_1V8SRAM pad_ring_inst/VDD_1V8_PADS};
#set_voltage 0.0 -object_list {ucu_anlg1/VSS top_riscv_soc/TOP/VSS pad_ring_inst/VSS top_riscv_soc/VSS};
set_voltage 0.0 -object_list {top_riscv_soc/TOP/VSS pad_ring_inst/VSS top_riscv_soc/VSS};

#-reuse option is used to share supply nets between power domains in te same scope

### Power State Table
add_port_state VDD_1V8 -state {LV 1.8}
add_port_state VDD_1V8SRAM -state {LV 1.8}
add_port_state top_riscv_soc/VDD_1V8 -state {LV 1.8}
add_port_state top_riscv_soc/VDD_1V8SRAM -state {LV 1.8}
add_port_state top_riscv_soc/TOP/VDD_1V8SRAM -state {LV 1.8}
#add_port_state {ucu_anlg1/VDD_1V8} -state {LV 1.8}
add_port_state VDD_3V3_PADS -state {HV 3.3}
add_port_state pad_ring_inst/VDD_3V3_PADS -state {HV 3.3}
add_port_state VDD_1V8_PADS -state {LV 1.8}
add_port_state pad_ring_inst/VDD_1V8_PADS -state {LV 1.8}
#add_port_state VDD_3V3_UCU -state {HV 3.3}
#add_port_state ucu_anlg1/VDD_3V3_UCU -state {HV 3.3}

add_port_state VSS -state {GND 0}
add_port_state top_riscv_soc/TOP/VSS -state {GND 0}
add_port_state top_riscv_soc/VSS -state {GND 0}
add_port_state pad_ring_inst/VSS -state {GND 0}
#add_port_state ucu_anlg1/VSS -state {GND 0}
#####################
### Set Level Shifter Strategy
####################
#set_level_shifter ls_1 -domain top_riscv_soc/PD_UCU  -applies_to inputs -location self -name_prefix PD_UCU
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
