`timescale 1ps / 1ps
//`default_nettype none
`define TESTING
`include "fifo.sv"

module test_edges;

	// Inputs
	reg clk;

	// Outputs
	wire out_pos;
        wire out_neg;
        wire hold0;

	// Instantiate the Unit Under Test (UUT)
        pos_edge  uut_pos ( .clk(clk),.out(out_pos));
        buf #(2,2) chain (hold0,out_pos);
        neg_edge  uut_neg ( .clk(hold0),.out(out_neg));

	initial begin
          clk=0;
		
        end

        always #40 clk=~clk;   
        
        always @(clk)begin
         prueba();
       end
     
       task prueba();
         if($time >= 500)begin
           $finish;
         end
       endtask
    

endmodule
