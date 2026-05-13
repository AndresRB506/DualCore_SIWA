`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2018 15:47:59
// Design Name: 
// Module Name: carry_skip_adder
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


module carry_skip_adder#(m=32)(A,B,Cin,Cout,S);
    input [m-1:0] A,B;
    input Cin;
    output  [m-1:0] S;
    output Cout;
    localparam n=4;
    
    wire [(m/4)-1:0][n-1:0] a,b;
    wire [(m/4)-1:0]cin;
    wire  [(m/4)-1:0][n-1:0] s;
    wire [(m/4)-1:0]cout;
    
    
    genvar i;
    generate
    for (i=0;i<m/4;i=i+1)begin
        CSA4 csa_inst(
        .a(a[i]),
        .b(b[i]),
        .cin(cin[i]),
        .s(s[i]),
        .cout(cout[i])
        );
        if (i!=0)begin
            assign a[i]=A[(n*(i+1))-1:(n*i)];
            assign b[i]=B[(n*(i+1))-1:(n*i)];
            assign cin[i]=cout[i-1];
        end
        else begin
            assign a[i]=A[n-1:0];
            assign b[i]=B[n-1:0];
            assign cin[i]=Cin;
        end
        if (i==((m/4)-1))assign Cout=cout[i];
        assign S[(n*(i+1))-1:(n*i)]=s[i];
    end
    endgenerate
    
endmodule
