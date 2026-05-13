`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2018 18:15:52
// Design Name: 
// Module Name: VCSA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "CSA4.sv"

module VCSA#(parameter m=32)(A,B,Cin,Cout,S);
    input [m-1:0] A,B;
    input Cin;
    output  [m-1:0] S;
    output Cout;
    
    localparam position=$clog2(m); 
    wire [position:0]C_cout;
    
    genvar i;
//    localparam transition=i/2;
//    localparam position_i=$clog2(i);
    genvar j;
    generate
    for (i=1;i<=m;i=i<<1)begin
        if (i==1)begin
            wire a;
            wire b;
            wire cin;
            wire cout;
            wire s;
            csk_bloque #(1) csk_bloque_inst(
            .a(a),
            .b(b),
            .cin(cin),
            .s(s),
            .cout(cout)
            );
            assign a=A[0];
            assign b=B[0];
            assign S[0]=s;
            assign cin=Cin;
            assign C_cout[0]=cout;
        end
        else begin
            wire [(i/2)-1:0]a;
            wire [(i/2)-1:0]b;
            wire cin;
            wire cout;
            wire [(i/2)-1:0]s;
            csk_bloque #(i/2) csk_bloque_inst(
                .a(a),
                .b(b),
                .cin(C_cout[$clog2(i)-1]),
                .s(s),
                .cout(cout)
                );
            if (i==2)begin
                assign a=A[1];
                assign b=B[1];
                assign S[1]=s;
                assign C_cout[1]=cout;
            end
            else begin
                assign a=A[(i)-1:(i/2)];
                assign b=B[(i)-1:(i/2)];
                assign S[(i)-1:(i/2)]=s;
                assign C_cout[$clog2(i)]=cout;
            end
        end
    end
    assign Cout=C_cout[$clog2(i)];
    endgenerate
    
endmodule
