`include "../BUS_Micro/Bus_Micro.sv"
`include "../DECO_INSTR/DECO_INSTR.sv"
`include "../ALU/ALU_2.sv"
`include "../Register_File/Banco_de_registros_latches.v"
`include "../MBC/MBC.sv"
`include "../TOP/control.sv"
//`include "../TOP/XSPRAMLP_2048X32_M8P.sv"
//`timescale 1ns/10ps

module Timer #(parameter bits= 32)(
 input clock,
 input reset,
 output reg [bits-1:0]count
 );
  always@(posedge clock or posedge reset) begin
   if(reset)begin
     count <= 0;
   end else begin
     count <= count+1;
   end
  end
endmodule

module top_CPU_riscv(
  input clk,
  input reset,
  input push_spi,
  input push_uart,
//  input push_anlg,
  input pop_spi,
  input pop_uart,
//  input pop_anlg,
  input [64:0] D_push_spi,
  input [64:0] D_push_uart,
  input maip,
//  input [64:0] D_push_anlg,
  output [64:0] D_pop_spi,
  output [64:0] D_pop_uart,
//  output [64:0] D_pop_anlg,
  output pndng_spi,
  output pndng_uart,
//  output pndng_anlg,
  output [7:0] full_range_level_shifter,
  output [31:0] IS_Val,
  output [31:0] IS_Config,
  output [3:0] IS_Trigger,
  output [7:0] Reg_GPIO_en,
  input [7:0] Reg_GPIO_int,
  output [7:0] Reg_GPIO_out
);

 parameter mcause_a=2;
 parameter mcause_b=3;
 parameter mepc= 1;
 parameter mtvec = 5;
 parameter max=13;

//Outputs from the MBC
  wire [31:0] d_read;
  wire [max-3:0] a;
  wire [31:0] d;
//  wire write;
  wire [64:0] D_push_mbc;
  wire push_mbc;
  wire mem_rdy_mem_cntrlr;
  wire pop_mbc;
  wire error_drs_mem_cntrlr;
  wire clk_mem;
  wire cen;
  wire sl;
  wire wen;
//Outputs from the Deco
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] imm_out;
  wire [6:0] codif_inst_deco;
  wire [3:0] csr;
//Outputs from the ALU
  wire zero_alu;
  wire overflow;
  wire negative;
  wire carry;
  wire [31:0] alu_out;
//Outputs from Register_File
  wire [31:0] comparation;
  wire meie;
  wire mtie;
  wire maie;
  wire [31:0] R1;
  wire [31:0] d_write;
  wire [31:0] CSR;
//outputs from the Bus
  wire meip; //pndng_mbc
  wire [64:0] D_pop_mbc;
//outputs from the central control
  wire r_1_w_0_mbc;
  wire b_mbc;
  wire h_mbc;
  wire enable_mbc;
  wire pop_intrpt;
  wire ld_id_instrl_deco;
  wire ld_addrs;
  wire ld_pc;
  wire s_addrs;
  wire [1:0]s_pc1;
  wire [1:0] s_pc2;
  wire [2:0] s_alu;
  wire [3:0] s_reg_w;
  wire [2:0] s_csr;
  wire write_reg_fl;
  wire csr_en_reg_fl;
  wire [3:0] cntrl_alu;
  wire sign_ext;
  wire inv_r1;
//outputs Timer
  wire [31:0]count_timer;
//outputs Memory
  wire RDY;
  wire [31:0] Q;
//signals generated at the TOP level
  logic mtip;
  logic [31:0]reg_write_data;
  logic [3:0] csr_id;
  logic [31:0] alu_b;
  logic [31:0] alu_a;
  logic [31:0] pc_pre;
  logic [31:0] addrs_reg;
  logic [31:0] r1_c;
  logic pop;
  logic Cin;
  logic reset_timer;
  logic [31:0] pc;
  logic glbl_ntrpt_en;
  logic int_A;
  logic int_T;
  logic int_E;
  logic ld_pc_clk;

control central_control (
  .clk(clk),
  .reset(reset),
  .codif_inst_deco(codif_inst_deco),
  .mem_rdy_mem_cntrlr(mem_rdy_mem_cntrlr),
  .error_drs_mem_cntrlr(error_drs_mem_cntrlr),
  .Zero_alu(zero_alu),
  .int_A(int_A),
  .int_T(int_T),
  .int_E(int_E),
  .r_1_w_0_mbc(r_1_w_0_mbc),
  .b_mbc(b_mbc),
  .h_mbc(h_mbc),
  .enable_mbc(enable_mbc),
  .pop_intrpt(pop_intrpt),
  .ld_id_instrl_deco(ld_id_instrl_deco),
  .ld_addrs(ld_addrs),
  .ld_pc(ld_pc),
  .s_addrs(s_addrs),
  .s_pc1(s_pc1),
  .s_pc2(s_pc2),
  .s_alu(s_alu),
  .sign_ext(sign_ext),
  .s_reg_w(s_reg_w),
  .s_csr(s_csr),
  .write_reg_fl(write_reg_fl),
  .csr_write(csr_write),
  .rst_tmr(rst_tmr),
  .cntrl_alu(cntrl_alu),
  .inv_r1(inv_r1)
);

XSPRAMLP_2048X32_M8P Memoria_8K (
  .Q(Q),
  .D(d),
  .A(a),
  .CLK(clk_mem),
  .CEn(cen),
  .WEn(wen),
  .SL(sl),
  .RDY(RDY)
);

mbc #(.max(13)) Memory_controller(
  .clk(clk),
  .reset(reset),
  .address(addrs_reg[24:0]),
  .d_write(d_write),
  .b(b_mbc),
  .h(h_mbc),
  .sign_ext(sign_ext),
  .enable(enable_mbc),
  .r_w(r_1_w_0_mbc),
  .d_pop(D_pop_mbc[61:0]),
  .pndng(meip),
  .q(Q),
  .d_read(d_read),
  .a(a),
  .d(d),
  .d_psh(D_push_mbc),
  .psh(push_mbc),
  .mem_rdy(mem_rdy_mem_cntrlr),
  .pop_mbc(pop_mbc),
  .error_drs(error_drs_mem_cntrlr),
  .clk_mem(clk_mem),
  .cen(cen),
  .sl(sl),
  .wen(wen)
);

DECO_INSTR Deco(
    .reset(reset),
    .ld_id(ld_id_instrl_deco),
    .inst(d_read),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .imm(imm_out),
    .codif(codif_inst_deco),
    .csr(csr)
    );

ALU_2 #(.bits_size(32),.cntrl_size(4)) Alu(
    .A(alu_a),
    .B(alu_b),
    .Alu_Cntrl(cntrl_alu),
    .Cin(Cin),
    .Zero(zero_alu),
    .oVerflow(overflow),
    .Negative(negative),
    .Carry(carry),
    .OUT(alu_out)
    );

Banco_registros_latches Reg_file(
  .csr_id(csr_id),
  .rs1(rs1),
  .rs2(rs2),
  .rd(rd),
  .write(write_reg_fl),
  .csr_write(csr_write),
  .reg_write_data(reg_write_data),
  .clk(clk),
  .rst(reset),
  .mip_IO(meip),
  .mip_time(mtip),
  .timer(count_timer),
  .comparation(comparation),
  .mie_IO(meie),
  .Mie_analogic(maie),
  .mip_analogic(maip),
  .mie_time(mtie),
  .R1(R1),
  .R2(d_write),
  .CSR(CSR),
  .full_range_level_shifter(full_range_level_shifter),
  .IS_Val(IS_Val),
  .IS_Config(IS_Config),
  .IS_Trigger(IS_Trigger),
  .Reg_GPIO_en(Reg_GPIO_en),
  .Reg_GPIO_int(Reg_GPIO_int),
  .Reg_GPIO_out(Reg_GPIO_out)
);

tec_riscv_bus Bus(
  .clk(clk),
  .reset(reset),
  .pndng_mbc(meip),
  .pndng_spi(pndng_spi),
  .pndng_uart(pndng_uart),
//  .pndng_anlg(pndng_anlg),
  .push_mbc(push_mbc),
  .push_spi(push_spi),
  .push_uart(push_uart),
//  .push_anlg(push_anlg),
  .pop_mbc(pop),
  .pop_spi(pop_spi),
  .pop_uart(pop_uart),
//  .pop_anlg(pop_anlg),
  .D_pop_mbc(D_pop_mbc),
  .D_pop_spi(D_pop_spi),
  .D_pop_uart(D_pop_uart),
//  .D_pop_anlg(D_pop_anlg),
  .D_push_mbc(D_push_mbc),
  .D_push_spi(D_push_spi),
  .D_push_uart(D_push_uart)
//  .D_push_anlg(D_push_anlg)
);

Timer temporizador_top(
 .clock(clk_timer),
 .reset(reset_timer),
 .count(count_timer)
 );
always@(posedge clk or posedge reset) begin
  if(reset)begin
    mtip <= 0;
  end else begin
    mtip <= (count_timer >= comparation)?{1'b1}:{1'b0};
  end
end
assign clk_timer = (mtie&clk&~mtip);
assign reset_timer = (reset|rst_tmr);

 always_comb begin
   pop <= pop_mbc|pop_intrpt;

   case(s_reg_w)// synopsys infer_mux
     0: begin
       reg_write_data <= {{31{1'b0}},zero_alu};
     end
     1: begin
       reg_write_data <= imm_out;
     end
     2: begin
       reg_write_data <= alu_out;
     end
     3: begin
       reg_write_data <= R1;
     end
     4: begin
       reg_write_data <= {{1'b0},D_pop_mbc[56:32],D_pop_mbc[59:57],{1'b0},D_pop_mbc[61:60]};
     end
     5: begin
       reg_write_data <= D_pop_mbc[31:0];
     end
     6: begin
       reg_write_data <= d_read;
     end
     7: begin
       reg_write_data <= CSR;
     end
     8:begin
       reg_write_data <= pc;
     end
     9:begin
       reg_write_data <= {imm_out[11:0],rs2,rs1,codif_inst_deco,{3'b000}};
     end
     10:begin
       reg_write_data <= {{27{1'b0}},rd};
     end
     11:begin
       reg_write_data <= {{29{1'b0}},{3'b100}};
     end
     12: begin
       reg_write_data <= {{29{1'b0}},{3'b011}};
     end
     13: begin
       reg_write_data <= {{29{1'b0}},{3'b101}};
     end
     default: begin
       reg_write_data <=0;
     end
   endcase
end

always_comb begin
   case(s_csr) // synopsys infer_mux
     0: begin
       csr_id <= csr;
     end
     1: begin
       csr_id <= mcause_a;
     end
     2: begin
       csr_id <= mcause_b;
     end
     3: begin
       csr_id <= mepc;
     end
     4: begin
       csr_id <= mtvec;
     end
   endcase
end

always_comb begin
   case(s_alu) // synopsys infer_mux
     0:begin
       alu_b <= d_write;
     end
     1:begin
       alu_b <= 4;
     end
     2:begin
       alu_b <= imm_out;
     end
     3:begin
       alu_b <= 1;
     end
     4:begin
       alu_b <=CSR;
     end
     default: begin
       alu_b<=0;
     end
   endcase
 end

 //reg ld_addrs_clk;
 //assign ld_addrs_clk = ld_addrs & ~clk;
  
always@(posedge ld_addrs or posedge reset) begin
  if (reset) begin
    addrs_reg <= 0;
  end else begin
    addrs_reg <= (s_addrs)?pc:alu_out;
  end
end

assign Cin = 0;
assign int_A = maie & maip;
assign int_T = mtie & mtip;
assign int_E = meie & meip;

always_comb begin
  case(s_pc2) // synopsys infer_mux
    0: begin
      r1_c <= pc;
    end
    1: begin
      r1_c<= R1;
    end
    2: begin
      r1_c<=imm_out;
    end
    default: begin
      r1_c <=0;
    end
  endcase
end

assign alu_a = (inv_r1)?~r1_c:r1_c;

always_comb begin
  case(s_pc1) // synopsys infer_mux
    1: pc_pre <= imm_out;
    0: pc_pre <= alu_out;
    2: pc_pre <= CSR;
    default: pc_pre  <= alu_out;
  endcase
end

assign ld_pc_clk = ld_pc & ~clk;

dff_async_rst pc0 (.data(pc_pre[0]),.clk(ld_pc_clk),.reset(reset),.q(pc[0]));
dff_async_rst pc1 (.data(pc_pre[1]),.clk(ld_pc_clk),.reset(reset),.q(pc[1]));
dff_async_rst pc2 (.data(pc_pre[2]),.clk(ld_pc_clk),.reset(reset),.q(pc[2]));
dff_async_rst pc3 (.data(pc_pre[3]),.clk(ld_pc_clk),.reset(reset),.q(pc[3]));
dff_async_rst pc4 (.data(pc_pre[4]),.clk(ld_pc_clk),.reset(reset),.q(pc[4]));
dff_async_rst pc5 (.data(pc_pre[5]),.clk(ld_pc_clk),.reset(reset),.q(pc[5]));
dff_async_rst pc6 (.data(pc_pre[6]),.clk(ld_pc_clk),.reset(reset),.q(pc[6]));
dff_async_rst pc7 (.data(pc_pre[7]),.clk(ld_pc_clk),.reset(reset),.q(pc[7]));
dff_async_rst pc8 (.data(pc_pre[8]),.clk(ld_pc_clk),.reset(reset),.q(pc[8]));
dff_async_rst pc9 (.data(pc_pre[9]),.clk(ld_pc_clk),.reset(reset),.q(pc[9]));
dff_async_rst pc10 (.data(pc_pre[10]),.clk(ld_pc_clk),.reset(reset),.q(pc[10]));
dff_async_rst pc11 (.data(pc_pre[11]),.clk(ld_pc_clk),.reset(reset),.q(pc[11]));
dff_async_rst pc12 (.data(pc_pre[12]),.clk(ld_pc_clk),.reset(reset),.q(pc[12]));
dff_async_rst pc13 (.data(pc_pre[13]),.clk(ld_pc_clk),.reset(reset),.q(pc[13]));
dff_async_rst pc14 (.data(pc_pre[14]),.clk(ld_pc_clk),.reset(reset),.q(pc[14]));
dff_async_rst pc15 (.data(pc_pre[15]),.clk(ld_pc_clk),.reset(reset),.q(pc[15]));
dff_async_rst pc16 (.data(pc_pre[16]),.clk(ld_pc_clk),.reset(reset),.q(pc[16]));
dff_async_rst pc17 (.data(pc_pre[17]),.clk(ld_pc_clk),.reset(reset),.q(pc[17]));
dff_async_rst pc18 (.data(pc_pre[18]),.clk(ld_pc_clk),.reset(reset),.q(pc[18]));
dff_async_rst pc19 (.data(pc_pre[19]),.clk(ld_pc_clk),.reset(reset),.q(pc[19]));
dff_async_rst pc20 (.data(pc_pre[20]),.clk(ld_pc_clk),.reset(reset),.q(pc[20]));
dff_async_rst pc21 (.data(pc_pre[21]),.clk(ld_pc_clk),.reset(reset),.q(pc[21]));
dff_async_rst pc22 (.data(pc_pre[22]),.clk(ld_pc_clk),.reset(reset),.q(pc[22]));
dff_async_rst pc23 (.data(pc_pre[23]),.clk(ld_pc_clk),.reset(reset),.q(pc[23]));
dff_async_rst pc24 (.data(pc_pre[24]),.clk(ld_pc_clk),.reset(reset),.q(pc[24]));
dff_async_rst pc25 (.data(pc_pre[25]),.clk(ld_pc_clk),.reset(reset),.q(pc[25]));
dff_async_rst pc26 (.data(pc_pre[26]),.clk(ld_pc_clk),.reset(reset),.q(pc[26]));
dff_async_rst pc27 (.data(pc_pre[27]),.clk(ld_pc_clk),.reset(reset),.q(pc[27]));
dff_async_rst pc28 (.data(pc_pre[28]),.clk(ld_pc_clk),.reset(reset),.q(pc[28]));
dff_async_rst pc29 (.data(pc_pre[29]),.clk(ld_pc_clk),.reset(reset),.q(pc[29]));
dff_async_rst pc30 (.data(pc_pre[30]),.clk(ld_pc_clk),.reset(reset),.q(pc[30]));
dff_async_rst pc31 (.data(pc_pre[31]),.clk(ld_pc_clk),.reset(reset),.q(pc[31]));
 

endmodule
