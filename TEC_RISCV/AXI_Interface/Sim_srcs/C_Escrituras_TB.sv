`timescale 1ns / 1ps

`define ADW 32 
`define Masters 2
`define Slaves 2 

module C_Escrituras_TB;

//#########################################################
//               UUT INTERFACE DEFINITION
//#########################################################
    //Etapa de Push   
    reg ACLK,ARESETn;
    reg [`Masters-1:0][`ADW-1:0] M_AWADDR;
    reg [`Masters-1:0][`ADW-1:0] M_WDATA;
    reg [`Masters-1:0][2:0] M_AWPROT;
    reg [`Masters-1:0][(`ADW/8)-1:0] M_WSTRB;
    reg [`Masters-1:0]M_AWVALID;
    reg [`Masters-1:0]M_WVALID;
    wire [`Masters-1:0]M_AWREADY;
    wire [`Masters-1:0]M_WREADY;
    wire [`Slaves-1:0][`ADW*2+3+(`ADW/8)+$clog2(`Masters+1):0]F_Write;
    //Etapa de Direccionamiento////
    reg [`Slaves-1:0][1:0]S_BRESP;
    reg [`Slaves-1:0]S_BVALID;
    reg [`Slaves-1:0][$clog2(`Masters+1)-1:0]R_id;
    reg [`Masters-1:0]M_BREADY;
    wire [`Masters-1:0]M_BVALID;
    wire [`Masters-1:0][1:0]M_BRESP;
    wire [`Slaves-1:0]S_BREADY;
  

//#########################################################
//                   UUT DEFINITION
//#########################################################
C_Escrituras #(`ADW,`Masters,`Slaves) C_E(
    //Etapa de Push
    .ACLK(ACLK),.ARESETn(ARESETn),
    .M_AWADDR(M_AWADDR),
    .M_WDATA(M_WDATA),
    .M_AWPROT(M_AWPROT),
    .M_WSTRB(M_WSTRB),
    .M_AWVALID(M_AWVALID),
    .M_WVALID(M_WVALID),
    .M_AWREADY(M_AWREADY),
    .M_WREADY(M_WREADY),
    .F_Write(F_Write),
    //Etapa de Direccionamiento////
    .S_BRESP(S_BRESP),
    .S_BVALID(S_BVALID),
    .R_id(R_id),
    .M_BREADY(M_BREADY),
    .M_BVALID(M_BVALID),
    .M_BRESP(M_BRESP),
    .S_BREADY(S_BREADY)
    );

//#########################################################
//                   INITIAL
//#########################################################

initial begin
    ACLK=0;
    ARESETn=0;
#23
//Test de solicitudes de Push///////////////////////////////////////////////////////////
    ARESETn=1;
    M_AWADDR[0]=32'h400000F5;
    M_WDATA[0]=32'h12345678;
    M_AWPROT[0]=3'b010;
    M_WSTRB[0]=4'b1010;
    M_AWVALID[0]=0;
    M_WVALID[0]=0;
    M_AWADDR[1]=32'h40001234;
    M_WDATA[1]=32'h87654321;
    M_AWPROT[1]=3'b101;
    M_WSTRB[1]=4'b0101;
    M_AWVALID[1]=0;
    M_WVALID[1]=0;
#10
    M_AWVALID[0]=1;
    M_WVALID[0]=1;
#10
    M_AWVALID[0]=0;
    M_WVALID[0]=0;
    M_AWVALID[1]=1;
    M_WVALID[1]=1;
                        //{M_ARADDR[i],M_ARPROT[i], M_WDATA[i],M_WSTRB[i],Master_id[i],Push[i]}
    #2  if (F_Write[0]=={32'h400000F5,3'b010,32'h12345678,4'b1010,2'b01,1'b1})$display("Pass first test");
        else $display("Fail first test");
#8
    M_AWVALID[1]=0;
    M_WVALID[1]=0;
    #2  if (F_Write[1]=={32'h40001234,3'b101,32'h87654321,4'b0101,2'b10,1'b1})$display("Pass second test");
        else $display("Fail second test");    
#18
    M_AWVALID=2'b11;
    M_WVALID=2'b11;
#10
    M_AWVALID=2'b00;
    M_WVALID=2'b00;
    #2  if (F_Write[1]=={32'h40001234,3'b101,32'h87654321,4'b0101,2'b10,1'b1}&&F_Write[0]=={32'h400000F5,3'b010,32'h12345678,4'b1010,2'b01,1'b1})$display("Pass third test");
        else $display("Fail third test");
#18 
    M_AWADDR[1]=32'h400000F5;
    M_AWVALID=2'b11;
    M_WVALID=2'b11;
#10
    M_AWVALID=2'b00;
    M_WVALID=2'b00;
    #2  if ( F_Write[0]=={32'h400000F5,3'b010,32'h12345678,4'b1010,2'b01,1'b1})$display("Pass fourth test");
            else $display("Fail fourth test");
#10
    if (F_Write[0]=={32'h400000F5,3'b101,32'h87654321,4'b0101,2'b10,1'b1})$display("Pass fifth test");
            else $display("Fail fifth test");
#48
//Test de Direccionamiento de respuesta///////////////////////////////////////////////////////////
    S_BRESP=0;
    S_BVALID=0;
    R_id=0;
    M_BREADY=2'b11;
#10
    S_BRESP[0]=2'b10;
    R_id[0]=2'b01;
    S_BRESP[1]=2'b01;
    R_id[1]=2'b10;
    S_BVALID=1;  
    #2 if (M_BVALID[0]==1 && M_BRESP[0]==2'b10)$display("Pass Dir 1 test");
            else $display("Fail Dir 1 test"); 
     if (M_BVALID[1]==0 && M_BRESP[0]==2'b10)$display("Pass Dir 2 test");
            else $display("Fail Dir 2 test");

#30 $finish;

end

always #5 ACLK=~ACLK;

endmodule
