`timescale 1ns / 1ps


module FIFO_E#(AW=32,DW=32,Masters=2)(
    input ACLK,
    input ARESETn,
    input [AW+DW+3+(DW/8)+$clog2(Masters+1):0]F_Write,
    input W_end,
    input AWREADY,
    input WREADY,
    output [$clog2(Masters+1)-1:0]R_id,
    output [AW-1:0]AWADDR,
    output [DW-1:0]WDATA,
    output [2:0]AWPROT,
    output [(DW/8)-1:0]WSTRB,
    output AWVALID,
    output WVALID
    );
    
//#########################################################
//          Definición de conexiones
//#########################################################
    logic Valid;
    logic [$clog2(Masters)-1:0] Waddr;
    logic [$clog2(Masters)-1:0] Raddr;
    logic R_en;
    logic [AW+DW+2+(DW/8)+$clog2(Masters+1):0]D_out;
//#########################################################
//          Definición de las instancias
//#########################################################
    FSM_FIFO#(Masters)FSM_Inst(
        .clk(ACLK),.reset(~ARESETn),
        .Push(F_Write[0]),
        .R_end(W_end),
        .S_Ready(AWREADY&WREADY),
        .Waddr(Waddr),
        .Raddr(Raddr),
        .R_en(R_en),
        .S_Valid(Valid)
    );    
    assign AWVALID=Valid;
    assign WVALID=Valid;
    
    B_Reg#(AW+DW+3+(DW/8)+$clog2(Masters+1),Masters)Bank_Inst(
        .clk(ACLK),.reset(~ARESETn),
        .D_in(F_Write[AW+DW+3+(DW/8)+$clog2(Masters+1):1]),
        .W_en(F_Write[0]),
        .Waddr(Waddr),
        .Raddr(Raddr),
        .R_en(R_en),
        .D_out(D_out)
        );
    assign R_id=D_out[$clog2(Masters+1)-1:0];
    assign WSTRB=D_out[$clog2(Masters+1)+(DW/8)-1:$clog2(Masters+1)];
    assign WDATA=D_out[$clog2(Masters+1)+(DW/8)+DW-1:$clog2(Masters+1)+(DW/8)];
    
    assign AWPROT=D_out[$clog2(Masters+1)+(DW/8)+DW+2:$clog2(Masters+1)+(DW/8)+DW];
    assign AWADDR=D_out[$clog2(Masters+1)+(DW/8)+DW+AW+2:$clog2(Masters+1)+(DW/8)+DW+3];
        
endmodule
