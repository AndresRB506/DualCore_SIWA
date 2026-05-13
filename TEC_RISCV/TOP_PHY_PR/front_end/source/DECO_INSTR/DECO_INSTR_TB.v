`timescale 1ns / 1ps
`include "DECO_INSTR.sv"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2017 11:21:03 PM
// Design Name: 
// Module Name: DECO_INSTR_TB
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


module DECO_INSTR_TB(

    );
    //Variables auxiliares
    reg error;
    
    reg [31:0]inst;    
    reg ld_id;
    wire [4:0] rs1,rs2,rd;
    wire [31:0] imm;
    wire [6:0] codif;
    wire inst_Exep;
    
    //Instancia 
    DECO_INSTR DECO_INSTR_Inst(
    //input
        .ld_id(ld_id),
        .inst(inst),
    //output
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .codif(codif)
//        .inst_Exep(inst_Exep)
        );
       
       
    initial 
    begin
        error=0;
        ld_id=0;
        //prueba1 LUI
        inst={{10{2'b01}},5'b11001,7'b0110111};    //{10{2'b01}} / rd=5'b11001 / Opcode=7'b0110111
        #10
        if (rs1!=5'd0 || rs2!=5'd0 || rd!=5'b11001 || imm!={{10{2'b01}},{12{1'b0}}} || codif!=7'b0001000 || inst_Exep!=1'b0)error=1'b1;
        #10
        
        //prueba2 JAL
        inst={{10{2'b01}},5'b11001,7'b1101111};    //{10{2'b01}} / rd=5'b11001 / Opcode=7'b1101111
        #10
        if (rs1!=5'd0 || rs2!=5'd0 || rd!=5'b11001 || imm!={{12{1'b0}},{4{2'b01}},1'b1,{5{2'b10}},1'b0} || codif!=7'b1000000 || inst_Exep!=1'b0)begin error=1'b1;end
        #10
        
        //prueba3 BEQ
        inst={{7'b0101010},5'b00110,5'b11001,3'b000,5'b01010,7'b1100011};    //rs2=5'b00110 /rs1=5'b11001 / Opcode=7'b1100011
        #10
        if (rs1!=5'b11001 || rs2!=5'b00110 || rd!=5'd0 || imm!={{20{1'b0}},1'b0,{3{2'b10}},4'b0101,1'b0} || codif!=7'b0000010 || inst_Exep!=1'b0)error=1'b1;
        #10
        
        //prueba4 SB        
        inst={{7'b0101010},5'b00110,5'b11001,3'b000,5'b01010,7'b0100011};    //rs2=5'b00110 /rs1=5'b11001 / Opcode=7'b0100011
        #10
        if (rs1!=5'b11001 || rs2!=5'b00110 || rd!=5'd0 || imm!={{20{1'b0}},7'b0101010,5'b01010} || codif!=7'b0000011 || inst_Exep!=1'b0)error=1'b1;
        #10
        
        //prueba5 jalr
        inst={{6{2'b01}},5'b11001,3'b000,5'b00110,7'b1100111};    //rd=5'b00110 /rs1=5'b11001 / Opcode=7'b1100111
        #10
        if (rs1!=5'b11001 || rs2!=5'd0 || rd!=5'b00110|| imm!={{20{1'b0}},{6{2'b01}}} || codif!=7'b0000110 || inst_Exep!=1'b0)error=1'b1;
        #10;
  
        //prueba6 lb
        inst={{6{2'b10}},5'b11001,3'b000,5'b00110,7'b0000011};    //rd=5'b00110 /rs1=5'b11001 / Opcode=7'b0000011
        #10
        if (rs1!=5'b11001 || rs2!=5'd0 || rd!=5'b00110|| imm!={{20{1'b1}},{6{2'b10}}} || codif!=7'b0000100 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba7 lbu
        inst={{6{2'b10}},5'b11001,3'b100,5'b00110,7'b0000011};    //rd=5'b00110 /rs1=5'b11001 / Opcode=7'b0000011
        #10
        if (rs1!=5'b11001 || rs2!=5'd0 || rd!=5'b00110|| imm!={{20{1'b0}},{6{2'b10}}} || codif!=7'b0100100 || inst_Exep!=1'b0)error=1'b1;
        #10;     
        
        //prueba8 ADDI
        inst={{6{2'b10}},5'b11001,3'b000,5'b00110,7'b0010011};    //rd=5'b00110 /rs1=5'b11001 / Opcode=7'b0010011
        #10
        if (rs1!=5'b11001 || rs2!=5'd0 || rd!=5'b00110|| imm!={{20{1'b1}},{6{2'b10}}} || codif!=7'b1000100 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba9 SLLI
        inst={{7'd0},{5'b10101},5'b11001,3'b001,5'b00110,7'b0010011};    //rd=5'b00110 /rs1=5'b11001 / Opcode=7'b0010011
        #10
        if (rs1!=5'b11001 || rs2!=5'd0 || rd!=5'b00110|| imm!={{27{1'b0}},{5'b10101}} || codif!=7'b0001101 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba10 ADD
        inst={{7'd0},{5'b10101},5'b11001,3'b000,5'b00110,7'b0110011};    //rd=5'b00110 /rs1=5'b11001 /rs2=5'b10101 / Opcode=7'b0110011
        #10
        if (rs1!=5'b11001 || rs2!=5'd10101 || rd!=5'b00110|| imm!={32{1'b0}} || codif!=7'b0000111 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba11 ECALL
        inst={{7'd0},{5'b00000},5'b00000,3'b000,5'b00000,7'b1110011};    // Opcode=7'b1110011
        #10
        if (rs1!=5'b00000 || rs2!=5'b00000 || rd!=5'b00000|| imm!={32{1'b0}} || codif!=7'b0100001 || inst_Exep!=1'b0)error=1'b1;
        #10;       
        
        //prueba12 EBREAK
        inst={{7'd0},{5'b00001},5'b00000,3'b000,5'b00000,7'b1110011};    // Opcode=7'b1110011
        #10
        if (rs1!=5'b00000 || rs2!=5'b00000 || rd!=5'b00000|| imm!={32'h00000001} || codif!=7'b0101001 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba13 MRET
        inst={{7'b0011000},{5'b00010},5'b00000,3'b000,5'b00000,7'b1110011};    // Opcode=7'b1110011
        #10
        if (rs1!=5'b00000 || rs2!=5'b00000 || rd!=5'b00000|| imm!={{20{1'b0}},12'b001100000010} || codif!=7'b0111001 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba14 WFI
        inst={{7'b0001000},{5'b00101},5'b00000,3'b000,5'b00000,7'b1110011};    // Opcode=7'b1110011
        #10
        if (rs1!=5'b00000 || rs2!=5'b00000 || rd!=5'b00000|| imm!={{20{1'b0}},12'b000100000101} || codif!=7'b1100001 || inst_Exep!=1'b0)error=1'b1;
        #10;
        
        //prueba15 CSRRW
        inst={{12'h123},5'b11001,3'b001,5'b00110,7'b1110011};    //rd=5'b00110 /rs1=5'b11001 /Opcode=7'b1110011
        #10
        if (rs1!=5'b11001 || rs2!=5'b00000 || rd!=5'b00110|| imm!={32{1'b0}} || codif!=7'b0001001 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba16 CSRRWI
        inst={{12'h123},5'b11001,3'b101,5'b00110,7'b1110011};    //rd=5'b00110 /zimm=5'b11001 /Opcode=7'b1110011
        #10
        if (rs1!=5'b00000 || rs2!=5'b00000 || rd!=5'b00110|| imm!={{27{1'b0}},5'b11001} || codif!=7'b0101001 || inst_Exep!=1'b0)error=1'b1;
        #10;                
        
        //prueba17 IRQ
        inst={{7'b1010101},5'b00110,5'b11001,3'b101,5'b00110,7'b0011011};    //rd=5'b00110 /rs1=5'b11001 /rs2=5'b00110 /Opcode=7'b0011011
        #10
        if (rs1!=5'b11001 || rs2!=5'b00110 || rd!=5'b00110|| imm!={{25{1'b1}},7'b1010101} || codif!=7'b0101111 || inst_Exep!=1'b0)error=1'b1;
        #10;        
        
        //prueba18 default (excepción)
        inst={{7'b1010101},5'b00110,5'b11001,3'b101,5'b00110,7'b1111111};    //rd=5'b00110 /rs1=5'b11001 /rs2=5'b00110 /Opcode=7'b1111111
        #10
        if (rs1!=5'b11111 || rs2!=5'b11111 || rd!=5'b11111|| imm!={{25{1'b1}},7'b1111111} || codif!=7'b1111111 || inst_Exep!=1'b1)error=1'b1;
        #10;          
    end      
    
endmodule
