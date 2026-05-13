`timescale 1ps / 1ps
`default_nettype none
`define MAX 13
`include "MBC.sv"

module Sim_fifo;

	// Inputs
        reg clk;
        reg [24:0] address;
        reg [31:0] d_write;
        reg b;
        reg h;
        reg enable;
        reg r_w;
        reg [61:0] d_pop;
        reg pndng;
        reg [31:0] q;
        reg reset;

	// Outputs
        wire [31:0] d_read;
        wire [`MAX-3:0] a;
        wire [31:0] d;
        wire write;
        wire [63:0] d_psh;
        wire psh;
        wire mem_rdy;
        wire pop_mbc;
        wire error_drs;
        wire clk_mem;
        wire cen;
        wire sl;
        wire wen;

	// Instantiate the Unit Under Test (UUT)
      mbc #(`MAX) uut(
        .clk(clk),
        .address(address),
        .d_write(d_write),
        .b(b),
        .h(h),
        .enable(enable),
        .r_w(r_w),
        .d_pop(d_pop),
        .pndng,
        .q(q),
        .d_read(d_read),
        .a(a),
        .d(d),
        .write(write),
        .d_psh(d_psh),
        .psh(psh),
        .mem_rdy(mem_rdy),
        .pop_mbc(pop_mbc),
        .error_drs(error_drs),
        .clk_mem(clk_mem),
        .cen(cen),
        .sl(sl),
        .wen(wen),
        .reset(reset)
      );

initial begin
        clk=0;
        address=0;
        d_write=0;
        b=0;
        h=0;
        enable=0;
        r_w=0;
        clk=0;
        d_pop=0;
        pndng=0;
        q=0;
        #100;
        $finish;
end
		
endmodule
