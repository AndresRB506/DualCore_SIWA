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
#mv_no_cells_at_default_va  true
#create_voltage_area   -power_domain PD_TOP
# Este es BBOX reportado por la creacion: Voltage area geometry : { 180.040 188.960 1569.960 1304.480 }



create_voltage_area   -coordinate {176.680 177.320  1503.320 612.12  906.680 612.12   1503.320 1342.120  } -is_fixed -power_domain top_riscv_soc/PD_CORE -guard_band_x 2.0 -guard_band_y 2.0 -target_utilization 0.80000 -cycle_color

create_voltage_area   -coordinate {176.680 622.12 896.68 1342.120 } -is_fixed -guard_band_x 2.0 -guard_band_y 2.0 -power_domain top_riscv_soc/TOP/PD_SRAM -target_utilization 0.90000 -cycle_color

create_voltage_area   -coordinate {   0.000 0.000   1484.000 167.000  0.000 167.000   167.000 1353.000  0.000 1353.000   1338.000 1519.995  } -is_fixed -power_domain pad_ring_inst/PD_PADS -target_utilization 0.80000 -cycle_color


