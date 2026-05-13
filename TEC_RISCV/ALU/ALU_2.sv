//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2018 10:40:08
// Design Name: 
// Module Name: ALU_2
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
`include "../ALU/ALU_Library.sv"

module ALU_2 #(bits_size=32, cntrl_size=4)(
    input [bits_size-1:0] A,
    input [bits_size-1:0] B,
    input [cntrl_size-1:0] Alu_Cntrl,
    input  Cin,
    output reg Zero, 
    output reg oVerflow,
    output reg Negative,
    output reg Carry,
    output reg [bits_size-1:0] OUT
    );
   reg [bits_size-1:0] final_suma;
   reg [bits_size-1:0] complemento_a_2;
   reg cout;
   reg [bits_size-1:0] final_shift;
   reg [1:0] shift_cod;
   
    //////instancia del carry skip adder//////
    
    CSK_sin_mux inst_CSK(
   .A(A),
   .B(complemento_a_2),
   .Cin(Cin),
   .S(final_suma),
   .Cout(cout) 
           );

    Barrel_Shifter inst_BS(
    .A(A),
    .B(B),
    .Alu_cntrl(shift_cod),
    .Y(final_shift)
      );
        
    function compare (input [bits_size-1:0] A, input [bits_size-1:0] B, input [2:0] cod);
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
        
    function [bits_size-1:0] logical (input signed [bits_size-1:0] A, input signed [bits_size-1:0] B, input [1:0] cod);
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
                          complemento_a_2=B;
                          OUT = final_suma[bits_size-1:0]; 
                          Carry=cout;
                          oVerflow = ((1'b0~^A[bits_size-1]~^B[bits_size-1]) & (A[bits_size-1]^OUT[bits_size-1]));
                          Zero = 1'b0;
                     end
            4'b0111: begin //SUB_UNSIGNED
                          complemento_a_2=(-B);///para hacer la resta
                          OUT = final_suma[bits_size-1:0];
                          Carry=cout; 
                          Zero = 1'b0;
                          oVerflow = ((1'b1~^A[bits_size-1]~^B[bits_size-1]) & (A[bits_size-1]^OUT[bits_size-1]));
                     end
                     
            4'b1000: begin //SHIFT_LEFT_LOGICAL
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b1001: begin //SHIFT_RIGTH_LOGICAL
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end   
            4'b1010: begin //SHIFT_RIGTH_ARITMETIC
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
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
            Negative = OUT[bits_size-1];        
    end
    
endmodule
