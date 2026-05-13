`timescale 1ns/10ps
`define DEBUG
`include "../TOPCORE/topcore_tecriscv.sv"
`include "Status.sv"
`include "IS25WP032D.v"

module topcore_tb;
	logic clk;
	logic reset;
	wire MISO;
	logic RX_UART;
	wire MOSI;
	wire SCLK;
	wire SCS;
	wire TX_UART;
	wire  [7:0] gpio;
	wire [7:0] full_range_level_shifter;
    wire [31:0] IS_Val;
    wire [31:0] IS_Config;
    wire [3:0] IS_Trigger;
    logic maip;
    wire [7:0] conf_GPIO_output;

	//////////////////////////////////////////////////////////////////////
	//Instanciamiento
	//////////////////////////////////////////////////////////////////////
	topcore_tecriscv uut(
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
	    .conf_GPIO_output(conf_GPIO_output),
	    .gpio(gpio));

	IS25WP032D mem(
		.SCLK(SCLK),
		.CS(SCS),
		.SI(MOSI),
		.SO(MISO),
		.WP(1'b1),
		.SIO3(1'b1));

	//////////////////////////////////////////////////////////////////////
	//Variables internas y parametros
	//////////////////////////////////////////////////////////////////////

	//////////////////////////////////////////////////////////////////////
	//Task y testbench
	//////////////////////////////////////////////////////////////////////
	initial begin
		clk <= 0;
		reset <= 1;
		RX_UART <= 1;
		maip <= 0; //ENTRADA NUEVA
	end

	always #25 clk=~clk;   

	always @(posedge clk)begin
		prueba();
	end

	task prueba();
	if ($time<400000)begin
      reset <=1;
      RX_UART <= 1;
      maip <= 0; //ENTRADA NUEVA
    end
    else begin
    	reset <=0;
    	if($time >4000000)begin
    		$finish;
    	end
    end
    endtask : prueba

endmodule  