`timescale 1ns / 1ps
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2018 13:48:55
// Design Name: 
// Module Name: test_ALU_2
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


module test_ALU_2 #(bits_size=32, cntrl_size=4)(

  );
    reg [bits_size-1:0] in_A;
    reg [bits_size-1:0] in_B;
    reg [cntrl_size-1:0] Cntrl;
    reg Cin;
    wire Z, V, C, N;
    wire [bits_size-1:0] salida;
    
    integer j;
    
    ALU_2 inst_ALU(
        .A(in_A),
        .B(in_B),
        .Alu_Cntrl(Cntrl),
        .Cin(Cin),
        .Zero(Z), 
        .oVerflow(V),
        .Carry(C),
        .Negative(N),
        .OUT(salida)
    );
    
    reg C_flag, Z_flag, N_flag, V_flag;
    reg [bits_size:0] suma;
    reg [bits_size-1:0] out_alu;
    reg error_flag;
    
    initial begin
        in_A = 32'h0a0a0a0a;    //Igual A y B
        in_B = 32'h0a0a0a0a;
        Cntrl = {$random($random())}%13;   
        Cin=0;
        error_flag = 1'b0;
        suma = 33'd0;
        repeat(10000000) begin 
        $display("---------------------------------------------------------------------------------");
        $display("Entradas | A: %h, B: %h",in_A,in_B);              
            for (j=0; j < 2; j = j+1) begin            
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
                                suma = {0,in_A} + {0,in_B}+Cin;
                                out_alu = suma[31:0];
                                C_flag = suma[32];
                                Z_flag = 1'b0;
                                V_flag = ((1'b0~^in_A[31]~^in_B[31]) & (in_A[31]^out_alu[31]));
                             end
                    4'b0111: begin //SUB_UNSIGNED
                                suma = {0,in_A} + {0,(~in_B+1'b1)}+Cin;                         
                                out_alu = suma[31:0];
                                C_flag = suma[32];
                                Z_flag = 1'b0;
                                V_flag = ((1'b1~^in_A[31]~^in_B[31]) & (in_A[31]^out_alu[31]));
                             end
                    4'b1000: begin //SHIFT_LEFT_LOGICAL
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) << $signed(in_B[4:0]);
                             end
                    4'b1001: begin //SHIFT_RIGTH_LOGICAL
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) >> $signed(in_B[4:0]);
                             end
                    4'b1010: begin //SHIFT_RIGTH_ARITMETIC
                                C_flag = 1'b0;
                                V_flag = 1'b0;
                                Z_flag = 1'b0;
                                out_alu = $signed(in_A) >>> $signed(in_B[4:0]);
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
                
                #200 ;      //Espera para que los datos se procesen
                
                if ((N_flag != N) || (V_flag != V) || (Z_flag != Z) || (C_flag != C) || (salida != out_alu)) begin
                    error_flag = 1'b1;
                    j = 50000;
                end else begin
                    $display("Acción | Cntrl: %h",Cntrl);
                    $display("Salidas | Salida: %h, N: %d, V: %d, Z: %d, C: %d",salida,N,V,Z,C);
                    Cin=~Cin;
                    if (Cin==1'b0) Cntrl = {$random($random())}%13;
                end
                   
            end
            if(j=='d50000) begin
                break;
                $display("Error entre lo esperado y lo obtenido");
            end
            Cntrl = {$random($random())}%13;	// numeros para el control random
            in_A = $random($random());          //Números aleatorios
            in_B = {$random($random())}%29;     //Números aleatorios positivos de 0-29
        end        
    end                        
    
endmodule
