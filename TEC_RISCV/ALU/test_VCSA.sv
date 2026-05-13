`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2018 10:22:31
// Design Name: 
// Module Name: test_VCSA
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


module test_VCSA#(parameter n = 32) 
    (
    );
    reg [n-1:0] A,B;
    reg Cin;
    wire [n-1:0] S;
    wire Cout;
 
   VCSA inst_VCSA(
    .A(A),
    .B(B),
    .Cin(Cin),
    .S(S),
    .Cout(Cout)
            );
    integer i,j,k;
    initial begin
    Cin=0;
    for (i=0; i < 1024;i=i+1) begin  
       A=i;              
       for (j=0; j < 1024; j = j+1) begin
             
             B= j;
                
            for(k=0; k<2; k= k+1)begin 
              #10
              Cin=~Cin;
            end
       end
    end
    #40
    $finish;
    
    end
endmodule
