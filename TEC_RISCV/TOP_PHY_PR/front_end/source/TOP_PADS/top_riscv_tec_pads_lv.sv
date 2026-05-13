// Author Alfonso Chacon Rodriguez
// Sept 2, 2018
// Revision 0.1
// Revision date: 
// Checks: Ronny Garcia Ramirez
// 


// SoC Core
`include "../TOP/topcore_tecriscv.sv"
`include "../TOP_PADS/pad_ring.sv"
//`include "../TOP_PADS/ucu_anlg.sv"
// Verilog models for RTL simulation with pads are defined within pad_ring.sv
// Uncomment when in Debug Mode
//

// Signals with a "_pad" suffix are connected to a IO Pad
// Signals with a "anlg" suffix are connected to a 3.3V Domain
// The latter signals will later become internal in order to connect to microDIE's hard macro interface registers

module top_riscv_tec_pads(
	input clk_pad,
	input reset_pad,
	input MISO_pad,
	input RX_UART_pad,
        input maip_pad,
	inout MOSI_pad,
	inout SCLK_pad,
	inout SCS_pad,
	inout TX_UART_pad,
	inout [7:0] gpio_pad,
 // Estas salidas no estan alambradas a PADs, sino que vienen de los Level Shifters de 3.3V
/*	output clk_HV, 
	output reset_HV,
	output [7:0] 	full_range_level_shifter_HV,
	output [31:0] 	IS_Val_HV,
	output [31:0]	IS_Config_HV,
	output [3:0]	IS_Trigger_HV 
*/		//Salidas definidas para bloque UCU en 1.8V
//	output clk, 
//	output reset,
	output [7:0] 	full_range_level_shifter,
	output [31:0] 	IS_Val,
	output [31:0]	IS_Config,
	output [3:0]	IS_Trigger 
);

// 
// PADS wiring
logic    clk,
	reset,
	MISO,
	RX_UART,	
	MOSI,
	SCLK,
	SCS,
	TX_UART,
	maip;
//Bidirectional pads
logic	[7:0] gpio;
logic   [7:0] Reg_GPIO_en;
logic   [7:0] Reg_GPIO_int;
logic   [7:0] Reg_GPIO_out;


//Alambrado para salidas en HV (3.3) desde el TOP
//logic		clk_HV, reset_HV;
//wire [7:0] 	full_range_level_shifter;
//wire [31:0] 	IS_Val;
//wire [31:0]	IS_Config;
//wire [3:0]	IS_Trigger;

topcore_tecriscv top_riscv_soc(
	.clk(clk),
	.reset(reset),
	.full_range_level_shifter(full_range_level_shifter),
	.IS_Val(IS_Val),
	.IS_Config(IS_Config),
	.IS_Trigger(IS_Trigger),
	.MISO(MISO),
	.RX_UART(RX_UART),
	.MOSI(MOSI),
	.SCLK(SCLK),
	.SCS(SCS),
	.TX_UART(TX_UART),
	.maip(maip),
	.Reg_GPIO_en(Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(Reg_GPIO_out)
);

// PAD connections
// PAD_enablers

wire gnd_en;

// Module HV de salida para la UCU

/*ucu_anlg ucu_anlg1(	
        .clk(clk),
	.reset(reset),
	.full_range_level_shifter(full_range_level_shifter),
	.IS_Val(IS_Val),
	.IS_Config(IS_Config),
	.IS_Trigger(IS_Trigger),
	.clk_HV(clk_HV),
	.reset_HV(reset_HV),
	.full_range_level_shifter_HV(full_range_level_shifter_HV),
	.IS_Val_HV(IS_Val_HV),
	.IS_Config_HV(IS_Config_HV),
	.IS_Trigger_HV(IS_Trigger_HV));
*/

// Instancion del anillo de pads
pad_ring pad_ring_inst(.clk_pad(clk_pad),
		 	.reset_pad(reset_pad),
			.MISO_pad(MISO_pad),
			.RX_UART_pad(RX_UART_pad),
			.MOSI_pad(MOSI_pad),
			.SCLK_pad(SCLK_pad),
			.SCS_pad(SCS_pad),
			.TX_UART_pad(TX_UART_pad),
			.gpio_pad(gpio_pad),
			.maip_pad(maip_pad),
			.clk(clk),
		 	.reset(reset),
			.MISO(MISO),
			.RX_UART(RX_UART),
			.MOSI(MOSI),
			.SCLK(SCLK),
			.SCS(SCS),
			.TX_UART(TX_UART),
			.maip(maip),
			.Reg_GPIO_en(Reg_GPIO_en),
        		.Reg_GPIO_int(Reg_GPIO_int),
        		.Reg_GPIO_out(Reg_GPIO_out)

);


endmodule

