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
        reg rqst0;
        reg rqst1;
        reg [`VECTOR-1:0] D_push0;
        reg [`VECTOR-1:0] D_push1;
        reg push_0;
        reg push_1;
        reg MEIE;
        reg pop;
        //outputs
        wire clean0;
        wire clean1;
        wire MTIP;
        wire MEIP;
        wire [`VECTOR-1:0] D_pop;
        wire pndng; 

	// Instantiate the Unit Under Test (UUT)

      interruption_handler #(.vector(`VECTOR),.depth_io(`DEPTH_IO),.depth_other(`DEPTH_OTHER)) uut(
        .clk(clk),
        .reset(reset),
        .clean0(clean0),
        .clean1(clean1),
        .rqst0(rqst0),
        .rqst1(rqst1),
        .D_push0(D_push0),
        .D_push1(D_push1),
        .push_0(push_0),
        .push_1(push_1),
        .MEIE(MEIE),
        .pop(pop),
        .MTIP(MTIP),
        .MEIP(MEIP),
        .D_pop(D_pop),
        .pndng(pndng) 
      );
	
initial begin
        clk=0;
        reset=0;
        rqst0=0;
        rqst1=0;
        D_push0=0;
        D_push1=0;
        push_0=0;
        push_1=0;
        MEIE=0;
        pop=0;
#50;
end

always #50 clk=~clk;   

always@(posedge clk)begin
  prueba();
end

 int ciclo =0;
 int sub_ciclo = 0;
 int contador =0;
 
  task prueba();

  case(ciclo)
    
    0:begin //RESET
	 clk = 0;
	 reset =1;
         push_0 = 0;
         push_1 = 0;
         rqst0 = 0;
         rqst1 = 0;
         pop = 0;
	 D_push0 = 0;
         D_push1 = 0;
         MEIE = 1;
         ciclo = 1;
    end
    1:begin //Inicio
//       $display("ciclo 1");
	 clk = 0;
	 reset =0;
         push_0 = 0;
         push_1 = 0;
         rqst0 = 0;
         rqst1 = 0;
         pop = 0;
	 D_push0 = 0;
         D_push1 = 0;
         MEIE = 1;
         ciclo = 2;
    end
    2: begin // push desde el dispositivo 0
       rqst0 = 1;
       if(contador < 6) begin
         D_push0 = 1792; //fuente 7 código 0
       end else begin
         if(contador<10)begin
           D_push0 = 1539; //fuente 6 código 3
         end else begin
           D_push0 = 128;  //fuente 0 código 80h --M interrupción de timing
           ciclo = 3;
         end
       end
         if(clean0 && ~push_0)begin
           push_0 = 1;
//           $display("ciclo 2");
           $display("at %g pushed data from device 0: %g count_cam: %g count_standar: %g MEIP: %g MTIP %g pndng: %g",
                     $time,
                     D_push0,
                     Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count,
                     Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count,
                     MEIP,
                     MTIP,
                     pndng );
           contador = contador+1;
         end else begin
           push_0 = 0;
         end 
    end  
    3: begin // pop de 5odas las interrupciones
      rqst0=0;
      rqst1=0;
      pop =~pop;
      push_0 = 0;
      push_1 = 0;
      D_push0 = 0;
      D_push1 = 0;
      if(pop==1)begin
 //          $display("ciclo 3");
           $display("at %g poped data from device 0: %g count_cam: %g count_standar: %g MEIP: %g MTIP %g pndng: %g",
                     $time,
                     D_pop,
                     Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count,
                     Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count,
                     MEIP,
                     MTIP,
                     pndng );
      end
      if((Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count == 0)&&(Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count == 0))begin
        contador =0;
        pop = 0;
        case (sub_ciclo) 
         0: begin
            ciclo=4;
         end
         1:begin
           ciclo=5;
           rqst0=1;
           rqst1=1;
           push_0=0;
           push_1=0;
         end
         2: $finish;
        endcase
      end
    end

   4:begin
       rqst1 = 1;
       if(contador < 6) begin
         D_push1 = 1792; //fuente 7 código 0
       end else begin
         if(contador<10)begin
           D_push1= 1539; //fuente 6 código 3
         end else begin
           D_push1= 128;  //fuente 0 código 80h --M interrupción de timing
           ciclo = 3;
           sub_ciclo =1;
         end
       end
         if(clean1 && ~push_1)begin
           push_1 = 1;
//           $display("ciclo 4");
           $display("at %g pushed data from device 1: %g count_cam: %g count_standar: %g MEIP: %g MTIP %g pndng: %g",
                     $time,
                     D_push0,
                     Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count,
                     Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count,
                     MEIP,
                     MTIP,
                     pndng );
           contador = contador+1;
         end else begin
           push_1 = 0;
         end 
   end
   
   5:begin
       if(contador < 6) begin
         D_push1 = 1792; //fuente 7 código 0
         D_push0 = 1792; //fuente 7 código 0
       end else begin
         if(contador<10)begin
           D_push1= 1539; //fuente 6 código 3
           D_push0= 1539; //fuente 6 código 3
         end else begin
           D_push1= 128;  //fuente 0 código 80h --M interrupción de timing
           D_push0= 128;  //fuente 0 código 80h --M interrupción de timing
           ciclo = 3;
           sub_ciclo = 2;
         end
       end
         if(clean1 && ~push_1 && rqst1)begin
           push_1 = 1;
//           $display("ciclo 5");
           $display("at %g pushed data from device 1: %g count_cam: %g count_standar: %g MEIP: %g MTIP %g pndng: %g",
                     $time,
                     D_push0,
                     Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count,
                     Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count,
                     MEIP,
                     MTIP,
                     pndng );
           contador = contador+1;
         end else begin
           push_1 = 0;
 	   rqst1=0;
           rqst0=1;
         end 
         if(clean0 && ~push_0 && rqst0)begin
           push_0 = 1;
//           $display("ciclo 5");
           $display("at %g pushed data from device 0: %g count_cam: %g count_standar: %g MEIP: %g MTIP %g pndng: %g",
                     $time,
                     D_push0,
                     Sim_fifo_intr_cntrl.uut.fifo_int.cam_fifo.count,
                     Sim_fifo_intr_cntrl.uut.fifo_int.fifo_standar.count,
                     MEIP,
                     MTIP,
                     pndng );
           contador = contador+1;
         end else begin
           push_0 = 0;
 	   rqst1=1;
           rqst0=0;
         end 
     
   end
    
   default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
   end
  endcase
  endtask

endmodule
