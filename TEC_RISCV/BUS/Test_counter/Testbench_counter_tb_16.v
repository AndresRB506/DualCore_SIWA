`timescale 1ps / 1ps
`default_nettype none
`define MAX 16

module Sim_counter;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [$clog2(`MAX)-1:0] count;

	// Instantiate the Unit Under Test (UUT)
        Counter #(`MAX) uut (.count(count),
                                .clk(clk),
                                .rst(rst)
                                );

	initial begin
clk=0;
#1;

	rst = {1'b1};
#1
	rst = {1'b0};
#100
	rst = {1'b1};

		
end

always #1 clk=~clk;   
endmodule
