####################################################################################################################################
#Institución:                          Instituto Tecnológico de Costa Rica

#Realizado por:		   Jairo Mauricio Valverde Cruz           jmvc04@gmail.com

#Proyecto:   Detector de secuencia: 1101. Proyecto creado con fines didácticos

#Herramienta:        Version E-2010.12-SP1 for linux -- Jan 13, 2011

#Fecha de creación:  29 Agosto 2011 

#Refrencias (detalladas en el Manual - Wiki):
# 1. Bindu, 2009. 
# 2. Manuales de Design Compiler.
####################################################################################################################################

set tech_home {/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/xh018}


# El siguente comando concatena al search path los directorios listados
set home_base {/mnt/vol_NFS_Zener/WD_ESPEC/moviedo/ALU_register/verificacion_temporizado}
set search_path    "$home_base ./libs ./reports ./source ./scripts"
set search_path [concat $search_path $tech_home/synopsys/v6_0/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/ \
				$tech_home/synopsys/v6_3/TLUplus/v6_3_1_1/  \
				$tech_home/diglibs/D_CELLS_LL/v1_1/liberty_LPMOS/v1_1_1/PVT_1_80V_range/ \
				$tech_home/diglibs/D_CELLS_LL/v1_1/dc_shell_symb/v1_1_1 \
				$tech_home/diglibs/IO_CELLS_FC1V8/v1_0/dc_shell_symb/v1_0_0/ \
				$tech_home/diglibs/IO_CELLS_FC1V8/v1_0/liberty_LPMOS/v1_0_1/PVT_1_80V_1_80V_range/]

# El comando set establece un valor para una variable. 
set target_library "D_CELLS_LL_LPMOS_typ_1_80V_25C.db IO_CELLS_FC1V8_LPMOS_typ_1_80V_1_80V_25C.db"
set link_library "* $target_library"

echo "search_path:       $search_path"
echo "link_library:      $link_library"
echo "target_library:    $target_library"

# Leer el archivo de verilog obtenido al final de la implementación física (detector_phy.v)
read_verilog /mnt/vol_NFS_Zener/WD_ESPEC/moviedo//ALU_register/verificacion_temporizado/source/top_phy.v

#Definir el módulo principal
current_design top

#Leer las capacitancias parásitas máximas
read_parasitics -format SPEF /mnt/vol_NFS_Zener/WD_ESPEC/moviedo//ALU_register/verificacion_temporizado/source/top_phy.spef.max

#Leer las especificaciones de temporizado
read_sdc /mnt/vol_NFS_Zener/WD_ESPEC/moviedo//ALU_register/verificacion_temporizado/source/top_phy.sdc

#Generar reportes de temporizado
report_timing -from [all_inputs] -to [all_registers -data_pins] -max_paths 40 > reports/entrada_registro.txt
report_timing -from [all_register -clock_pins] -to [all_registers -data_pins] -max_paths 40 > reports/registro_registro.txt
report_timing -from [all_register -clock_pins] -to [all_outputs] -max_paths 40 > reports/registro_salida.txt

#Leer las capacitancias parásitas mínimas
#read_parasitics -format SPEF /mnt/vol_NFS_Zener/WD_ESPEC/mefonseca/sintesis_AXI/AXI_bus/temporizado_layout/source/AXI_Int_phy.spef.min

#Generar el reporte de temporizado de registro a registro con el tiempo de transición y la capacitancia
report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins] > reports/criticas_tran_cap.txt


