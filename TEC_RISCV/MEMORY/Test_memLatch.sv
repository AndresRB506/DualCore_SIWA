`timescale 1ps / 1ps
`default_nettype none
`define BITS 32
`define DEPTH 8 
`include "Memory_latch.sv"

module Sim_Mem;

	// Inputs
	reg write;
	reg [`BITS-1:0]datos_in;
        reg [$clog2(`DEPTH)-1:0] direcciones;
        reg clk = 0;

	// Outputs
	wire [`BITS-1:0]datos_out;

	// Instantiate the Unit Under Test (UUT)
      mem_latch #(.bits(`BITS),.entradas(`DEPTH)) uut(
        .direcciones(direcciones),
        .datos_in(datos_in),
        .datos_out(datos_out),
        .write(write)
    );
	
initial begin
        write =0;
	datos_in = 0;
        direcciones = 0;
#100;
		
end

always #50 clk=~clk;   
always@(posedge clk)begin
  prueba();
end

 int ciclo = 0;
 int i = 0;
 
  task prueba();

  case(ciclo)
    0:begin
     direcciones = i;
     datos_in = i;
     ciclo=1;
     write = 0;
    end
    1:begin
     $display("tiempo %g se escribió %g en la dirección  %g",$time,datos_in,direcciones);
     write = 1;
     ciclo = 2;
    end
    2: begin
     i=i+1;
     write = 0;
     ciclo = 0;
     if(i>=`DEPTH) begin
       direcciones = 0;
       i=0;
       ciclo = 3;
     end
    end
    3:begin
      $display("tiempo %g se leyó %g en la dirección  %g",$time,datos_out,direcciones);
      ciclo = 4;
      end
    4:begin
      ciclo = 3;
      direcciones = direcciones +1;
      if(direcciones >= `DEPTH-1) begin
        $finish;
      end
    end
  endcase
  endtask

endmodule
