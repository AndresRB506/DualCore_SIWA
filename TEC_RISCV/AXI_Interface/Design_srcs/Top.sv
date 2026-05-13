`timescale 1ns / 1ps
//`include "AXI_Ports.sv"

module Top(
    input ACLK,
    input ARESETn
    );
localparam AW=32;
localparam DW=32;
localparam Masters=2;
localparam Slaves=2;
    
//#########################################################
//          Definición de conexiones
//#########################################################    
    Ports #(AW,DW,Masters)M_Ports();
    Ports #(AW,DW,Slaves)S_Ports();
    
//#########################################################
//          Definición de las instancias
//#########################################################
    AXI_Int #(AW,DW,Masters,Slaves) AXI_BUS(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .M_Ports(M_Ports),
    .S_Ports(S_Ports)
    );
     
    AXI_Master Master_0(
    .aclk(ACLK),
    .aresetn(ARESETn),
    .m_axi_awaddr(M_Ports.AWADDR[0]),
    .m_axi_awprot(M_Ports.AWPROT[0]),
    .m_axi_awvalid(M_Ports.AWVALID[0]),
    .m_axi_awready(M_Ports.AWREADY[0]),
    .m_axi_wdata(M_Ports.WDATA[0]),
    .m_axi_wstrb(M_Ports.WSTRB[0]),
    .m_axi_wvalid(M_Ports.WVALID[0]),
    .m_axi_wready(M_Ports.WREADY[0]),
    .m_axi_bresp(M_Ports.BRESP[0]),
    .m_axi_bvalid(M_Ports.BVALID[0]),
    .m_axi_bready(M_Ports.BREADY[0]),
    .m_axi_araddr(M_Ports.ARADDR[0]),
    .m_axi_arprot(M_Ports.ARPROT[0]),
    .m_axi_arvalid(M_Ports.ARVALID[0]),
    .m_axi_arready(M_Ports.ARREADY[0]),
    .m_axi_rdata(M_Ports.RDATA[0]),
    .m_axi_rresp(M_Ports.RRESP[0]),
    .m_axi_rvalid(M_Ports.RVALID[0]),
    .m_axi_rready(M_Ports.RREADY[0])
    );
    
    AXI_Master_1 Master_1(
    .aclk(ACLK),
    .aresetn(ARESETn),
    .m_axi_awaddr(M_Ports.AWADDR[1]),
    .m_axi_awprot(M_Ports.AWPROT[1]),
    .m_axi_awvalid(M_Ports.AWVALID[1]),
    .m_axi_awready(M_Ports.AWREADY[1]),
    .m_axi_wdata(M_Ports.WDATA[1]),
    .m_axi_wstrb(M_Ports.WSTRB[1]),
    .m_axi_wvalid(M_Ports.WVALID[1]),
    .m_axi_wready(M_Ports.WREADY[1]),
    .m_axi_bresp(M_Ports.BRESP[1]),
    .m_axi_bvalid(M_Ports.BVALID[1]),
    .m_axi_bready(M_Ports.BREADY[1]),
    .m_axi_araddr(M_Ports.ARADDR[1]),
    .m_axi_arprot(M_Ports.ARPROT[1]),
    .m_axi_arvalid(M_Ports.ARVALID[1]),
    .m_axi_arready(M_Ports.ARREADY[1]),
    .m_axi_rdata(M_Ports.RDATA[1]),
    .m_axi_rresp(M_Ports.RRESP[1]),
    .m_axi_rvalid(M_Ports.RVALID[1]),
    .m_axi_rready(M_Ports.RREADY[1])
    );   
    
    AXI_Slave Slave_0(
    .aclk(ACLK),
    .aresetn(ARESETn),
    .s_axi_awaddr(S_Ports.AWADDR[0]),
    .s_axi_awprot(S_Ports.AWPROT[0]),
    .s_axi_awvalid(S_Ports.AWVALID[0]),
    .s_axi_awready(S_Ports.AWREADY[0]),
    .s_axi_wdata(S_Ports.WDATA[0]),
    .s_axi_wstrb(S_Ports.WSTRB[0]),
    .s_axi_wvalid(S_Ports.WVALID[0]),
    .s_axi_wready(S_Ports.WREADY[0]),
    .s_axi_bresp(S_Ports.BRESP[0]),
    .s_axi_bvalid(S_Ports.BVALID[0]),
    .s_axi_bready(S_Ports.BREADY[0]),
    .s_axi_araddr(S_Ports.ARADDR[0]),
    .s_axi_arprot(S_Ports.ARPROT[0]),
    .s_axi_arvalid(S_Ports.ARVALID[0]),
    .s_axi_arready(S_Ports.ARREADY[0]),
    .s_axi_rdata(S_Ports.RDATA[0]),
    .s_axi_rresp(S_Ports.RRESP[0]),
    .s_axi_rvalid(S_Ports.RVALID[0]),
    .s_axi_rready(S_Ports.RREADY[0])
    );
    
    AXI_Slave_1 Slave_1(
    .aclk(ACLK),
    .aresetn(ARESETn),
    .s_axi_awaddr(S_Ports.AWADDR[1]),
    .s_axi_awprot(S_Ports.AWPROT[1]),
    .s_axi_awvalid(S_Ports.AWVALID[1]),
    .s_axi_awready(S_Ports.AWREADY[1]),
    .s_axi_wdata(S_Ports.WDATA[1]),
    .s_axi_wstrb(S_Ports.WSTRB[1]),
    .s_axi_wvalid(S_Ports.WVALID[1]),
    .s_axi_wready(S_Ports.WREADY[1]),
    .s_axi_bresp(S_Ports.BRESP[1]),
    .s_axi_bvalid(S_Ports.BVALID[1]),
    .s_axi_bready(S_Ports.BREADY[1]),
    .s_axi_araddr(S_Ports.ARADDR[1]),
    .s_axi_arprot(S_Ports.ARPROT[1]),
    .s_axi_arvalid(S_Ports.ARVALID[1]),
    .s_axi_arready(S_Ports.ARREADY[1]),
    .s_axi_rdata(S_Ports.RDATA[1]),
    .s_axi_rresp(S_Ports.RRESP[1]),
    .s_axi_rvalid(S_Ports.RVALID[1]),
    .s_axi_rready(S_Ports.RREADY[1])
    );
    
        
endmodule
