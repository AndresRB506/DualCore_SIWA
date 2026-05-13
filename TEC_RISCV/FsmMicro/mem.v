`timescale 1ns / 1ps

module mem(
    input [2:0]dir,       // Dirección de la instrucción
    output reg [12:0]instr	  //instrucción que contiene 7 bits de Branch logic, 3 de BrachT  y 3 de salidas
    );
    
    //Instrucciones de prueba
    always @*
    begin
        case(dir)
            3'b000: instr = 13'b0000000000110; //a.6    
            3'b001: instr = 13'b0000100011010; //b.2
            3'b010: instr = 13'b0000100100000; //d.0
            3'b011: instr = 13'b0000100010111; //c.7
            3'b100: instr = 13'b1000001000101; //in=0->e.5 //in=1->d
            3'b101: instr = 13'b0000100000001; //f.1
        endcase    
    end
    
endmodule
