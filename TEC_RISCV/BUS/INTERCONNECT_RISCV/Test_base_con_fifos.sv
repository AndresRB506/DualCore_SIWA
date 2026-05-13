`timescale 1ns/10ps
//`default_nettype none
`define PCKG_SZ 64 
`define BROADCAST {8{1'b1}}
`define DRVRS 4 
`define BITS 1
`define NUM_MSGS 4
`define DEPTH 8
`include "Library.sv"
`include "Library_Test.sv"

//`include "mapped_gate_level_netlist.v"
module Sim_bs_systm;

//#########################################################
//               UUT INTERFACE DEFINITION
//#########################################################
  
  reg clk;
  reg reset;
  wire pndng[`BITS-1:0][`DRVRS-1:0];
  wire [`PCKG_SZ-1:0]D_pop[`BITS-1:0][`DRVRS-1:0];
  reg push[`BITS-1:0][`DRVRS-1:0];
  reg pop[`BITS-1:0][`DRVRS-1:0];
  wire full_in[`BITS-1:0][`DRVRS-1:0];
  wire full_out[`BITS-1:0][`DRVRS-1:0];
  wire [`PCKG_SZ-1:0]D_push[`BITS-1:0][`DRVRS-1:0];

//#########################################################
//                   UUT DEFINITION
//#########################################################

 prll_bs_gnrtr_n_rbtr_fifo #(.buses(`BITS),.bits(`PCKG_SZ),.drvrs(`DRVRS),.broadcast(`BROADCAST),.depth(`DEPTH)) uut( 
  .clk(clk),
  .reset(reset),
  .pndng(pndng),
  .push(push),
  .pop(pop),
  .D_pop(D_pop),
  .D_push(D_push),
  .full_in(full_in),
  .full_out(full_out)
);

//#########################################################
//        DEFINITION OF TEST VARS
//#########################################################
  int i = 0;
  int k = 0;
  int y = 0;
  int aux_counter = 0;
  int status[`BITS][`DRVRS];
  
// typedef struct {
//    bit [7:0] trgt;           //Identificador de la interfaz de destino
//    bit [`PCKG_SZ-9:0] pyld;  // Payload del mensaje
//    int src;                  // Interfaz de fuente del mensaje
//    int tm_rcvd;              // timempo en el que se rcibió el mensaje
//    int tm_snd;               // tiempo en el que se envió el mensaje
//    int bus;                  // Identificador del bus en el que se envió el mensaje
//}
 


//#########################################################
//                   INITIAL
//#########################################################

initial begin
$dumpfile("vcd_file.vcd");
$dumpvars(0,Sim_bs_systm);
//$vcdplusfile ("Ronny.vpd");
//$vcdpluson;
  clk=0;
  reset =1;
end

  always #1 clk=~clk;   
  always @(posedge clk)begin
    prueba();
  end


//#########################################################
//                   TESTS DEFINITION
//#########################################################
  
  task prueba ();
      reset = 0;
    
    // at time 0 the queues get loaded with the pending messages 
    //************************************************************
    if($time == 1)begin
      aux_counter = 0;
      $display("Time = %g:",$time);
      tipos_de_mensajes[0].pyld ={`PCKG_SZ-8{1'b0}};
      tipos_de_mensajes[1].pyld ={`PCKG_SZ-8{1'b1}};
      tipos_de_mensajes[2].pyld ={(`PCKG_SZ-8)/2{2'b01}};
      tipos_de_mensajes[3].pyld ={(`PCKG_SZ-8)/2{2'b10}};
      
      for(k=0;k <`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)begin
          for(y=0; y < 4; y=y+1)begin
            tipos_de_mensajes[y].trgt = (i==(`DRVRS-1))?0:i+1;
            tipos_de_mensajes[y].bt = k;
            tipos_de_mensajes[y].src = i;
            $display("Push Source %g target: %g payload:  %h Bit %g msg type %g",tipos_de_mensajes[y].src,tipos_de_mensajes[y].trgt,tipos_de_mensajes[y].pyld,tipos_de_mensajes[y].bt,y);
            input_queues.push(tipos_de_mensajes[y]);
            aux_counter = aux_counter +1;
          end
        end
      end
    $display("%g messages pushed to the queues",aux_counter);
    end

    //**************************************
    // Declare the connections with the UUT
    //**************************************
    for(k=0;k <`BITS;k=k+1)begin
      for(i=0;i<`DRVRS;i=i+1)begin
        if(input_queues.get_pndng(k,i))begin
          auxiliar = input_queues.current(k,i);
        end
        D_pop[k][i]={auxiliar.trgt,auxiliar.pyld};
        pndng[k][i] = input_queues.get_pndng(k,i);
      end
    end


    //************************************
    // Check on the receiving interfaces
    //************************************
    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)
        begin
          if( push[k][i] == 1 )begin
            recibido.trgt = D_push[k][i][`PCKG_SZ-1:`PCKG_SZ-8];
            recibido.bt = k;
            recibido.src = {8{1'b1}};
            recibido.pyld = D_push[k][i][`PCKG_SZ-9:0];
            recibido.tm_rcvd = $time;
            recibido.tm_snd =0;
            recibido.rcvd =i;
            if(0==mensajes_enviados.find(recibido)) begin
              $display("Error: the received message at time %g in terminal %g of bus %g with payload %h is corrupted",$time,i,k,recibido.pyld);
              mensajes_enviados.push(recibido);
            end

            $display("At time %t: in terminal %g bus %g message saved. target: %g, message: %h ",$time,i,k, D_push[k][i][`PCKG_SZ-1:`PCKG_SZ-8],D_push[k][i][`PCKG_SZ-9:0]);
          end
        end
    end

    //************************************
    // Check on the send interfaces
    //************************************
    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1) begin
          if( pop[k][i] == 1 )begin
            enviado.trgt =  D_pop[k][i][`PCKG_SZ-1:`PCKG_SZ-8];
            enviado.bt = k;
            enviado.src = i;
            enviado.pyld = D_pop[k][i][`PCKG_SZ-9:0];
            enviado.tm_snd = $time;
            enviado.cmplt = 0;
            enviado.tm_rcvd = 0;
            input_queues.pop(k,i);
            if(mensajes_enviados.push(enviado) == 0) begin 
              $display("ERROR: there are more send messages than expected");
            end
    //          auxiliar = input_queues.current(k,i);
    //          $display("%h",{auxiliar.trgt,auxiliar.pyld});
              $display("At time %t: in terminal %g bus %g message pop. target: %g,message: %h",$time,i,k,enviado.trgt,enviado.pyld);
          end        
        end
    end
 
    //************************************
    // Check on the end criteria 
    //************************************

 
  if($time >= 20000)begin
    mensajes_enviados.report();
    $display("Test_Status: FAILED, Timeup");
    $finish;
  end

  if(input_queues.empty()) begin
//    $display("Empty");
    if(mensajes_enviados.all_received())begin
      mensajes_enviados.report();
      $display("Test Finished");
      $finish;
    end
  end

  endtask

endmodule
