`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2018 02:19:48 PM
// Design Name: 
// Module Name: topTb
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


module topTb(

    );
    
    reg clk,reset;
    reg [2:0]inputs;
    wire [2:0]outputs;
    
    top topInst(
    .clk(clk),.reset(reset),
    .inputs(inputs),
    .outputs(outputs)
    );
    
    initial 
    begin
    clk=0;
    reset=1;
    inputs=0;
    #20
    reset=0;
    #500
    $finish;
   
    end
    
    
    always
    begin
    #5 clk=~clk;
    end
    
    
    
endmodule
