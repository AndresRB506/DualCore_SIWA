##############################################################################################
#########               Primera colocacion  						######### 
########       Se definen areas de voltaje    ########################
##############################################################################################
## Se debe bloquear el ruteo sobre la SRAM, y se genera una zona de exclusion a su alrededr
## Leer manual de la XSPRAMLP_2048X32_M8P para detalles
## HTTML en file:///mnt/vol_NFS_Zener/WD_ESPEC/achacon/Herramientas/X-FAB/XH018/xh018/spram/XSPRAMBLP_256X32_M8P/v4_0_1/doc/XSPRAMBLP_256X32_M8P.html#TIMING_PARAMETERS
##
#Vamos a crear las areas de voltaje 
#Tratando de hacer coincidir la PD_TOP con la PD_CORE

#Evitamos que se pongan celdas en la zona de MultiVoltaje
mv_no_cells_at_default_va  true
#create_voltage_area   -power_domain PD_TOP
# Este es BBOX reportado por la creacion: Voltage area geometry : { 180.040 188.960 1569.960 1304.480 }

#create_voltage_area   -coordinate { 180.000 190.000 1530.000 570.000 920.000 570.000 1530.000 1304.000 } \
# -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color

# En esta que sigue, usamos todo el core basado en lo que reporta el area del Default VA
#create_voltage_area   -name soc_core -coordinate { 180.040 188.960 1569.960 570.000 920.000 570.000 1569.960 1304.480} \
# -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color

#create_voltage_area   -coordinate { 180.040 188.960 1569.960 570.000 920.000 570.000 1569.960 1304.480} \
# -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color

create_voltage_area   -coordinate { 180.040 188.960 1509.960 570.000 920.000 570.000 1509.960 1304.480} \
 -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color

create_voltage_area   -coordinate {180.040 580.00 910.00 1304.480 } -is_fixed -power_domain top_riscv_soc/TOP/PD_SRAM -target_utilization 0.90000 -cycle_color

create_voltage_area   -coordinate {0.000 0.000   1516.000 176.000  0.000 176.000   172.000 1320.000 \
                       0.000 1320.000   1407.000 1494.000  } -is_fixed -power_domain pad_ring_inst/PD_PADS -target_utilization 0.90000 -cycle_color

create_voltage_area   -coordinate {  1517.410 580.260 1569.275 1303.995 } -is_fixed -power_domain ucu_anlg1/PD_UCU -guard_band_x 5.0 -guard_band_y 5.0 -target_utilization 0.80000 -cycle_color
### Conexiones a bloque UCU. Por ahora comenntadas
#create_voltage_area   -coordinate { 210.000 220.000 1520.000 550.000 950.000 550.000 1520.000 1280.000 } -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color
#Vamos a crear la zona de voltaje de la UCU afuera del CORE para colocar a mano los Level Shifters
#create_voltage_area   -coordinate {  1540.000 760.000 1570.000 1300.000 } -is_fixed -power_domain ucu_anlg1/PD_UCU -target_utilization 0.80000 -cycle_color
#Por ahora le damos 20 micrometros de ancho luego habra que meterle mas.
#create_voltage_area   -coordinate {  1571.000 750.000 1591.000 1304.480 } -is_fixed -power_domain ucu_anlg1/PD_UCU -target_utilization 0.80000 -cycle_color
