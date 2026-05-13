`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 16 
`define NTRFS_ID_W 0
`define NTRFS_ID_R 1
`define BROADCAST {8{1'b1}}

module Sim_bs_cntrlr;

// Inputs
  reg clk;
  reg reset;
  reg bs_grnt_w;
  reg bs_grnt_r;
  reg pndng_w;
  reg pndng_r;
  reg [`PCKG_SZ-1:0] D_pop_w;
  reg [`PCKG_SZ-1:0] D_pop_r;
// Outputs
  wire [`PCKG_SZ-1:0] D_push_w;
  wire [`PCKG_SZ-1:0] D_push_r;
  wire push_w;
  wire push_r;
  wire pop_w;
  wire pop_r;
  wire bs_rqst_w;
  wire bs_rqst_r;
  wire bus;
  wire bs_bsy;


	// Instantiate the Unit Under Test (UUT)

  bs_ntrfs #(`PCKG_SZ,`NTRFS_ID_W,`BROADCAST) uut_w(
  .clk(clk),
  .reset(reset),
  .bs_grnt(bs_grnt_w),
  .pndng(pndng_w),
  .D_pop(D_pop_w),
  .D_push(D_push_w),
  .push(push_w),
  .pop(pop_w),
  .bs_rqst(bs_rqst_w),
  .bus(bus),
  .bs_bsy(bs_bsy)
);


  bs_ntrfs #(`PCKG_SZ,`NTRFS_ID_R,`BROADCAST) uut_r(
  .clk(clk),
  .reset(reset),
  .bs_grnt(bs_grnt_r),
  .pndng(pndng_r),
  .D_pop(D_pop_r),
  .D_push(D_push_r),
  .push(push_r),
  .pop(pop_r),
  .bs_rqst(bs_rqst_r),
  .bus(bus),
  .bs_bsy(bs_bsy)
);
	initial begin
clk=0;
#1;

  reset=  {1'b1};
  bs_grnt_w=  {1'b1};
  pndng_w= {1'b1};
  D_pop_w= {`PCKG_SZ/2{2'b01}};
  bs_grnt_r=  {1'b0};
  pndng_r= {1'b1};
  D_pop_r= {`PCKG_SZ/2{2'b10}};

#1

  reset=  {1'b0};
  bs_grnt_w=  {1'b1};
  pndng_w= {1'b1};
  D_pop_w= {`PCKG_SZ/8{8'b00000010}};
  bs_grnt_r=  {1'b0};
  pndng_r= {1'b1};
  D_pop_r= {`PCKG_SZ/2{2'b10}};
#47
  reset=  {1'b0};
  bs_grnt_w=  {1'b1};
  pndng_w= {1'b1};
  D_pop_w= {`PCKG_SZ/2{2'b11}};
  bs_grnt_r=  {1'b0};
  pndng_r= {1'b1};
  D_pop_r= {`PCKG_SZ/2{2'b10}};
#50
  reset=  {1'b1};
  bs_grnt_w=  {1'b1};
  pndng_w= {1'b1};
  D_pop_w= {`PCKG_SZ/2{2'b01}};
  bs_grnt_r=  {1'b0};
  pndng_r= {1'b1};
  D_pop_r= {`PCKG_SZ/2{2'b10}};
end

always #1 clk=~clk;   
endmodule
