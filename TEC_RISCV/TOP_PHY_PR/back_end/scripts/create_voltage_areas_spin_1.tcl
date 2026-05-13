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
# Este es BBOX reportado por la creacion: Voltage area geometry : {189.420 188.245} {1497.020 1330.645}

get_attribute [get_core_area] bbox
get_attribute [get_die_area] bbox
## BBOX Area reportada para el CORE, si abrir espacio  a Alfredo {189.420 188.525} {1497.020 1330.925}
## BBOX Area reportada para el CORE, abriendo espacio a Alfredo {189.420 188.525} {1474.620 1330.925}
## BBOX Area reportada para el DIE {0.000 0.000} {1520.000 1520.000}



# 166 CELL_HEIGHTS
#Dejamos 8 tracks a la derecha para poder acomodar buffers del DEFAULT_VA hacia los puertos de Level Shifting del UCU

# La formula es UPPER_MOST_CORNER_X=RIGHT_BOUNDARY-CELL_HEIGHT
# Meter luego en script usando lindex 
create_voltage_area   -coordinate {189.420 188.525  1465.660 584.485 918.1 584.485  1465.660 1330.925  } -is_fixed -power_domain top_riscv_soc/PD_CORE -target_utilization 0.80000 -cycle_color

create_voltage_area   -coordinate {189.420 586.485 913.1 1330.645 } -is_fixed -power_domain top_riscv_soc/TOP/PD_SRAM -target_utilization 0.90000 -cycle_color

create_voltage_area   -coordinate {   0.000 0.000   1353.000 167.000  0.000 167.000   167.000 1353.000  0.000 1353.000   1338.000 1520.0  } -is_fixed -power_domain pad_ring_inst/PD_PADS -target_utilization 0.80000 -cycle_color
