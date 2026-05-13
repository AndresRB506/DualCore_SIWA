`timescale 1ns / 1ps

//////////////////////////////////////////////////////////
// Definition of a D flip flop with asyncronous reset  //
/////////////////////////////////////////////////////////

module dff_async_rst (data,clk,reset,q);

  input data, clk, reset ; 
  output q;
  reg q;

  always @ ( posedge clk or posedge reset)
    if (reset) begin
      q <= 1'b0;
    end  else begin
      q <= data;
    end

endmodule

//////////////////////////////////////////////////////////
// Definition of a third state buffer  //
/////////////////////////////////////////////////////////

module tri_buf (a,b,en);
    input a;
    output b;
    input en;
    wire a,en;
    wire b;
    
   assign b = (en) ? a : 1'bz;
     	  	 
endmodule

///////////////////////////////////////////////////////////////
// Definition of a serial to parallel signal converter block // 
//////////////////////////////////////////////////////////////

module parallel_serial (
  input S_in,
  input P_in,
  input sel_P_S,
  output S_out,
  output P_out   
  );

  tri_buf serial(.a(S_in),.b(S_out),.en(~sel_P_S));
  tri_buf parallel_in (.a(P_in),.b(S_out),.en(sel_P_S));
//to send Pot to hiz when sel_p_s = 0 enable the line below and disable the
//line after that one
//  tri_buf parallel_out (.a(S_in),.b(P_out),.en(sel_P_S)); 
  assign P_out = S_in;

endmodule

//////////////////////////////////////////////////////////////////////////////
// Definition of a register block which can be readed and writed either in //
// parallel or in series                                                   //
/////////////////////////////////////////////////////////////////////////////

module serializer #(parameter pckg_sz) (
  input sel_p_s,
  input s_in,
  input rst,
  input clk,
  input [pckg_sz-1:0] P_in,
  output s_out,
  output [pckg_sz-1:0] P_out
  );
  wire [pckg_sz-1:0] q;
  wire [pckg_sz-1:0] d;

  genvar i;
  generate
    for ( i = 0; i < pckg_sz; i = i+1 )
      begin : bit
        dff_async_rst dff (.data(d[i]),.clk(clk),.reset(rst),.q(q[i]));
      end
    for( i = 0; i < pckg_sz-1; i = i+1 )
      begin: bt
        parallel_serial pts (.S_in(q[i]),.P_in(P_in[i+1]),.sel_P_S(sel_p_s),.S_out(d[i+1]),.P_out(P_out[i]));
      end
  endgenerate
  assign d[0] = (sel_p_s)?P_in[0]:s_in;
  assign s_out =(~sel_p_s)?q[pckg_sz-1]:1'bz;
  assign P_out[pckg_sz-1] = q[pckg_sz-1];
endmodule

