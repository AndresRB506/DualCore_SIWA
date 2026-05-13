`timescale 1ns / 1ps

`define ADW 32 
`define Masters 2
`define Slaves 2 
//`include "Library.sv"
module Deco_push_TB;

//#########################################################
//               UUT INTERFACE DEFINITION
//#########################################################
 //inputs

  reg [`Masters-1:0][`ADW-1:0]A;
  reg [`Masters-1:0]V;
 //outputs
  wire [`Masters-1:0][$clog2(`Slaves+1)-1:0]Sel;
  wire [`Masters-1:0]Rst;
  wire [`Masters-1:0]Push;
  

//#########################################################
//                   UUT DEFINITION
//#########################################################

 Deco_Push #(`ADW,`Masters,`Slaves) uut(
  .A(A),
  .V(V),
  .Sel(Sel),
  .Rst(Rst),
  .Push(Push)
);

//#########################################################
//                   INITIAL
//#########################################################

initial begin
    A=0;
    V=0;
#10 
    A[0]=32'h40000010;
    A[1]=32'h40001010;
    V=2'b11;
    #2  if (Push==0)$display("Fail first test");
        else $display("Pass first test");
#10
    A[0]=32'h40000010;
    A[1]=32'h40000010;
    V=2'b11;
    #2  if (Push[1]==1)$display("Fail second test");
        else $display("Pass second test");
#10
    A[0]=32'h40000010;
    A[1]=32'h40000010;
    V[0]=0;
    V[1]=1;
    #2  if (Push[1]==0)$display("Fail third test");
        else $display("Pass third test");
#30 $finish;
end


endmodule