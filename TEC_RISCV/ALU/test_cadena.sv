`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2018 17:40:46
// Design Name: 
// Module Name: test_cadena
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


module test_cadena(
);
reg [31:0] A,B;
reg Cin;
wire [31:0] Sum;
wire Cout;

Manchester_carry_chain inst_MCC(
.A(A),
.B(B),
.Cin(Cin),
.Sum(Sum),
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