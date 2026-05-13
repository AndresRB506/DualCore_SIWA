// CODIF[6:0]
//0XXX000 --> U-type Instruction
//1XXX000 --> J-type Instruction
//XXXX010 --> B-type Instruction
//XXXX011 --> S-type Instruction
//XXXX100 --> I-type Instruction
//XXXX101 --> R-type Instruction (SLLI,SRLI,SRAI)
//XXXX110 --> I-type jalr
//XXXX111 --> r-type instructions (add,sll.slt,sltu,xor,srl,or,and,sub,sra)
//XXXX001 --> Machine-Mode-type Instruction

// CODIF[6:0]
//0001000 --> LUI (No ALU)
//0000000 --> AUIPC (No ALU)
//1000000 --> JAL (No ALU)
//0000010 --> BEQ (ALU: EQU) 
//0001010 --> BNE (ALU: NEQU)
//0100010 --> BLT (ALU: LESS_THAN)
//0101010 --> BGE (ALU: GREATER_THAN)
//0110010 --> BLTU(ALU: LESS_THAN, unsigned)
//0111010 --> BGEU(ALU: GREATER_THAN, unsigned)
//0000011 --> SB (No ALU)
//0001011 --> SH (No ALU)
//0010011 --> SW (No ALU)
//0000110 --> JALR (No ALU)
//0000100 --> LB (No ALU)
//0001100 --> LH (No ALU)
//0010100 --> LW (No ALU)
//0100100 --> LBU (No ALU)
//0101100 --> LHU (No ALU)
//1100100 --> ADDI (ALU: add signed)
//1110100 --> SLTI (ALU: less_than signed)
//1011100 --> SLTIU (ALU: less_than unsigned)
//1100100 --> XORI (ALU: bit wise xor)
//1110100 --> ORI (ALU: bit wise or)
//1111100 --> ANDI (ALU: bit wise and)
//0001101 --> SLLI (ALU: shift left logical inmediate)
//0101101 --> SRLI (ALU: shift right logical inmediate)
//1101101 --> SRAI (ALU: shift right aritmetic inmediate)
//0000111 --> ADD (ALU: add unigned aritmetic overflow ignored)
//1000111 --> SUB (ALU: sub usigned aritmetic overflow ignored)
//0001111 --> SLL (ALU: Shift left)
//0010111 --> SLT (ALU: compare less than signed)
//0011111 --> SLTU(ALU: compare less than unsigned)
//0100111 --> XOR (ALU: bitwise Xor)
//0101111 --> SRL (ALU: Shift rigth logic)
//1101111 --> SRA (ALU: Shift rigth aritmetic)
//0110111 --> OR  (ALU: bitwise or)
//0111111 --> AND  (ALU: bitwise and)
//0100001 --> ECALL  (NO ALU)
//0101001 --> EBREAK (No ALU)
//0111001 --> MRET (No ALU)
//1100001 --> WFI  (No ALU)
//0010001 --> CSRRW (No ALU)
//0010001 --> CSRRS (ALU: bitwise OR)
//0011001 --> CSRRC (ALU: bitwise AND)
//1001001 --> CSRRWI (No ALU)
//1010001 --> CSRRSI (ALU: bitwise OR)
//1011001 --> CSRRCI (ALU: bitwise AND)

module DECO_INSTR(
//input
    input ld_id,
    input [31:0] inst,
    input reset,
//output
    output reg[4:0] rs1,
    output reg[4:0] rs2,
    output reg[4:0] rd,
    output reg[31:0] imm,
    output reg[6:0] codif,
    output reg[3:0] csr
    );
//Intermediate variables
    reg [31:0] inst_reg;

//capture of the instruction
    always @(posedge ld_id or posedge reset) begin
      if(reset) begin
        inst_reg <= 0;
      end else begin
        inst_reg <= inst;
      end
    end

//Combinational logic
    always_comb begin
        imm = {32{1'b1}};
        rd = {5{1'b1}};
        rs1 ={5{1'b1}};
        rs2 = {5{1'b1}};
        codif = {7{1'b1}}; //by default the output code signals invalid inst_regruction
        csr = {4{1'b1}};

    //////////////////////////////////////////////
    //  Instructions from the 32I base standard //
    //////////////////////////////////////////////

    if(inst_reg[1:0] == 2'b11) begin      
        case (inst_reg[6:2])
        5'b00101,5'b01101: begin               // U-type inst_regructions (AUIPC, LUI) Valid
            imm = {inst_reg[31:12], {12{1'b0}}};
            rd = inst_reg[11:7];
            rs1 = {5{1'b0}};
            rs2 = {5{1'b0}};
            codif = {{3'b000},inst_reg[5],{3'b000}};
            csr = {4{1'b0}};
        end

// CODIF[6:0]
//0001000 --> LUI (No ALU)
//0000000 --> AUIPC (No ALU)


        5'b11011: begin                             // j-type inst_regructions (JAL) *Valid
            imm = {{11{inst_reg[31]}},inst_reg[31],inst_reg[19:12],inst_reg[20],inst_reg[30:21],1'b0};      
            rd = inst_reg[11:7];
            rs1 = {5{1'b0}};
            rs2 = {5{1'b0}};
            codif = {{7'b1000000}};
            csr = {4{1'b0}};
        end
// CODIF[6:0]
//1000000 --> JAL (No ALU)

        5'b11000: begin                             // B-type inst_regructions (beq,bne,blt,bge,bltu,bgeu) Valid
            imm = {{19{inst_reg[31]}},inst_reg[31],inst_reg[7],inst_reg[30:25],inst_reg[11:8],1'b0};
            rd = {5{1'b0}};
            rs1 = inst_reg[19:15];
            rs2 = inst_reg[24:20];
            codif = {{1'b0},inst_reg[14:12],{3'b010}};
            csr = {4{1'b0}};
        end

// CODIF[6:0]
//0000010 --> BEQ (ALU: EQU) 
//0001010 --> BNE (ALU: NEQU)
//0100010 --> BLT (ALU: LESS_THAN)
//0101010 --> BGE (ALU: GREATER_THAN)
//0110010 --> BLTU(ALU: LESS_THAN, unsigned)
//0111010 --> BGEU(ALU: GREATER_THAN, unsigned)
  

        5'b01000: begin                             // S-type inst_regructions (sb,sh,sw) Valid
            imm = {{20{inst_reg[31]}},inst_reg[31:25],inst_reg[11:7]} ;
            rs1 = inst_reg[19:15];
            rs2 = inst_reg[24:20];
            rd = {5{1'b0}};
            codif = {{1'b0},inst_reg[14:12],{3'b011}};            
            csr = {4{1'b0}};
        end

// CODIF[6:0]
//0000011 --> SB (No ALU)
//0001011 --> SH (No ALU)
//0010011 --> SW (No ALU)

        5'b11001: begin                            //  i-type inst_regruction (jalr) Valid
                imm = {{20{inst_reg[31]}},inst_reg[31:20]}; 
                rs1 = inst_reg[19:15];
                rd = inst_reg[11:7];
                rs2 = {5{1'b0}};
                codif ={ {1'b0} ,inst_reg[14:12] ,{3'b110} };
                csr = {4{1'b0}};
        end
// CODIF[6:0]
//0000110 --> JALR (No ALU)


        5'b00000: begin                             // i-type inst_regructions (lb,lh,lw,lbu,lhu) Valid
           if((inst_reg[14] != 1'b1)) begin
                imm = {{20{inst_reg[31]}},inst_reg[31:20]};
           end else begin                           // This is for lbu, lhu
                imm = {{20{1'b0}},inst_reg[31:20]};
           end 
                rs1 = inst_reg[19:15];
                rd = inst_reg[11:7];
                rs2 = {5{1'b0}};
                codif ={ {1'b0} ,inst_reg[14:12] ,{3'b100} };
                csr = {4{1'b0}};
        end
// CODIF[6:0]
//0000100 --> LB (No ALU)
//0001100 --> LH (No ALU)
//0010100 --> LW (No ALU)
//0100100 --> LBU (No ALU)
//0101100 --> LHU (No ALU)

        5'b00100: begin                             
            if((inst_reg[13:12] != 2'b01)) begin // i-type inst_regructions (addi,slti,sltiu,xori,ori,andi) Valid
                imm = {{20{inst_reg[31]}},inst_reg[31:20]}; 
                codif ={ {1'b1} ,inst_reg[14:12] ,{3'b100} };
                csr = {4{1'b0}};
            end else begin                   // r-type inst_regructions (slli,srli,srai)
                imm = {{20{inst_reg[31]}},inst_reg[31:20]};
                codif = {inst_reg[30],inst_reg[14:12],{3'b101}};     
                csr = {4{1'b0}};
            end
            rs1 = inst_reg[19:15];
            rd = inst_reg[11:7];
            rs2 = {5{1'b0}};
        end

// CODIF[6:0]
//100100 --> ADDI (ALU: add signed)
//1110100 --> SLTI (ALU: less_than signed)
//1011100 --> SLTIU (ALU: less_than unsigned)
//1100100 --> XORI (ALU: bit wise xor)
//1110100 --> ORI (ALU: bit wise or)
//1111100 --> ANDI (ALU: bit wise and)
//0001101 --> SLLI (ALU: shift left logical inmediate)
//0101101 --> SRLI (ALU: shift right logical inmediate)
//1101101 --> SRAI (ALU: shift right aritmetic inmediate)



        5'b01100: begin // r-type inst_regructions (add,sll.slt,sltu,xor,srl,or,and,sub,sra) Valid
                imm = {32{1'b0}};
                rs2 = inst_reg[24:20];
                rs1 = inst_reg[19:15];
                rd  = inst_reg[11:7];
                codif = {inst_reg[30],inst_reg[14:12],{3'b111}};
                csr = {4{1'b0}};
            end
// CODIF[6:0]
//0000111 --> ADD (ALU: add unigned aritmetic overflow ignored)
//1000111 --> SUB (ALU: sub usigned aritmetic overflow ignored)
//0001111 --> SLL (ALU: Shift left)
//0010111 --> SLT (ALU: compare less than signed)
//0011111 --> SLTU(ALU: compare less than unsigned)
//0100111 --> XOR (ALU: bitwise Xor)
//0101111 --> SRL (ALU: Shift rigth logic)
//1101111 --> SRA (ALU: Shift rigth aritmetic)
//0110111 --> OR  (ALU: bitwise or)
//0111111 --> AND  (ALU: bitwise and)


        


        5'b11100: begin 
            if(inst_reg[14:12] == 3'b000) begin // ECALL, EBREAK, MRET //Valid
                rd =  {5{1'b0}};
                rs1 = {5{1'b0}};       
                rs2 = {5{1'b0}};
                imm = {{20{1'b0}},inst_reg[31:20]}; 
                csr = {4{1'b0}};
                
                case(inst_reg[31:20])
                  12'b000000000000:begin //ECALL              
                    codif = {{4'b0100},{3'b001}};
                  end
                  12'b000000000001:begin //EBREAK              
                    codif = {{4'b0101},{3'b001}};
                  end
                  12'b001100000010:begin //MRET              
                    codif = {{4'b0111},{3'b001}};
                  end
                  12'b000100000101:begin //WFI              
                    codif = {{4'b1100},{3'b001}};
                  end
                  default:begin
                    codif = {{4'b1111},{3'b111}};
                  end
                endcase 
            end else if(inst_reg[14] == 1'b0) begin // CSRRW,CSRRS,CSRRC
                rd = inst_reg[11:7];
                rs1 = inst_reg[19:15];        
                rs2 = {5{1'b0}};
                imm = {32{1'b0}}; 
                codif = {1'b0,inst_reg[14:12],{3'b001}};
                csr = inst_reg[23:20];
                
            end else begin // CSRRWI,CSRRSI,CSRRCI
                rd = inst_reg[11:7];
                rs1 = {5{1'b0}};        
                rs2 = {5{1'b0}};
                imm = {{27{1'b0}},inst_reg[19:15]}; 
                codif = {1'b0,inst_reg[14:12],{3'b000}};
                csr = inst_reg[23:20];
            end
        end

// CODIF[6:0]
//0100001 --> ECALL  (NO ALU)
//0101001 --> EBREAK (No ALU)
//0111001 --> MRET (No ALU)
//1100001 --> WFI  (No ALU)
//0001001 --> CSRRW (No ALU)
//0010001 --> CSRRS (ALU: bitwise OR)
//0011001 --> CSRRC (ALU: bitwise AND)
//0101001 --> CSRRWI (No ALU)
//0110001 --> CSRRSI (ALU: bitwise OR)
//0111001 --> CSRRCI (ALU: bitwise AND)


        5'b00110: begin // IRQ
            if (inst_reg[14:12] != 3'b000) begin                    // IRQXX (NOT SBREAK) Valid
                imm = {{25{inst_reg[31]}},inst_reg[31:25]};             //como estaba ambiguo se especificó 
                rd = {inst_reg[11:7]};                              //el codif como 0-funct3-111
                rs1 = {inst_reg[19:15]};
                rs2 = {inst_reg[24:20]};
                codif = {{1{1'b0}} ,inst_reg[14:12] , {3'b111}};
                csr = {4{1'b0}}; 
            end
        end
	   default: begin
           imm = {32{1'b1}};
           rd = {5{1'b1}};
           rs1 ={5{1'b1}};
           rs2 = {5{1'b1}};
           codif = {7{1'b1}}; //by default the output code signals invalid inst_regruction
           csr = {4{1'b1}};
        end
        endcase
      end else begin
           imm = {32{1'b1}};
           rd = {5{1'b1}};
           rs1 ={5{1'b1}};
           rs2 = {5{1'b1}};
           codif = {7{1'b1}}; //by default the output code signals invalid inst_regruction
           csr = {4{1'b1}};
      end
    end

endmodule
