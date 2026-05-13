`include "../TOP/TecRiscv_top_CPU.sv"
`include "../SPI/top_spi.sv"

module topcore_spi(
	input clk,
	input reset,
	input push_uart,
	input pop_uart,
	input [64:0] D_push_uart,
	input MISO,
	output [64:0] D_pop_uart,
	output pndng_uart,
	output pndng_anlg,
	output MOSI,
	output SCLK,
	output SCS,
	inout [7:0] gpio
        output [7:0] full_range_level_shifter,
        output [31:0] IS_Val,
        output [31:0] IS_Config,
        output [3:0] IS_Trigger
);

logic push_spi;
logic pop_spi;
logic[64:0] D_push_spi;
logic [64:0] D_pop_spi;
logic pndng_spi;

top_CPU_riscv TOP(
	.clk(clk),
    .reset(reset),
    .push_spi(push_spi),
    .push_uart(push_uart),
    .pop_spi(pop_spi),
    .pop_uart(pop_uart),
    .D_push_spi(D_push_spi),
    .D_push_uart(D_push_uart),
    .D_pop_spi(D_pop_spi),
    .D_pop_uart(D_pop_uart),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),
    .gpio(gpio),
    .full_range_level_shifter(full_range_level_shifter),
    .IS_Val(S_Val),
    .IS_Config(S_Config),
    .IS_Trigger(S_Trigger)
);

top_spi SPI(
	.CLK(clk),
	.reset(reset),
	.pndgn(pndng_spi),
	.D_pop(D_pop_spi),
	.MISO(MISO),
	.pop(pop_spi),
	.D_push(D_push_spi),
	.push(push_spi),
	.MOSI(MOSI),
	.SCLK(SCLK),
	.SCS(SCS)
);


endmodule // TecRiscv_top_CPU
