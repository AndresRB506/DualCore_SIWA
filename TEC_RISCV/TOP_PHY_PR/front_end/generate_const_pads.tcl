## We define operating conditions of the Pad libraries
## Leer en archivo de comandos utiles synopsys como se extraen las propiedades de las bibliotecas

set ALL_IN_EX_CLK_NAME [remove_from_collection [all_inputs] [get_ports clk_pad]]
#create a collection of all outputs
set ALL_OUT_NAME [all_outputs]
#name of the library characterization to be used 1.8V 25°C
set LIB_NAME "D_CELLS_HDLL_LPMOS_typ_1_80V_25C";


# Create a clock with a period in ns
set CLK_PER 50
create_clock -period $CLK_PER -name CLK [get_ports clk_pad]
set_clock_uncertainty -setup 0.1 [get_clocks CLK]
set_clock_uncertainty -hold 0.1 [get_clocks CLK]
set_clock_transition 0.05 [get_clocks CLK]
#set_clock_latency -source 2 [get_clocks CLK]
set_clock_latency 1 [get_clocks CLK]

# Configuración de las redes de propagación de reloj y reset
set_dont_touch_network [get_clocks CLK]
#set_dont_touch_network [get_ports reset]

# Configuración del retardo de las sañales de entrada, excepto el reloj
set_input_delay -max [expr $CLK_PER * 0.4] -clock CLK $ALL_IN_EX_CLK_NAME
set_input_delay -min 0.1 -clock CLK $ALL_IN_EX_CLK_NAME

# Configuración del retardo de las sañales de salida, excepto el reloj
set_output_delay -max [expr $CLK_PER * 0.4] -clock CLK $ALL_OUT_NAME
set_output_delay -min -0.1 -clock CLK $ALL_OUT_NAME


set_operating_conditions -library IO_CELLS_FC3V_LPMOS_UPF_typ_3_30V_3_30V_25C typ_3_30V_3_30V_25C
characterize -constraints -verbose [get_cells *_pad_inst]
