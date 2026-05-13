`timescale 1ns / 1ps


module FIFO_L#(AW=32,Masters=2)(
    input ACLK,
    input ARESETn,
    input [AW+3+$clog2(Masters+1):0]F_Read,
    input R_end,
    input ARREADY,
    output [$clog2(Masters+1)-1:0]D_id,
    output [AW-1:0]ARADDR,
    output [2:0]ARPROT,
    output ARVALID
    );
    
//#########################################################
//          Definición de conexiones
//#########################################################
    logic [$clog2(Masters)-1:0] Waddr;
    logic [$clog2(Masters)-1:0] Raddr;
    logic R_en;
    logic [AW+2+$clog2(Masters+1):0]D_out;
//#########################################################
//          Definición de las instancias
//#########################################################
    FSM_FIFO#(Masters)FSM_Inst(
        .clk(ACLK),.reset(~ARESETn),
        .Push(F_Read[0]),
        .R_end(R_end),
        .S_Ready(ARREADY),
        .Waddr(Waddr),
        .Raddr(Raddr),
        .R_en(R_en),
        .S_Valid(ARVALID)
    );    
    
    B_Reg#(AW+3+$clog2(Masters+1),Masters)Bank_Inst(
        .clk(ACLK),.reset(~ARESETn),
        .D_in(F_Read[AW+3+$clog2(Masters+1):1]),
        .W_en(F_Read[0]),
        .Waddr(Waddr),
        .Raddr(Raddr),
        .R_en(R_en),
        .D_out(D_out)
        );
    assign D_id=D_out[$clog2(Masters+1)-1:0];
    assign ARPROT=D_out[$clog2(Masters+1)+2:$clog2(Masters+1)];
    assign ARADDR=D_out[AW+2+$clog2(Masters+1):$clog2(Masters+1)+3];
        
endmodule
