`define DEBUG
`timescale 1ns/10ps
`include "../TOP/topcore_tecriscv.sv"
`include "../TOP/Status.sv"
`include "../TOP/IS25WP032D.v"

module Test_Top;

	logic clk;
	logic reset;
	wire  MISO;
	logic RX_UART;
	logic maip;
	wire MOSI;
	wire SCLK;
	wire SCS;
	wire TX_UART;
	wire [7:0] full_range_level_shifter;
        wire [31:0] IS_Val;
        wire [31:0] IS_Config;
        wire [3:0] IS_Trigger;
	wire [7:0] gpio;
        wire [7:0] Reg_GPIO_en;
        wire [7:0] Reg_GPIO_out;
        logic [7:0] Reg_GPIO_int;

 topcore_tecriscv uut (
	.clk(clk),
	.reset(reset),
	.MISO(MISO),
	.RX_UART(RX_UART),
	.maip(maip),
	.MOSI(MOSI),
	.SCLK(SCLK),
	.SCS(SCS),
	.TX_UART(TX_UART),
	.full_range_level_shifter(full_range_level_shifter),
        .IS_Val(IS_Val),
        .IS_Config(IS_Config),
        .IS_Trigger(IS_Trigger),
        .Reg_GPIO_en(Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(Reg_GPIO_out));


	IS25WP032D mem(
		.SCLK(SCLK),
		.CS(SCS),
		.SI(MOSI),
		.SO(MISO),
		.WP(1'b1),
		.SIO3(1'b1));

  initial begin
     reset <= 1;
     clk <= 0;
     Reg_GPIO_int<=0;
     maip <=0;
     RX_UART <= 1;
  end
    
  always #50 clk = ~clk;
  always@(posedge clk) begin
    prueba ();
  end 
  task prueba();
  
     if($time < 350000) begin
       reset <= 1;
       RX_UART <= 1;
     end else begin 
       reset <= 0;
       if($time >10000000) begin
         $finish;
       end
     end
     

  endtask


endmodule
