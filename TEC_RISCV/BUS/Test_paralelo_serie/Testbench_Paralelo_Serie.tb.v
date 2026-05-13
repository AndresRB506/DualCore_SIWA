`timescale 1ps / 1ps
`default_nettype none
`define SIZE 16

module Sim_serializer;

	// Inputs
	reg [`SIZE-1:0] P_in;
	reg clk;
	reg rst;
	reg s_in;
        reg sel_p_s;

	// Outputs
	wire [`SIZE-1:0] P_out;
	wire s_out;

	// Instantiate the Unit Under Test (UUT)
        serializer #(`SIZE) uut (.sel_p_s(sel_p_s),
                                .s_in(s_in),
                                .rst(rst),
                                .clk(clk),
                                .P_in(P_in),
                                .s_out(s_out),
                                .P_out(P_out));

	initial begin
clk=0;
#1;

	P_in = {`SIZE/2{2'b10}};
	rst = {1'b1};
	s_in = {1'b0};
        sel_p_s = {1'b0};
#1
	P_in = {`SIZE/2{2'b10}};
	rst = {1'b0};
	s_in = {1'b0};
        sel_p_s = {1'b1};
#2
	P_in = {`SIZE/2{2'b10}};
	rst = {1'b0};
	s_in = {1'b0};
        sel_p_s = {1'b0};
#20
	P_in = {`SIZE{1'b1}};
	rst = {1'b0};
	s_in = {1'b0};
        sel_p_s = {1'b0};

		
end

always #3 clk=~clk;   
endmodule
