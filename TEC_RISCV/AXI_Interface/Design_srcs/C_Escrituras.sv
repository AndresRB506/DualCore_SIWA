`timescale 1ns / 1ps


module C_Escrituras#(AW=32,DW=32,Masters=2,Slaves=2)(
    //Etapa de Push
    input ACLK,ARESETn,
    input [Masters-1:0][AW-1:0] M_AWADDR,
    input [Masters-1:0][DW-1:0] M_WDATA,
    input [Masters-1:0][2:0] M_AWPROT,
    input [Masters-1:0][(DW/8)-1:0] M_WSTRB,
    input [Masters-1:0]M_AWVALID,
    input [Masters-1:0]M_WVALID,
    output [Masters-1:0]M_AWREADY,
    output [Masters-1:0]M_WREADY,
    output [Slaves-1:0][AW+DW+3+(DW/8)+$clog2(Masters+1):0]F_Write,
    //Etapa de Direccionamiento////
    input [Slaves-1:0][1:0]S_BRESP,
    input [Slaves-1:0]S_BVALID,
    input [Slaves-1:0][$clog2(Masters+1)-1:0]R_id,
    input [Masters-1:0]M_BREADY,
    output [Masters-1:0]M_BVALID,
    output [Masters-1:0][1:0]M_BRESP,
    output [Slaves-1:0]S_BREADY
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
    logic [Masters-1:0][AW+3:0]FF_in_1;
    logic [Masters-1:0][AW+3:0]FF_out_1;
    logic [Masters-1:0]Reset;
    logic [Masters-1:0][DW+4:0]FF_in_2;
    logic [Masters-1:0][DW+4:0]FF_out_2;

    //Demux
    logic [Masters-1:0][AW+DW+3+(DW/8)+$clog2(Masters+1):0]Dem_in;
    wire [Slaves-1:0][AW+DW+2+(DW/8)+$clog2(Masters+1):0]Dem_outs;
    //Master id's
    logic [Masters-1:0][$clog2(Masters+1)-1:0] Master_id;
    //Push
    logic [Masters-1:0][Slaves-1:0]M_Push;
    logic [Masters-1:0][Slaves-1:0]W_Push;
//Etapa de direccionamiento///////////////////////////////////////////////////////////////////////////////////////
    logic [Slaves-1:0][2:0] Dem_dir_in;
    wire [Masters-1:0][1:0] Dem_dir_out;
    logic [Slaves-1:0][Masters-1:0] Dem_dir_Bvalid;
    logic [Slaves-1:0][Masters-1:0] Bvalid_or;
//Lógica de error ///////////////////////////////////////////////////////////////////////////////////////
    logic [Masters-1:0]SE;
 
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
    
    genvar i;
    genvar j;
    generate   
    for (i=0;i<Masters;i=i+1)begin :Write_push_logic
        //Definición de las compuertas OR de Push
        if (i==0)assign W_Push[0]=M_Push[0];
        else 
        assign W_Push[i]=M_Push[i]|W_Push[i-1];
        //Conexiones del Deco 
        assign A[i]=FF_out_1[i][AW+3:4];
        assign V[i]=FF_out_1[i][0]&FF_out_2[i][0];
        assign Reset[i]=Rst[i]|~ARESETn;
        //Asignación de señales de Ready en 1 
        assign M_AWREADY[i]=1;
        assign M_WREADY[i]=1;
        //Agrupamiento de entradas de los FlipFlops y Demux
        assign FF_in_1[i]={M_AWADDR[i],M_AWPROT[i],M_AWVALID[i]};
        assign FF_in_2[i]={M_WDATA[i],M_WSTRB[i],M_WVALID[i]};
        assign Dem_in[i]={Addr[i],FF_out_1[i][3:1],FF_out_2[i][DW+4:1],Master_id[i],Push[i]};
        //Aumento del indentificador del maestro
        assign Master_id[i]=i+1'b1;
        //Instancias de los Flip Flops 
        ffD #(AW+4) FF1(.clk(ACLK),.reset(Reset[i]),.En(M_AWVALID[i]),.D(FF_in_1[i]),.Q(FF_out_1[i]));
        ffD #(DW+5) FF2(.clk(ACLK),.reset(Reset[i]),.En(M_WVALID[i]),.D(FF_in_2[i]),.Q(FF_out_2[i]));     
        //Instancia de los demux
        DemPush #(AW+DW+4+(DW/8)+$clog2(Masters+1),Slaves) Dem(.selec(Sel[i]),.Data_in(Dem_in[i]),.Push(M_Push[i]),.Data_out(Dem_outs));
    end
    for (j=0;j<Slaves;j=j+1)begin 
        //Asignación de las señales a F_Write
        assign F_Write[j]={Dem_outs[j],W_Push[Masters-1][j]};
    end
    endgenerate
    
//Etapa de Direccionamiento/////////////////////////////////////////////////////////////////////////////////////////  
    generate
    for (j=0;j<Slaves;j=j+1)begin :Write_redirect
        //Agrupamiento de señales de entrada del Demux
        assign Dem_dir_in[j]={S_BRESP[j],S_BVALID[j]};
        if (j==0)assign Bvalid_or[0]=Dem_dir_Bvalid[0];
        else assign Bvalid_or[j]=Dem_dir_Bvalid[j]|Bvalid_or[j-1];
        //Instancias de Demux y Mux
        DemPush #(3,Masters) Dem_dir(.selec(R_id[j]),.Data_in(Dem_dir_in[j]),.Push(Dem_dir_Bvalid[j]),.Data_out(Dem_dir_out));
        Mux #(1,Masters+1) Mu (.selec(R_id[j]),.Data_in({M_BREADY,1'b0}),.Data_out(S_BREADY[j]));
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
    for (i=0;i<Masters;i=i+1)begin :W_deco_error
        Mux #(1,2) Mux_Err1(
        .selec(SE[i]),
        .Data_in({1'b1,Bvalid_or[Slaves-1][i]}),
        .Data_out(M_BVALID[i])
        );
        Mux #(2,2) Mux_Err2(
        .selec(SE[i]),
        .Data_in({2'b11,Dem_dir_out[i]}),
        .Data_out(M_BRESP[i])
        );
    end
    endgenerate

endmodule
