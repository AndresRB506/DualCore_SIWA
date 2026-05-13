
`ifndef FIFOS
`define FIFOS
`include "../FIFO_Latches/fifo.sv"
`endif


/////////////////////////////////////////////////////////////////////////////
//    This implementation is for two devices pushing interrupts to the pipe 
////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
//    Implementación del bloque de FIFO del controlador de interrupciones 
///////////////////////////////////////////////////////////////////////////

module fifo_int_cntrl #(parameter depth_io = 5, parameter depth_other = 5, parameter vector =72)(
  input pop,
  input push,
  input clk,
  input reset,
  input [vector-1:0] D_push,
  input MEIE,
  output MTIP,
  output MEIP,
  output pndng,
  output [vector-1:0] D_pop
);

  wire [vector-1:0] D_pop_0;
  wire [vector-1:0] D_pop_1;
  wire push_0;
  wire push_1;
  wire pop_0;
  wire pop_1;
  wire pndng_0;
  wire int1;
  wire int2;
  wire int3;
  wire fifo_sel;

  ntrpt_cam_fifo   #(.depth(depth_other),.bits(vector)) cam_fifo (.Din(D_push),.Dout(D_pop_0),.push(push_0),.pop(pop),.clk(clk),.pndng(pndng_0),.MTIP(MTIP),.reset(reset));
  fifo_ltch_no_rst #(.depth(depth_io),.bits(vector))    fifo_standar (.Din(D_push),.Dout(D_pop_1),.push(push_1),.pop(pop_1),.clk(clk),.pndng(MEIP),.rst(reset));
  xnor id0_0 (int1,D_push[10],D_push[9]);
  and id0_1 (fifo_sel,int1,~D_push[8]);
  and id1 (push_0,fifo_sel,push);
  and id2 (push_1,~fifo_sel,push);
  and id3 (pop_0,pop,pndng_0);
  and id4_0 (int3,pop,~pndng_0);
  and id4_1 (pop_1,int3,MEIE);
  and id5_0 (int2,MEIP,MEIE);
  or id5_1 (pndng,pndng_0,int2);
  assign D_pop = (pndng_0)?D_pop_0:D_pop_1;
endmodule


module  interruption_handler #(parameter vector=72, parameter depth_io = 5, parameter depth_other = 5) (
  input  clk,
  input reset,
  input rqst0,
  input rqst1,
  input [vector-1:0] D_push0,
  input [vector-1:0] D_push1,
  input push_0,
  input push_1,
  input MEIE,
  input pop,
  output clean0,
  output clean1,
  output MTIP,
  output MEIP,
  output [vector-1:0] D_pop,
  output pndng 
);
  wire enable;
  and priority_encoder(enable,~rqst0,rqst1);
  not encoder_clean0(clean0,enable);
  buf encoder_clean1(clean1,enable);
  wire push;
  wire [vector-1:0] D_push;
  assign push   = (enable)?push_1:push_0;
  assign D_push = (enable)?D_push1:D_push0;

  fifo_int_cntrl  #(.depth_io(depth_io),.depth_other(depth_other),.vector(vector)) fifo_int(.pop(pop),.push(push),.clk(clk),.reset(reset),.D_push(D_push),.MEIE(MEIE),.MTIP(MTIP),.MEIP(MEIP),.pndng(pndng),.D_pop(D_pop));
endmodule
