`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.05.2018 18:35:58
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dff_async_rst #(bits_sz=32) (
  input [bits_sz-1:0] data,
  input clk,
  input reset,
  output reg [bits_sz-1:0] q);

  always @ ( posedge clk or posedge reset)
    if (reset) begin
      q <= 1'b0;
    end  else begin
      q <= data;
    end

endmodule

module top #(bits_size=32, cntrl_size=4)(
    input [bits_size-1:0] A_top,
    input [bits_size-1:0] B_top,
    input [cntrl_size-1:0] Alu_Cntrl_top,
    input Cin_top,
    input clk,
    input reset,
    output reg Zero_top, 
    output reg oVerflow_top,
    output reg Negative_top,
    output reg Carry_top,
    output reg [bits_size-1:0] OUT_top
    );
wire [bits_size-1:0] cable_A;
wire [bits_size-1:0] cable_B;
wire [cntrl_size-1:0] cable_Alu_Cntrl;
wire cable_Cin;
wire cable_Zero;
wire cable_overflow;
wire cable_negative;
wire cable_carryout;
wire [bits_size-1:0] cable_OUT;


  ALU_2 inst_ALU(
     .A(cable_A),
     .B(cable_B),
     .Alu_Cntrl(cable_Alu_Cntrl),
     .Cin(cable_Cin),
     .Zero(cable_Zero), 
     .oVerflow(cable_overflow),
     .Negative(cable_negative),
     .Carry(cable_carryout),
     .OUT(cable_OUT)
    );

 dff_async_rst  inst_ffA (
  .data(A_top),
  .clk(clk),
  .reset(reset),
  .q(cable_A)
  );

 dff_async_rst inst_ffB (
  .data(B_top),
  .clk(clk),
  .reset(reset),
  .q(cable_B)
  );

 dff_async_rst#(.bits_sz(cntrl_size)) inst_ffcntrl (
  .data(Alu_Cntrl_top),
  .clk(clk),
  .reset(reset),
  .q(cable_Alu_Cntrl)
  );

 dff_async_rst#(.bits_sz(1)) inst_ffcin (
  .data(Cin_top),
  .clk(clk),
  .reset(reset),
  .q(cable_Cin)
  );
//
 dff_async_rst#(.bits_sz(1)) inst_ffzero (
 .data(cable_Zero),
 .clk(clk),
 .reset(reset),
 .q(Zero_top)
 );

dff_async_rst#(.bits_sz(1)) inst_ffoverflow (
 .data(cable_overflow),
 .clk(clk),
 .reset(reset),
 .q(oVerflow_top)
 );

dff_async_rst#(.bits_sz(1)) inst_ffnegative (
 .data(cable_negative),
 .clk(clk),
 .reset(reset),
 .q(Negative_top)
 );

dff_async_rst#(.bits_sz(1)) inst_ffcarryout (
 .data(cable_carryout),
 .clk(clk),
 .reset(reset),
 .q(Carry_top)
 );

dff_async_rst inst_ffout (
 .data(cable_OUT),
 .clk(clk),
 .reset(reset),
 .q(OUT_top)
 );




endmodule
