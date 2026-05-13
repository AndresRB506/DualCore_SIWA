//`timescale 1ns / 1ps
`define DEPTH 4 
`define BITS 16
`define COMP_TEST
//`define TESTING
`include "fifo.sv"


module top_del_sistema(
  input [`BITS-1:0] Din,
  output[`BITS-1:0] Dout,
  input push,
  input pop,
  input clk,
  input [`DEPTH-1:0] deleteme,
  output pndng,
  input rst);

 fifo_ltch_no_rst #(.depth(`DEPTH),.bits(`BITS)) uut (
  .Din(Din),
  .deleteme(deleteme),
  .Dout(Dout),
  .push(push),
  .pop(pop),
  .clk(clk),
  .pndng(pndng),
  .rst(rst));
endmodule
