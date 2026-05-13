`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2018 03:19:10 PM
// Design Name: 
// Module Name: top
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


module top(
    input clk,reset,
    input [2:0]inputs,  //entradas
    output [2:0]outputs  //salidas
    );
    wire [31:0] instr;
    wire [2:0]dir;  //se debe a que la memoria de prueba tiene pocas instrucciones
    
    
    //Instancias de los modulos principales
    FsmMicro #(32,3,3) FsmMicroInst(
        .clk(clk),.reset(reset),
        .inputs(inputs),
        .instr(instr),
        .dir(dir),
        .outputs(outputs)
        );
        
        mem memInst(
        .dir(dir),       
        .instr(instr)      
        );
         
    
endmodule
