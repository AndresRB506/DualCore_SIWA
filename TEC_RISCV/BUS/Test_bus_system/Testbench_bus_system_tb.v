`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 16 
`define BROADCAST {8{1'b1}}
`define DRVRS 4
`include "../Library.sv"

module Sim_bs_systm;
 //inputs
  reg clk;
  reg reset;
  reg [`DRVRS-1:0] pndng;
  reg [`DRVRS-1:0][`PCKG_SZ-1:0] D_pop;
 //outputs
  wire [`DRVRS-1:0] push;
  wire [`DRVRS-1:0] pop;
  wire [`DRVRS-1:0][`PCKG_SZ-1:0] D_push;

 //Other varibles
  reg [7:0]target [`DRVRS-1:0];
  int i = 0;

 bs_gnrtr #(`DRVRS,`PCKG_SZ,`BROADCAST) uut(
  .clk(clk),
  .reset(reset),
  .pndng(pndng),
  .push(push),
  .pop(pop),
  .D_pop(D_pop),
  .D_push(D_push)
);


initial begin
clk=0;
  for(i=0;i<`DRVRS;i=i+1)
  begin
    target[i] = i;
  end

#1;
  reset = 1;
  pndng = {`DRVRS{1'b1}};
  for(i=0; i< `DRVRS; i=i+1)
  begin
    D_pop[i][`PCKG_SZ-1:0] = {target[i+1],{(`PCKG_SZ/8)-1{target[i]}}};
  end
#1
  reset = 0;
  pndng = {`DRVRS{1'b1}};
  for(i=0; i< `DRVRS; i=i+1)
  begin
    if(i != `DRVRS-1)
      D_pop[i][`PCKG_SZ-1:0] = {target[i+1],{(`PCKG_SZ/8)-1{target[i]}}};
    else
      D_pop[i][`PCKG_SZ-1:0] = {target[0],{(`PCKG_SZ/8)-1{target[i]}}};
  end
#500
  reset = 1;
  pndng = {`DRVRS{1'b1}};
  for(i=0; i< `DRVRS; i=i+1)
  begin
    if(i != `DRVRS-1)
      D_pop[i][`PCKG_SZ-1:0] = {target[i+1],{(`PCKG_SZ/8)-1{target[i]}}};
    else
      D_pop[i][`PCKG_SZ-1:0] = {target[0],{(`PCKG_SZ/8)-1{target[i]}}};
  end
end
always #1 clk=~clk;   
always #1 prueba();
task prueba ();
if(push != 0) begin
  $display("%g Dato_guardado",$time);
end
endtask
endmodule
