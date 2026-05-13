`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2017 08:03:16 PM
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb(

    );
    reg [31:0] in_A;
    reg [31:0] in_B;
    reg [3:0] Cntrl;
    wire Z, V, C, N;
    wire [31:0] salida;
    
    integer i,j;
    
    ALU inst_ALU(
        .A(in_A),
        .B(in_B),
        .Alu_Cntrl(Cntrl),
        .Zero(Z), 
        .oVerflow(V),
        .Carry(C),
        .Negative(N),
        .OUT(salida)
    );
    
    reg C_flag, Z_flag, N_flag, V_flag;
    reg [32:0] suma;
    reg [31:0] out_alu;
    reg error_flag;
    
    initial begin
        in_A = 32'h0a0a0a0a;    //Igual A y B
        in_B = 32'h0a0a0a0a;
        Cntrl = 4'd0;
        error_flag = 1'b0;
        suma = 33'd0;
        
        for (i=0; i < 5;i=i+1) begin                
            for (j=0; j < 14; j = j+1) begin            
                case (Cntrl) 
                    4'b0000: begin          //EQU
                                Z_flag = ($signed(in_A) == $signed(in_B));
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                out_alu = 32'd0;
                             end
                    4'b0001: begin          //LESS THAN
                                Z_flag = ($signed(in_A) < $signed(in_B));
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                out_alu = 32'd0;
                             end
                    4'b0010: begin //LESS_THAN_UNSIGNED
                                Z_flag = (in_A < in_B);
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                out_alu = 32'd0;
                             end
                    4'b0011: begin //GREATER_THAN
                                Z_flag = ($signed(in_A) > $signed(in_B));
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                out_alu = 32'd0;
                             end
                    4'b0100: begin //GREATER_THAN_UNSIGNED
                                Z_flag = (in_A > in_B);
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                out_alu = 32'd0;
                             end
                    4'b0101, 4'b0110: begin //ADD & ADD_UNSIGNED
                                suma = {0,in_A} + {0,in_B};
                                out_alu = suma[31:0];
                                C_flag = suma[32];
                                Z_flag = 1'b0;
                                V_flag = ((1'b0~^in_A[31]~^in_B[31]) & (in_A[31]^out_alu[31]));
                             end
                    4'b0111: begin //SUB_UNSIGNED
                                suma = {0,in_A} + {0,(~in_B+1'b1)};                         
                                out_alu = suma[31:0];
                                C_flag = suma[32];
                                Z_flag = 1'b0;
                                V_flag = ((1'b1~^in_A[31]~^in_B[31]) & (in_A[31]^out_alu[31]));
                             end
                    4'b1000: begin //SHIFT_LEFT_LOGICAL
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) << $signed(in_B);
                             end
                    4'b1001: begin //SHIFT_RIGTH_LOGICAL
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) >> $signed(in_B);
                             end
                    4'b1010: begin //SHIFT_RIGTH_ARITMETIC
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) >>> $signed(in_B);
                             end
                    4'b1011: begin //BITWISE_OR
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) | $signed(in_B);
                             end
                    4'b1100: begin //BITWISE_XOR
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) ^ $signed(in_B);
                             end
                    4'b1101: begin //BITWISE_AND
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) & $signed(in_B);
                             end
                    default: begin //default
                                C_flag = 1'bZ;
                                V_flag = 1'bZ;
                                Z_flag = 1'bZ;
                                out_alu = 32'dZ;
                             end                                                                        
                endcase
                N_flag = out_alu[31];
                
                #200
                
                if ((N_flag != N) || (V_flag != V) || (Z_flag != Z) || (C_flag != C) || (salida != out_alu)) begin
                    error_flag = 1'b1;
                    j = 50;
                    i = 50;
                end
                Cntrl = Cntrl + 4'd1;   
            end
            Cntrl = 4'd0;
            if (i == 0) begin
                in_A = 32'h00000003;
                in_B = 32'h00000005;
            end
            else if (i == 1) begin
                in_A = 32'hf0000003;
                in_B = 32'h00000007;
            end
            else if (i == 2) begin
                in_A = 32'hffffffff;
                in_B = 32'h0000000a;
            end
            else if (i == 3) begin
                in_A = 32'hffffffff;
                in_B = 32'h00000001;
            end
        end        
    end                        
    
endmodule
