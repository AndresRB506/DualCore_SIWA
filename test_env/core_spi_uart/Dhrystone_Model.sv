task dhrystone_model(output int dmips); 
   
   logic [31:0] pc;
   logic [31:0] next_pc;
   logic [7:0]  mem           [8388608]; //Adding more space than the RTL has, to be able to run dhrystone easier
   logic [7:0]  mem_uart      [8388608]; //8MB UART Space
   logic [7:0]  mem_spi       [16777216]; //16MB SPI Space
   logic [12:0] mem_addr;
   logic [22:0] uart_addr;
   logic [23:0] spi_addr;
   logic [31:0] addr;
   logic [31:0] reg_file      [32];
   logic [31:0] mip_mie;
   logic [31:0] mepc;
   logic [31:0] mcause1;
   logic [31:0] mcause2;
   logic [31:0] gpio;
   logic [31:0] mvtec;
   logic [31:0] comp_timer;
   logic [31:0] val_timer;
   logic [31:0] full_range_level_shifter;
   logic [31:0] IS_Val;
   logic [31:0] IS_Config;
   logic [31:0] IS_Trigger;
   logic [31:0] program_queue [$];
   logic [31:0] instruction;
   //logic [31:0]  instruction_word;
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
   logic [11:0] csr_reg;
   logic [4:0]  zimm;

   logic [31:0] ext_imm;
   logic        update_pc;
   logic [31:0] mem_data;
   logic        intr;
   logic [2:0]  mcause2[2:0]; //Table 1.6 from Overleaf Specs
   logic [31:0] last_pc;
   logic [6:0]  deco_code;
   logic [63:0] uart_pkt;

   int file;
   int max_pc;
   int count;
   int finish_count;
   int inst_cycles;

   string instruction_str;
   string data;
   string inst_reg_file [$];
   string csr_reg_file  [$];
   
   /////////////////////////////// Init Msg ////////////////////////////////////////

   $display("-----------------------------------",);
   $display("Initiating DMIPS Calculation...");
   $display("-----------------------------------",);

   ///////////////////////////////// Load program /////////////////////////////////////

   count = 0;
   intr = 0;
   mcause2[2:0] = 0;
   finish_count = 0;
   last_pc = 0;
   deco_code = 0;
   csr_reg = 0;
   inst_cycles = 0;
   file = $fopen("dhrystone.txt","r");
   while(!$feof(file)) begin
     $fgets(instruction_str,file);
     inst_queue.push_back(instruction_str);
     instruction = instruction_str.atohex();
     instruction[7:0]   = mem[count];
     instruction[15:8]  = mem[count + 1];
     instruction[23:16] = mem[count + 2];
     instruction[31:24] = mem[count + 3];
     mem[count]  = instruction[7:0];
     //$display("Ref Mod: Introduced instruction: %h",instruction);
     //$display("count ",count);
     count++;
   end
   $fclose(file);
   pc = 0;
   reg_file[0] = 0;
   //$display("count ",count);
   max_pc = count - 4; //last instruction is 0xffffffff, this must not be taken into account
   //$display("max_pc ",max_pc);
   executed_inst = 0;

   ///////////////////////////////// Initialization of CSR Registers and Reg File ///////////////////////////

   mip_mie                  = 32'h00010004;
   mepc                     = 32'h00000000;
   mcause1                  = 32'h00000000;
   mcause2                  = 32'h00000000;
   gpio                     = 32'h00000000;
   mvtec                    = 32'h00000000;
   comp_timer               = 32'h00000000;
   val_timer                = 32'h00000000;
   full_range_level_shifter = 32'h00000000;
   IS_Val                   = 32'h00000000;
   IS_Config                = 32'h00000000;
   IS_Trigger               = 32'h00000000;

   foreach(reg_file[i]) begin
      reg_file[i] = 0;
   end

   ///////////////////////////// Execute program on Ref Model ////////////////////////////////////////////

   while (pc < max_pc) begin

      ///////////////////////////// Initializing some variables /////////////////////////////////////////////

      inst_reg_file.delete();
      csr_reg_file.delete();
      update_pc = 0;
      mem_addr = 0;

      ///////////////////////////// Instruction Fetch ///////////////////////////////////////////////////////

      instruction[7:0]   = mem[pc];
      instruction[15:8]  = mem[pc + 1];
      instruction[23:16] = mem[pc + 2];
      instruction[31:24] = mem[pc + 3];
      $display("Instruction: %h",instruction);
      instruction_str.hextoa(instruction);
      while (instruction_str.len() <= 7) begin
         instruction_str = {"0",instruction_str};
      end
      exe_inst_queue.push_back(instruction_str);
      //$display({"Instruction: ",instruction_str});

      ///////////////////////////// Decode and Execute ///////////////////////////////////////////////////////

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
                  rd = 0;
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
                  rd = 0;
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
                  rd = 0;
               end
               3'b101 : begin //BGE
                  rs2 = instruction[24:20];
                  rs1 = instruction[19:15];
                  offset_b  = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  ext_imm  = 32'(signed'(offset_b));
                  if($signed(reg_file[rs1]) >= $signed(reg_file[rs2])) begin
                     next_pc = pc + $signed(ext_imm);
                     //$display("offset_b %h",ext_imm);
                     //$display("next_pc %h",next_pc);
                     update_pc = 1;
                  end
                  rd = 0;
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
                  rd = 0;
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
                  rd = 0;
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
            endcase // funct3
         end
         7'b0000011 : begin //LB, LH, LW, LBU, LHU
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //LB
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     reg_file[rd] = 32'(signed'(mem[mem_addr]));
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     reg_file[rd] = 0;
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     reg_file[rd] = 0;
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rs2 = 0;
                  deco_code = 7'b0000100;
               end
               3'b001 : begin //LH
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     reg_file[rd] = 32'(signed'({mem[mem_addr + 1],mem[mem_addr]}));
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     reg_file[rd] = 0;
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     reg_file[rd] = 0;
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rs2 = 0;
                  deco_code = 7'b0001100;
               end
               3'b010 : begin //LW
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     reg_file[rd] = {mem[mem_addr + 3],mem[mem_addr + 2],mem[mem_addr + 1],mem[mem_addr]};
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     reg_file[rd] = 0;
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     reg_file[rd] = 0;
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rs2 = 0;
                  deco_code = 7'b0010100;
               end
               3'b100 : begin //LBU
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     reg_file[rd] = 32'(unsigned'(mem[mem_addr]));
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     reg_file[rd] = 0;
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     reg_file[rd] = 0;
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rs2 = 0;
                  deco_code = 7'b0100100;
               end
               3'b101 : begin //LHU
                  imm      = instruction[31:20];
                  rs1      = instruction[19:15];
                  rd       = instruction[11:7];
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     reg_file[rd] = 32'(unsigned'({mem[mem_addr + 1],mem[mem_addr]}));
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     reg_file[rd] = 0;
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     reg_file[rd] = 0;
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rs2 = 0;
                  deco_code = 7'b0101100;
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
            endcase // funct3
         end
         7'b0100011 : begin //SB, SH, SW
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //SB
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     mem[mem_addr] = reg_file[rs2][7:0];
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     mem_uart[uart_addr + 3] = reg_file[rs2][31:24];
                     mem_uart[uart_addr + 2] = reg_file[rs2][23:16];
                     mem_uart[uart_addr + 1] = reg_file[rs2][15:8];
                     mem_uart[uart_addr]     = reg_file[rs2][7:0];
                     uart_pkt = {2'b10,2'b00,3'b101,addr[24:0],mem_uart[uart_addr + 3],mem_uart[uart_addr + 2],mem_uart[uart_addr + 1],mem_uart[uart_addr]};
                     data.hextoa(uart_pkt);
                     uart_output.push_back(data);
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     mem_spi[spi_addr] = reg_file[rs2][7:0];
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rd = 0;
                  deco_code = 7'b0000011;
               end
               3'b001 : begin //SH
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     mem[mem_addr + 1] = reg_file[rs2][15:8];
                     mem[mem_addr]     = reg_file[rs2][7:0];
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     mem_uart[uart_addr + 3] = reg_file[rs2][31:24];
                     mem_uart[uart_addr + 2] = reg_file[rs2][23:16];
                     mem_uart[uart_addr + 1] = reg_file[rs2][15:8];
                     mem_uart[uart_addr]     = reg_file[rs2][7:0];
                     uart_pkt = {2'b10,2'b00,3'b110,addr[24:0],mem_uart[uart_addr + 3],mem_uart[uart_addr + 2],mem_uart[uart_addr + 1],mem_uart[uart_addr]};
                     data.hextoa(uart_pkt);
                     uart_output.push_back(data);
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     mem_spi[spi_addr + 1] = reg_file[rs2][15:8];
                     mem_spi[spi_addr]     = reg_file[rs2][7:0];
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rd = 0;
                  deco_code = 7'b0001011;
               end
               3'b010 : begin //SW
                  rs2      = instruction[24:20];
                  rs1      = instruction[19:15];
                  imm      = {instruction[31:25],instruction[11:7]};
                  ext_imm  = 32'(signed'(imm));
                  addr = reg_file[rs1] + $signed(ext_imm);
                  if (addr < 8192) begin //addressing RAM space (0KB-8KB)
                     mem_addr = addr[12:0];
                     mem[mem_addr + 3] = reg_file[rs2][31:24];
                     mem[mem_addr + 2] = reg_file[rs2][23:16];
                     mem[mem_addr + 1] = reg_file[rs2][15:8];
                     mem[mem_addr]     = reg_file[rs2][7:0];
                  end
                  else if((addr >= 8388608) && (addr < 16777216)) begin //addressing UART space (8MB-16MB)
                     uart_addr = addr[22:0];
                     mem_uart[uart_addr + 3] = reg_file[rs2][31:24];
                     mem_uart[uart_addr + 2] = reg_file[rs2][23:16];
                     mem_uart[uart_addr + 1] = reg_file[rs2][15:8];
                     mem_uart[uart_addr]     = reg_file[rs2][7:0];
                     uart_pkt = {2'b10,2'b00,3'b100,addr[24:0],mem_uart[uart_addr + 3],mem_uart[uart_addr + 2],mem_uart[uart_addr + 1],mem_uart[uart_addr]};
                     data.hextoa(uart_pkt);
                     uart_output.push_back(data);
                  end
                  else if((addr >= 16777216) && (addr < 33554432)) begin //addressing SPI space (16MB-32MB)
                     spi_addr = addr[23:0];
                     mem_spi[spi_addr + 3] = reg_file[rs2][31:24];
                     mem_spi[spi_addr + 2] = reg_file[rs2][23:16];
                     mem_spi[spi_addr + 1] = reg_file[rs2][15:8];
                     mem_spi[spi_addr]     = reg_file[rs2][7:0];
                  end
                  else begin //non-existent address
                     intr = 1;
                     mcause2[2:0] = 0;
                  end
                  rd = 0;
                  deco_code = 7'b0010011;
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
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
                     intr = 1;
                     mcause2[2:0] = 5;
                  end
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
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
                     intr = 1;
                     mcause2[2:0] = 5;
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
                     intr = 1;
                     mcause2[2:0] = 5;
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
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
            endcase
         end
         7'b0001111 : begin //FENCE, FENCE.I
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //FENCE
                  intr = 1;
                  mcause2[2:0] = 5;
               end
               3'b001 : begin //FENCE.I
                  intr = 1;
                  mcause2[2:0] = 5;
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
            endcase // funct3
         end
         7'b1110011 : begin //ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
            funct3 = instruction[14:12];
            case (funct3)
               3'b000 : begin //ECALL, EBREAK
                  intr = 1;
                  mcause2[2:0] = 5;
               end
               3'b001 : begin //CSRRW
                  csr_reg = instruction[31:20];
                  rs1     = instruction[19:15];
                  rd      = instruction[11:7];
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = reg_file[rs1][1:0];
                        mip_mie[4] = reg_file[rs1][4];
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = reg_file[rs1][31:2];
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = reg_file[rs1];
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = reg_file[rs1];
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = reg_file[rs1][7:0];
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = reg_file[rs1][31:2];
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = reg_file[rs1];
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = reg_file[rs1];
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = reg_file[rs1][7:0];
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = reg_file[rs1];
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = reg_file[rs1];
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = reg_file[rs1][3:0];
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               3'b010 : begin //CSRRS
                  csr_reg = instruction[31:20];
                  rs1     = instruction[19:15];
                  rd      = instruction[11:7];
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = mip_mie[1:0] | reg_file[rs1][1:0];
                        mip_mie[4] = mip_mie[4] | reg_file[rs1][4];
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = mepc[31:2] | reg_file[rs1][31:2];
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = mcause1 | reg_file[rs1];
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = mcause2 | reg_file[rs1];
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = gpio[7:0] | reg_file[rs1][7:0];
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = mvtec[31:2] | reg_file[rs1][31:2];
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = comp_timer | reg_file[rs1];
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = val_timer | reg_file[rs1];
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = full_range_level_shifter[7:0] | reg_file[rs1][7:0];
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = IS_Val | reg_file[rs1];
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = IS_Config | reg_file[rs1];
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = IS_Trigger[3:0] | reg_file[rs1][3:0];
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               3'b011 : begin //CSRRC
                  csr_reg = instruction[31:20];
                  rs1     = instruction[19:15];
                  rd      = instruction[11:7];
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = mip_mie[1:0] & ~(reg_file[rs1][1:0]);
                        mip_mie[4] = mip_mie[4] & ~(reg_file[rs1][4]);
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = mepc[31:2] & ~(reg_file[rs1][31:2]);
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = mcause1 & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = mcause2 & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = gpio[7:0] & ~(reg_file[rs1][7:0]);
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = mvtec[31:2] & ~(reg_file[rs1][31:2]);
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = comp_timer & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = val_timer & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = full_range_level_shifter[7:0] & ~(reg_file[rs1][7:0]);
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = IS_Val & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = IS_Config & ~(reg_file[rs1]);
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = IS_Trigger[3:0] & ~(reg_file[rs1][3:0]);
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               3'b101 : begin //CSRRWI
                  csr_reg = instruction[31:20];
                  zimm    = instruction[19:15];
                  rd      = instruction[11:7];
                  ext_imm = 32'(unsigned'(zimm));
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = ext_imm[1:0];
                        mip_mie[4] = ext_imm[4];
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = ext_imm[31:2];
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = ext_imm;
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = ext_imm;
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = ext_imm[7:0];
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = ext_imm[31:2];
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = ext_imm;
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = ext_imm;
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = ext_imm[7:0];
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = ext_imm;
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = ext_imm;
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = ext_imm[3:0];
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               3'b110 : begin //CSRRSI
                  csr_reg = instruction[31:20];
                  zimm    = instruction[19:15];
                  rd      = instruction[11:7];
                  ext_imm = 32'(unsigned'(zimm));
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = mip_mie[1:0] | ext_imm[1:0];
                        mip_mie[4] = mip_mie[4] | ext_imm[4];
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = mepc[31:2] | ext_imm[31:2];
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = mcause1 | ext_imm;
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = mcause2 | ext_imm;
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = gpio[7:0] | ext_imm[7:0];
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = mvtec[31:2] | ext_imm[31:2];
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = comp_timer | ext_imm;
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = val_timer | ext_imm;
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = full_range_level_shifter[7:0] | ext_imm[7:0];
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = IS_Val | ext_imm;
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = IS_Config | ext_imm;
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = IS_Trigger[3:0] | ext_imm[3:0];
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               3'b111 : begin //CSRRCI
                  csr_reg = instruction[31:20];
                  zimm    = instruction[19:15];
                  rd      = instruction[11:7];
                  ext_imm = 32'(unsigned'(zimm));
                  case (csr_reg)
                     12'b0000_0000_0000: begin //mip_mie CSR
                        if(rd != 0) begin
                           reg_file[rd] = mip_mie;
                        end
                        mip_mie[1:0] = mip_mie[1:0] & ~(ext_imm[1:0]);
                        mip_mie[4] = mip_mie[4] & ~(ext_imm[4]);
                     end
                     12'b0000_0000_0001: begin //mepc CSR
                        if(rd != 0) begin
                           reg_file[rd] = mepc;
                        end
                        mepc[31:2] = mepc[31:2] & ~(ext_imm[31:2]);
                     end
                     12'b0000_0000_0010: begin //mcause1 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause1;
                        end
                        mcause1 = mcause1 & ~(ext_imm);
                     end
                     12'b0000_0000_0011: begin //mcause2 CSR
                        if(rd != 0) begin
                           reg_file[rd] = mcause2;
                        end
                        mcause2 = mcause2 & ~(ext_imm);
                     end
                     12'b0000_0000_0100: begin //GPIO CSR
                        if(rd != 0) begin
                           reg_file[rd] = gpio;
                        end
                        gpio[7:0] = gpio[7:0] & ~(ext_imm[7:0]);
                     end
                     12'b0000_0000_0101: begin //mvtec CSR
                        if(rd != 0) begin
                           reg_file[rd] = mvtec;
                        end
                        mvtec[31:2] = mvtec[31:2] & ~(ext_imm[31:2]);
                     end
                     12'b0000_0000_0110: begin //timer CSR
                        if(rd != 0) begin
                           reg_file[rd] = comp_timer;
                        end
                        comp_timer = comp_timer & ~(ext_imm);
                     end
                     12'b0000_0000_0111: begin //timer_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = val_timer;
                        end
                        //val_timer = val_timer & ~(ext_imm);
                     end
                     12'b0000_0000_1000: begin //full range level shifter CSR
                        if(rd != 0) begin
                           reg_file[rd] = full_range_level_shifter;
                        end
                        full_range_level_shifter[7:0] = full_range_level_shifter[7:0] & ~(ext_imm[7:0]);
                     end
                     12'b0000_0000_1001: begin //IS_value CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Val;
                        end
                        IS_Val = IS_Val & ~(ext_imm);
                     end
                     12'b0000_0000_1010: begin //IS_config CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Config;
                        end
                        IS_Config = IS_Config & ~(ext_imm);
                     end
                     12'b0000_0000_1011: begin //IS_trigger CSR
                        if(rd != 0) begin
                           reg_file[rd] = IS_Trigger;
                        end
                        IS_Trigger[3:0] = IS_Trigger[3:0] & ~(ext_imm[3:0]);
                     end
                     default : begin
                        intr = 1;
                        mcause2[2:0] = 5;
                     end
                  endcase
               end
               default : begin
                  intr = 1;
                  mcause2[2:0] = 5;
               end/* Unknown Instruction */
            endcase // funct3
         end
         default : begin
            intr = 1;
            mcause2[2:0] = 5;
         end/* Unknown Instruction */
      endcase
      reg_file[0] = 0;

      ////////////////////////////// Update CSR /////////////////////////////////

      if(comp_timer == val_timer) begin
         mip_mie[2] = 1;
      end
      else begin
         mip_mie[2] = 0;
      end // else

      //////////////////////////////////////// Check for Interruptions ////////////////////////////////////////////

      if (intr == 1) begin
         $display("An interrupt has ocurred!!!");
         mepc = pc;//mepc = pc
         next_pc = mvtec; //intr_handler position
         update_pc = 1;
         case (mcause2[2:0])
            3'b000 : begin //Bad_Addr
               mcause1[4:0]   = rd;
               mcause1[31:5]  = 0;
               mcause2[31:20] = imm;
               mcause2[19:15] = rs2;
               mcause2[14:10] = rs1;
               mcause2[9:3]   = deco_code;
               $display("Bad Address");
               $finish;
            end
            3'b000 : begin //Digital_IO
               mcause1        = 0; //DATA
               mcause2[31]    = 0;
               mcause2[19:15] = rs2;
               mcause2[14:10] = rs1;
               mcause2[9:3]   = deco_code;
               $display("Digital_IO");
               $finish;
            end
            3'b011 : begin //Timer
               mcause1 = 0;
               mcause2[31:3] = 0;
               $finish;
            end
            3'b100 : begin //Analog_IO
               mcause1 = 0;
               mcause2[31:3] = 0;
               $finish;
            end
            3'b101 : begin //Bad_Inst
               mcause1 = 0;
               mcause2[31:3] = 0;
               $display("Bad Instruction");
               $finish;
            end
            default : begin/* default */
               $display("Bad Interrupt");
               $finish;
            end
         endcase
         intr = 0;
      end

      //////////////////////////// Updates PC ////////////////////////////////////

      if (update_pc == 1) begin
         pc = next_pc;
      end
      else begin
         pc = pc + 4;
      end

      ////////////////////////// Check if the program is cycled to end the test////////////////////////////////////////

      if(last_pc == pc) begin
         finish_count++;
         if(finish_count == 3) begin
            pc = max_pc;
         end
      end
      else begin
         last_pc = pc;
         finish_count = 0;
      end
   end

   /////////////////////////////////// Dhrystone test has finished /////////////////////////////////////////////

   $display("-----------------------------------");
   $display("Dhrystone Test has finished correctly...");
   $display("-----------------------------------");

endtask
