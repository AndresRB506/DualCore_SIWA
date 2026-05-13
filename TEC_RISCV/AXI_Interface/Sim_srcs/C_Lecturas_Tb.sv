`timescale 1ns / 1ps

`define ADW 32 
`define Masters 2
`define Slaves 2 

module C_Lecturas_TB;

//#########################################################
//               UUT INTERFACE DEFINITION
//#########################################################
    //Etapa de Push
    reg ACLK,ARESETn;
    reg [`Masters-1:0][`ADW-1:0] M_ARADDR;
    reg [`Masters-1:0][2:0] M_ARPROT;
    reg [`Masters-1:0]M_ARVALID;
    wire [`Masters-1:0]M_ARREADY;
    wire [`Slaves-1:0][`ADW+3+$clog2(`Masters+1):0]F_Read;
    //Etapa de Direccionamiento////
    reg [`Slaves-1:0][`ADW-1:0]S_RDATA;
    reg [`Slaves-1:0][1:0]S_RRESP;
    reg [`Slaves-1:0]S_RVALID;
    reg [`Slaves-1:0][$clog2(`Masters+1)-1:0]D_id;
    reg [`Masters-1:0]M_RREADY;
    wire [`Masters-1:0][`ADW-1:0]M_RDATA;
    wire [`Masters-1:0]M_RVALID;
    wire [`Masters-1:0][1:0]M_RRESP;
    wire [`Slaves-1:0]S_RREADY;
  

//#########################################################
//                   UUT DEFINITION
//#########################################################
C_Lecturas #(`ADW,`Masters,`Slaves) C_L(
    //Etapa de Push
    .ACLK(ACLK),.ARESETn(ARESETn),
    .M_ARADDR(M_ARADDR),
    .M_ARPROT(M_ARPROT),
    .M_ARVALID(M_ARVALID),
    .M_ARREADY(M_ARREADY),
    .F_Read(F_Read),
    //Etapa de Direccionamiento////
    .S_RDATA(S_RDATA),
    .S_RRESP(S_RRESP),
    .S_RVALID(S_RVALID),
    .D_id(D_id),
    .M_RREADY(M_RREADY),
    .M_RDATA(M_RDATA),
    .M_RVALID(M_RVALID),
    .M_RRESP(M_RRESP),
    .S_RREADY(S_RREADY)
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
    M_ARADDR[0]=32'h400000F5;
    M_ARPROT[0]=3'b010;
    M_ARVALID[0]=0;
    M_ARADDR[1]=32'h40001234;
    M_ARPROT[1]=3'b101;
    M_ARVALID[1]=0;
#10
    M_ARVALID[0]=1;
#10
    M_ARVALID[0]=0;
    M_ARVALID[1]=1;
                        //{M_ARADDR[i],M_ARPROT[i],Master_id[i],Push[i]}
    #2  if (F_Read[0]=={32'h400000F5,3'b010,2'b01,1'b1})$display("Pass first test");
        else $display("Fail first test");
#8
    M_ARVALID[1]=0;
    #2  if (F_Read[1]=={32'h40001234,3'b101,2'b10,1'b1})$display("Pass second test");
        else $display("Fail second test");    
#18
    M_ARVALID=2'b11;
#10
    M_ARVALID=2'b00;
    #2  if (F_Read[1]=={32'h40001234,3'b101,2'b10,1'b1}&&F_Read[0]=={32'h400000F5,3'b010,2'b01,1'b1})$display("Pass third test");
        else $display("Fail third test");
#18 
    M_ARADDR[1]=32'h400000F5;
    M_ARVALID=2'b11;
#10
    M_ARVALID=2'b00;
    #2  if ( F_Read[0]=={32'h400000F5,3'b010,2'b01,1'b1})$display("Pass fourth test");
            else $display("Fail fourth test");
#10
    if (F_Read[0]=={32'h400000F5,3'b101,2'b10,1'b1})$display("Pass fifth test");
            else $display("Fail fifth test");
#48
//Test de Direccionamiento de respuesta///////////////////////////////////////////////////////////
    S_RDATA=0;
    S_RRESP=0;
    S_RVALID=0;
    D_id=0;
    M_RREADY=2'b11;
#10
    S_RDATA[0]=32'h12345678;
    S_RRESP[0]=2'b10;
    D_id[0]=2'b01;
    S_RDATA[1]=32'h87654321;
    S_RRESP[1]=2'b01;
    D_id[1]=2'b10;  
    #2 if (M_RDATA[0]==32'h12345678 && M_RRESP[0]==2'b10)$display("Pass Dir 1 test");
            else $display("Fail Dir 1 test"); 
     if (M_RDATA[1]==32'h87654321 && M_RRESP[0]==2'b10)$display("Pass Dir 2 test");
            else $display("Fail Dir 2 test");

#30 $finish;

end

always #5 ACLK=~ACLK;

endmodule
