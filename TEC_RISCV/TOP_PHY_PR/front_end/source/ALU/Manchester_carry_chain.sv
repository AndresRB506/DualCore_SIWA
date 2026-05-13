`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2018 14:34:39
// Design Name: 
// Module Name: Manchester_carry_chain
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


module Manchester_carry_chain (a,b,cin,cout,sum ) ;
    input [3:0] a,b;
    input cin;
    output [3:0] sum;
    output cout;

    assign {cout,sum}=a+b+cin;
endmodule

module cadena (a,b,cin,sum,cout);
    
    input [3:0] a,b;
    input cin;
    output [3:0] sum;
    output cout;
    
    wire [3:1] carry;
    
    Manchester_carry_chain a0(a[0],cin,sum[0],carry[1]);
    Manchester_carry_chain a1(a[1],cin,sum[1],carry[2]);
    Manchester_carry_chain a2(a[2],cin,sum[2],carry[3]);
    Manchester_carry_chain a3(a[3],cin,sum[3],cout);    
    
endmodule




//    parameter n=4;
//    input [3:0] a,b;
//    input cin;
//    output [3:0] s;
//    output cout;

//    wire [3:0] p= a ^ b;  //propagate
//    wire [3:0] g= a & b;  //generate
//    wire [4:0] c= {g | p & c[n-1:0],cin};  
//    assign s = p ^ c[3:0];  //suma
    