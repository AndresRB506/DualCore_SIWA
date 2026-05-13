`include "../Register_File/Biblioteca.v"


module Banco_registros_latches(csr_id, rs1, rs2, rd, csr_write, reg_write_data, write, R1, R2, clk, rst, mip_IO, mip_time, mie_time, mie_IO, comparation, timer,CSR, full_range_level_shifter, IS_Val, IS_Config, IS_Trigger, Mie_analogic, mip_analogic,Reg_GPIO_en,Reg_GPIO_int,Reg_GPIO_out,en_bus);
parameter width=32;
parameter number_reg_integer=32;
parameter number_reg_csr=12;
parameter ad_integer=$clog2(number_reg_integer);
parameter ad_csr=$clog2(number_reg_csr);

/*Entradas y salidas*/
input [ad_csr-1:0] csr_id;
input [ad_integer-1:0] rs1;
input [ad_integer-1:0] rs2;
input [ad_integer-1:0] rd;
input write;
input csr_write;
//input csr_en;
input [width-1:0] reg_write_data;
input clk;
input rst;
input mip_IO;
input mip_time;
input mip_analogic;
input [31:0] timer;


output [31:0] comparation;
output mie_IO;
output mie_time;
output Mie_analogic;
output [width-1:0] R1;
output [width-1:0] R2;
output [width-1:0] CSR;
output [7:0] full_range_level_shifter;
output [31:0] IS_Val;
output [31:0] IS_Config;
output [3:0] IS_Trigger;
output [7:0] Reg_GPIO_en;
input [7:0] Reg_GPIO_int;
output [7:0] Reg_GPIO_out;
output en_bus;

wire write_negado;
wire [width-1:0] dato_escribe;

assign write_negado=~write && ~csr_write;


//Cables
//wire [width-1:0] sal2_integer;
//wire [width-1:0] sal2_csr;
//wire write_csr;
//wire write_reg;
//and write_csr_gen (write_csr,csr_en,write);
//and write_reg_gen (write_reg,~csr_en,write);

Reg_32_bit #(.width(width),.number_reg(number_reg_integer)) Reg_integer(
	.Din(dato_escribe),
	.Dout1(R1),
	.Dout2(R2),
	.addres1(rs1),
	.addres2(rs2),
	.addres3(rd),
	.Write_en(write),
        .rst(rst),
	.clk(clk)
	);

csr_file #(.width(width),.number_reg(number_reg_csr)) Reg_csr(
	.Din(dato_escribe),
	.Dout1(CSR),
	.addres1(csr_id),
	.Write_en(csr_write),
	.clk(clk),
	.rst(rst),
	.mip_IO(mip_IO),
	.mip_time(mip_time),
	.mie_IO(mie_IO),
	.mie_time(mie_time),
	.comparation(comparation),
	.timer(timer),
	.full_range_level_shifter(full_range_level_shifter),
	.IS_Val(IS_Val),
	.IS_Config(IS_Config),
	.IS_Trigger(IS_Trigger),
	.Mie_analogic(Mie_analogic),
	.mip_analogic(mip_analogic),
	.Reg_GPIO_en(Reg_GPIO_en),
	.Reg_GPIO_int(Reg_GPIO_int),
	.Reg_GPIO_out(Reg_GPIO_out),
	.en_bus(en_bus)
	);
latch_entrada Latch_entrada(
	.clk(write_negado),
	.d(reg_write_data),
	.q(dato_escribe)
	);
//assign R2 = csr_en ? sal2_csr : sal2_integer;

endmodule
module latch_entrada(clk,d,q);
//Entradas y Salidas
	input clk;
	input [31:0]  d;
	output reg [31:0] q;
//Logica
	always @ (clk, d)
			if (clk) q <= d;
endmodule
