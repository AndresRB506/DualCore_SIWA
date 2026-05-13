`include "../TOP/TecRiscv_top_CPU.sv"
`include "../SPI/top_spi.sv"
`include "../UART/scrs/uart.sv"

module test_ts(
	input clk,
	input reset,
	input MISO,
	input RX_UART,
	output MOSI,
	output SCLK,
	output CS,
	output TX_UART,
	inout [7:0] gpio,
        output [7:0] full_range_level_shifter,
        output [31:0] IS_Val,
        output [31:0] IS_Config,
        output [3:0] IS_Trigger,
        input maip,
        output [7:0] conf_GPIO_output
);

//Señales internas uart
logic 	push_uart;
logic 	pop_uart;
logic 	[64:0] 	D_push_uart;
logic 	[64:0] 	D_pop_uart;
logic 	pndng_uart;
//Señales internas spi 
logic 	push_spi;
logic 	pop_spi;
logic	[64:0] 	D_push_spi;
logic 	[64:0] 	D_pop_spi;
logic 	pndng_spi;

top_CPU_riscv TOP(
	.clk(clk),
    .reset(reset),
    .push_spi(push_spi),
    .push_uart(push_uart),
    .push_anlg(push_anlg),
    .pop_spi(pop_spi),
    .pop_uart(pop_uart),
    .pop_anlg(pop_anlg),
    .D_push_spi(D_push_spi),
    .D_push_uart(D_push_uart),
    .D_push_anlg(D_push_anlg),
    .D_pop_spi(D_pop_spi),
    .D_pop_uart(D_pop_uart),
    .D_pop_anlg(D_pop_anlg),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),
    .gpio(gpio),
    .pndng_anlg(pndgn_anlg)
    .full_range_level_shifter(full_range_level_shifter),
    .IS_Val(IS_Val),
    .IS_Config(IS_Config),
    .maip(maip),
    .IS_Trigger(IS_Trigger),
    .conf_GPIO_output(conf_GPIO_output)
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

uart UART(	
    .sys_clk(clk),
	.sys_rst_l(reset),
	.TX_UART(TX_UART),
	.RX_UART(RX_UART),
	.pndng_T(pndng_uart),
	.D_pop_fT(D_pop_uart),
	.pop_T(pop_uart),
	.D_push_fR(D_push_uart),
	.push_fR(push_uart)
);

endmodule // TecRiscv_top_CPU
