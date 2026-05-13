`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Módulo General
// Module Name: CMB
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CMB(
    input reloj, reset, mtie, meie,
    input full, pndng,
    input [79:0] d_pop,
    input clean,
    input enable, rw, b, h,
    input [31:0] address,
    input [31:0] data_write,
    input [31:0] csr_io,
    input [5:0][31:0] csr_lim,
    //Salidas del módulo
    output reg mem_rdy,
    output reg [31:0] data_read,
    output reg pop, push,
    output reg [79:0] d_push,
    output reg rqs_intr_mem, io_intr_push,
    output reg [71:0] io_intr_d_push
    );
    wire C_En, W_En, Sl, Clk_Mem;
    reg [10:0] A_Sys;
    reg [31:0] D_Sys;

//---------------Salidas internas de los módulos---------------
    //Salidas de la memoria
    wire [31:0] Q_m;
    wire Rdy_Mem;
    controlador #(.bus_sz(80), .Adrs_Data_sz(32), 
             .Intr_D_sz(72), .cod_sz(8),
             .mem_adrs_sz(11), .bs_adrs_sz(24), 
             .cant_io(5), .fifo_int_depth(3),
             .watch_dog_sz(32), .fifo_int_sz(72)) inst_controller(
    .CLK_sys(reloj), .Rst(reset),
    .MTIE(mtie), .MEIE(meie), .Full(full), .Pndng(pndng),
    .Clean(clean), .Enable(enable), .RW(rw), .B(b), .H(h),
    .D_pop(d_pop),
    .Address(address),
    .Data_Write(data_write),
    .CSR_io(csr_io),
    .CSR_limits(csr_lim),
    .Mem_rdy(mem_rdy), .Push(push), .IO_Intr_push(io_intr_push),
    .D_push(d_push),
    .Pop(pop), .Rqs_Intr_mem(rqs_intr_mem),
    .Data_read(data_read),
    .IO_Intr_D_push(io_intr_d_push),
    //Para la memoria ponerla externamente
    .q(Q_m),
    .rdy_mem(Rdy_Mem),
    .c_en(C_En), .w_en(W_En), .sl(Sl), .clk_mem(Clk_Mem),
    .a_sys(A_Sys),
    .d_sys(D_Sys)
    );

    XSPRAMLP_2048X32_M8P memoria(.Q(Q_m), .D(D_Sys), .A(A_Sys), .CLK(Clk_Mem), .CEn(C_En), .WEn(W_En), .SL(Sl), .RDY(Rdy_Mem));


endmodule
