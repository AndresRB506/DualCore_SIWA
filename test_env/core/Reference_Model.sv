task reference_model(output string data_out[$], output int executed_inst, output string exe_inst_queue[$]); 
   
   logic [31:0] pc;
   logic [31:0] next_pc;
   logic [7:0]  mem           [8192]; //8KB RAM memory
   logic [7:0]  mem_uart      [8388608]; //8MB UART Space
   logic [7:0]  mem_spi       [16777216]; //16MB SPI Space
   logic [12:0] mem_addr;
   logic [22:0] uart_addr;
   logic [23:0] spi_addr;
   logic [31:0] addr;
   logic [31:0] reg_file      [32];
   logic [31:0] mip_mie;
   logic [31:0] mepc;
   logic [31:0] interrupt1;
   logic [31:0] interrupt2;
   logic [31:0] gpio;
   logic [31:0] mvtec;
   logic [31:0] comp_timer;
   logic [31:0] val_timer;
   logic [31:0] program_queue [$];
   logic [31:0] instruction;
   logic [6:0]  opcode;
   logic [11:0] imm;
   logic [19:0] imm2;
   logic [20:0] offset;
   logic [12:0] offset_b;
   logic [2:0]  funct3;
   logic [4:0]  rs1;
   logic [4:0]  rs2;
   logic [4:0]  rd;
   logic [6:0]  funct7;
   logic [4:0]  shamt;

   logic [31:0] ext_imm;
   logic        update_pc;
   logic [31:0] mem_data;
   logic        intr;
   logic [2:0]  intr_code; //Table 1.6 from Overleaf Specs

   int file;
   int max_pc;
   int count;

   string instruction_str;
   string data;
   string inst_reg_file [$];
   

   //Load program
   data_out.delete();
   exe_inst_queue.delete();
   count = 0;
   intr = 0;
   intr_code = 0;
   file = $fopen(`PROGRAM_FILE,"r");
   while(!$feof(file)) begin
     $fgets(instruction_str,file);
     instruction = instruction_str.atohex();
     mem[count]     = instruction[31:24];
     mem[count + 1] = instruction[23:16];
     mem[count + 2] = instruction[15:8];
     mem[count + 3] = instruction[7:0];
     //$display("Ref Mod: Introduced instruction: %h",instruction);
     count = count + 4;
   end
   pc = 0;
   reg_file[0] = 0;
   max_pc = count;
   executed_inst = 0;

   //Initialization of CSR Registers
   mip_mie    = 32'h00000000;
   mepc       = 32'h00000000;
   interrupt1 = 32'h00000000;
   interrupt1 = 32'h00000000;
   gpio       = 32'h00000000;
   mvtec      = 32'h00000000;

   //Execute program

   while (pc < max_pc) begin

      //Info for printing;
      inst_reg_file.delete();
      update_pc = 0;
      mem_addr = 0;

      //Instruction Fetch
      instruction[31:24] = mem[pc];
      instruction[23:16] = mem[pc + 1];
      instruction[15:8]  = mem[pc + 2];
      instruction[7:0]   = mem[pc + 3];
      $display("Instruction: %h",instruction);
      instruction_str.hextoa(instruction);
      while (instruction_str.len() <= 7) begin
         instruction_str = {"0",instruction_str};
      end
      exe_inst_queue.push_back(instruction_str);
      //$display({"Instruction: ",instruction_str});
      //Decode and Execute
      opcode = instruction[6:0];
      case (opcode)
         7'b0110111 : begin //LUI
            imm2 = instruction[31:12];
            rd  = instruction[11:7];
            reg_file[rd] = {imm2,12'b0000_0000_0000};
         end
         7'b0010111 : begin //AUIPC
            imm2 = instruction[31:12];
            rd  = instruction[11:7];
            reg_file[rd] = pc + {imm2,12'b0000_0000_0000};
         end
         7'b1101111 : begin //JAL
            offset = {instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
            //$display("DEBUG %h",offset);
            rd  = instruction[11:7];
            ext_imm = 32'(signed'(offset));
            reg_file[rd] = pc + 4;
            next_pc = pc + ext_imm;
            update_pc = 1;
         end
         7'b1100111 : begin //JALR
            imm = instruction[31:20];
            rs1 = instruction[19:15];
            rd  = instruction[11:7];
            reg_file[rd] = pc + 4;
            ext_imm = 32'(signed'(imm));
            next_pc = reg_file[rs1] + $signed(ext_imm);
            next_pc[0] = 0;
            update_pc = 1;
         end
         7'b1100011 : begin //BEQ, BNE, BLT, BGE, BLTU, BGEU
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //BEQ
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if(reg_file[rs1] == reg_file[rs2]) begin
                     next_pc = pc + $signed(ext_imm);
                     update_pc = 1;
                  end
               end
               3'b001 : begin //BNE
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if(reg_file[rs1] != reg_file[rs2]) begin
                     next_pc = pc + $signed(ext_imm);
                     update_pc = 1;
                  end
               end
               3'b100 : begin //BLT
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if($signed(reg_file[rs1]) < $signed(reg_file[rs2])) begin
                     next_pc = pc + $signed(ext_imm);
                     update_pc = 1;
                  end
               end
               3'b101 : begin //BGE
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if($signed(reg_file[rs1]) >= $signed(reg_file[rs2])) begin
                     next_pc = pc + $signed(ext_imm);
                     $display("offset_b %h",ext_imm);
                     $display("next_pc %h",next_pc);
                     update_pc = 1;
                  end
               end
               3'b110 : begin //BLTU
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if(reg_file[rs1] < reg_file[rs2]) begin
                     next_pc = pc + $signed(ext_imm);
                     update_pc = 1;
                  end
               end
               3'b111 : begin //BGEU
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if(reg_file[rs1] >= reg_file[rs2]) begin
                     next_pc = pc + $signed(ext_imm);
                     update_pc = 1;
                  end
               end
            default : /* Invalid */;
            endcase
         end
         7'b0000011 : begin //LB, LH, LW, LBU, LHU
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //LB
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  reg_file[rd] = 32'(signed'(mem[mem_addr]));
               end
               3'b001 : begin //LH
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  reg_file[rd] = 32'(signed'({mem[mem_addr],mem[mem_addr + 1]}));
               end
               3'b010 : begin //LW
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  reg_file[rd] = {mem[mem_addr],mem[mem_addr + 1],mem[mem_addr + 2],mem[mem_addr + 3]};
               end
               3'b100 : begin //LBU
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  reg_file[rd] = 32'(unsigned'(mem[mem_addr]));
               end
               3'b101 : begin //LHU
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  reg_file[rd] = 32'(unsigned'({mem[mem_addr],mem[mem_addr + 1]}));
               end
            default : /* Invalid */;
            endcase
         end
         7'b0100011 : begin //SB, SH, SW
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //SB
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  mem[mem_addr] = reg_file[rs2][7:0];
               end
               3'b001 : begin //SH
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  mem_addr = reg_file[rs1] + $signed(ext_imm);
                  mem[mem_addr]     = reg_file[rs2][15:8];
                  mem[mem_addr + 1] = reg_file[rs2][7:0];
               end
               3'b010 : begin //SW
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     mem[mem_addr]     = reg_file[rs2][31:24];
                     mem[mem_addr + 1] = reg_file[rs2][23:16];
                     mem[mem_addr + 2] = reg_file[rs2][15:8];
                     mem[mem_addr + 3] = reg_file[rs2][7:0];
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     mem_uart[uart_addr]     = reg_file[rs2][31:24];
                     mem_uart[uart_addr + 1] = reg_file[rs2][23:16];
                     mem_uart[uart_addr + 2] = reg_file[rs2][15:8];
                     mem_uart[uart_addr + 3] = reg_file[rs2][7:0];
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     mem_spi[spi_addr]     = reg_file[rs2][31:24];
                     mem_spi[spi_addr + 1] = reg_file[rs2][23:16];
                     mem_spi[spi_addr + 2] = reg_file[rs2][15:8];
                     mem_spi[spi_addr + 3] = reg_file[rs2][7:0];
                  end
                  else begin //non-existent address
                     intr = 1;
                     intr_code = 0;
                  end
               end
            default : /* Invalid */;
            endcase
         end
         7'b0010011 : begin //ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //ADDI
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  reg_file[rd] = reg_file[rs1] + ext_imm;
               end
               3'b010 : begin //SLTI
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  if($signed(reg_file[rs1]) < $signed(ext_imm)) begin
                     reg_file[rd] = 1;
                  end
                  else begin
                     reg_file[rd] = 0;
                  end
               end
               3'b011 : begin //SLTIU
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  if($unsigned(reg_file[rs1]) < $unsigned(ext_imm)) begin
                     reg_file[rd] = 1;
                  end
                  else begin
                     reg_file[rd] = 0;
                  end
               end
               3'b100 : begin //XORI
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  reg_file[rd] = reg_file[rs1] ^ ext_imm;
               end
               3'b110 : begin //ORI
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  reg_file[rd] = reg_file[rs1] | ext_imm;
               end
               3'b111 : begin //ANDI
                  imm = instruction[31:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  ext_imm = 32'(signed'(imm));
                  reg_file[rd] = reg_file[rs1] & ext_imm;
               end
               3'b001 : begin //SLLI
                  shamt = instruction[24:20];
                  rs1   = instruction[19:15];
                  rd    = instruction[11:7];
                  reg_file[rd] = reg_file[rs1] << shamt;
               end
               3'b101 : begin //SRLI, SRAI
                  shamt = instruction[24:20];
                  rs1   = instruction[19:15];
                  rd    = instruction[11:7];
                  if(instruction[31:25] == 7'b0000000) begin
                     reg_file[rd] = reg_file[rs1] >> shamt;
                  end
                  else if(instruction[31:25] == 7'b0100000) begin
                     reg_file[rd] = $signed(reg_file[rs1]) >>> shamt;
                  end
                  else begin //INVALID
                  end
               end
            default : /* Invalid */;
            endcase
         end
         7'b0110011 : begin //ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //ADD, SUB
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  if(instruction[31:25] == 7'b0000000) begin
                     reg_file[rd] = reg_file[rs1] + reg_file[rs2];
                  end
                  else if(instruction[31:25] == 7'b0100000) begin
                     reg_file[rd] = reg_file[rs1] - reg_file[rs2];
                  end
                  else begin //INVALID
                  end
               end
               3'b001 : begin //SLL
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  shamt = reg_file[rs2][4:0];
                  reg_file[rd] = reg_file[rs1] << shamt;
               end
               3'b010 : begin //SLT
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  if($signed(reg_file[rs1]) < $signed(reg_file[rs2])) begin
                     reg_file[rd] = 1;
                  end
                  else begin
                     reg_file[rd] = 0;
                  end
               end
               3'b011 : begin //SLTU
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  if($unsigned(reg_file[rs1]) < $unsigned(reg_file[rs2])) begin
                     reg_file[rd] = 1;
                  end
                  else begin
                     reg_file[rd] = 0;
                  end
               end
               3'b100 : begin //XOR
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  reg_file[rd] = reg_file[rs1] ^ reg_file[rs2];
               end
               3'b101 : begin //SRL, SRA
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  shamt = reg_file[rs2][4:0];
                  if(instruction[31:25] == 7'b0000000) begin
                     reg_file[rd] = reg_file[rs1] >> shamt;
                  end
                  else if(instruction[31:25] == 7'b0100000) begin
                     reg_file[rd] = $signed(reg_file[rs1]) >>> shamt;
                  end
                  else begin //INVALID
                  end
               end
               3'b110 : begin //OR
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  reg_file[rd] = reg_file[rs1] | reg_file[rs2];
               end
               3'b111 : begin //AND
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  rd  = instruction[11:7];
                  reg_file[rd] = reg_file[rs1] & reg_file[rs2];
               end
            default : /* Invalid */;
            endcase
         end
         7'b0001111 : begin //FENCE, FENCE.I
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //FENCE
                  intr = 1;
                  intr_code = 5;
               end
               3'b001 : begin //FENCE.I
                  intr = 1;
                  intr_code = 5;
               end
            default : /* Invalid */;
            endcase
         end
         7'b1110011 : begin //ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //ECALL, EBREAK
                  intr = 1;
                  intr_code = 5;
               end
               3'b001 : begin //CSRRW
               end
               3'b010 : begin //CSRRS
               end
               3'b011 : begin //CSRRC
               end
               3'b101 : begin //CSRRWI
               end
               3'b110 : begin //CSRRSI
               end
               3'b111 : begin //CSRRCI
               end
            default : /* Invalid */;
            endcase
         end
         default : begin
            intr = 1;
            intr_code = 5;
         end/* Unknown Instruction */
      endcase
      reg_file[0] = 0;

      //Store data for selfchecking
      data.hextoa(pc);
      while (data.len() <= 7) begin
         data = {"0",data};
      end
      data_out.push_back(data);
      inst_reg_file.push_back(data);
      for (int i = 1; i < 32; i++) begin
         data.hextoa(reg_file[i]);
         while (data.len() <= 7) begin
            data = {"0",data};
         end
         data_out.push_back(data);
         inst_reg_file.push_back(data);
      end
      executed_inst++;
      print_reg_file(inst_reg_file);

      //Check Interruption

      if (intr == 1) begin
         $display("An interrupt has ocurred!!!");
         mepc = pc;//mepc = pc
         case (intr_code)
            3'b000 : begin //Bad_Addr

            end
            default : /* default */;
         endcase
         intr = 0;
         intr_code = 0;
      end

      //Updates PC
      if (update_pc == 1) begin
         pc = next_pc;
      end
      else begin
         pc = pc + 4;
      end
   end

  $display("-----------------------------------",);
  $display("Prediction has Finished...");
  $display("-----------------------------------",);
      

endtask