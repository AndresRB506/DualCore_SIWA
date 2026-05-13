`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2017 06:37:33 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] Alu_Cntrl,
    output reg Zero, 
    output reg oVerflow,
    output reg Negative,
    output reg Carry,
    output reg [31:0] OUT
    );
    
    reg [32:0] final_suma;
    
    function [32:0] sum (input [31:0] A, input [31:0] B);
        begin
            sum = A + B;                
        end
    endfunction
        
    function [31:0] shift (input signed [31:0] A, input [31:0] B, input [1:0] cod);
    begin
        case(cod)
        2'b00: begin
                shift = $signed(A) << B;
               end
        2'b01: begin
                shift = $signed(A) >> B;
               end
        2'b10: begin
                shift = $signed(A) >>> B;
               end
        default: begin
                 shift = 32'hXXXXXXXX;
                 end
        endcase        
    end
    endfunction
        
    function compare (input [31:0] A, input [31:0] B, input [2:0] cod);
    begin
        case (cod)
        3'b000: begin       //EQU
                compare = ($signed(A) == $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b001: begin       //LESS_THAN
                compare = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b010: begin       //LESS_THAN_UNSIGNED
                compare = (A < B) ? 1'b1 : 1'b0;
                end
        3'b011: begin       //GREATER_THAN
                compare = ($signed(A) > $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b100: begin       //GREATER_THAN_UNSIGNED
                compare = (A > B) ? 1'b1 : 1'b0;
                end
        default: begin
                 compare = 1'bX;
                 end
        endcase
    end
    endfunction
        
    function [31:0] logical (input signed [31:0] A, input signed [31:0] B, input [1:0] cod);
    begin
        case (cod)
        2'b00: begin        //BITWISE_XOR
                logical = $signed(A) ^ $signed(B);
               end
        2'b01: begin        //BITWISE_AND
                logical = $signed(A) & $signed(B);
               end
        2'b11: begin        //BITWISE_OR
                logical = $signed(A) | $signed(B);
               end
        default: begin
                 logical = 32'hXXXXXXXX;
                 end
        endcase
    end
    endfunction 
     
    always @* begin
        case(Alu_Cntrl)
            4'b0000: begin //EQU
                        OUT = 32'd0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);                        
                     end
            4'b0001: begin //LESS_THAN
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0010: begin //LESS_THAN_UNSIGNED
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0011: begin //GREATER_THAN
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0100: begin //GREATER_THAN_UNSIGNED
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0101, 4'b0110: begin //ADD
                        final_suma = sum(A,B);
                        OUT = final_suma[31:0];                        
                        Zero = 1'b0;
                        oVerflow = ((1'b0~^A[31]~^B[31]) & (A[31]^OUT[31])) ? 1'b1 : 1'b0;
                        Carry = final_suma[32] ? 1'b1 : 1'b0;
                     end
            4'b0111: begin //SUB_UNSIGNED
                        final_suma = sum(A,-B);
                        OUT = final_suma[31:0];
                        Zero = 1'b0;
                        oVerflow = ((1'b1~^A[31]~^B[31]) & (A[31]^OUT[31])) ? 1'b1 : 1'b0;
                        Carry = final_suma[32] ? 1'b1 : 1'b0;
                     end
            4'b1000: begin //SHIFT_LEFT_LOGICAL
                        OUT = shift(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b1001: begin //SHIFT_RIGTH_LOGICAL
                        OUT = shift(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end   
            4'b1010: begin //SHIFT_RIGTH_ARITMETIC
                        OUT = shift(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0; 
                        Carry = 1'b0;                                       
                     end
            4'b1011: begin //BITWISE_OR
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0; 
                        Carry = 1'b0;      
                     end
            4'b1100: begin //BITWISE_XOR
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;                                                 
                     end
            4'b1101: begin //BITWISE_AND
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;                                                         
                     end                                                          
            default: begin //default
                        OUT = 32'dX;        
                        Zero = 1'bX; 
                        oVerflow = 1'bX; 
                        Carry = 1'bX;       
                     end        
            endcase
            Negative = OUT[31];        
    end
    
endmodule
