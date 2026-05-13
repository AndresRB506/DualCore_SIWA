`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2018 03:27:08 PM
// Design Name: 
// Module Name: branchTL
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


module branchTL #(parameter i=3, parameter s=3)(
    input [(i-1):0]inputs,       //entradas
    input [3:0] BranchI,			//Branch instruction proveniente de la memoria
    input [(s-1):0]BranchT,			//Branch Target proveniente de la memoria
    output reg [(s-1):0] bruPC 			//Target modificado
    );
    
    always@*
    begin
    case (BranchI[3:2])
            2'b00: bruPC = BranchT;  //Branch on condition         // 
                                                                    // } Acá se definen lógicas de branch según condiciones de entrada
                                                                    // } si estas no se dan, entonces se deja pasar el Branch target original
            2'b01: bruPC = BranchT;                                 //Branch on not condition    // |
    
            2'b10:
                //Acá se definen 4 branch según 4 posibles entradas, en este caso las direcciones de branch son adyacentes
                //como ejemplo se definen las entradas igual a 0,1,2,3 pero esto puede variar, lo que no varía es la
                //adyacencia de estos estados al estado en el que se está, siendo este el branch target
                if(inputs==0) bruPC = BranchT + 1; 
                else if(inputs==1)bruPC = BranchT + 2;        
                else if(inputs==2)bruPC = BranchT+ 3;
                else if(inputs==3)bruPC = BranchT;
            default:bruPC = BranchT;
                
    endcase            
    end
    
    
endmodule
