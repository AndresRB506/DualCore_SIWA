`include "../BUS_Micro/Bus_Micro_lib.sv"
/////////////////////////////////////////////////////////////////////////////
// Definition of the control interfase for the prll bus for the Tec_riscv  //
/////////////////////////////////////////////////////////////////////////////

module prll_intrfs_cntrl_riscv #(parameter id = 0, parameter bdcst = 255, parameter drvrs = 4) (
  input clk,
  input reset,
  input [2:0] D_in,
  input pndng,
  output ld_w,
  output rst_w,
  output rst_r,
  output bs_grnt,
  output push,
  output pop,
  inout trn_chng,
  inout wrt
);
  reg c_r;
  reg bs_grnt_pre;
  reg c_w;
  reg sv_flg;
  reg c_a;
  wire s_ds_r;
  wire s_ds_w;
  reg  trn_chng_pre;
  reg  wt_flg;
  reg rd_flg;
  wire trn_chng_nthng_t_snd;
  wire wrt_pre;
  wire bs_rqst;
  wire rdi;
  wire [$clog2(drvrs)-1:0] cnt_rbtr;
  
  dff_async_rst bs_grnt_dly (.data(bs_grnt_pre),.clk(clk),.reset(reset),.q(bs_grnt));
  Counter_arb#(drvrs) arb_cntr(.count(cnt_rbtr),.clk(trn_chng),.rst(reset));
  Arbiter_st_Mchn arb_st_mchn (.clk(clk),.reset(reset),.condition_a(c_a),.trn_chng_nthng_t_snd(trn_chng_nthng_t_snd));
   prll_wt_st_mchn wt_st_mchn(.c_w(c_w),.reset(reset),.clk(clk),.rst_w(rst_w),.pop(pop),.wrt_pre(wrt_pre),.s_ds_w(s_ds_w),.bs_rqst(bs_rqst),.ld_w(ld_w));
   prll_rd_st_mchn rd_st_mchn(.c_r(c_r),.reset(reset),.clk(clk),.rst_r(rst_r),.push(push),.rdi(rdi),.s_ds_r(s_ds_r));
   tri_buf trn_chng_buf(.a(trn_chng_pre),.b(trn_chng),.en(bs_grnt_pre));
   tri_buf wrt_buf(.a(wrt_pre),.b(wrt),.en(bs_grnt_pre));

  always@(*)begin
    wt_flg = rdi && bs_grnt;
    c_w = (s_ds_w)?pndng:wt_flg;
    trn_chng_pre = trn_chng_nthng_t_snd || rst_w;
    rd_flg = wrt && ~bs_grnt;
    sv_flg = ((D_in==id)||(D_in==bdcst))?{1'b1}:{1'b0};
    c_r = (s_ds_r)?sv_flg:rd_flg;
    bs_grnt_pre = (cnt_rbtr == id)?{1'b1}:{1'b0};
    c_a = bs_grnt && ~bs_rqst;
  end
endmodule
///////////////////////////////////////////////////////////////////////
// Definition of the prll bus interface 
///////////////////////////////////////////////////////////////////////

module prll_bs_ntrfs_riscv #(parameter drvrs = 4, parameter bits = 32, parameter id = 0,parameter bdcst = 255)(
  output [bits-1:0] D_push,
  input pndng,
  input clk,
  input reset,
  inout [bits-1:0] bus,
  inout trn_chng,
  inout wrt,
  output pop,
  output push,
  input [bits-1:0] D_pop
);
  wire rst_r;
  wire rst_w;
  wire ld_w;
  wire bs_grnt;
  wire [bits-1:0] bus_pre_w;
  reg ld_r;

  prll_d_reg #(bits) D_reg_rd(.clk(ld_r),.reset(rst_r),.D_in(bus),.D_out(D_push));
  prll_d_reg #(bits) D_reg_wt(.clk(ld_w),.reset(rst_w),.D_in(D_pop),.D_out(bus_pre_w));
  prll_intrfs_cntrl_riscv #(id,bdcst,drvrs) prll_cntrl(.clk(clk),
						 .reset(reset),
						 .D_in(D_push[bits-1:bits-3]),
						 .pndng(pndng),
 						 .ld_w(ld_w),
						 .rst_w(rst_w),
   						 .rst_r(rst_r),
						 .bs_grnt(bs_grnt),
						 .push(push),
						 .pop(pop),
						 .trn_chng(trn_chng),
						 .wrt(wrt));
  genvar i;
  generate
    for(i=0;i<bits;i=i+1) begin:bit_
     tri_buf bus_buf (.a(bus_pre_w[i]),.b(bus[i]),.en(bs_grnt)); 
    end
  endgenerate

  always@(*)begin
    ld_r <= ~bs_grnt && wrt;
    
  end
endmodule

//////////////////////////////////////////////////////
//This is a a paralell bus with no central arbiter  //
//////////////////////////////////////////////////////

module tec_riscv_bus #(parameter bits = 65, parameter broadcast = {3{1'b1}}) (
  input clk,
  input reset,
  output  pndng_mbc,
  output  pndng_spi,
  output  pndng_uart,
//  output  pndng_anlg,
  input  push_mbc,
  input  push_spi,
  input  push_uart,
//  input  push_anlg,
  input  pop_mbc,
  input  pop_spi,
  input  pop_uart,
//  input  pop_anlg,
  output  [bits-1:0] D_pop_mbc,
  output  [bits-1:0] D_pop_spi,
  output  [bits-1:0] D_pop_uart,
//  output  [bits-1:0] D_pop_anlg,
  input [bits-1:0] D_push_mbc,
  input [bits-1:0] D_push_spi,
  input [bits-1:0] D_push_uart
//  input [bits-1:0] D_push_anlg
);
  wire [bits-1:0] bus;
  wire trn_chng;
  wire wrt;

  wire  pndng_mbc_int;
  wire  pndng_spi_int;
  wire  pndng_uart_int;
//  wire  pndng_anlg_int;
  
  wire  push_mbc_int;
  wire  push_spi_int;
  wire  push_uart_int;
//  wire  push_anlg_int;
  
  wire  pop_mbc_int;
  wire  pop_spi_int;
  wire  pop_uart_int;
//  wire  pop_anlg_int;
  
  wire  [bits-1:0] D_pop_mbc_int;
  wire  [bits-1:0] D_pop_spi_int;
  wire  [bits-1:0] D_pop_uart_int;
//  wire  [bits-1:0] D_pop_anlg_int;
  
  wire  [bits-1:0] D_push_mbc_int;
  wire  [bits-1:0] D_push_spi_int;
  wire  [bits-1:0] D_push_uart_int;
//  wire  [bits-1:0] D_push_anlg_int;
  
        prll_bs_ntrfs_riscv #(.drvrs(3),.bits(bits),.id(0),.bdcst(broadcast)) mbc_bs_ntrfs (
        .D_push(D_push_mbc_int),
        .pndng(pndng_mbc_int),
        .clk(clk),
        .reset(reset),
        .bus(bus),
        .trn_chng(trn_chng),
        .wrt(wrt),
        .pop(pop_mbc_int),
        .push(push_mbc_int),
        .D_pop(D_pop_mbc_int));
        
         prll_bs_ntrfs_riscv #(.drvrs(3),.bits(bits),.id(1),.bdcst(broadcast)) spi_bs_ntrfs (
        .D_push(D_push_spi_int),
        .pndng(pndng_spi_int),
        .clk(clk),
        .reset(reset),
        .bus(bus),
        .trn_chng(trn_chng),
        .wrt(wrt),
        .pop(pop_spi_int),
        .push(push_spi_int),
        .D_pop(D_pop_spi_int));
        
        prll_bs_ntrfs_riscv #(.drvrs(3),.bits(bits),.id(2),.bdcst(broadcast)) uart_bs_ntrfs (
        .D_push(D_push_uart_int),
        .pndng(pndng_uart_int),
        .clk(clk),
        .reset(reset),
        .bus(bus),
        .trn_chng(trn_chng),
        .wrt(wrt),
        .pop(pop_uart_int),
        .push(push_uart_int),
        .D_pop(D_pop_uart_int));

//        prll_bs_ntrfs_riscv #(.drvrs(4),.bits(bits),.id(3),.bdcst(broadcast)) anlg_bs_ntrfs (
//        .D_push(D_push_anlg_int),
//        .pndng(pndng_anlg_int),
//        .clk(clk),
//        .reset(reset),
//        .bus(bus),
//        .trn_chng(trn_chng),
//        .wrt(wrt),
//        .pop(pop_anlg_int),
//        .push(push_anlg_int),
//        .D_pop(D_pop_anlg_int));

        fifo_flops_no_full #(.depth(3),.bits(65)) fifo_out_mbc(
          .Din(D_push_mbc_int),
          .Dout(D_pop_mbc),
          .push(push_mbc_int),
          .pop(pop_mbc),
          .pndng(pndng_mbc),
          .rst(reset),
          .clk(clk));

        fifo_flops_no_full #(.depth(3),.bits(65)) fifo_in_mbc(
          .Din(D_push_mbc),
          .Dout(D_pop_mbc_int),
          .push(push_mbc),
          .pop(pop_mbc_int),
          .pndng(pndng_mbc_int),
          .rst(reset),
          .clk(clk));

        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_out_spi(
          .Din(D_push_spi_int),
          .Dout(D_pop_spi),
          .push(push_spi_int),
          .pop(pop_spi),
          .pndng(pndng_spi),
          .rst(reset),
          .clk(clk));

        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_in_spi(
          .Din(D_push_spi),
          .Dout(D_pop_spi_int),
          .push(push_spi),
          .pop(pop_spi_int),
          .pndng(pndng_spi_int),
          .rst(reset),
          .clk(clk));

        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_out_uart(
          .Din(D_push_uart_int),
          .Dout(D_pop_uart),
          .push(push_uart_int),
          .pop(pop_uart),
          .pndng(pndng_uart),
          .rst(reset),
          .clk(clk));

        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_in_uart(
          .Din(D_push_uart),
          .Dout(D_pop_uart_int),
          .push(push_uart),
          .pop(pop_uart_int),
          .pndng(pndng_uart_int),
          .rst(reset),
          .clk(clk));

//        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_out_anlg(
//          .Din(D_push_anlg_int),
//          .Dout(D_pop_anlg),
//          .push(push_anlg_int),
//          .pop(pop_anlg),
//          .pndng(pndng_anlg),
//          .rst(reset),
//          .clk(clk));
//
//        fifo_flops_no_full #(.depth(2),.bits(65)) fifo_in_anlg(
//          .Din(D_push_anlg),
//          .Dout(D_pop_anlg_int),
//          .push(push_anlg),
//          .pop(pop_anlg_int),
//          .pndng(pndng_anlg_int),
//          .rst(reset),
//          .clk(clk));

endmodule
