/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in topographical mode
// Version   : L-2016.03-SP3
// Date      : Fri Dec 22 06:33:30 2017
/////////////////////////////////////////////////////////////


module dff_async_rst_143 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n1;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n1), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n1) );
endmodule


module tri_buf_251 ( a, b, en );
  input a, en;
  output b;
  wire   N0, n1;
  tri   b;

  ITLLLX1 b_tri ( .A(n1), .EN(N0), .Q(b) );
  INLLX1 U2 ( .A(en), .Q(N0) );
  INLLX1 U1 ( .A(a), .Q(n1) );
endmodule


module Counter_arb_mx_cnt2_1 ( clk, rst, \count[0]_BAR  );
  input clk, rst;
  output \count[0]_BAR ;
  wire   \count[0] , N4, n1;
  tri   clk;
  assign \count[0]_BAR  = N4;

  DFRRQLLX1 \count_reg[0]  ( .D(N4), .C(clk), .RN(n1), .Q(\count[0] ) );
  INLLX1 U4 ( .A(\count[0] ), .Q(N4) );
  INLLX1 U3 ( .A(rst), .Q(n1) );
endmodule


module dff_async_rst_13 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Arbiter_st_Mchn_1 ( clk, reset, condition_a, trn_chng_nthng_t_snd );
  input clk, reset, condition_a;
  output trn_chng_nthng_t_snd;
  wire   nxt_st;

  dff_async_rst_13 st0 ( .data(nxt_st), .clk(clk), .reset(reset), .q(
        trn_chng_nthng_t_snd) );
  NO2I1SLLX1 U3 ( .AN(condition_a), .B(trn_chng_nthng_t_snd), .Q(nxt_st) );
endmodule


module Counter_mx_cnt64_3 ( count, clk, rst );
  output [5:0] count;
  input clk, rst;
  wire   N1, N2, N3, N4, N5, N6, n6, n1, n2, n3, n4, n5, n7;

  DFRRQLLX1 \count_reg[5]  ( .D(N6), .C(clk), .RN(n6), .Q(count[5]) );
  DFRRQLLX1 \count_reg[4]  ( .D(N5), .C(clk), .RN(n6), .Q(count[4]) );
  DFRRQLLX1 \count_reg[3]  ( .D(N4), .C(clk), .RN(n6), .Q(count[3]) );
  DFRRQLLX1 \count_reg[2]  ( .D(N3), .C(clk), .RN(n6), .Q(count[2]) );
  DFRRQLLX1 \count_reg[1]  ( .D(N2), .C(clk), .RN(n6), .Q(count[1]) );
  DFRRQLLX1 \count_reg[0]  ( .D(N1), .C(clk), .RN(n6), .Q(count[0]) );
  INLLX1 U3 ( .A(count[0]), .Q(N1) );
  INLLX1 U4 ( .A(rst), .Q(n6) );
  NA3LLX0 U5 ( .A(count[0]), .B(count[1]), .C(count[2]), .Q(n3) );
  INLLX1 U6 ( .A(count[3]), .Q(n2) );
  NO2LLX1 U7 ( .A(n3), .B(n2), .Q(n1) );
  NA2LLX1 U8 ( .A(n1), .B(count[4]), .Q(n7) );
  OA21LLX1 U9 ( .A(n1), .B(count[4]), .C(n7), .Q(N5) );
  AN21LLX1 U10 ( .A(n3), .B(n2), .C(n1), .Q(N4) );
  INLLX1 U11 ( .A(count[1]), .Q(n5) );
  NO2LLX1 U12 ( .A(N1), .B(n5), .Q(n4) );
  OA21LLX1 U13 ( .A(n4), .B(count[2]), .C(n3), .Q(N3) );
  AN21LLX1 U14 ( .A(N1), .B(n5), .C(n4), .Q(N2) );
  EN2LLX2 U15 ( .A(count[5]), .B(n7), .Q(N6) );
endmodule


module dff_async_rst_10 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_11 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_12 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Read_st_Mchn_1 ( condition_r, rdi, reset, clk, s_ds_r, s_cmp, 
        rst_cntr_r, rst_r, en_r, push, p_s_r_BAR );
  output [1:0] s_ds_r;
  input condition_r, reset, clk;
  output rdi, s_cmp, rst_cntr_r, rst_r, en_r, push, p_s_r_BAR;
  wire   \s_ds_r[1] , n1, n2, n3, n4;
  wire   [2:0] nxt_st;
  wire   [2:0] cur_st;
  assign en_r = \s_ds_r[1] ;
  assign s_ds_r[1] = \s_ds_r[1] ;

  dff_async_rst_12 st0 ( .data(nxt_st[0]), .clk(clk), .reset(reset), .q(
        cur_st[0]) );
  dff_async_rst_11 st1 ( .data(nxt_st[1]), .clk(clk), .reset(reset), .q(
        cur_st[1]) );
  dff_async_rst_10 st2 ( .data(nxt_st[2]), .clk(clk), .reset(reset), .q(
        cur_st[2]) );
  AN21LLX1 U3 ( .A(cur_st[1]), .B(cur_st[2]), .C(cur_st[0]), .Q(rst_r) );
  ON21LLX1 U4 ( .A(cur_st[0]), .B(cur_st[1]), .C(cur_st[2]), .Q(p_s_r_BAR) );
  NA2LLX1 U5 ( .A(cur_st[0]), .B(cur_st[1]), .Q(n4) );
  NO2LLX1 U6 ( .A(cur_st[2]), .B(n4), .Q(\s_ds_r[1] ) );
  NO2I1LLX1 U7 ( .AN(cur_st[2]), .B(n4), .Q(s_ds_r[0]) );
  NO3I1SLLX1 U8 ( .AN(cur_st[0]), .B(cur_st[1]), .C(cur_st[2]), .Q(rdi) );
  NA2LLX1 U9 ( .A(cur_st[1]), .B(cur_st[2]), .Q(n1) );
  NO2LLX1 U10 ( .A(cur_st[0]), .B(n1), .Q(push) );
  ON222LLX0 U11 ( .A(cur_st[2]), .B(cur_st[1]), .C(cur_st[2]), .D(n4), .E(n4), 
        .F(condition_r), .Q(nxt_st[0]) );
  INLLX1 U12 ( .A(n4), .Q(n2) );
  ON21LLX1 U13 ( .A(rdi), .B(n2), .C(condition_r), .Q(n3) );
  NA2I1SLLX1 U14 ( .AN(\s_ds_r[1] ), .B(n3), .Q(nxt_st[1]) );
  NO22SLLX1 U15 ( .A(condition_r), .B(cur_st[2]), .C(n4), .Q(nxt_st[2]) );
endmodule


module dff_async_rst_7 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_8 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_9 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Write_st_Mchn_1 ( clk, reset, condition_w, bs_bsy, bs_rqst, s_ds_w, 
        rst_cntr_w, rst_w, en_w, pop, p_s_w_BAR );
  output [1:0] s_ds_w;
  input clk, reset, condition_w;
  output bs_bsy, bs_rqst, rst_cntr_w, rst_w, en_w, pop, p_s_w_BAR;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;
  wire   [2:0] nxt_st;
  wire   [2:0] cur_st;

  dff_async_rst_9 st0 ( .data(nxt_st[0]), .clk(clk), .reset(reset), .q(
        cur_st[0]) );
  dff_async_rst_8 st1 ( .data(nxt_st[1]), .clk(clk), .reset(reset), .q(
        cur_st[1]) );
  dff_async_rst_7 st2 ( .data(nxt_st[2]), .clk(clk), .reset(reset), .q(
        cur_st[2]) );
  INLLX1 U3 ( .A(cur_st[1]), .Q(n4) );
  NA2LLX1 U4 ( .A(cur_st[2]), .B(n4), .Q(n9) );
  INLLX1 U5 ( .A(cur_st[2]), .Q(n3) );
  NA2LLX1 U6 ( .A(cur_st[1]), .B(n3), .Q(n7) );
  NA2LLX1 U7 ( .A(n9), .B(n7), .Q(n1) );
  NO2LLX1 U8 ( .A(cur_st[0]), .B(n1), .Q(rst_w) );
  INLLX1 U9 ( .A(cur_st[0]), .Q(n5) );
  NA2LLX1 U10 ( .A(n1), .B(n5), .Q(n2) );
  ON21LLX1 U11 ( .A(n3), .B(n5), .C(n2), .Q(bs_rqst) );
  NA2LLX1 U12 ( .A(cur_st[1]), .B(cur_st[0]), .Q(n8) );
  NA2I1SLLX1 U13 ( .AN(rst_w), .B(n8), .Q(rst_cntr_w) );
  NO2LLX1 U14 ( .A(cur_st[0]), .B(n9), .Q(s_ds_w[0]) );
  ON32LLX0 U15 ( .A(n4), .B(cur_st[0]), .C(n3), .D(cur_st[2]), .E(cur_st[1]), 
        .Q(s_ds_w[1]) );
  INLLX1 U16 ( .A(n2), .Q(bs_bsy) );
  ON22LLX0 U17 ( .A(cur_st[0]), .B(n9), .C(n5), .D(n7), .Q(en_w) );
  NO2LLX1 U18 ( .A(n8), .B(n3), .Q(pop) );
  ON222LLX0 U19 ( .A(n5), .B(condition_w), .C(n5), .D(n4), .E(cur_st[1]), .F(
        cur_st[2]), .Q(nxt_st[0]) );
  NA2LLX1 U20 ( .A(condition_w), .B(n4), .Q(n6) );
  AN21LLX1 U21 ( .A(n7), .B(n6), .C(n5), .Q(nxt_st[1]) );
  ON211LLX0 U22 ( .A(condition_w), .B(n9), .C(n8), .D(n7), .Q(nxt_st[2]) );
endmodule


module Counter_mx_cnt64_2 ( count, clk, rst );
  output [5:0] count;
  input clk, rst;
  wire   N1, N2, N3, N4, N5, N6, n1, n2, n3, n4, n5, n7, n9;

  DFRRQLLX1 \count_reg[5]  ( .D(N6), .C(clk), .RN(n9), .Q(count[5]) );
  DFRRQLLX1 \count_reg[4]  ( .D(N5), .C(clk), .RN(n9), .Q(count[4]) );
  DFRRQLLX1 \count_reg[3]  ( .D(N4), .C(clk), .RN(n9), .Q(count[3]) );
  DFRRQLLX1 \count_reg[2]  ( .D(N3), .C(clk), .RN(n9), .Q(count[2]) );
  DFRRQLLX1 \count_reg[1]  ( .D(N2), .C(clk), .RN(n9), .Q(count[1]) );
  DFRRQLLX1 \count_reg[0]  ( .D(N1), .C(clk), .RN(n9), .Q(count[0]) );
  INLLX1 U3 ( .A(count[0]), .Q(N1) );
  NA3LLX0 U5 ( .A(count[0]), .B(count[1]), .C(count[2]), .Q(n3) );
  INLLX1 U6 ( .A(count[3]), .Q(n2) );
  NO2LLX1 U7 ( .A(n3), .B(n2), .Q(n1) );
  NA2LLX1 U8 ( .A(n1), .B(count[4]), .Q(n7) );
  OA21LLX1 U9 ( .A(n1), .B(count[4]), .C(n7), .Q(N5) );
  AN21LLX1 U10 ( .A(n3), .B(n2), .C(n1), .Q(N4) );
  INLLX1 U11 ( .A(count[1]), .Q(n5) );
  NO2LLX1 U12 ( .A(N1), .B(n5), .Q(n4) );
  OA21LLX1 U13 ( .A(n4), .B(count[2]), .C(n3), .Q(N3) );
  AN21LLX1 U14 ( .A(N1), .B(n5), .C(n4), .Q(N2) );
  EN2LLX2 U15 ( .A(count[5]), .B(n7), .Q(N6) );
  INLLX1 U4 ( .A(rst), .Q(n9) );
endmodule


module tri_buf_250 ( a, b, en );
  input a, en;
  output b;
  wire   N0, n2;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(N0), .Q(b) );
  INLLX1 U2 ( .A(en), .Q(N0) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module ntrfs_cntrl_n_rbtr_32_0_ff_2 ( clk, reset, D_in, bs_grnt, pndng, bs_bsy, 
        trn_chng, rst_w, rst_r, en_w, en_r, push, pop, p_s_w_BAR, p_s_r_BAR );
  input [31:24] D_in;
  input clk, reset, pndng;
  output bs_grnt, rst_w, rst_r, en_w, en_r, push, pop, p_s_w_BAR, p_s_r_BAR;
  inout bs_bsy,  trn_chng;
  wire   p_s_r, clk_cntr_w, clk_cntr_r, \cnt_rbtr[0] , bs_grnt_pre,
         trn_chng_nthng_t_snd, trn_chng_pre, bs_rqst, c_a, cond_r, rdi, cond_w,
         bs_bsy_pre, rst_cntr_w, n21, n22, n23, n26, n27, n1, n2, n3, n4, n5,
         n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19;
  wire   [5:0] count_w;
  wire   [1:0] s_ds_r;
  wire   [1:0] s_ds_w;
  wire   [5:0] count_r;
  tri   bs_bsy;
  tri   trn_chng;
  assign p_s_r_BAR = p_s_r;
  assign p_s_w_BAR = bs_rqst;

  dff_async_rst_143 bs_grnt_dly ( .data(bs_grnt_pre), .clk(clk), .reset(reset), 
        .q(bs_grnt) );
  tri_buf_251 bs_bsy_tri_buf ( .a(bs_bsy_pre), .b(bs_bsy), .en(bs_grnt) );
  Counter_arb_mx_cnt2_1 arb_cntr ( .clk(trn_chng), .rst(reset), 
        .\count[0]_BAR (\cnt_rbtr[0] ) );
  Arbiter_st_Mchn_1 arb_st_mchn ( .clk(clk), .reset(reset), .condition_a(c_a), 
        .trn_chng_nthng_t_snd(trn_chng_nthng_t_snd) );
  Counter_mx_cnt64_3 counter_w ( .count(count_w), .clk(clk_cntr_w), .rst(
        rst_cntr_w) );
  Counter_mx_cnt64_2 counter_r ( .count(count_r), .clk(clk_cntr_r), .rst(rst_r) );
  tri_buf_250 buf_trn_chng ( .a(trn_chng_pre), .b(trn_chng), .en(bs_grnt) );
  Read_st_Mchn_1 rdstmchn ( .condition_r(cond_r), .rdi(rdi), .reset(reset), 
        .clk(clk), .s_ds_r(s_ds_r), .rst_r(rst_r), .en_r(en_r), .push(push), 
        .p_s_r_BAR(p_s_r) );
  Write_st_Mchn_1 wtstmchn ( .clk(clk), .reset(reset), .condition_w(cond_w), 
        .bs_bsy(bs_bsy_pre), .bs_rqst(bs_rqst), .s_ds_w(s_ds_w), .rst_cntr_w(
        rst_cntr_w), .rst_w(rst_w), .en_w(en_w), .pop(pop) );
  DFRQLLX1 bs_grnt_pre_reg ( .D(\cnt_rbtr[0] ), .C(clk), .Q(bs_grnt_pre) );
  AN32LLX0 U29 ( .A(bs_bsy), .B(n22), .C(n26), .D(n21), .E(s_ds_r[1]), .Q(n23)
         );
  NO2I1SLLX1 U34 ( .AN(en_r), .B(n27), .Q(clk_cntr_r) );
  NO2I1SLLX1 U35 ( .AN(en_w), .B(n27), .Q(clk_cntr_w) );
  INLLX2 U33 ( .A(clk), .Q(n27) );
  NO3SLLX1 U3 ( .A(D_in[31]), .B(D_in[29]), .C(D_in[27]), .Q(n4) );
  NO3SLLX1 U4 ( .A(D_in[26]), .B(D_in[28]), .C(D_in[25]), .Q(n1) );
  NO2I1SLLX1 U5 ( .AN(n1), .B(D_in[30]), .Q(n3) );
  INLLX1 U6 ( .A(D_in[24]), .Q(n2) );
  AN31LLX1 U7 ( .A(n4), .B(n3), .C(n2), .D(p_s_r), .Q(n9) );
  NA3LLX0 U8 ( .A(count_r[4]), .B(count_r[1]), .C(count_r[0]), .Q(n5) );
  NO2LLX1 U9 ( .A(n5), .B(count_r[5]), .Q(n7) );
  AN31LLX1 U11 ( .A(n7), .B(count_r[3]), .C(count_r[2]), .D(n19), .Q(n8) );
  NO2LLX1 U12 ( .A(n9), .B(n8), .Q(n21) );
  INLLX1 U13 ( .A(s_ds_r[0]), .Q(n13) );
  NA4SLLX1 U14 ( .A(D_in[30]), .B(D_in[26]), .C(D_in[28]), .D(D_in[25]), .Q(
        n11) );
  NA4SLLX1 U15 ( .A(D_in[24]), .B(D_in[31]), .C(D_in[29]), .D(D_in[27]), .Q(
        n10) );
  NO22SLLX1 U16 ( .A(n11), .B(n10), .C(n21), .Q(n12) );
  ON32LLX0 U17 ( .A(n13), .B(s_ds_r[1]), .C(n12), .D(s_ds_r[0]), .E(n23), .Q(
        cond_r) );
  INLLX1 U18 ( .A(bs_grnt), .Q(n26) );
  NA2LLX1 U19 ( .A(s_ds_w[1]), .B(pndng), .Q(n18) );
  NO4I2LLX1 U20 ( .AN(s_ds_w[0]), .BN(count_w[5]), .C(count_w[4]), .D(
        count_w[1]), .Q(n16) );
  NO3SLLX1 U21 ( .A(count_w[2]), .B(count_w[0]), .C(count_w[3]), .Q(n15) );
  NO2LLX1 U22 ( .A(s_ds_w[0]), .B(n26), .Q(n14) );
  AN22LLX0 U23 ( .A(n16), .B(n15), .C(rdi), .D(n14), .Q(n17) );
  ON22LLX0 U24 ( .A(n18), .B(s_ds_w[0]), .C(s_ds_w[1]), .D(n17), .Q(cond_w) );
  OR2SLLX1 U25 ( .A(rst_w), .B(trn_chng_nthng_t_snd), .Q(trn_chng_pre) );
  NO2LLX1 U26 ( .A(bs_rqst), .B(n26), .Q(c_a) );
  INLLX1 U27 ( .A(s_ds_r[1]), .Q(n22) );
  INLLX1 U10 ( .A(p_s_r), .Q(n19) );
endmodule


module dff_async_rst_141 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n1;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n1), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n1) );
endmodule


module tri_buf_246 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_247 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_123 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_247 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_246 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module dff_async_rst_111 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_112 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_113 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_114 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_115 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_116 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_117 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_118 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_119 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_120 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_121 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_122 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_123 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_124 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_125 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_126 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_127 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_128 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_129 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_130 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_131 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_132 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_133 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_134 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_135 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_136 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_137 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_138 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_139 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_140 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_142 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module tri_buf_186 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_187 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_93 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_187 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_186 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_188 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_189 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_94 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_189 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_188 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_190 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_191 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_95 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_191 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_190 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_192 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_193 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_96 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_193 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_192 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_194 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_195 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_97 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_195 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_194 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_196 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_197 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_98 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_197 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_196 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_198 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_199 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_99 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_199 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_198 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_200 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_201 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_100 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_201 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_200 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_202 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_203 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_101 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_203 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_202 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_204 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_205 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_102 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_205 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_204 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_206 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_207 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_103 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_207 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_206 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_208 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_209 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_104 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_209 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_208 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_210 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_211 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_105 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_211 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_210 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_212 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_213 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_106 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_213 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_212 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_214 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_215 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_107 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_215 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_214 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_216 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_217 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_108 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_217 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_216 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_218 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_219 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_109 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_219 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_218 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_220 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_221 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_110 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_221 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_220 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_222 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_223 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_111 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_223 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_222 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_224 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_225 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_112 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_225 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_224 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_226 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_227 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_113 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_227 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_226 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_228 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_229 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_114 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_229 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_228 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_230 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_231 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_115 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_231 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_230 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_232 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_233 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_116 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_233 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_232 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_234 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_235 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_117 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_235 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_234 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_236 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_237 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_118 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_237 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_236 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_238 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_239 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_119 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_239 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_238 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_240 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_241 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_120 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_241 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_240 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_242 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_243 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_121 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_243 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_242 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_244 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_245 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_122 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_245 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_244 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module serializer_pckg_sz32_3 ( s_in, rst, clk, P_in, s_out, P_out, 
        sel_p_s_BAR );
  input [31:0] P_in;
  output [31:0] P_out;
  input s_in, rst, clk, sel_p_s_BAR;
  output s_out;
  wire   sel_p_s, n2, n1, n10, n11, n12;
  wire   [31:0] d;
  wire   [30:0] q;
  tri   s_out;
  assign sel_p_s = sel_p_s_BAR;

  dff_async_rst_142 \_bit[0].dff  ( .data(d[0]), .clk(clk), .reset(rst), .q(
        q[0]) );
  dff_async_rst_141 \_bit[1].dff  ( .data(d[1]), .clk(clk), .reset(rst), .q(
        q[1]) );
  dff_async_rst_140 \_bit[2].dff  ( .data(d[2]), .clk(clk), .reset(rst), .q(
        q[2]) );
  dff_async_rst_139 \_bit[3].dff  ( .data(d[3]), .clk(clk), .reset(rst), .q(
        q[3]) );
  dff_async_rst_138 \_bit[4].dff  ( .data(d[4]), .clk(clk), .reset(rst), .q(
        q[4]) );
  dff_async_rst_137 \_bit[5].dff  ( .data(d[5]), .clk(clk), .reset(rst), .q(
        q[5]) );
  dff_async_rst_136 \_bit[6].dff  ( .data(d[6]), .clk(clk), .reset(rst), .q(
        q[6]) );
  dff_async_rst_135 \_bit[7].dff  ( .data(d[7]), .clk(clk), .reset(rst), .q(
        q[7]) );
  dff_async_rst_134 \_bit[8].dff  ( .data(d[8]), .clk(clk), .reset(rst), .q(
        q[8]) );
  dff_async_rst_133 \_bit[9].dff  ( .data(d[9]), .clk(clk), .reset(rst), .q(
        q[9]) );
  dff_async_rst_132 \_bit[10].dff  ( .data(d[10]), .clk(clk), .reset(rst), .q(
        q[10]) );
  dff_async_rst_131 \_bit[11].dff  ( .data(d[11]), .clk(clk), .reset(rst), .q(
        q[11]) );
  dff_async_rst_130 \_bit[12].dff  ( .data(d[12]), .clk(clk), .reset(rst), .q(
        q[12]) );
  dff_async_rst_129 \_bit[13].dff  ( .data(d[13]), .clk(clk), .reset(rst), .q(
        q[13]) );
  dff_async_rst_128 \_bit[14].dff  ( .data(d[14]), .clk(clk), .reset(rst), .q(
        q[14]) );
  dff_async_rst_127 \_bit[15].dff  ( .data(d[15]), .clk(clk), .reset(rst), .q(
        q[15]) );
  dff_async_rst_126 \_bit[16].dff  ( .data(d[16]), .clk(clk), .reset(rst), .q(
        q[16]) );
  dff_async_rst_125 \_bit[17].dff  ( .data(d[17]), .clk(clk), .reset(rst), .q(
        q[17]) );
  dff_async_rst_124 \_bit[18].dff  ( .data(d[18]), .clk(clk), .reset(rst), .q(
        q[18]) );
  dff_async_rst_123 \_bit[19].dff  ( .data(d[19]), .clk(clk), .reset(rst), .q(
        q[19]) );
  dff_async_rst_122 \_bit[20].dff  ( .data(d[20]), .clk(clk), .reset(rst), .q(
        q[20]) );
  dff_async_rst_121 \_bit[21].dff  ( .data(d[21]), .clk(clk), .reset(rst), .q(
        q[21]) );
  dff_async_rst_120 \_bit[22].dff  ( .data(d[22]), .clk(clk), .reset(rst), .q(
        q[22]) );
  dff_async_rst_119 \_bit[23].dff  ( .data(d[23]), .clk(clk), .reset(rst), .q(
        q[23]) );
  dff_async_rst_118 \_bit[24].dff  ( .data(d[24]), .clk(clk), .reset(rst), .q(
        q[24]) );
  dff_async_rst_117 \_bit[25].dff  ( .data(d[25]), .clk(clk), .reset(rst), .q(
        q[25]) );
  dff_async_rst_116 \_bit[26].dff  ( .data(d[26]), .clk(clk), .reset(rst), .q(
        q[26]) );
  dff_async_rst_115 \_bit[27].dff  ( .data(d[27]), .clk(clk), .reset(rst), .q(
        q[27]) );
  dff_async_rst_114 \_bit[28].dff  ( .data(d[28]), .clk(clk), .reset(rst), .q(
        q[28]) );
  dff_async_rst_113 \_bit[29].dff  ( .data(d[29]), .clk(clk), .reset(rst), .q(
        q[29]) );
  dff_async_rst_112 \_bit[30].dff  ( .data(d[30]), .clk(clk), .reset(rst), .q(
        q[30]) );
  dff_async_rst_111 \_bit[31].dff  ( .data(d[31]), .clk(clk), .reset(rst), .q(
        n2) );
  parallel_serial_123 \bt[0].pts  ( .S_in(q[0]), .P_in(P_in[1]), .S_out(d[1]), 
        .sel_P_S_BAR(n11) );
  parallel_serial_122 \bt[1].pts  ( .S_in(q[1]), .P_in(P_in[2]), .S_out(d[2]), 
        .sel_P_S_BAR(sel_p_s) );
  parallel_serial_121 \bt[2].pts  ( .S_in(q[2]), .P_in(P_in[3]), .S_out(d[3]), 
        .sel_P_S_BAR(sel_p_s) );
  parallel_serial_120 \bt[3].pts  ( .S_in(q[3]), .P_in(P_in[4]), .S_out(d[4]), 
        .sel_P_S_BAR(n12) );
  parallel_serial_119 \bt[4].pts  ( .S_in(q[4]), .P_in(P_in[5]), .S_out(d[5]), 
        .sel_P_S_BAR(sel_p_s) );
  parallel_serial_118 \bt[5].pts  ( .S_in(q[5]), .P_in(P_in[6]), .S_out(d[6]), 
        .sel_P_S_BAR(sel_p_s) );
  parallel_serial_117 \bt[6].pts  ( .S_in(q[6]), .P_in(P_in[7]), .S_out(d[7]), 
        .sel_P_S_BAR(sel_p_s) );
  parallel_serial_116 \bt[7].pts  ( .S_in(q[7]), .P_in(P_in[8]), .S_out(d[8]), 
        .sel_P_S_BAR(n11) );
  parallel_serial_115 \bt[8].pts  ( .S_in(q[8]), .P_in(P_in[9]), .S_out(d[9]), 
        .sel_P_S_BAR(n11) );
  parallel_serial_114 \bt[9].pts  ( .S_in(q[9]), .P_in(P_in[10]), .S_out(d[10]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_113 \bt[10].pts  ( .S_in(q[10]), .P_in(P_in[11]), .S_out(
        d[11]), .sel_P_S_BAR(n12) );
  parallel_serial_112 \bt[11].pts  ( .S_in(q[11]), .P_in(P_in[12]), .S_out(
        d[12]), .sel_P_S_BAR(n12) );
  parallel_serial_111 \bt[12].pts  ( .S_in(q[12]), .P_in(P_in[13]), .S_out(
        d[13]), .sel_P_S_BAR(n12) );
  parallel_serial_110 \bt[13].pts  ( .S_in(q[13]), .P_in(P_in[14]), .S_out(
        d[14]), .sel_P_S_BAR(n11) );
  parallel_serial_109 \bt[14].pts  ( .S_in(q[14]), .P_in(P_in[15]), .S_out(
        d[15]), .sel_P_S_BAR(n11) );
  parallel_serial_108 \bt[15].pts  ( .S_in(q[15]), .P_in(P_in[16]), .S_out(
        d[16]), .sel_P_S_BAR(n11) );
  parallel_serial_107 \bt[16].pts  ( .S_in(q[16]), .P_in(P_in[17]), .S_out(
        d[17]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_106 \bt[17].pts  ( .S_in(q[17]), .P_in(P_in[18]), .S_out(
        d[18]), .sel_P_S_BAR(n12) );
  parallel_serial_105 \bt[18].pts  ( .S_in(q[18]), .P_in(P_in[19]), .S_out(
        d[19]), .sel_P_S_BAR(n12) );
  parallel_serial_104 \bt[19].pts  ( .S_in(q[19]), .P_in(P_in[20]), .S_out(
        d[20]), .sel_P_S_BAR(n12) );
  parallel_serial_103 \bt[20].pts  ( .S_in(q[20]), .P_in(P_in[21]), .S_out(
        d[21]), .sel_P_S_BAR(n12) );
  parallel_serial_102 \bt[21].pts  ( .S_in(q[21]), .P_in(P_in[22]), .S_out(
        d[22]), .sel_P_S_BAR(n11) );
  parallel_serial_101 \bt[22].pts  ( .S_in(q[22]), .P_in(P_in[23]), .S_out(
        d[23]), .sel_P_S_BAR(n11) );
  parallel_serial_100 \bt[23].pts  ( .S_in(q[23]), .P_in(P_in[24]), .S_out(
        d[24]), .sel_P_S_BAR(n11) );
  parallel_serial_99 \bt[24].pts  ( .S_in(q[24]), .P_in(P_in[25]), .S_out(
        d[25]), .sel_P_S_BAR(n11) );
  parallel_serial_98 \bt[25].pts  ( .S_in(q[25]), .P_in(P_in[26]), .S_out(
        d[26]), .sel_P_S_BAR(n11) );
  parallel_serial_97 \bt[26].pts  ( .S_in(q[26]), .P_in(P_in[27]), .S_out(
        d[27]), .sel_P_S_BAR(n11) );
  parallel_serial_96 \bt[27].pts  ( .S_in(q[27]), .P_in(P_in[28]), .S_out(
        d[28]), .sel_P_S_BAR(n11) );
  parallel_serial_95 \bt[28].pts  ( .S_in(q[28]), .P_in(P_in[29]), .S_out(
        d[29]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_94 \bt[29].pts  ( .S_in(q[29]), .P_in(P_in[30]), .S_out(
        d[30]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_93 \bt[30].pts  ( .S_in(q[30]), .P_in(P_in[31]), .S_out(
        d[31]), .sel_P_S_BAR(sel_p_s) );
  ITLLLX1 s_out_tri ( .A(n1), .EN(n10), .Q(s_out) );
  NO2I1LLX1 U7 ( .AN(P_in[0]), .B(sel_p_s), .Q(d[0]) );
  INLLX1 U8 ( .A(n2), .Q(n1) );
  INLLX1 U2 ( .A(sel_p_s), .Q(n10) );
  BULLX1 U3 ( .A(sel_p_s), .Q(n11) );
  BULLX1 U4 ( .A(sel_p_s), .Q(n12) );
endmodule


module tri_buf_184 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_185 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_92 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_185 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_184 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module dff_async_rst_79 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_80 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_81 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_82 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_83 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_84 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_85 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_86 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_87 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_88 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_89 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_90 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_91 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_92 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_93 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_94 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_95 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_96 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_97 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_98 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_99 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_100 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_101 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_102 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_103 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_104 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_105 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_106 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_107 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_108 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_109 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_110 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module tri_buf_124 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_125 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_62 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_125 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_124 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_126 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_127 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_63 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_127 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_126 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_128 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_129 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_64 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_129 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_128 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_130 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_131 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_65 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_131 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_130 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_132 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_133 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_66 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_133 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_132 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_134 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_135 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_67 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_135 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_134 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_136 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_137 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_68 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_137 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_136 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_138 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_139 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_69 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_139 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_138 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_140 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_141 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_70 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_141 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_140 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_142 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_143 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_71 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_143 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_142 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_144 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_145 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_72 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_145 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_144 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_146 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_147 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_73 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_147 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_146 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_148 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_149 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_74 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_149 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_148 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_150 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_151 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_75 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_151 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_150 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_152 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_153 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_76 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_153 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_152 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_154 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_155 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_77 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_155 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_154 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_156 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_157 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_78 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_157 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_156 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_158 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_159 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_79 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_159 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_158 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_160 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_161 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_80 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_161 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_160 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_162 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_163 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_81 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_163 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_162 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_164 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_165 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_82 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_165 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_164 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_166 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_167 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_83 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_167 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_166 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_168 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_169 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_84 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_169 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_168 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_170 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_171 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_85 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_171 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_170 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_172 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_173 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_86 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_173 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_172 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_174 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_175 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_87 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_175 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_174 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_176 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_177 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_88 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_177 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_176 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_178 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_179 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_89 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_179 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_178 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_180 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_181 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_90 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_181 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_180 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_182 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(1'b1), .EN(en), .Q(b) );
endmodule


module tri_buf_183 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_91 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   S_in, sel_P_S;
  tri   S_out;
  assign P_out = S_in;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_183 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_182 parallel_in ( .a(1'b0), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module serializer_pckg_sz32_2 ( s_in, rst, clk, P_in, s_out, P_out, 
        sel_p_s_BAR );
  input [31:0] P_in;
  output [31:0] P_out;
  input s_in, rst, clk, sel_p_s_BAR;
  output s_out;
  wire   sel_p_s, n37, n38;
  wire   [31:0] d;
  wire   [30:0] q;
  tri   s_in;
  assign sel_p_s = sel_p_s_BAR;

  dff_async_rst_110 \_bit[0].dff  ( .data(d[0]), .clk(clk), .reset(rst), .q(
        q[0]) );
  dff_async_rst_109 \_bit[1].dff  ( .data(d[1]), .clk(clk), .reset(rst), .q(
        q[1]) );
  dff_async_rst_108 \_bit[2].dff  ( .data(d[2]), .clk(clk), .reset(rst), .q(
        q[2]) );
  dff_async_rst_107 \_bit[3].dff  ( .data(d[3]), .clk(clk), .reset(rst), .q(
        q[3]) );
  dff_async_rst_106 \_bit[4].dff  ( .data(d[4]), .clk(clk), .reset(rst), .q(
        q[4]) );
  dff_async_rst_105 \_bit[5].dff  ( .data(d[5]), .clk(clk), .reset(rst), .q(
        q[5]) );
  dff_async_rst_104 \_bit[6].dff  ( .data(d[6]), .clk(clk), .reset(rst), .q(
        q[6]) );
  dff_async_rst_103 \_bit[7].dff  ( .data(d[7]), .clk(clk), .reset(rst), .q(
        q[7]) );
  dff_async_rst_102 \_bit[8].dff  ( .data(d[8]), .clk(clk), .reset(rst), .q(
        q[8]) );
  dff_async_rst_101 \_bit[9].dff  ( .data(d[9]), .clk(clk), .reset(rst), .q(
        q[9]) );
  dff_async_rst_100 \_bit[10].dff  ( .data(d[10]), .clk(clk), .reset(rst), .q(
        q[10]) );
  dff_async_rst_99 \_bit[11].dff  ( .data(d[11]), .clk(clk), .reset(rst), .q(
        q[11]) );
  dff_async_rst_98 \_bit[12].dff  ( .data(d[12]), .clk(clk), .reset(rst), .q(
        q[12]) );
  dff_async_rst_97 \_bit[13].dff  ( .data(d[13]), .clk(clk), .reset(rst), .q(
        q[13]) );
  dff_async_rst_96 \_bit[14].dff  ( .data(d[14]), .clk(clk), .reset(rst), .q(
        q[14]) );
  dff_async_rst_95 \_bit[15].dff  ( .data(d[15]), .clk(clk), .reset(rst), .q(
        q[15]) );
  dff_async_rst_94 \_bit[16].dff  ( .data(d[16]), .clk(clk), .reset(rst), .q(
        q[16]) );
  dff_async_rst_93 \_bit[17].dff  ( .data(d[17]), .clk(clk), .reset(rst), .q(
        q[17]) );
  dff_async_rst_92 \_bit[18].dff  ( .data(d[18]), .clk(clk), .reset(rst), .q(
        q[18]) );
  dff_async_rst_91 \_bit[19].dff  ( .data(d[19]), .clk(clk), .reset(rst), .q(
        q[19]) );
  dff_async_rst_90 \_bit[20].dff  ( .data(d[20]), .clk(clk), .reset(rst), .q(
        q[20]) );
  dff_async_rst_89 \_bit[21].dff  ( .data(d[21]), .clk(clk), .reset(rst), .q(
        q[21]) );
  dff_async_rst_88 \_bit[22].dff  ( .data(d[22]), .clk(clk), .reset(rst), .q(
        q[22]) );
  dff_async_rst_87 \_bit[23].dff  ( .data(d[23]), .clk(clk), .reset(rst), .q(
        q[23]) );
  dff_async_rst_86 \_bit[24].dff  ( .data(d[24]), .clk(clk), .reset(rst), .q(
        q[24]) );
  dff_async_rst_85 \_bit[25].dff  ( .data(d[25]), .clk(clk), .reset(rst), .q(
        q[25]) );
  dff_async_rst_84 \_bit[26].dff  ( .data(d[26]), .clk(clk), .reset(rst), .q(
        q[26]) );
  dff_async_rst_83 \_bit[27].dff  ( .data(d[27]), .clk(clk), .reset(rst), .q(
        q[27]) );
  dff_async_rst_82 \_bit[28].dff  ( .data(d[28]), .clk(clk), .reset(rst), .q(
        q[28]) );
  dff_async_rst_81 \_bit[29].dff  ( .data(d[29]), .clk(clk), .reset(rst), .q(
        q[29]) );
  dff_async_rst_80 \_bit[30].dff  ( .data(d[30]), .clk(clk), .reset(rst), .q(
        q[30]) );
  dff_async_rst_79 \_bit[31].dff  ( .data(d[31]), .clk(clk), .reset(rst), .q(
        P_out[31]) );
  parallel_serial_92 \bt[0].pts  ( .S_in(q[0]), .P_in(1'b0), .S_out(d[1]), 
        .P_out(P_out[0]), .sel_P_S_BAR(n37) );
  parallel_serial_91 \bt[1].pts  ( .S_in(q[1]), .P_in(1'b0), .S_out(d[2]), 
        .P_out(P_out[1]), .sel_P_S_BAR(n37) );
  parallel_serial_90 \bt[2].pts  ( .S_in(q[2]), .P_in(1'b0), .S_out(d[3]), 
        .P_out(P_out[2]), .sel_P_S_BAR(n37) );
  parallel_serial_89 \bt[3].pts  ( .S_in(q[3]), .P_in(1'b0), .S_out(d[4]), 
        .P_out(P_out[3]), .sel_P_S_BAR(n37) );
  parallel_serial_88 \bt[4].pts  ( .S_in(q[4]), .P_in(1'b0), .S_out(d[5]), 
        .P_out(P_out[4]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_87 \bt[5].pts  ( .S_in(q[5]), .P_in(1'b0), .S_out(d[6]), 
        .P_out(P_out[5]), .sel_P_S_BAR(n38) );
  parallel_serial_86 \bt[6].pts  ( .S_in(q[6]), .P_in(1'b0), .S_out(d[7]), 
        .P_out(P_out[6]), .sel_P_S_BAR(n38) );
  parallel_serial_85 \bt[7].pts  ( .S_in(q[7]), .P_in(1'b0), .S_out(d[8]), 
        .P_out(P_out[7]), .sel_P_S_BAR(n38) );
  parallel_serial_84 \bt[8].pts  ( .S_in(q[8]), .P_in(1'b0), .S_out(d[9]), 
        .P_out(P_out[8]), .sel_P_S_BAR(n38) );
  parallel_serial_83 \bt[9].pts  ( .S_in(q[9]), .P_in(1'b0), .S_out(d[10]), 
        .P_out(P_out[9]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_82 \bt[10].pts  ( .S_in(q[10]), .P_in(1'b0), .S_out(d[11]), 
        .P_out(P_out[10]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_81 \bt[11].pts  ( .S_in(q[11]), .P_in(1'b0), .S_out(d[12]), 
        .P_out(P_out[11]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_80 \bt[12].pts  ( .S_in(q[12]), .P_in(1'b0), .S_out(d[13]), 
        .P_out(P_out[12]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_79 \bt[13].pts  ( .S_in(q[13]), .P_in(1'b0), .S_out(d[14]), 
        .P_out(P_out[13]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_78 \bt[14].pts  ( .S_in(q[14]), .P_in(1'b0), .S_out(d[15]), 
        .P_out(P_out[14]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_77 \bt[15].pts  ( .S_in(q[15]), .P_in(1'b0), .S_out(d[16]), 
        .P_out(P_out[15]), .sel_P_S_BAR(n37) );
  parallel_serial_76 \bt[16].pts  ( .S_in(q[16]), .P_in(1'b0), .S_out(d[17]), 
        .P_out(P_out[16]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_75 \bt[17].pts  ( .S_in(q[17]), .P_in(1'b0), .S_out(d[18]), 
        .P_out(P_out[17]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_74 \bt[18].pts  ( .S_in(q[18]), .P_in(1'b0), .S_out(d[19]), 
        .P_out(P_out[18]), .sel_P_S_BAR(n38) );
  parallel_serial_73 \bt[19].pts  ( .S_in(q[19]), .P_in(1'b0), .S_out(d[20]), 
        .P_out(P_out[19]), .sel_P_S_BAR(n38) );
  parallel_serial_72 \bt[20].pts  ( .S_in(q[20]), .P_in(1'b0), .S_out(d[21]), 
        .P_out(P_out[20]), .sel_P_S_BAR(n38) );
  parallel_serial_71 \bt[21].pts  ( .S_in(q[21]), .P_in(1'b0), .S_out(d[22]), 
        .P_out(P_out[21]), .sel_P_S_BAR(n38) );
  parallel_serial_70 \bt[22].pts  ( .S_in(q[22]), .P_in(1'b0), .S_out(d[23]), 
        .P_out(P_out[22]), .sel_P_S_BAR(n38) );
  parallel_serial_69 \bt[23].pts  ( .S_in(q[23]), .P_in(1'b0), .S_out(d[24]), 
        .P_out(P_out[23]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_68 \bt[24].pts  ( .S_in(q[24]), .P_in(1'b0), .S_out(d[25]), 
        .P_out(P_out[24]), .sel_P_S_BAR(n37) );
  parallel_serial_67 \bt[25].pts  ( .S_in(q[25]), .P_in(1'b0), .S_out(d[26]), 
        .P_out(P_out[25]), .sel_P_S_BAR(n37) );
  parallel_serial_66 \bt[26].pts  ( .S_in(q[26]), .P_in(1'b0), .S_out(d[27]), 
        .P_out(P_out[26]), .sel_P_S_BAR(n37) );
  parallel_serial_65 \bt[27].pts  ( .S_in(q[27]), .P_in(1'b0), .S_out(d[28]), 
        .P_out(P_out[27]), .sel_P_S_BAR(n37) );
  parallel_serial_64 \bt[28].pts  ( .S_in(q[28]), .P_in(1'b0), .S_out(d[29]), 
        .P_out(P_out[28]), .sel_P_S_BAR(n37) );
  parallel_serial_63 \bt[29].pts  ( .S_in(q[29]), .P_in(1'b0), .S_out(d[30]), 
        .P_out(P_out[29]), .sel_P_S_BAR(n37) );
  parallel_serial_62 \bt[30].pts  ( .S_in(q[30]), .P_in(1'b0), .S_out(d[31]), 
        .P_out(P_out[30]), .sel_P_S_BAR(n37) );
  AND2LLX1 U6 ( .A(s_in), .B(n37), .Q(d[0]) );
  BULLX1 U1 ( .A(sel_p_s), .Q(n37) );
  BULLX1 U2 ( .A(sel_p_s), .Q(n38) );
endmodule


module bs_ntrfs_n_rbtr_32_0_ff_2 ( clk, reset, pndng, D_pop, D_push, push, pop, 
        bus, bs_bsy, trn_chng );
  input [31:0] D_pop;
  output [31:0] D_push;
  input clk, reset, pndng;
  output push, pop;
  inout bus,  bs_bsy,  trn_chng;
  wire   en_r, clk_rd, en_w, clk_wt, bs_grnt, rst_w, rst_r, p_s_r, N0, n1, n2;
  tri   bus;
  tri   bs_bsy;
  tri   trn_chng;
  tri   bus_pre_wd;

  ntrfs_cntrl_n_rbtr_32_0_ff_2 cntrl ( .clk(clk), .reset(reset), .D_in(
        D_push[31:24]), .bs_grnt(bs_grnt), .pndng(pndng), .bs_bsy(bs_bsy), 
        .trn_chng(trn_chng), .rst_w(rst_w), .rst_r(rst_r), .en_w(en_w), .en_r(
        en_r), .push(push), .pop(pop), .p_s_w_BAR(n2), .p_s_r_BAR(p_s_r) );
  serializer_pckg_sz32_3 srlzr_wt ( .s_in(1'b0), .rst(rst_w), .clk(clk_wt), 
        .P_in(D_pop), .s_out(bus_pre_wd), .sel_p_s_BAR(n2) );
  serializer_pckg_sz32_2 srlzr_rd ( .s_in(bus), .rst(rst_r), .clk(clk_rd), 
        .P_in({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}), .P_out(
        D_push), .sel_p_s_BAR(p_s_r) );
  ITLLLX1 bus_tri ( .A(n1), .EN(N0), .Q(bus) );
  AND2LLX1 U4 ( .A(clk), .B(en_w), .Q(clk_wt) );
  AND2LLX1 U5 ( .A(clk), .B(en_r), .Q(clk_rd) );
  INLLX1 U3 ( .A(bs_grnt), .Q(N0) );
  INLLX1 U6 ( .A(bus_pre_wd), .Q(n1) );
endmodule


module dff_async_rst_0 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_1 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_2 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Write_st_Mchn_0 ( clk, reset, condition_w, bs_bsy, bs_rqst, s_ds_w, 
        rst_cntr_w, rst_w, en_w, pop, p_s_w_BAR );
  output [1:0] s_ds_w;
  input clk, reset, condition_w;
  output bs_bsy, bs_rqst, rst_cntr_w, rst_w, en_w, pop, p_s_w_BAR;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;
  wire   [2:0] nxt_st;
  wire   [2:0] cur_st;

  dff_async_rst_2 st0 ( .data(nxt_st[0]), .clk(clk), .reset(reset), .q(
        cur_st[0]) );
  dff_async_rst_1 st1 ( .data(nxt_st[1]), .clk(clk), .reset(reset), .q(
        cur_st[1]) );
  dff_async_rst_0 st2 ( .data(nxt_st[2]), .clk(clk), .reset(reset), .q(
        cur_st[2]) );
  INLLX1 U3 ( .A(cur_st[1]), .Q(n4) );
  NA2LLX1 U4 ( .A(cur_st[2]), .B(n4), .Q(n9) );
  INLLX1 U5 ( .A(cur_st[2]), .Q(n3) );
  NA2LLX1 U6 ( .A(cur_st[1]), .B(n3), .Q(n7) );
  NA2LLX1 U7 ( .A(n9), .B(n7), .Q(n1) );
  NO2LLX1 U8 ( .A(cur_st[0]), .B(n1), .Q(rst_w) );
  INLLX1 U9 ( .A(cur_st[0]), .Q(n5) );
  NA2LLX1 U10 ( .A(n1), .B(n5), .Q(n2) );
  ON21LLX1 U11 ( .A(n3), .B(n5), .C(n2), .Q(bs_rqst) );
  NA2LLX1 U12 ( .A(cur_st[1]), .B(cur_st[0]), .Q(n8) );
  NA2I1SLLX1 U13 ( .AN(rst_w), .B(n8), .Q(rst_cntr_w) );
  NO2LLX1 U14 ( .A(cur_st[0]), .B(n9), .Q(s_ds_w[0]) );
  ON32LLX0 U15 ( .A(n4), .B(cur_st[0]), .C(n3), .D(cur_st[2]), .E(cur_st[1]), 
        .Q(s_ds_w[1]) );
  INLLX1 U16 ( .A(n2), .Q(bs_bsy) );
  ON22LLX0 U17 ( .A(cur_st[0]), .B(n9), .C(n5), .D(n7), .Q(en_w) );
  NO2LLX1 U18 ( .A(n8), .B(n3), .Q(pop) );
  ON222LLX0 U19 ( .A(n5), .B(condition_w), .C(n5), .D(n4), .E(cur_st[1]), .F(
        cur_st[2]), .Q(nxt_st[0]) );
  NA2LLX1 U20 ( .A(condition_w), .B(n4), .Q(n6) );
  AN21LLX1 U21 ( .A(n7), .B(n6), .C(n5), .Q(nxt_st[1]) );
  ON211LLX0 U22 ( .A(condition_w), .B(n9), .C(n8), .D(n7), .Q(nxt_st[2]) );
endmodule


module dff_async_rst_3 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_4 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_5 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Read_st_Mchn_0 ( condition_r, rdi, reset, clk, s_ds_r, s_cmp, 
        rst_cntr_r, rst_r, p_s_r, en_r, push );
  output [1:0] s_ds_r;
  input condition_r, reset, clk;
  output rdi, s_cmp, rst_cntr_r, rst_r, p_s_r, en_r, push;
  wire   \s_ds_r[1] , n1, n2, n3, n4;
  wire   [2:0] nxt_st;
  wire   [2:0] cur_st;
  assign en_r = \s_ds_r[1] ;
  assign s_ds_r[1] = \s_ds_r[1] ;

  dff_async_rst_5 st0 ( .data(nxt_st[0]), .clk(clk), .reset(reset), .q(
        cur_st[0]) );
  dff_async_rst_4 st1 ( .data(nxt_st[1]), .clk(clk), .reset(reset), .q(
        cur_st[1]) );
  dff_async_rst_3 st2 ( .data(nxt_st[2]), .clk(clk), .reset(reset), .q(
        cur_st[2]) );
  ON21LLX1 U3 ( .A(cur_st[0]), .B(cur_st[1]), .C(cur_st[2]), .Q(s_cmp) );
  AN21LLX1 U5 ( .A(cur_st[1]), .B(cur_st[2]), .C(cur_st[0]), .Q(rst_r) );
  NA2LLX1 U6 ( .A(cur_st[0]), .B(cur_st[1]), .Q(n4) );
  ON222LLX0 U7 ( .A(cur_st[2]), .B(cur_st[1]), .C(cur_st[2]), .D(n4), .E(n4), 
        .F(condition_r), .Q(nxt_st[0]) );
  NO2LLX1 U8 ( .A(cur_st[2]), .B(n4), .Q(\s_ds_r[1] ) );
  NO2I1LLX1 U9 ( .AN(cur_st[2]), .B(n4), .Q(s_ds_r[0]) );
  NO3I1SLLX1 U10 ( .AN(cur_st[0]), .B(cur_st[1]), .C(cur_st[2]), .Q(rdi) );
  NA2LLX1 U11 ( .A(cur_st[1]), .B(cur_st[2]), .Q(n1) );
  NO2LLX1 U12 ( .A(cur_st[0]), .B(n1), .Q(push) );
  INLLX1 U13 ( .A(n4), .Q(n2) );
  ON21LLX1 U14 ( .A(rdi), .B(n2), .C(condition_r), .Q(n3) );
  NA2I1SLLX1 U15 ( .AN(\s_ds_r[1] ), .B(n3), .Q(nxt_st[1]) );
  NO22SLLX1 U16 ( .A(condition_r), .B(cur_st[2]), .C(n4), .Q(nxt_st[2]) );
endmodule


module Counter_mx_cnt64_0 ( count, clk, rst );
  output [5:0] count;
  input clk, rst;
  wire   N1, N2, N3, N4, N5, N6, n1, n2, n3, n4, n5, n7, n9;

  DFRRQLLX1 \count_reg[5]  ( .D(N6), .C(clk), .RN(n9), .Q(count[5]) );
  DFRRQLLX1 \count_reg[4]  ( .D(N5), .C(clk), .RN(n9), .Q(count[4]) );
  DFRRQLLX1 \count_reg[3]  ( .D(N4), .C(clk), .RN(n9), .Q(count[3]) );
  DFRRQLLX1 \count_reg[2]  ( .D(N3), .C(clk), .RN(n9), .Q(count[2]) );
  DFRRQLLX1 \count_reg[1]  ( .D(N2), .C(clk), .RN(n9), .Q(count[1]) );
  DFRRQLLX1 \count_reg[0]  ( .D(N1), .C(clk), .RN(n9), .Q(count[0]) );
  INLLX1 U3 ( .A(count[0]), .Q(N1) );
  NA3LLX0 U5 ( .A(count[0]), .B(count[1]), .C(count[2]), .Q(n3) );
  INLLX1 U6 ( .A(count[3]), .Q(n2) );
  NO2LLX1 U7 ( .A(n3), .B(n2), .Q(n1) );
  NA2LLX1 U8 ( .A(n1), .B(count[4]), .Q(n7) );
  OA21LLX1 U9 ( .A(n1), .B(count[4]), .C(n7), .Q(N5) );
  AN21LLX1 U10 ( .A(n3), .B(n2), .C(n1), .Q(N4) );
  INLLX1 U11 ( .A(count[1]), .Q(n5) );
  NO2LLX1 U12 ( .A(N1), .B(n5), .Q(n4) );
  OA21LLX1 U13 ( .A(n4), .B(count[2]), .C(n3), .Q(N3) );
  AN21LLX1 U14 ( .A(N1), .B(n5), .C(n4), .Q(N2) );
  EN2LLX2 U15 ( .A(count[5]), .B(n7), .Q(N6) );
  INLLX1 U4 ( .A(rst), .Q(n9) );
endmodule


module Counter_mx_cnt64_1 ( count, clk, rst );
  output [5:0] count;
  input clk, rst;
  wire   N1, N2, N3, N4, N5, N6, n1, n2, n3, n4, n5, n7, n8;

  DFRRQLLX1 \count_reg[5]  ( .D(N6), .C(clk), .RN(n8), .Q(count[5]) );
  DFRRQLLX1 \count_reg[4]  ( .D(N5), .C(clk), .RN(n8), .Q(count[4]) );
  DFRRQLLX1 \count_reg[3]  ( .D(N4), .C(clk), .RN(n8), .Q(count[3]) );
  DFRRQLLX1 \count_reg[2]  ( .D(N3), .C(clk), .RN(n8), .Q(count[2]) );
  DFRRQLLX1 \count_reg[1]  ( .D(N2), .C(clk), .RN(n8), .Q(count[1]) );
  DFRRQLLX1 \count_reg[0]  ( .D(N1), .C(clk), .RN(n8), .Q(count[0]) );
  INLLX1 U3 ( .A(count[0]), .Q(N1) );
  INLLX1 U4 ( .A(rst), .Q(n8) );
  NA3LLX0 U5 ( .A(count[0]), .B(count[1]), .C(count[2]), .Q(n3) );
  INLLX1 U6 ( .A(count[3]), .Q(n2) );
  NO2LLX1 U7 ( .A(n3), .B(n2), .Q(n1) );
  NA2LLX1 U8 ( .A(n1), .B(count[4]), .Q(n7) );
  OA21LLX1 U9 ( .A(n1), .B(count[4]), .C(n7), .Q(N5) );
  AN21LLX1 U10 ( .A(n3), .B(n2), .C(n1), .Q(N4) );
  INLLX1 U11 ( .A(count[1]), .Q(n5) );
  NO2LLX1 U12 ( .A(N1), .B(n5), .Q(n4) );
  OA21LLX1 U13 ( .A(n4), .B(count[2]), .C(n3), .Q(N3) );
  AN21LLX1 U14 ( .A(N1), .B(n5), .C(n4), .Q(N2) );
  EN2LLX2 U15 ( .A(count[5]), .B(n7), .Q(N6) );
endmodule


module dff_async_rst_6 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module Arbiter_st_Mchn_0 ( clk, reset, condition_a, trn_chng_nthng_t_snd );
  input clk, reset, condition_a;
  output trn_chng_nthng_t_snd;
  wire   nxt_st;

  dff_async_rst_6 st0 ( .data(nxt_st), .clk(clk), .reset(reset), .q(
        trn_chng_nthng_t_snd) );
  NO2I1SLLX1 U3 ( .AN(condition_a), .B(trn_chng_nthng_t_snd), .Q(nxt_st) );
endmodule


module Counter_arb_mx_cnt2_0 ( count, clk, rst );
  output [0:0] count;
  input clk, rst;
  wire   N4, n3;
  tri   clk;

  DFRRQLLX1 \count_reg[0]  ( .D(N4), .C(clk), .RN(n3), .Q(count[0]) );
  INLLX1 U4 ( .A(count[0]), .Q(N4) );
  INLLX1 U3 ( .A(rst), .Q(n3) );
endmodule


module dff_async_rst_78 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module tri_buf_248 ( a, b, en );
  input a, en;
  output b;
  wire   N0, n2;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(N0), .Q(b) );
  INLLX1 U2 ( .A(en), .Q(N0) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_249 ( a, b, en );
  input a, en;
  output b;
  wire   N0, n2;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(N0), .Q(b) );
  INLLX1 U2 ( .A(en), .Q(N0) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module ntrfs_cntrl_n_rbtr_32_1_ff_2 ( clk, reset, D_in, bs_grnt, pndng, bs_bsy, 
        trn_chng, rst_w, rst_r, p_s_r, en_w, en_r, push, pop, p_s_w_BAR, IN0
 );
  input [31:24] D_in;
  input clk, reset, pndng, IN0;
  output bs_grnt, rst_w, rst_r, p_s_r, en_w, en_r, push, pop, p_s_w_BAR;
  inout bs_bsy,  trn_chng;
  wire   clk_cntr_w, clk_cntr_r, \cnt_rbtr[0] , bs_grnt_pre, s_cmp,
         trn_chng_nthng_t_snd, trn_chng_pre, bs_rqst, c_a, cond_r, rdi, cond_w,
         bs_bsy_pre, rst_cntr_w, n15, n16, n17, n20, n21, n1, n3, n4, n5, n6,
         n7, n8, n9, n10, n11, n12, n13, n14, n18, n19, n22;
  wire   [5:0] count_w;
  wire   [1:0] s_ds_r;
  wire   [1:0] s_ds_w;
  wire   [5:0] count_r;
  tri   bs_bsy;
  tri   trn_chng;
  assign p_s_r = s_cmp;
  assign p_s_w_BAR = bs_rqst;

  dff_async_rst_78 bs_grnt_dly ( .data(bs_grnt_pre), .clk(clk), .reset(reset), 
        .q(bs_grnt) );
  tri_buf_249 bs_bsy_tri_buf ( .a(bs_bsy_pre), .b(bs_bsy), .en(bs_grnt) );
  Counter_arb_mx_cnt2_0 arb_cntr ( .count(\cnt_rbtr[0] ), .clk(trn_chng), 
        .rst(reset) );
  Arbiter_st_Mchn_0 arb_st_mchn ( .clk(clk), .reset(reset), .condition_a(c_a), 
        .trn_chng_nthng_t_snd(trn_chng_nthng_t_snd) );
  Counter_mx_cnt64_1 counter_w ( .count(count_w), .clk(clk_cntr_w), .rst(
        rst_cntr_w) );
  Counter_mx_cnt64_0 counter_r ( .count(count_r), .clk(clk_cntr_r), .rst(rst_r) );
  tri_buf_248 buf_trn_chng ( .a(trn_chng_pre), .b(trn_chng), .en(bs_grnt) );
  Read_st_Mchn_0 rdstmchn ( .condition_r(cond_r), .rdi(rdi), .reset(reset), 
        .clk(clk), .s_ds_r(s_ds_r), .s_cmp(s_cmp), .rst_r(rst_r), .en_r(en_r), 
        .push(push) );
  Write_st_Mchn_0 wtstmchn ( .clk(clk), .reset(reset), .condition_w(cond_w), 
        .bs_bsy(bs_bsy_pre), .bs_rqst(bs_rqst), .s_ds_w(s_ds_w), .rst_cntr_w(
        rst_cntr_w), .rst_w(rst_w), .en_w(en_w), .pop(pop) );
  DFRQLLX1 bs_grnt_pre_reg ( .D(\cnt_rbtr[0] ), .C(clk), .Q(bs_grnt_pre) );
  AN32LLX0 U23 ( .A(bs_bsy), .B(n16), .C(n20), .D(n15), .E(s_ds_r[1]), .Q(n17)
         );
  NO2I1SLLX1 U28 ( .AN(en_r), .B(n21), .Q(clk_cntr_r) );
  NO2I1SLLX1 U29 ( .AN(en_w), .B(n21), .Q(clk_cntr_w) );
  INLLX2 U27 ( .A(clk), .Q(n21) );
  NO2I1LLX1 U3 ( .AN(count_r[0]), .B(count_r[5]), .Q(n1) );
  AN31LLX1 U5 ( .A(n1), .B(count_r[4]), .C(count_r[3]), .D(IN0), .Q(n8) );
  NO2LLX1 U6 ( .A(D_in[27]), .B(D_in[28]), .Q(n3) );
  AN32LLX0 U7 ( .A(count_r[2]), .B(s_cmp), .C(count_r[1]), .D(n3), .E(IN0), 
        .Q(n7) );
  NO3SLLX1 U8 ( .A(D_in[30]), .B(D_in[31]), .C(D_in[29]), .Q(n5) );
  NO2LLX1 U9 ( .A(D_in[25]), .B(D_in[26]), .Q(n4) );
  AN31LLX1 U10 ( .A(n5), .B(D_in[24]), .C(n4), .D(s_cmp), .Q(n6) );
  NO3SLLX1 U11 ( .A(n8), .B(n7), .C(n6), .Q(n15) );
  INLLX1 U12 ( .A(s_ds_r[0]), .Q(n12) );
  NA4SLLX1 U13 ( .A(D_in[25]), .B(D_in[26]), .C(D_in[27]), .D(D_in[28]), .Q(
        n10) );
  NA4SLLX1 U14 ( .A(D_in[30]), .B(D_in[31]), .C(D_in[29]), .D(D_in[24]), .Q(n9) );
  NO22SLLX1 U15 ( .A(n10), .B(n9), .C(n15), .Q(n11) );
  ON32LLX0 U16 ( .A(n12), .B(s_ds_r[1]), .C(n11), .D(s_ds_r[0]), .E(n17), .Q(
        cond_r) );
  INLLX1 U17 ( .A(bs_grnt), .Q(n20) );
  NA2LLX1 U18 ( .A(s_ds_w[1]), .B(pndng), .Q(n22) );
  NO4I2LLX1 U19 ( .AN(s_ds_w[0]), .BN(count_w[5]), .C(count_w[4]), .D(
        count_w[1]), .Q(n18) );
  NO3SLLX1 U20 ( .A(count_w[2]), .B(count_w[0]), .C(count_w[3]), .Q(n14) );
  NO2LLX1 U21 ( .A(s_ds_w[0]), .B(n20), .Q(n13) );
  AN22LLX0 U22 ( .A(n18), .B(n14), .C(rdi), .D(n13), .Q(n19) );
  ON22LLX0 U24 ( .A(n22), .B(s_ds_w[0]), .C(s_ds_w[1]), .D(n19), .Q(cond_w) );
  OR2SLLX1 U25 ( .A(rst_w), .B(trn_chng_nthng_t_snd), .Q(trn_chng_pre) );
  NO2LLX1 U26 ( .A(bs_rqst), .B(n20), .Q(c_a) );
  INLLX1 U30 ( .A(s_ds_r[1]), .Q(n16) );
endmodule


module dff_async_rst_46 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_47 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_48 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_49 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_50 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_51 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_52 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_53 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_54 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_55 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_56 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_57 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_58 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_59 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_60 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_61 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_62 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_63 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_64 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_65 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_66 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_67 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_68 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_69 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_70 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_71 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_72 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_73 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_74 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_75 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_76 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_77 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module tri_buf_62 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_63 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_31 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_63 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_62 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_64 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_65 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_32 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_65 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_64 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_66 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_67 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_33 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_67 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_66 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_68 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_69 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_34 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_69 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_68 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_70 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_71 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_35 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_71 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_70 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_72 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_73 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_36 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_73 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_72 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_74 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_75 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_37 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_75 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_74 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_76 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_77 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_38 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_77 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_76 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_78 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_79 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_39 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_79 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_78 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_80 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_81 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_40 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_81 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_80 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_82 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_83 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_41 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_83 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_82 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_84 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_85 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_42 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_85 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_84 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_86 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_87 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_43 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_87 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_86 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_88 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_89 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_44 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_89 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_88 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_90 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_91 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_45 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_91 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_90 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_92 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_93 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_46 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_93 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_92 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_94 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_95 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_47 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_95 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_94 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_96 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_97 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_48 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_97 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_96 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_98 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_99 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_49 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_99 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_98 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_100 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_101 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_50 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_101 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_100 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_102 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_103 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_51 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_103 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_102 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_104 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_105 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_52 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_105 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_104 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_106 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_107 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_53 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_107 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_106 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_108 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_109 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_54 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_109 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_108 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_110 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_111 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_55 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_111 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_110 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_112 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_113 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_56 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_113 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_112 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_114 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_115 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_57 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_115 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_114 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_116 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_117 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_58 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_117 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_116 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_118 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_119 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_59 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_119 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_118 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_120 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_121 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_60 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_121 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_120 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module tri_buf_122 ( a, b, en_BAR );
  input a, en_BAR;
  output b;
  wire   en, n2;
  tri   b;
  assign en = en_BAR;

  ITLLLX1 b_tri ( .A(n2), .EN(en), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
endmodule


module tri_buf_123 ( a, b, en );
  input a, en;
  output b;
  wire   n3, n4;
  tri   b;

  ITLLLX1 b_tri ( .A(n3), .EN(n4), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n3) );
  INLLX1 U2 ( .A(en), .Q(n4) );
endmodule


module parallel_serial_61 ( S_in, P_in, S_out, P_out, sel_P_S_BAR );
  input S_in, P_in, sel_P_S_BAR;
  output S_out, P_out;
  wire   sel_P_S;
  tri   S_out;
  assign sel_P_S = sel_P_S_BAR;

  tri_buf_123 serial ( .a(S_in), .b(S_out), .en(sel_P_S) );
  tri_buf_122 parallel_in ( .a(P_in), .b(S_out), .en_BAR(sel_P_S) );
endmodule


module serializer_pckg_sz32_1 ( s_in, rst, clk, P_in, s_out, P_out, 
        sel_p_s_BAR );
  input [31:0] P_in;
  output [31:0] P_out;
  input s_in, rst, clk, sel_p_s_BAR;
  output s_out;
  wire   sel_p_s, n2, n1, n9, n10, n11, n12, n13;
  wire   [31:0] d;
  wire   [30:0] q;
  tri   s_out;
  assign sel_p_s = sel_p_s_BAR;

  dff_async_rst_77 \_bit[0].dff  ( .data(d[0]), .clk(clk), .reset(rst), .q(
        q[0]) );
  dff_async_rst_76 \_bit[1].dff  ( .data(d[1]), .clk(clk), .reset(rst), .q(
        q[1]) );
  dff_async_rst_75 \_bit[2].dff  ( .data(d[2]), .clk(clk), .reset(rst), .q(
        q[2]) );
  dff_async_rst_74 \_bit[3].dff  ( .data(d[3]), .clk(clk), .reset(rst), .q(
        q[3]) );
  dff_async_rst_73 \_bit[4].dff  ( .data(d[4]), .clk(clk), .reset(rst), .q(
        q[4]) );
  dff_async_rst_72 \_bit[5].dff  ( .data(d[5]), .clk(clk), .reset(rst), .q(
        q[5]) );
  dff_async_rst_71 \_bit[6].dff  ( .data(d[6]), .clk(clk), .reset(rst), .q(
        q[6]) );
  dff_async_rst_70 \_bit[7].dff  ( .data(d[7]), .clk(clk), .reset(rst), .q(
        q[7]) );
  dff_async_rst_69 \_bit[8].dff  ( .data(d[8]), .clk(clk), .reset(rst), .q(
        q[8]) );
  dff_async_rst_68 \_bit[9].dff  ( .data(d[9]), .clk(clk), .reset(rst), .q(
        q[9]) );
  dff_async_rst_67 \_bit[10].dff  ( .data(d[10]), .clk(clk), .reset(rst), .q(
        q[10]) );
  dff_async_rst_66 \_bit[11].dff  ( .data(d[11]), .clk(clk), .reset(rst), .q(
        q[11]) );
  dff_async_rst_65 \_bit[12].dff  ( .data(d[12]), .clk(clk), .reset(rst), .q(
        q[12]) );
  dff_async_rst_64 \_bit[13].dff  ( .data(d[13]), .clk(clk), .reset(rst), .q(
        q[13]) );
  dff_async_rst_63 \_bit[14].dff  ( .data(d[14]), .clk(clk), .reset(rst), .q(
        q[14]) );
  dff_async_rst_62 \_bit[15].dff  ( .data(d[15]), .clk(clk), .reset(rst), .q(
        q[15]) );
  dff_async_rst_61 \_bit[16].dff  ( .data(d[16]), .clk(clk), .reset(rst), .q(
        q[16]) );
  dff_async_rst_60 \_bit[17].dff  ( .data(d[17]), .clk(clk), .reset(rst), .q(
        q[17]) );
  dff_async_rst_59 \_bit[18].dff  ( .data(d[18]), .clk(clk), .reset(rst), .q(
        q[18]) );
  dff_async_rst_58 \_bit[19].dff  ( .data(d[19]), .clk(clk), .reset(rst), .q(
        q[19]) );
  dff_async_rst_57 \_bit[20].dff  ( .data(d[20]), .clk(clk), .reset(rst), .q(
        q[20]) );
  dff_async_rst_56 \_bit[21].dff  ( .data(d[21]), .clk(clk), .reset(rst), .q(
        q[21]) );
  dff_async_rst_55 \_bit[22].dff  ( .data(d[22]), .clk(clk), .reset(rst), .q(
        q[22]) );
  dff_async_rst_54 \_bit[23].dff  ( .data(d[23]), .clk(clk), .reset(rst), .q(
        q[23]) );
  dff_async_rst_53 \_bit[24].dff  ( .data(d[24]), .clk(clk), .reset(rst), .q(
        q[24]) );
  dff_async_rst_52 \_bit[25].dff  ( .data(d[25]), .clk(clk), .reset(rst), .q(
        q[25]) );
  dff_async_rst_51 \_bit[26].dff  ( .data(d[26]), .clk(clk), .reset(rst), .q(
        q[26]) );
  dff_async_rst_50 \_bit[27].dff  ( .data(d[27]), .clk(clk), .reset(rst), .q(
        q[27]) );
  dff_async_rst_49 \_bit[28].dff  ( .data(d[28]), .clk(clk), .reset(rst), .q(
        q[28]) );
  dff_async_rst_48 \_bit[29].dff  ( .data(d[29]), .clk(clk), .reset(rst), .q(
        q[29]) );
  dff_async_rst_47 \_bit[30].dff  ( .data(d[30]), .clk(clk), .reset(rst), .q(
        q[30]) );
  dff_async_rst_46 \_bit[31].dff  ( .data(d[31]), .clk(clk), .reset(rst), .q(
        n2) );
  parallel_serial_61 \bt[0].pts  ( .S_in(q[0]), .P_in(P_in[1]), .S_out(d[1]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_60 \bt[1].pts  ( .S_in(q[1]), .P_in(P_in[2]), .S_out(d[2]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_59 \bt[2].pts  ( .S_in(q[2]), .P_in(P_in[3]), .S_out(d[3]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_58 \bt[3].pts  ( .S_in(q[3]), .P_in(P_in[4]), .S_out(d[4]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_57 \bt[4].pts  ( .S_in(q[4]), .P_in(P_in[5]), .S_out(d[5]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_56 \bt[5].pts  ( .S_in(q[5]), .P_in(P_in[6]), .S_out(d[6]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_55 \bt[6].pts  ( .S_in(q[6]), .P_in(P_in[7]), .S_out(d[7]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_54 \bt[7].pts  ( .S_in(q[7]), .P_in(P_in[8]), .S_out(d[8]), 
        .sel_P_S_BAR(n12) );
  parallel_serial_53 \bt[8].pts  ( .S_in(q[8]), .P_in(P_in[9]), .S_out(d[9]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_52 \bt[9].pts  ( .S_in(q[9]), .P_in(P_in[10]), .S_out(d[10]), 
        .sel_P_S_BAR(n9) );
  parallel_serial_51 \bt[10].pts  ( .S_in(q[10]), .P_in(P_in[11]), .S_out(
        d[11]), .sel_P_S_BAR(n9) );
  parallel_serial_50 \bt[11].pts  ( .S_in(q[11]), .P_in(P_in[12]), .S_out(
        d[12]), .sel_P_S_BAR(n9) );
  parallel_serial_49 \bt[12].pts  ( .S_in(q[12]), .P_in(P_in[13]), .S_out(
        d[13]), .sel_P_S_BAR(n12) );
  parallel_serial_48 \bt[13].pts  ( .S_in(q[13]), .P_in(P_in[14]), .S_out(
        d[14]), .sel_P_S_BAR(n10) );
  parallel_serial_47 \bt[14].pts  ( .S_in(q[14]), .P_in(P_in[15]), .S_out(
        d[15]), .sel_P_S_BAR(n10) );
  parallel_serial_46 \bt[15].pts  ( .S_in(q[15]), .P_in(P_in[16]), .S_out(
        d[16]), .sel_P_S_BAR(n10) );
  parallel_serial_45 \bt[16].pts  ( .S_in(q[16]), .P_in(P_in[17]), .S_out(
        d[17]), .sel_P_S_BAR(n10) );
  parallel_serial_44 \bt[17].pts  ( .S_in(q[17]), .P_in(P_in[18]), .S_out(
        d[18]), .sel_P_S_BAR(n10) );
  parallel_serial_43 \bt[18].pts  ( .S_in(q[18]), .P_in(P_in[19]), .S_out(
        d[19]), .sel_P_S_BAR(n10) );
  parallel_serial_42 \bt[19].pts  ( .S_in(q[19]), .P_in(P_in[20]), .S_out(
        d[20]), .sel_P_S_BAR(n10) );
  parallel_serial_41 \bt[20].pts  ( .S_in(q[20]), .P_in(P_in[21]), .S_out(
        d[21]), .sel_P_S_BAR(n10) );
  parallel_serial_40 \bt[21].pts  ( .S_in(q[21]), .P_in(P_in[22]), .S_out(
        d[22]), .sel_P_S_BAR(n13) );
  parallel_serial_39 \bt[22].pts  ( .S_in(q[22]), .P_in(P_in[23]), .S_out(
        d[23]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_38 \bt[23].pts  ( .S_in(q[23]), .P_in(P_in[24]), .S_out(
        d[24]), .sel_P_S_BAR(sel_p_s) );
  parallel_serial_37 \bt[24].pts  ( .S_in(q[24]), .P_in(P_in[25]), .S_out(
        d[25]), .sel_P_S_BAR(n9) );
  parallel_serial_36 \bt[25].pts  ( .S_in(q[25]), .P_in(P_in[26]), .S_out(
        d[26]), .sel_P_S_BAR(n9) );
  parallel_serial_35 \bt[26].pts  ( .S_in(q[26]), .P_in(P_in[27]), .S_out(
        d[27]), .sel_P_S_BAR(n13) );
  parallel_serial_34 \bt[27].pts  ( .S_in(q[27]), .P_in(P_in[28]), .S_out(
        d[28]), .sel_P_S_BAR(n10) );
  parallel_serial_33 \bt[28].pts  ( .S_in(q[28]), .P_in(P_in[29]), .S_out(
        d[29]), .sel_P_S_BAR(n10) );
  parallel_serial_32 \bt[29].pts  ( .S_in(q[29]), .P_in(P_in[30]), .S_out(
        d[30]), .sel_P_S_BAR(n10) );
  parallel_serial_31 \bt[30].pts  ( .S_in(q[30]), .P_in(P_in[31]), .S_out(
        d[31]), .sel_P_S_BAR(n10) );
  ITLLLX1 s_out_tri ( .A(n1), .EN(n11), .Q(s_out) );
  NO2I1SLLX1 U7 ( .AN(P_in[0]), .B(n12), .Q(d[0]) );
  INLLX1 U8 ( .A(n2), .Q(n1) );
  BULLX1 U1 ( .A(sel_p_s), .Q(n9) );
  BULLX1 U2 ( .A(sel_p_s), .Q(n10) );
  INLLX1 U3 ( .A(n10), .Q(n11) );
  BULLX1 U4 ( .A(sel_p_s), .Q(n12) );
  BULLX1 U5 ( .A(sel_p_s), .Q(n13) );
endmodule


module dff_async_rst_14 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_15 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_16 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_17 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_18 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_19 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_20 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_21 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_22 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_23 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_24 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_25 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_26 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_27 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_28 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_29 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_30 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_31 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_32 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_33 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_34 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_35 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_36 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_37 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_38 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_39 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_40 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_41 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_42 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_43 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_44 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;
  tri   data;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module dff_async_rst_45 ( data, clk, reset, q );
  input data, clk, reset;
  output q;
  wire   n3;

  DFRRQLLX1 q_reg ( .D(data), .C(clk), .RN(n3), .Q(q) );
  INLLX1 U3 ( .A(reset), .Q(n3) );
endmodule


module tri_buf_0 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_1 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_0 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_1 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_0 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_2 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_3 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_1 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_3 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_2 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_4 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_5 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_2 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_5 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_4 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_6 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_7 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_3 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_7 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_6 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_8 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_9 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_4 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_9 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_8 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_10 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_11 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_5 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_11 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_10 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_12 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_13 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_6 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_13 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_12 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_14 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_15 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_7 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_15 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_14 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_16 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_17 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_8 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_17 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_16 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_18 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_19 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_9 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_19 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_18 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_20 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_21 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_10 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_21 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_20 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_22 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_23 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_11 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_23 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_22 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_24 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_25 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_12 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_25 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_24 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_26 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_27 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_13 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_27 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_26 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_28 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_29 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_14 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_29 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_28 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_30 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_31 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_15 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_31 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_30 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_32 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_33 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_16 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_33 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_32 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_34 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_35 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_17 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_35 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_34 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_36 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_37 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_18 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_37 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_36 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_38 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_39 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_19 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_39 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_38 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_40 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_41 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_20 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_41 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_40 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_42 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_43 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_21 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_43 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_42 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_44 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_45 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_22 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_45 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_44 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_46 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_47 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_23 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_47 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_46 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_48 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_49 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_24 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_49 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_48 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_50 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_51 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_25 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_51 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_50 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_52 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_53 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_26 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_53 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_52 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_54 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_55 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_27 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_55 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_54 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_56 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_57 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_28 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_57 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_56 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_58 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_59 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_29 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_59 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_58 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module tri_buf_60 ( a, b, en );
  input a, en;
  output b;
  wire   n5;
  tri   b;

  ITLLLX1 b_tri ( .A(1'b1), .EN(n5), .Q(b) );
  INLLX1 U1 ( .A(en), .Q(n5) );
endmodule


module tri_buf_61 ( a, b, en );
  input a, en;
  output b;
  wire   n2, n3;
  tri   b;

  ITLLLX1 b_tri ( .A(n2), .EN(n3), .Q(b) );
  INLLX1 U1 ( .A(a), .Q(n2) );
  INLLX1 U2 ( .A(en), .Q(n3) );
endmodule


module parallel_serial_30 ( S_in, P_in, sel_P_S, S_out, P_out );
  input S_in, P_in, sel_P_S;
  output S_out, P_out;
  wire   S_in, n4;
  tri   S_out;
  assign P_out = S_in;

  tri_buf_61 serial ( .a(S_in), .b(S_out), .en(n4) );
  tri_buf_60 parallel_in ( .a(1'b0), .b(S_out), .en(sel_P_S) );
  INLLX1 U1 ( .A(sel_P_S), .Q(n4) );
endmodule


module serializer_pckg_sz32_0 ( sel_p_s, s_in, rst, clk, P_in, s_out, P_out );
  input [31:0] P_in;
  output [31:0] P_out;
  input sel_p_s, s_in, rst, clk;
  output s_out;
  wire   n37;
  wire   [31:0] d;
  wire   [30:0] q;
  tri   s_in;

  dff_async_rst_45 \_bit[0].dff  ( .data(d[0]), .clk(clk), .reset(rst), .q(
        q[0]) );
  dff_async_rst_44 \_bit[1].dff  ( .data(d[1]), .clk(clk), .reset(rst), .q(
        q[1]) );
  dff_async_rst_43 \_bit[2].dff  ( .data(d[2]), .clk(clk), .reset(rst), .q(
        q[2]) );
  dff_async_rst_42 \_bit[3].dff  ( .data(d[3]), .clk(clk), .reset(rst), .q(
        q[3]) );
  dff_async_rst_41 \_bit[4].dff  ( .data(d[4]), .clk(clk), .reset(rst), .q(
        q[4]) );
  dff_async_rst_40 \_bit[5].dff  ( .data(d[5]), .clk(clk), .reset(rst), .q(
        q[5]) );
  dff_async_rst_39 \_bit[6].dff  ( .data(d[6]), .clk(clk), .reset(rst), .q(
        q[6]) );
  dff_async_rst_38 \_bit[7].dff  ( .data(d[7]), .clk(clk), .reset(rst), .q(
        q[7]) );
  dff_async_rst_37 \_bit[8].dff  ( .data(d[8]), .clk(clk), .reset(rst), .q(
        q[8]) );
  dff_async_rst_36 \_bit[9].dff  ( .data(d[9]), .clk(clk), .reset(rst), .q(
        q[9]) );
  dff_async_rst_35 \_bit[10].dff  ( .data(d[10]), .clk(clk), .reset(rst), .q(
        q[10]) );
  dff_async_rst_34 \_bit[11].dff  ( .data(d[11]), .clk(clk), .reset(rst), .q(
        q[11]) );
  dff_async_rst_33 \_bit[12].dff  ( .data(d[12]), .clk(clk), .reset(rst), .q(
        q[12]) );
  dff_async_rst_32 \_bit[13].dff  ( .data(d[13]), .clk(clk), .reset(rst), .q(
        q[13]) );
  dff_async_rst_31 \_bit[14].dff  ( .data(d[14]), .clk(clk), .reset(rst), .q(
        q[14]) );
  dff_async_rst_30 \_bit[15].dff  ( .data(d[15]), .clk(clk), .reset(rst), .q(
        q[15]) );
  dff_async_rst_29 \_bit[16].dff  ( .data(d[16]), .clk(clk), .reset(rst), .q(
        q[16]) );
  dff_async_rst_28 \_bit[17].dff  ( .data(d[17]), .clk(clk), .reset(rst), .q(
        q[17]) );
  dff_async_rst_27 \_bit[18].dff  ( .data(d[18]), .clk(clk), .reset(rst), .q(
        q[18]) );
  dff_async_rst_26 \_bit[19].dff  ( .data(d[19]), .clk(clk), .reset(rst), .q(
        q[19]) );
  dff_async_rst_25 \_bit[20].dff  ( .data(d[20]), .clk(clk), .reset(rst), .q(
        q[20]) );
  dff_async_rst_24 \_bit[21].dff  ( .data(d[21]), .clk(clk), .reset(rst), .q(
        q[21]) );
  dff_async_rst_23 \_bit[22].dff  ( .data(d[22]), .clk(clk), .reset(rst), .q(
        q[22]) );
  dff_async_rst_22 \_bit[23].dff  ( .data(d[23]), .clk(clk), .reset(rst), .q(
        q[23]) );
  dff_async_rst_21 \_bit[24].dff  ( .data(d[24]), .clk(clk), .reset(rst), .q(
        q[24]) );
  dff_async_rst_20 \_bit[25].dff  ( .data(d[25]), .clk(clk), .reset(rst), .q(
        q[25]) );
  dff_async_rst_19 \_bit[26].dff  ( .data(d[26]), .clk(clk), .reset(rst), .q(
        q[26]) );
  dff_async_rst_18 \_bit[27].dff  ( .data(d[27]), .clk(clk), .reset(rst), .q(
        q[27]) );
  dff_async_rst_17 \_bit[28].dff  ( .data(d[28]), .clk(clk), .reset(rst), .q(
        q[28]) );
  dff_async_rst_16 \_bit[29].dff  ( .data(d[29]), .clk(clk), .reset(rst), .q(
        q[29]) );
  dff_async_rst_15 \_bit[30].dff  ( .data(d[30]), .clk(clk), .reset(rst), .q(
        q[30]) );
  dff_async_rst_14 \_bit[31].dff  ( .data(d[31]), .clk(clk), .reset(rst), .q(
        P_out[31]) );
  parallel_serial_30 \bt[0].pts  ( .S_in(q[0]), .P_in(1'b0), .sel_P_S(sel_p_s), 
        .S_out(d[1]), .P_out(P_out[0]) );
  parallel_serial_29 \bt[1].pts  ( .S_in(q[1]), .P_in(1'b0), .sel_P_S(sel_p_s), 
        .S_out(d[2]), .P_out(P_out[1]) );
  parallel_serial_28 \bt[2].pts  ( .S_in(q[2]), .P_in(1'b0), .sel_P_S(sel_p_s), 
        .S_out(d[3]), .P_out(P_out[2]) );
  parallel_serial_27 \bt[3].pts  ( .S_in(q[3]), .P_in(1'b0), .sel_P_S(sel_p_s), 
        .S_out(d[4]), .P_out(P_out[3]) );
  parallel_serial_26 \bt[4].pts  ( .S_in(q[4]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[5]), .P_out(P_out[4]) );
  parallel_serial_25 \bt[5].pts  ( .S_in(q[5]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[6]), .P_out(P_out[5]) );
  parallel_serial_24 \bt[6].pts  ( .S_in(q[6]), .P_in(1'b0), .sel_P_S(sel_p_s), 
        .S_out(d[7]), .P_out(P_out[6]) );
  parallel_serial_23 \bt[7].pts  ( .S_in(q[7]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[8]), .P_out(P_out[7]) );
  parallel_serial_22 \bt[8].pts  ( .S_in(q[8]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[9]), .P_out(P_out[8]) );
  parallel_serial_21 \bt[9].pts  ( .S_in(q[9]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[10]), .P_out(P_out[9]) );
  parallel_serial_20 \bt[10].pts  ( .S_in(q[10]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[11]), .P_out(P_out[10]) );
  parallel_serial_19 \bt[11].pts  ( .S_in(q[11]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[12]), .P_out(P_out[11]) );
  parallel_serial_18 \bt[12].pts  ( .S_in(q[12]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[13]), .P_out(P_out[12]) );
  parallel_serial_17 \bt[13].pts  ( .S_in(q[13]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[14]), .P_out(P_out[13]) );
  parallel_serial_16 \bt[14].pts  ( .S_in(q[14]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[15]), .P_out(P_out[14]) );
  parallel_serial_15 \bt[15].pts  ( .S_in(q[15]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[16]), .P_out(P_out[15]) );
  parallel_serial_14 \bt[16].pts  ( .S_in(q[16]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[17]), .P_out(P_out[16]) );
  parallel_serial_13 \bt[17].pts  ( .S_in(q[17]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[18]), .P_out(P_out[17]) );
  parallel_serial_12 \bt[18].pts  ( .S_in(q[18]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[19]), .P_out(P_out[18]) );
  parallel_serial_11 \bt[19].pts  ( .S_in(q[19]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[20]), .P_out(P_out[19]) );
  parallel_serial_10 \bt[20].pts  ( .S_in(q[20]), .P_in(1'b0), .sel_P_S(
        sel_p_s), .S_out(d[21]), .P_out(P_out[20]) );
  parallel_serial_9 \bt[21].pts  ( .S_in(q[21]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[22]), .P_out(P_out[21]) );
  parallel_serial_8 \bt[22].pts  ( .S_in(q[22]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[23]), .P_out(P_out[22]) );
  parallel_serial_7 \bt[23].pts  ( .S_in(q[23]), .P_in(1'b0), .sel_P_S(n37), 
        .S_out(d[24]), .P_out(P_out[23]) );
  parallel_serial_6 \bt[24].pts  ( .S_in(q[24]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[25]), .P_out(P_out[24]) );
  parallel_serial_5 \bt[25].pts  ( .S_in(q[25]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[26]), .P_out(P_out[25]) );
  parallel_serial_4 \bt[26].pts  ( .S_in(q[26]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[27]), .P_out(P_out[26]) );
  parallel_serial_3 \bt[27].pts  ( .S_in(q[27]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[28]), .P_out(P_out[27]) );
  parallel_serial_2 \bt[28].pts  ( .S_in(q[28]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[29]), .P_out(P_out[28]) );
  parallel_serial_1 \bt[29].pts  ( .S_in(q[29]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[30]), .P_out(P_out[29]) );
  parallel_serial_0 \bt[30].pts  ( .S_in(q[30]), .P_in(1'b0), .sel_P_S(sel_p_s), .S_out(d[31]), .P_out(P_out[30]) );
  BULLX1 U1 ( .A(sel_p_s), .Q(n37) );
  NO2I1LLX1 U6 ( .AN(s_in), .B(sel_p_s), .Q(d[0]) );
endmodule


module bs_ntrfs_n_rbtr_32_1_ff_2 ( clk, reset, pndng, D_pop, D_push, push, pop, 
        bus, bs_bsy, trn_chng );
  input [31:0] D_pop;
  output [31:0] D_push;
  input clk, reset, pndng;
  output push, pop;
  inout bus,  bs_bsy,  trn_chng;
  wire   en_r, clk_rd, en_w, clk_wt, bs_grnt, rst_w, rst_r, N0, n1, n2, n3, n5
;
  tri   bus;
  tri   bs_bsy;
  tri   trn_chng;
  tri   bus_pre_wd;

  ntrfs_cntrl_n_rbtr_32_1_ff_2 cntrl ( .clk(clk), .reset(reset), .D_in(
        D_push[31:24]), .bs_grnt(bs_grnt), .pndng(pndng), .bs_bsy(bs_bsy), 
        .trn_chng(trn_chng), .rst_w(rst_w), .rst_r(rst_r), .p_s_r(n2), .en_w(
        en_w), .en_r(en_r), .push(push), .pop(pop), .p_s_w_BAR(n5), .IN0(n3)
         );
  serializer_pckg_sz32_1 srlzr_wt ( .s_in(1'b0), .rst(rst_w), .clk(clk_wt), 
        .P_in(D_pop), .s_out(bus_pre_wd), .sel_p_s_BAR(n5) );
  serializer_pckg_sz32_0 srlzr_rd ( .sel_p_s(n3), .s_in(bus), .rst(rst_r), 
        .clk(clk_rd), .P_in({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}), .P_out(D_push) );
  ITLLLX1 bus_tri ( .A(n1), .EN(N0), .Q(bus) );
  AND2LLX1 U4 ( .A(clk), .B(en_w), .Q(clk_wt) );
  AND2LLX1 U5 ( .A(clk), .B(en_r), .Q(clk_rd) );
  INLLX1 U3 ( .A(bs_grnt), .Q(N0) );
  INLLX1 U6 ( .A(bus_pre_wd), .Q(n1) );
  INLLX1 U7 ( .A(n2), .Q(n3) );
endmodule


module bs_gnrtr_n_rbtr_1_2_32_ff ( clk, reset, .pndng({\pndng[0][1] , 
        \pndng[0][0] }), .push({\push[0][1] , \push[0][0] }), .pop({
        \pop[0][1] , \pop[0][0] }), .D_pop({\D_pop[0][1][31] , 
        \D_pop[0][1][30] , \D_pop[0][1][29] , \D_pop[0][1][28] , 
        \D_pop[0][1][27] , \D_pop[0][1][26] , \D_pop[0][1][25] , 
        \D_pop[0][1][24] , \D_pop[0][1][23] , \D_pop[0][1][22] , 
        \D_pop[0][1][21] , \D_pop[0][1][20] , \D_pop[0][1][19] , 
        \D_pop[0][1][18] , \D_pop[0][1][17] , \D_pop[0][1][16] , 
        \D_pop[0][1][15] , \D_pop[0][1][14] , \D_pop[0][1][13] , 
        \D_pop[0][1][12] , \D_pop[0][1][11] , \D_pop[0][1][10] , 
        \D_pop[0][1][9] , \D_pop[0][1][8] , \D_pop[0][1][7] , \D_pop[0][1][6] , 
        \D_pop[0][1][5] , \D_pop[0][1][4] , \D_pop[0][1][3] , \D_pop[0][1][2] , 
        \D_pop[0][1][1] , \D_pop[0][1][0] , \D_pop[0][0][31] , 
        \D_pop[0][0][30] , \D_pop[0][0][29] , \D_pop[0][0][28] , 
        \D_pop[0][0][27] , \D_pop[0][0][26] , \D_pop[0][0][25] , 
        \D_pop[0][0][24] , \D_pop[0][0][23] , \D_pop[0][0][22] , 
        \D_pop[0][0][21] , \D_pop[0][0][20] , \D_pop[0][0][19] , 
        \D_pop[0][0][18] , \D_pop[0][0][17] , \D_pop[0][0][16] , 
        \D_pop[0][0][15] , \D_pop[0][0][14] , \D_pop[0][0][13] , 
        \D_pop[0][0][12] , \D_pop[0][0][11] , \D_pop[0][0][10] , 
        \D_pop[0][0][9] , \D_pop[0][0][8] , \D_pop[0][0][7] , \D_pop[0][0][6] , 
        \D_pop[0][0][5] , \D_pop[0][0][4] , \D_pop[0][0][3] , \D_pop[0][0][2] , 
        \D_pop[0][0][1] , \D_pop[0][0][0] }), .D_push({\D_push[0][1][31] , 
        \D_push[0][1][30] , \D_push[0][1][29] , \D_push[0][1][28] , 
        \D_push[0][1][27] , \D_push[0][1][26] , \D_push[0][1][25] , 
        \D_push[0][1][24] , \D_push[0][1][23] , \D_push[0][1][22] , 
        \D_push[0][1][21] , \D_push[0][1][20] , \D_push[0][1][19] , 
        \D_push[0][1][18] , \D_push[0][1][17] , \D_push[0][1][16] , 
        \D_push[0][1][15] , \D_push[0][1][14] , \D_push[0][1][13] , 
        \D_push[0][1][12] , \D_push[0][1][11] , \D_push[0][1][10] , 
        \D_push[0][1][9] , \D_push[0][1][8] , \D_push[0][1][7] , 
        \D_push[0][1][6] , \D_push[0][1][5] , \D_push[0][1][4] , 
        \D_push[0][1][3] , \D_push[0][1][2] , \D_push[0][1][1] , 
        \D_push[0][1][0] , \D_push[0][0][31] , \D_push[0][0][30] , 
        \D_push[0][0][29] , \D_push[0][0][28] , \D_push[0][0][27] , 
        \D_push[0][0][26] , \D_push[0][0][25] , \D_push[0][0][24] , 
        \D_push[0][0][23] , \D_push[0][0][22] , \D_push[0][0][21] , 
        \D_push[0][0][20] , \D_push[0][0][19] , \D_push[0][0][18] , 
        \D_push[0][0][17] , \D_push[0][0][16] , \D_push[0][0][15] , 
        \D_push[0][0][14] , \D_push[0][0][13] , \D_push[0][0][12] , 
        \D_push[0][0][11] , \D_push[0][0][10] , \D_push[0][0][9] , 
        \D_push[0][0][8] , \D_push[0][0][7] , \D_push[0][0][6] , 
        \D_push[0][0][5] , \D_push[0][0][4] , \D_push[0][0][3] , 
        \D_push[0][0][2] , \D_push[0][0][1] , \D_push[0][0][0] }) );
  input clk, reset, \pndng[0][1] , \pndng[0][0] , \D_pop[0][1][31] ,
         \D_pop[0][1][30] , \D_pop[0][1][29] , \D_pop[0][1][28] ,
         \D_pop[0][1][27] , \D_pop[0][1][26] , \D_pop[0][1][25] ,
         \D_pop[0][1][24] , \D_pop[0][1][23] , \D_pop[0][1][22] ,
         \D_pop[0][1][21] , \D_pop[0][1][20] , \D_pop[0][1][19] ,
         \D_pop[0][1][18] , \D_pop[0][1][17] , \D_pop[0][1][16] ,
         \D_pop[0][1][15] , \D_pop[0][1][14] , \D_pop[0][1][13] ,
         \D_pop[0][1][12] , \D_pop[0][1][11] , \D_pop[0][1][10] ,
         \D_pop[0][1][9] , \D_pop[0][1][8] , \D_pop[0][1][7] ,
         \D_pop[0][1][6] , \D_pop[0][1][5] , \D_pop[0][1][4] ,
         \D_pop[0][1][3] , \D_pop[0][1][2] , \D_pop[0][1][1] ,
         \D_pop[0][1][0] , \D_pop[0][0][31] , \D_pop[0][0][30] ,
         \D_pop[0][0][29] , \D_pop[0][0][28] , \D_pop[0][0][27] ,
         \D_pop[0][0][26] , \D_pop[0][0][25] , \D_pop[0][0][24] ,
         \D_pop[0][0][23] , \D_pop[0][0][22] , \D_pop[0][0][21] ,
         \D_pop[0][0][20] , \D_pop[0][0][19] , \D_pop[0][0][18] ,
         \D_pop[0][0][17] , \D_pop[0][0][16] , \D_pop[0][0][15] ,
         \D_pop[0][0][14] , \D_pop[0][0][13] , \D_pop[0][0][12] ,
         \D_pop[0][0][11] , \D_pop[0][0][10] , \D_pop[0][0][9] ,
         \D_pop[0][0][8] , \D_pop[0][0][7] , \D_pop[0][0][6] ,
         \D_pop[0][0][5] , \D_pop[0][0][4] , \D_pop[0][0][3] ,
         \D_pop[0][0][2] , \D_pop[0][0][1] , \D_pop[0][0][0] ;
  output \push[0][1] , \push[0][0] , \pop[0][1] , \pop[0][0] ,
         \D_push[0][1][31] , \D_push[0][1][30] , \D_push[0][1][29] ,
         \D_push[0][1][28] , \D_push[0][1][27] , \D_push[0][1][26] ,
         \D_push[0][1][25] , \D_push[0][1][24] , \D_push[0][1][23] ,
         \D_push[0][1][22] , \D_push[0][1][21] , \D_push[0][1][20] ,
         \D_push[0][1][19] , \D_push[0][1][18] , \D_push[0][1][17] ,
         \D_push[0][1][16] , \D_push[0][1][15] , \D_push[0][1][14] ,
         \D_push[0][1][13] , \D_push[0][1][12] , \D_push[0][1][11] ,
         \D_push[0][1][10] , \D_push[0][1][9] , \D_push[0][1][8] ,
         \D_push[0][1][7] , \D_push[0][1][6] , \D_push[0][1][5] ,
         \D_push[0][1][4] , \D_push[0][1][3] , \D_push[0][1][2] ,
         \D_push[0][1][1] , \D_push[0][1][0] , \D_push[0][0][31] ,
         \D_push[0][0][30] , \D_push[0][0][29] , \D_push[0][0][28] ,
         \D_push[0][0][27] , \D_push[0][0][26] , \D_push[0][0][25] ,
         \D_push[0][0][24] , \D_push[0][0][23] , \D_push[0][0][22] ,
         \D_push[0][0][21] , \D_push[0][0][20] , \D_push[0][0][19] ,
         \D_push[0][0][18] , \D_push[0][0][17] , \D_push[0][0][16] ,
         \D_push[0][0][15] , \D_push[0][0][14] , \D_push[0][0][13] ,
         \D_push[0][0][12] , \D_push[0][0][11] , \D_push[0][0][10] ,
         \D_push[0][0][9] , \D_push[0][0][8] , \D_push[0][0][7] ,
         \D_push[0][0][6] , \D_push[0][0][5] , \D_push[0][0][4] ,
         \D_push[0][0][3] , \D_push[0][0][2] , \D_push[0][0][1] ,
         \D_push[0][0][0] ;

  tri   \bus[0] ;
  tri   \trn_chng[0] ;
  tri   \bs_bsy[0] ;

  bs_ntrfs_n_rbtr_32_0_ff_2 \BUS[0].ID[0].ntrfs  ( .clk(clk), .reset(reset), 
        .pndng(\pndng[0][0] ), .D_pop({\D_pop[0][0][31] , \D_pop[0][0][30] , 
        \D_pop[0][0][29] , \D_pop[0][0][28] , \D_pop[0][0][27] , 
        \D_pop[0][0][26] , \D_pop[0][0][25] , \D_pop[0][0][24] , 
        \D_pop[0][0][23] , \D_pop[0][0][22] , \D_pop[0][0][21] , 
        \D_pop[0][0][20] , \D_pop[0][0][19] , \D_pop[0][0][18] , 
        \D_pop[0][0][17] , \D_pop[0][0][16] , \D_pop[0][0][15] , 
        \D_pop[0][0][14] , \D_pop[0][0][13] , \D_pop[0][0][12] , 
        \D_pop[0][0][11] , \D_pop[0][0][10] , \D_pop[0][0][9] , 
        \D_pop[0][0][8] , \D_pop[0][0][7] , \D_pop[0][0][6] , \D_pop[0][0][5] , 
        \D_pop[0][0][4] , \D_pop[0][0][3] , \D_pop[0][0][2] , \D_pop[0][0][1] , 
        \D_pop[0][0][0] }), .D_push({\D_push[0][0][31] , \D_push[0][0][30] , 
        \D_push[0][0][29] , \D_push[0][0][28] , \D_push[0][0][27] , 
        \D_push[0][0][26] , \D_push[0][0][25] , \D_push[0][0][24] , 
        \D_push[0][0][23] , \D_push[0][0][22] , \D_push[0][0][21] , 
        \D_push[0][0][20] , \D_push[0][0][19] , \D_push[0][0][18] , 
        \D_push[0][0][17] , \D_push[0][0][16] , \D_push[0][0][15] , 
        \D_push[0][0][14] , \D_push[0][0][13] , \D_push[0][0][12] , 
        \D_push[0][0][11] , \D_push[0][0][10] , \D_push[0][0][9] , 
        \D_push[0][0][8] , \D_push[0][0][7] , \D_push[0][0][6] , 
        \D_push[0][0][5] , \D_push[0][0][4] , \D_push[0][0][3] , 
        \D_push[0][0][2] , \D_push[0][0][1] , \D_push[0][0][0] }), .push(
        \push[0][0] ), .pop(\pop[0][0] ), .bus(\bus[0] ), .bs_bsy(\bs_bsy[0] ), 
        .trn_chng(\trn_chng[0] ) );
  bs_ntrfs_n_rbtr_32_1_ff_2 \BUS[0].ID[1].ntrfs  ( .clk(clk), .reset(reset), 
        .pndng(\pndng[0][1] ), .D_pop({\D_pop[0][1][31] , \D_pop[0][1][30] , 
        \D_pop[0][1][29] , \D_pop[0][1][28] , \D_pop[0][1][27] , 
        \D_pop[0][1][26] , \D_pop[0][1][25] , \D_pop[0][1][24] , 
        \D_pop[0][1][23] , \D_pop[0][1][22] , \D_pop[0][1][21] , 
        \D_pop[0][1][20] , \D_pop[0][1][19] , \D_pop[0][1][18] , 
        \D_pop[0][1][17] , \D_pop[0][1][16] , \D_pop[0][1][15] , 
        \D_pop[0][1][14] , \D_pop[0][1][13] , \D_pop[0][1][12] , 
        \D_pop[0][1][11] , \D_pop[0][1][10] , \D_pop[0][1][9] , 
        \D_pop[0][1][8] , \D_pop[0][1][7] , \D_pop[0][1][6] , \D_pop[0][1][5] , 
        \D_pop[0][1][4] , \D_pop[0][1][3] , \D_pop[0][1][2] , \D_pop[0][1][1] , 
        \D_pop[0][1][0] }), .D_push({\D_push[0][1][31] , \D_push[0][1][30] , 
        \D_push[0][1][29] , \D_push[0][1][28] , \D_push[0][1][27] , 
        \D_push[0][1][26] , \D_push[0][1][25] , \D_push[0][1][24] , 
        \D_push[0][1][23] , \D_push[0][1][22] , \D_push[0][1][21] , 
        \D_push[0][1][20] , \D_push[0][1][19] , \D_push[0][1][18] , 
        \D_push[0][1][17] , \D_push[0][1][16] , \D_push[0][1][15] , 
        \D_push[0][1][14] , \D_push[0][1][13] , \D_push[0][1][12] , 
        \D_push[0][1][11] , \D_push[0][1][10] , \D_push[0][1][9] , 
        \D_push[0][1][8] , \D_push[0][1][7] , \D_push[0][1][6] , 
        \D_push[0][1][5] , \D_push[0][1][4] , \D_push[0][1][3] , 
        \D_push[0][1][2] , \D_push[0][1][1] , \D_push[0][1][0] }), .push(
        \push[0][1] ), .pop(\pop[0][1] ), .bus(\bus[0] ), .bs_bsy(\bs_bsy[0] ), 
        .trn_chng(\trn_chng[0] ) );
endmodule


module top_del_sistema ( clk, reset, .pndng({\pndng[0][1] , \pndng[0][0] }), 
    .D_pop({\D_pop[0][1][31] , \D_pop[0][1][30] , \D_pop[0][1][29] , 
        \D_pop[0][1][28] , \D_pop[0][1][27] , \D_pop[0][1][26] , 
        \D_pop[0][1][25] , \D_pop[0][1][24] , \D_pop[0][1][23] , 
        \D_pop[0][1][22] , \D_pop[0][1][21] , \D_pop[0][1][20] , 
        \D_pop[0][1][19] , \D_pop[0][1][18] , \D_pop[0][1][17] , 
        \D_pop[0][1][16] , \D_pop[0][1][15] , \D_pop[0][1][14] , 
        \D_pop[0][1][13] , \D_pop[0][1][12] , \D_pop[0][1][11] , 
        \D_pop[0][1][10] , \D_pop[0][1][9] , \D_pop[0][1][8] , 
        \D_pop[0][1][7] , \D_pop[0][1][6] , \D_pop[0][1][5] , \D_pop[0][1][4] , 
        \D_pop[0][1][3] , \D_pop[0][1][2] , \D_pop[0][1][1] , \D_pop[0][1][0] , 
        \D_pop[0][0][31] , \D_pop[0][0][30] , \D_pop[0][0][29] , 
        \D_pop[0][0][28] , \D_pop[0][0][27] , \D_pop[0][0][26] , 
        \D_pop[0][0][25] , \D_pop[0][0][24] , \D_pop[0][0][23] , 
        \D_pop[0][0][22] , \D_pop[0][0][21] , \D_pop[0][0][20] , 
        \D_pop[0][0][19] , \D_pop[0][0][18] , \D_pop[0][0][17] , 
        \D_pop[0][0][16] , \D_pop[0][0][15] , \D_pop[0][0][14] , 
        \D_pop[0][0][13] , \D_pop[0][0][12] , \D_pop[0][0][11] , 
        \D_pop[0][0][10] , \D_pop[0][0][9] , \D_pop[0][0][8] , 
        \D_pop[0][0][7] , \D_pop[0][0][6] , \D_pop[0][0][5] , \D_pop[0][0][4] , 
        \D_pop[0][0][3] , \D_pop[0][0][2] , \D_pop[0][0][1] , \D_pop[0][0][0] 
        }), .push({\push[0][1] , \push[0][0] }), .pop({\pop[0][1] , 
        \pop[0][0] }), .D_push({\D_push[0][1][31] , \D_push[0][1][30] , 
        \D_push[0][1][29] , \D_push[0][1][28] , \D_push[0][1][27] , 
        \D_push[0][1][26] , \D_push[0][1][25] , \D_push[0][1][24] , 
        \D_push[0][1][23] , \D_push[0][1][22] , \D_push[0][1][21] , 
        \D_push[0][1][20] , \D_push[0][1][19] , \D_push[0][1][18] , 
        \D_push[0][1][17] , \D_push[0][1][16] , \D_push[0][1][15] , 
        \D_push[0][1][14] , \D_push[0][1][13] , \D_push[0][1][12] , 
        \D_push[0][1][11] , \D_push[0][1][10] , \D_push[0][1][9] , 
        \D_push[0][1][8] , \D_push[0][1][7] , \D_push[0][1][6] , 
        \D_push[0][1][5] , \D_push[0][1][4] , \D_push[0][1][3] , 
        \D_push[0][1][2] , \D_push[0][1][1] , \D_push[0][1][0] , 
        \D_push[0][0][31] , \D_push[0][0][30] , \D_push[0][0][29] , 
        \D_push[0][0][28] , \D_push[0][0][27] , \D_push[0][0][26] , 
        \D_push[0][0][25] , \D_push[0][0][24] , \D_push[0][0][23] , 
        \D_push[0][0][22] , \D_push[0][0][21] , \D_push[0][0][20] , 
        \D_push[0][0][19] , \D_push[0][0][18] , \D_push[0][0][17] , 
        \D_push[0][0][16] , \D_push[0][0][15] , \D_push[0][0][14] , 
        \D_push[0][0][13] , \D_push[0][0][12] , \D_push[0][0][11] , 
        \D_push[0][0][10] , \D_push[0][0][9] , \D_push[0][0][8] , 
        \D_push[0][0][7] , \D_push[0][0][6] , \D_push[0][0][5] , 
        \D_push[0][0][4] , \D_push[0][0][3] , \D_push[0][0][2] , 
        \D_push[0][0][1] , \D_push[0][0][0] }) );
  input clk, reset, \pndng[0][1] , \pndng[0][0] , \D_pop[0][1][31] ,
         \D_pop[0][1][30] , \D_pop[0][1][29] , \D_pop[0][1][28] ,
         \D_pop[0][1][27] , \D_pop[0][1][26] , \D_pop[0][1][25] ,
         \D_pop[0][1][24] , \D_pop[0][1][23] , \D_pop[0][1][22] ,
         \D_pop[0][1][21] , \D_pop[0][1][20] , \D_pop[0][1][19] ,
         \D_pop[0][1][18] , \D_pop[0][1][17] , \D_pop[0][1][16] ,
         \D_pop[0][1][15] , \D_pop[0][1][14] , \D_pop[0][1][13] ,
         \D_pop[0][1][12] , \D_pop[0][1][11] , \D_pop[0][1][10] ,
         \D_pop[0][1][9] , \D_pop[0][1][8] , \D_pop[0][1][7] ,
         \D_pop[0][1][6] , \D_pop[0][1][5] , \D_pop[0][1][4] ,
         \D_pop[0][1][3] , \D_pop[0][1][2] , \D_pop[0][1][1] ,
         \D_pop[0][1][0] , \D_pop[0][0][31] , \D_pop[0][0][30] ,
         \D_pop[0][0][29] , \D_pop[0][0][28] , \D_pop[0][0][27] ,
         \D_pop[0][0][26] , \D_pop[0][0][25] , \D_pop[0][0][24] ,
         \D_pop[0][0][23] , \D_pop[0][0][22] , \D_pop[0][0][21] ,
         \D_pop[0][0][20] , \D_pop[0][0][19] , \D_pop[0][0][18] ,
         \D_pop[0][0][17] , \D_pop[0][0][16] , \D_pop[0][0][15] ,
         \D_pop[0][0][14] , \D_pop[0][0][13] , \D_pop[0][0][12] ,
         \D_pop[0][0][11] , \D_pop[0][0][10] , \D_pop[0][0][9] ,
         \D_pop[0][0][8] , \D_pop[0][0][7] , \D_pop[0][0][6] ,
         \D_pop[0][0][5] , \D_pop[0][0][4] , \D_pop[0][0][3] ,
         \D_pop[0][0][2] , \D_pop[0][0][1] , \D_pop[0][0][0] ;
  output \push[0][1] , \push[0][0] , \pop[0][1] , \pop[0][0] ,
         \D_push[0][1][31] , \D_push[0][1][30] , \D_push[0][1][29] ,
         \D_push[0][1][28] , \D_push[0][1][27] , \D_push[0][1][26] ,
         \D_push[0][1][25] , \D_push[0][1][24] , \D_push[0][1][23] ,
         \D_push[0][1][22] , \D_push[0][1][21] , \D_push[0][1][20] ,
         \D_push[0][1][19] , \D_push[0][1][18] , \D_push[0][1][17] ,
         \D_push[0][1][16] , \D_push[0][1][15] , \D_push[0][1][14] ,
         \D_push[0][1][13] , \D_push[0][1][12] , \D_push[0][1][11] ,
         \D_push[0][1][10] , \D_push[0][1][9] , \D_push[0][1][8] ,
         \D_push[0][1][7] , \D_push[0][1][6] , \D_push[0][1][5] ,
         \D_push[0][1][4] , \D_push[0][1][3] , \D_push[0][1][2] ,
         \D_push[0][1][1] , \D_push[0][1][0] , \D_push[0][0][31] ,
         \D_push[0][0][30] , \D_push[0][0][29] , \D_push[0][0][28] ,
         \D_push[0][0][27] , \D_push[0][0][26] , \D_push[0][0][25] ,
         \D_push[0][0][24] , \D_push[0][0][23] , \D_push[0][0][22] ,
         \D_push[0][0][21] , \D_push[0][0][20] , \D_push[0][0][19] ,
         \D_push[0][0][18] , \D_push[0][0][17] , \D_push[0][0][16] ,
         \D_push[0][0][15] , \D_push[0][0][14] , \D_push[0][0][13] ,
         \D_push[0][0][12] , \D_push[0][0][11] , \D_push[0][0][10] ,
         \D_push[0][0][9] , \D_push[0][0][8] , \D_push[0][0][7] ,
         \D_push[0][0][6] , \D_push[0][0][5] , \D_push[0][0][4] ,
         \D_push[0][0][3] , \D_push[0][0][2] , \D_push[0][0][1] ,
         \D_push[0][0][0] ;


  bs_gnrtr_n_rbtr_1_2_32_ff uut ( .clk(clk), .reset(reset), .pndng({
        \pndng[0][1] , \pndng[0][0] }), .push({\push[0][1] , \push[0][0] }), 
        .pop({\pop[0][1] , \pop[0][0] }), .D_pop({\D_pop[0][1][31] , 
        \D_pop[0][1][30] , \D_pop[0][1][29] , \D_pop[0][1][28] , 
        \D_pop[0][1][27] , \D_pop[0][1][26] , \D_pop[0][1][25] , 
        \D_pop[0][1][24] , \D_pop[0][1][23] , \D_pop[0][1][22] , 
        \D_pop[0][1][21] , \D_pop[0][1][20] , \D_pop[0][1][19] , 
        \D_pop[0][1][18] , \D_pop[0][1][17] , \D_pop[0][1][16] , 
        \D_pop[0][1][15] , \D_pop[0][1][14] , \D_pop[0][1][13] , 
        \D_pop[0][1][12] , \D_pop[0][1][11] , \D_pop[0][1][10] , 
        \D_pop[0][1][9] , \D_pop[0][1][8] , \D_pop[0][1][7] , \D_pop[0][1][6] , 
        \D_pop[0][1][5] , \D_pop[0][1][4] , \D_pop[0][1][3] , \D_pop[0][1][2] , 
        \D_pop[0][1][1] , \D_pop[0][1][0] , \D_pop[0][0][31] , 
        \D_pop[0][0][30] , \D_pop[0][0][29] , \D_pop[0][0][28] , 
        \D_pop[0][0][27] , \D_pop[0][0][26] , \D_pop[0][0][25] , 
        \D_pop[0][0][24] , \D_pop[0][0][23] , \D_pop[0][0][22] , 
        \D_pop[0][0][21] , \D_pop[0][0][20] , \D_pop[0][0][19] , 
        \D_pop[0][0][18] , \D_pop[0][0][17] , \D_pop[0][0][16] , 
        \D_pop[0][0][15] , \D_pop[0][0][14] , \D_pop[0][0][13] , 
        \D_pop[0][0][12] , \D_pop[0][0][11] , \D_pop[0][0][10] , 
        \D_pop[0][0][9] , \D_pop[0][0][8] , \D_pop[0][0][7] , \D_pop[0][0][6] , 
        \D_pop[0][0][5] , \D_pop[0][0][4] , \D_pop[0][0][3] , \D_pop[0][0][2] , 
        \D_pop[0][0][1] , \D_pop[0][0][0] }), .D_push({\D_push[0][1][31] , 
        \D_push[0][1][30] , \D_push[0][1][29] , \D_push[0][1][28] , 
        \D_push[0][1][27] , \D_push[0][1][26] , \D_push[0][1][25] , 
        \D_push[0][1][24] , \D_push[0][1][23] , \D_push[0][1][22] , 
        \D_push[0][1][21] , \D_push[0][1][20] , \D_push[0][1][19] , 
        \D_push[0][1][18] , \D_push[0][1][17] , \D_push[0][1][16] , 
        \D_push[0][1][15] , \D_push[0][1][14] , \D_push[0][1][13] , 
        \D_push[0][1][12] , \D_push[0][1][11] , \D_push[0][1][10] , 
        \D_push[0][1][9] , \D_push[0][1][8] , \D_push[0][1][7] , 
        \D_push[0][1][6] , \D_push[0][1][5] , \D_push[0][1][4] , 
        \D_push[0][1][3] , \D_push[0][1][2] , \D_push[0][1][1] , 
        \D_push[0][1][0] , \D_push[0][0][31] , \D_push[0][0][30] , 
        \D_push[0][0][29] , \D_push[0][0][28] , \D_push[0][0][27] , 
        \D_push[0][0][26] , \D_push[0][0][25] , \D_push[0][0][24] , 
        \D_push[0][0][23] , \D_push[0][0][22] , \D_push[0][0][21] , 
        \D_push[0][0][20] , \D_push[0][0][19] , \D_push[0][0][18] , 
        \D_push[0][0][17] , \D_push[0][0][16] , \D_push[0][0][15] , 
        \D_push[0][0][14] , \D_push[0][0][13] , \D_push[0][0][12] , 
        \D_push[0][0][11] , \D_push[0][0][10] , \D_push[0][0][9] , 
        \D_push[0][0][8] , \D_push[0][0][7] , \D_push[0][0][6] , 
        \D_push[0][0][5] , \D_push[0][0][4] , \D_push[0][0][3] , 
        \D_push[0][0][2] , \D_push[0][0][1] , \D_push[0][0][0] }) );
endmodule

