module ucu_anlg (
// Entradas a 1.8 V
	input clk,
	input reset,
	input [7:0] 	full_range_level_shifter,
	output [31:0] 	IS_Val,
	output [31:0]	IS_Config,
	output [3:0]	IS_Trigger, 
 // Salidas  3.3 V
	output clk_HV, 
	output reset_HV,
	output [7:0] 	full_range_level_shifter_HV,
	output [31:0] 	IS_Val_HV,
	output [31:0]	IS_Config_HV,
	output [3:0]	IS_Trigger_HV 
);

endmodule
