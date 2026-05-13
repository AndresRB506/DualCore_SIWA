`timescale 1ps / 1ps
`default_nettype none
`define BITS 16
`define DEPTH 16
`define TESTING
`include "fifo.sv"

module Sim_fifo;

	// Inputs
	reg clk;
	reg rst;
	reg [`BITS-1:0] Din;
        reg push;
        reg pop;

	// Outputs
	wire [`BITS-1:0] Dout;
	wire pndng;
//        wire full;
        wire MTIP;

	// Instantiate the Unit Under Test (UUT)
      ntrpt_cam_fifo #(`DEPTH,`BITS) uut(
        .clk(clk),
        .Din(Din),
        .Dout(Dout),
        .push(push),
        .pop(pop),
//        .full(full),
        .pndng(pndng),
        .reset(rst),
        .MTIP(MTIP)
    );
	
initial begin
	clk=0;
	rst = {1'b1};
        push =0;
        pop = 0;
        Din=0;
#100;
		
end

always #50 clk=~clk;   
always@(posedge clk)begin
  prueba();
end

 int ciclo =0;
 int dato =120;
 
  task prueba();

//      if(full==1)begin
      if(Sim_fifo.uut.count==`DEPTH)begin
        ciclo=3;
      end

  case(ciclo)
    
    0:begin
      rst=1;
      push=0;
      pop=0;
      Din = 0;
      ciclo = 1;
    end
    1:begin
      rst=0;
      push=0;
      pop=0;
      Din = 0;
      ciclo =2; 
    end
    2: begin
      rst = 0;
      push = ~push;
      pop=0;
      Din = dato;
      if(push==1)begin
        $display("at %g pushed data: %g count %g MTIP %g",$time,dato,Sim_fifo.uut.count,Sim_fifo.uut.MTIP);
      end else begin
        dato=dato+1;
      end
    end
    3: begin
      rst = 0;
      push =0;
      pop=~pop;
      Din = dato;
      if(pop==1)begin
        $display("at %g poped data: %g count: %g MTIP %g",$time,Dout,Sim_fifo.uut.count,Sim_fifo.uut.MTIP);
      end
      if(pndng == 0)begin
        $finish;
      end
    end
    default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
    end
  endcase
  endtask

endmodule
