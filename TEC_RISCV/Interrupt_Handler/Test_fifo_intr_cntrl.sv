`timescale 1ps / 1ps
`default_nettype none
`define DEPTH_IO 5
`define DEPTH_OTHER 5
`define VECTOR 72


`define TESTING
`include "intrpt_hndlr.sv"

module Sim_fifo_intr_cntrl;

	// Inputs
	reg clk;
	reg reset;
        reg push;
        reg pop;
	reg [`VECTOR-1:0] D_push;
        reg MEIE;

	// Outputs
	wire [`VECTOR-1:0] D_pop;
	wire MTIP;
        wire MEIP;
        wire pndng;

	// Instantiate the Unit Under Test (UUT)

       fifo_int_cntrl #(.depth_io(`DEPTH_IO),.depth_other(`DEPTH_OTHER),.vector(`VECTOR)) uut(
          .pop(pop),
          .push(push),
          .clk(clk),
          .reset(reset),
          .D_push(D_push),
          .MEIE(MEIE),
          .MTIP(MTIP),
          .MEIP(MEIP),
          .pndng(pndng),
          .D_pop(D_pop)
        );
	
initial begin
	 clk = 0;
	 reset =0;
         push = 0;
         pop = 0;
	 D_push = 0;
         MEIE = 0;
#50;
end

always #50 clk=~clk;   
always@(posedge clk)begin
  prueba();
end

 int ciclo =0;
 int dato =0;
 int contador =0;
 
  task prueba();

  case(ciclo)
    
    0:begin //RESET
	 clk = 0;
	 reset =1;
         push = 0;
         pop = 0;
	 D_push = 0;
         MEIE = 1;
         ciclo = 1;
    end
    1:begin //Inicio
	 clk = 0;
	 reset =0;
         push = 0;
         pop = 0;
	 D_push = 0;
         MEIE = 0;
         ciclo = 2;
    end
    2: begin
      push <= ~push;
      pop <= 0;
      if(contador < 5) begin
        dato = 1536; //code 0 source 6 
      end else begin
          if(contador == 5)begin
            dato =128; //code 80h source 0 
          end else begin
            dato =1792; //code 0 source 7
          end 
      end
      D_push <= dato;
      if(push==1)begin
        $display("at %g pushed data: %g count_cam %g count_standar %g",$time,dato,Sim_fifo_intr_cntrl.uut.cam_fifo.count,Sim_fifo_intr_cntrl.uut.fifo_standar.count);
        contador = contador+1;
        if(contador>10)begin
          ciclo = 3;
          contador= 0;
        end
      end
    end
    3: begin
      pop =~pop;
      push = 0;
      D_push = 0;
      if(pop==1)begin
        $display("at %g poped data: %g count_cam: %g count_standar %g",$time,D_pop,Sim_fifo_intr_cntrl.uut.cam_fifo.count,Sim_fifo_intr_cntrl.uut.fifo_standar.count);
      end
      if((Sim_fifo_intr_cntrl.uut.cam_fifo.count == 0)&(Sim_fifo_intr_cntrl.uut.fifo_standar.count == 0))begin
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
