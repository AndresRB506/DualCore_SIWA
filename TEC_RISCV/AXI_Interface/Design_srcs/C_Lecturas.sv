`timescale 1ns / 1ps


module C_Lecturas#(AW=32,DW=32,Masters=2,Slaves=2)(
    //Etapa de Push
    input ACLK,ARESETn,
    input [Masters-1:0][AW-1:0] M_ARADDR,
    input [Masters-1:0][2:0] M_ARPROT,
    input [Masters-1:0]M_ARVALID,
    output [Masters-1:0]M_ARREADY,
    output [Slaves-1:0][AW+3+$clog2(Masters+1):0]F_Read,
    //Etapa de Direccionamiento////
    input [Slaves-1:0][DW-1:0]S_RDATA,
    input [Slaves-1:0][1:0]S_RRESP,
    input [Slaves-1:0]S_RVALID,
    input [Slaves-1:0][$clog2(Masters+1)-1:0]D_id,
    input [Masters-1:0]M_RREADY,
    output [Masters-1:0][DW-1:0]M_RDATA,
    output [Masters-1:0]M_RVALID,
    output [Masters-1:0][1:0]M_RRESP,
    output [Slaves-1:0]S_RREADY
    );

//#########################################################
//          Definición de conexiones
//#########################################################
//Etapa de Push
    //Deco Push////////////////////////////////////////////////////////////////////////////////////////////////////
    logic [Masters-1:0][AW-1:0]A;
    logic [Masters-1:0]V;
    logic [Masters-1:0][$clog2(Slaves+1)-1:0]Sel;
    logic [Masters-1:0]Rst;
    logic [Masters-1:0]Push;
    logic [Masters-1:0][AW-1:0]Addr;
    //Flip Flops
    logic [Masters-1:0][AW+3:0]FF_in;
    logic [Masters-1:0][AW+3:0]FF_out;
    logic [Masters-1:0]Reset;
    //Demux
    logic [Masters-1:0][AW+3+$clog2(Masters+1):0]Dem_in;
    wire [Slaves-1:0][AW+2+$clog2(Masters+1):0]Dem_outs;
    //Master id's
    logic [Masters-1:0][$clog2(Masters+1)-1:0] Master_id;
    //Push
    logic [Masters-1:0][Slaves-1:0]M_Push;
    logic [Masters-1:0][Slaves-1:0]R_Push;
//Etapa de direccionamiento///////////////////////////////////////////////////////////////////////////////////////
    logic [Slaves-1:0][AW+2:0] Dem_dir_in;
    wire [Masters-1:0][AW+1:0] Dem_dir_out;
    logic [Slaves-1:0][Masters-1:0] Dem_dir_Rvalid;
    logic [Slaves-1:0][Masters-1:0] Rvalid_or;
//Lógica de error ///////////////////////////////////////////////////////////////////////////////////////
    logic [Masters-1:0] SE;
 
//#########################################################
//          Definición de las instancias
//#########################################################
//Etapa de Push///////////////////////////////////////////////////////////////////////////////////////////////////    
    Deco_Push#(AW,Masters,Slaves) D_Push(
    .A(A),
    .V(V),
    .Sel(Sel),
    .Rst(Rst),
    .Push(Push),
    .Addr(Addr)
    );
    //concatenar este address en ves del otro
    genvar i;
    genvar j;
    generate   
    for (i=0;i<Masters;i=i+1)begin :Read_push_logic
        if (i==0)assign R_Push[0]=M_Push[0];
        else assign R_Push[i]=M_Push[i]|R_Push[i-1];
        assign A[i]=FF_out[i][AW+3:4];
        assign V[i]=FF_out[i][0];
        assign Reset[i]=Rst[i]|~ARESETn;
         
        
        assign M_ARREADY[i]=1;
        assign FF_in[i]={M_ARADDR[i],M_ARPROT[i],M_ARVALID[i]};
        assign Master_id[i]=i+1'b1;
        assign Dem_in[i]={Addr[i],FF_out[i][3:1],Master_id[i],Push[i]};
         
        ffD #(AW+4) FF(.clk(ACLK),.reset(Reset[i]),.En(M_ARVALID[i]),.D(FF_in[i]),.Q(FF_out[i]));    
        DemPush #(AW+4+$clog2(Masters+1),Slaves) Dem(.selec(Sel[i]),.Data_in(Dem_in[i]),.Push(M_Push[i]),.Data_out(Dem_outs));
    end
    for (j=0;j<Slaves;j=j+1)begin 
        assign F_Read[j]={Dem_outs[j],R_Push[Masters-1][j]};
    end
    endgenerate
    
//Etapa de Direccionamiento/////////////////////////////////////////////////////////////////////////////////////////  
    generate
    for (j=0;j<Slaves;j=j+1)begin :Read_redirect
        assign Dem_dir_in[j]={S_RDATA[j],S_RRESP[j],S_RVALID[j]};
        if (j==0)assign Rvalid_or[0]=Dem_dir_Rvalid[0];
        else assign Rvalid_or[j]=Dem_dir_Rvalid[j]|Rvalid_or[j-1];
        DemPush #(DW+3,Masters) Dem_dir(.selec(D_id[j]),.Data_in(Dem_dir_in[j]),.Push(Dem_dir_Rvalid[j]),.Data_out(Dem_dir_out));
        Mux #(1,Masters+1) Mu (.selec(D_id[j]),.Data_in({M_RREADY,1'b0}),.Data_out(S_RREADY[j]));
    end 
    
    for (i=0;i<Masters;i=i+1)begin
        assign M_RDATA[i]=Dem_dir_out[i][DW+1:2];    
    end
    endgenerate 
    
// Lógica de error /////////////////////////////////////////////////////////////////////////////////////////////////
    Deco_error #(Masters,Slaves) Deco_Err(
    .V(V),
    .S(Sel),
    .R(Rst),
    .SE(SE)
    );
    generate
    for (i=0;i<Masters;i=i+1)begin :R_deco_error
        Mux #(1,2) Mux_Err1(
        .selec(SE[i]),
        .Data_in({1'b1,Rvalid_or[Slaves-1][i]}),
        .Data_out(M_RVALID[i])
        );
        Mux #(2,2) Mux_Err2(
        .selec(SE[i]),
        .Data_in({2'b11,Dem_dir_out[i][1:0]}),
        .Data_out(M_RRESP[i])
        );
    end
    endgenerate

endmodule
