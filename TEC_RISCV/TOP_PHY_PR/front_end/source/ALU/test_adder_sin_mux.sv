`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2018 16:38:21
// Design Name: 
// Module Name: test_adders
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


module test_adder_sin_mux #(parameter n = 32) 
    (
    );
    reg [n-1:0] A,B;
    reg Cin;
    wire [n-1:0] S;
    wire Cout;
 
     CSK_sin_mux inst_CSK_sin_mux(
    .A(A),
    .B(-B),
    .Cin(Cin),
    .S(S),
    .Cout(Cout)
            );
            
    initial begin
        A = 'd3;    //Igual A y B
        B = 'd2;
        Cin = 0;
      #100 ;  
        


    
    /*integer i,j,k;
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
    */
    $finish;
    
    end
endmodule