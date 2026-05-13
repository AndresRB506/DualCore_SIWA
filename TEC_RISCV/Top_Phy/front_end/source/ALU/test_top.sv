`timescale 1ns / 1ps

module test_top (

  );
    reg [31:0] in_A;
    reg [31:0] in_B;
    reg [3:0] Cntrl;
    reg Cin;
    reg clk;
    reg reset;
    wire Z, V, C, N;
    wire [31:0] salida;
    
    integer j;
   
    top inst_top(
        .A_top(in_A),
        .B_top(in_B),
        .Alu_Cntrl_top(Cntrl),
        .Cin_top(Cin),
        .clk(clk),
        .reset(reset),
        .Zero_top(Z), 
        .oVerflow_top(V),
        .Carry_top(C),
        .Negative_top(N),
        .OUT_top(salida)
    );
    
    reg C_flag, Z_flag, N_flag, V_flag;
    reg [32:0] suma;
    reg [31:0] out_alu;
    reg error_flag;
    
    
    
    initial begin
        clk = 1'b0;
        in_A = 32'h0a0a0a0a;    //Igual A y B
        in_B = 32'h0a0a0a0a;
        Cntrl = {$random($random())}%13;   
        Cin=0;
        reset=1'b0;
        #5
        reset=1'b1;
        #5
        reset=1'b0;
        error_flag = 1'b0;
        suma = 33'd0;
        repeat(100000000) begin 
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
                
                repeat(4) @(posedge clk);     //Espera para que los datos se procesen
                
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
            Cntrl = {$random($random())}%13;
            in_A = $random($random());          //Números aleatorios
            in_B = {$random($random())}%29;     //Números aleatorios positivos de 0-29
        end   
	#70
	$finish;     
    end                        
    always #25 clk = !clk;
endmodule
