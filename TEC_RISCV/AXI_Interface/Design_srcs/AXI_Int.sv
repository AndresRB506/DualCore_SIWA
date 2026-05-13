`timescale 1ns / 1ps
//`include "AXI_Ports.sv"
//////////////////////////////////////
// Definición del módulo principal //                                                
////////////////////////////////////

module AXI_Int#(AW=32,DW=32,Masters=2,Slaves=2)(
    input ACLK,
    input ARESETn,
    Ports.master M_Ports,
    Ports.slave S_Ports
    );
    
//#########################################################
//          Definición de conexiones
//#########################################################
//C_Lecturas
    logic [Slaves-1:0][AW+3+$clog2(Masters+1):0]F_Read;
    logic [Slaves-1:0][$clog2(Masters+1)-1:0]D_id;
//C_Escrituras
    logic [Slaves-1:0][AW+DW+3+(DW/8)+$clog2(Masters+1):0]F_Write;
    logic [Slaves-1:0][$clog2(Masters+1)-1:0]R_id;
    
//#########################################################
//          Definición de las instancias
//#########################################################
    C_Lecturas #(AW,DW,Masters,Slaves) C_L(
    //Etapa de Push
    .ACLK(ACLK),.ARESETn(ARESETn),
    .M_ARADDR(M_Ports.ARADDR),
    .M_ARPROT(M_Ports.ARPROT),
    .M_ARVALID(M_Ports.ARVALID),
    .M_ARREADY(M_Ports.ARREADY),
    .F_Read(F_Read),
    //Etapa de Direccionamiento////
    .S_RDATA(S_Ports.RDATA),
    .S_RRESP(S_Ports.RRESP),
    .S_RVALID(S_Ports.RVALID),
    .D_id(D_id),
    .M_RREADY(M_Ports.RREADY),
    .M_RDATA(M_Ports.RDATA),
    .M_RVALID(M_Ports.RVALID),
    .M_RRESP(M_Ports.RRESP),
    .S_RREADY(S_Ports.RREADY)
    );
    
    C_Escrituras #(AW,DW,Masters,Slaves) C_E(
    //Etapa de Push
    .ACLK(ACLK),.ARESETn(ARESETn),
    .M_AWADDR(M_Ports.AWADDR),
    .M_WDATA(M_Ports.WDATA),
    .M_AWPROT(M_Ports.AWPROT),
    .M_WSTRB(M_Ports.WSTRB),
    .M_AWVALID(M_Ports.AWVALID),
    .M_WVALID(M_Ports.WVALID),
    .M_AWREADY(M_Ports.AWREADY),
    .M_WREADY(M_Ports.WREADY),
    .F_Write(F_Write),
    //Etapa de Direccionamiento////
    .S_BRESP(S_Ports.BRESP),
    .S_BVALID(S_Ports.BVALID),
    .R_id(R_id),
    .M_BREADY(M_Ports.BREADY),
    .M_BVALID(M_Ports.BVALID),
    .M_BRESP(M_Ports.BRESP),
    .S_BREADY(S_Ports.BREADY)
    );

    genvar i;
    generate
    for (i=0;i<Slaves;i=i+1)begin
        FIFO_L #(AW,Masters) F_L(
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .F_Read(F_Read[i]),
        .R_end(S_Ports.RVALID[i]),
        .ARREADY(S_Ports.ARREADY[i]),
        .D_id(D_id[i]),
        .ARADDR(S_Ports.ARADDR[i]),
        .ARPROT(S_Ports.ARPROT[i]),
        .ARVALID(S_Ports.ARVALID[i])
        );
        
        FIFO_E #(AW,DW,Masters) F_E(
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .F_Write(F_Write[i]),
        .W_end(S_Ports.BVALID[i]),
        .AWREADY(S_Ports.AWREADY[i]),
        .WREADY(S_Ports.WREADY[i]),
        .R_id(R_id[i]),
        .AWADDR(S_Ports.AWADDR[i]),
        .WDATA(S_Ports.WDATA[i]),
        .AWPROT(S_Ports.AWPROT[i]),
        .WSTRB(S_Ports.WSTRB[i]),
        .AWVALID(S_Ports.AWVALID[i]),
        .WVALID(S_Ports.WVALID[i])
        );
    end
    endgenerate    
    
endmodule
