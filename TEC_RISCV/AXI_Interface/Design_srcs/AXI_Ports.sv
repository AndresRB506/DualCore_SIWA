`timescale 1ns / 1ps

interface Ports #(AW=32,DW=32,Dev=2);
        //canal de dirección de escritura
    logic [Dev-1:0]AWVALID;
    logic [Dev-1:0][AW-1:0]AWADDR;
    logic [Dev-1:0][2:0] AWPROT;
    logic [Dev-1:0]AWREADY;
        //canal de datos de escritura
    logic [Dev-1:0]WVALID;
    logic [Dev-1:0][DW-1:0]WDATA;
    logic [Dev-1:0][3:0]WSTRB;
    logic [Dev-1:0]WREADY;
        //canal de respuesta de escritura
    logic [Dev-1:0]BVALID;
    logic [Dev-1:0]BREADY;
    logic [Dev-1:0][1:0]BRESP;
        //canal de dirección de lectura
    logic [Dev-1:0]ARVALID;
    logic [Dev-1:0][AW-1:0]ARADDR;
    logic [Dev-1:0][2:0]ARPROT;
    logic [Dev-1:0]ARREADY;
        //canal de datos de lectura
    logic [Dev-1:0]RVALID;
    logic [Dev-1:0][DW-1:0]RDATA;
    logic [Dev-1:0][1:0]RRESP;
    logic [Dev-1:0]RREADY;    
        
    modport master(
    input AWVALID,AWADDR,AWPROT,RREADY,ARVALID,ARADDR,ARPROT,
            WVALID,WDATA,WSTRB,BREADY,
    output AWREADY,WREADY,BVALID,BRESP,ARREADY,RVALID,RDATA,RRESP 
    );

    modport slave(
    output AWVALID,AWADDR,AWPROT,RREADY,ARVALID,ARADDR,ARPROT,
                WVALID,WDATA,WSTRB,BREADY,
    input AWREADY,WREADY,BVALID,BRESP,ARREADY,RVALID,RDATA,RRESP     
    );    
    
endinterface

