#####################################################################################################
#Institución:	Instituto Tecnológico de Costa Rica
#
#Realizado por:	Jairo Mauricio Valverde Cruz	jmvc04@gmail.com
#Corregido por:	Reinaldo Castro González	leinardo.soctra@gmail.com
#
# Proyecto:	ALU de secuencia: 1101. Proyecto creado con fines didácticos.
#
# Herramienta:	Design Compiler  Version L-2016.03-SP3 for linux64 - Jul 18, 2016
#
# Fecha de creación:  27 Agosto 2011 editado en 21 Noviembre 2017
#
# Refrencias (detalladas en el Manual - Wiki):
# 1. A. Chacón, 2009.  
# 2. Manuales de Design Compiler.
# 3. Bindu, 2009. 
#####################################################################################################

# Eliminar diseños previos
remove_design -designs


saif_map -start
# Primero se analiza el módulo principal
analyze -library WORK -format sverilog {controlador.sv}

#Luego se analiza los otros módulos
analyze -format sverilog {bus_fsm.sv core_fsm.sv error_handler.sv mem_sgnl_gen.sv fifo.sv}

#Elaboramos el módulo principal
elaborate controlador -architecture verilog -library WORK

#Enlazar los demás módulos al módulo principal
link

#set_power_prediction

#Escribir el archivo *.ddc (base de datos sin sintetizar)
write -hierarchy -format ddc -output ./db/controlador_unmapped.ddc

#Aplicar especificaciones de diseño (constraints)
source controlador_constraint.tcl
propagate_constraints

#Revisar el diseño
check_design

reset_switching_activity
read_saif -input controlador.saif -instance_name tb_controlador/inst_controller -auto_map_names
#Compilar el diseño
compile_ultra

#Escribir la lista de nodos a nivel de compuertas (Gate Level Netlist) que se utiliza para:
#- Verificar el funcionamiento lógico del sistema digital después de la Síntesis RTL.
#- Como una de las entradas para el sintetizador físico (IC Compiler).
set verilogout_no_tri true
change_names -hierarchy -rules verilog 
write -hierarchy -format verilog -output ./db/controlador.v

#Generar los reportes

report_power -analysis_effort high > reports/controlador_power.txt
report_area > reports/controlador_area.txt
report_cell > reports/controlador_cell.txt
report_qor > reports/controlador_qor.txt
report_timing > reports/controlador_timing.txt
report_port > reports/controlador_port.txt

#Escribir el archivo *.ddc (base de datos sintetizada)5
write -hierarchy -format ddc -output ./db/controlador_mapped.ddc

#Escribir el archivo *.sdc (Synopsys Design Constraints), utilizado como una de las entradas 
#para el sintetizador físico (IC Compiler)
write_sdc ./db/controlador.sdc

#Revisar la configuración de temporizado
check_timing

set_fix_hold $CLK_NAME
compile_ultra -incremental -only_design_rule

report_constraint -all_violators
redirect reports/controlador.rpt {report_constraint -all_violators}
