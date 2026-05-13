`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////buffer triestado//////////////////////////////////////////////
module tristate_buffer #(parameter m=32)(input_x, enable, output_x);
input [m-1:0]input_x;
input enable;
output [m-1:0] output_x;

assign output_x = enable? input_x : 'bz;

endmodule
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////barrel_shifter///////////////////////////////////////////

module Barrel_Shifter #(parameter m=32)(A,B,Alu_cntrl,Y);
    input [m-1:0] A,B;
    input [1:0] Alu_cntrl;
    output [m-1:0] Y;
    
    reg bandera;
    reg aritmetic;
////////////////////////////////////////////////////////////
    reg [m-1:0] shifts_amount; 
    always @(*) begin
    if (Alu_cntrl==2'b00)
        begin
           shifts_amount=32'd32-{27'd0,B[4:0]};
           bandera=1'b1;
           aritmetic=1'b0;
        end
    else if (Alu_cntrl==2'b01)
        begin
          shifts_amount=B;
          bandera=1'b0;
          aritmetic=1'b0;
        end
    else if (Alu_cntrl==2'b10)
        begin
          shifts_amount=B;
          bandera=1'b0;
          aritmetic=1'b1;
        end
    else begin
         shifts_amount = 32'hXXXXXXXX;
        end
   end
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////
////mux decode
     reg [3:0]select;
    reg [7:0]select2;
    genvar v;
    genvar w;
    generate 
    for (v=0;v<4;v=v+1)begin
    always@(*)begin
        if (shifts_amount[1:0]==v)begin
            select[v]=1;
        end
        else begin
            select[v]=0;
        end
    end
    end
    for (w=0;w<8;w=w+1)begin
    always@(*)begin
        if (shifts_amount[4:2]==w)begin
            select2[w]=1;
        end
        else begin
            select2[w]=0;
        end
    end
    end
    endgenerate


/////////////////////////////////////////////////
/////mux de 5 a 1///////////////////
localparam comp_paso=3;
wire [comp_paso:0][m-1:0]x;
wire [comp_paso:0][m-1:0]a;
wire [m-1:0]salida_mux5;
genvar i;

    generate
    for (i=0;i<=comp_paso;i=i+1)begin
    /////instanciación del mux de 4 a 1
    tristate_buffer inst_buffer(
    .input_x(a[i]), 
    .enable(select[i]), 
    .output_x(x[i])
    );
    //////////////////////////////////
    if (i!=0)begin
    
        assign a[i]={A[i-1:0],A[m-1:i]};
        assign salida_mux5=x[i];

    end
    else begin
        assign a[i]= A[m-1:0];
        assign salida_mux5=x[i];
    end
    
    end
    endgenerate



///////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////mux de 8 a 1
localparam stages=28;
wire [stages:0][m-1:0]in_x; //////  8 entradas de 32 bits
wire [stages:0][m-1:0]out_x; 
wire [m-1:0] S; 
genvar j;
    generate
    for (j=0;j<=stages;j=j+4)begin
    /////instanciación del mux de 8 a 1
    tristate_buffer inst_buffer_s(
    .input_x(in_x[j/4]), 
    .enable(select2[j/4]), 
    .output_x(out_x[j/4])
    );
    //////////////////////////////////
    if (j!=0)begin
    
        assign in_x[j/4]={salida_mux5[j-1:0],salida_mux5[m-1:j]};
        assign S=out_x[j/4];
    end
    else begin
        assign in_x[j/4]= salida_mux5[m-1:0];
        assign S=out_x[j/4];
    end
    
    end
    endgenerate

/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
///////////////////////Máscara para lógica right--left//////////////////////////////////////////

    wire [m-1:0]Sal1;
    wire [m-1:0] Sal2;
    reg [m-1:0]control;
    genvar l;
    generate 
    for (l=0;l<m;l=l+1)begin
    always@(*)begin
        if (bandera)begin
            if (l<B[4:0])control[l]=1'b0;
            else control[l]=1'b1;
        end
        else begin
            if (l>=32-B[4:0])control[l]=1'b0;
            else control[l]=1'b1;
        end
    end
    assign Sal1[l]=S[l] & control[l];
    assign Sal2[l]=A[m-1] & aritmetic & ~control[l];
    assign Y[l]= Sal1[l]|Sal2[l];
    end
    endgenerate
    
    
    
 

   
endmodule
