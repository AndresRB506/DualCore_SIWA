`include "../BUS/Library.sv"
`include "../ALU/ALU_Library.sv"
`include "../DECO_INSTR/DECO_INSTR.sv"
`include "../MMU/code/controlador.sv"
`include "../Interrupt_Handler/intrpt_hndlr.sv"
`include "../Register_File/Reg_latch_complete/Banco_de_registros_latches.v"

//Parametros

  `define bus_sz=80 // size of the external bus data 
  `define Adrs_Data_sz=32 //size of the internal data bus 
  `define Intr_D_sz=72 // size of the vector pushed into the intr hndlr
  `define cod_sz=8 //size of the code used by the 
  `define mem_adrs_sz=11 //size of the RAM address bus
  `define bs_adrs_sz = 24 //size of the internal address bus
  `define cant_io=5 // number of IOs in the system
  `define fifo_int_depth=3 //depth of the internal fifo
  `define watch_dog_sz=32 
  `define fifo_int_sz=72 //size of the internal fifo word

module CPU (
  input reset,
  input clock,
//interface with the memory
  input [`Adrs_Data_sz-1:0] q,
  output [`Adrs_Data_sz-1:0] d_sys,
  output [`mem_adrs_sz-1:0] a_sys,
  input rdy_mem,
  output clk_mem,
  output c_en,
  output w_en,
  output sl
);

// inputs to the MBC 
    wire MTIE; 
    wire MEIE; 
    wire Full; 
    wire Pndng;
    wire Clean; 
    wire Enable; 
    wire RW; 
    wire B; 
    wire H;
    wire [`bus_sz-1:0] D_pop;
    wire [`Adrs_Data_sz-1:0] Address;
    wire [`Adrs_Data_sz-1:0] Data_Write;
    wire [`Adrs_Data_sz-1:0] CSR_io;
    wire [`cant_io:0][`Adrs_Data_sz-1:0] CSR_limits;
//outputs from the MBC
    wire Mem_rdy; 
    wire Push; 
    wire IO_Intr_push;
    wire [`bus_sz-1:0] D_push;
    wire Pop; 
    wire Rqs_Intr_mem;
    wire [`Adrs_Data_sz-1:0] Data_read;
    wire [`Intr_D_sz-1:0] IO_Intr_D_push;
//inputs for the Inst Deco
    wire ld_id;
//outputs from the Inst Deco
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd; 
    wire [31:0] imm;
    wire [6:0] codif;
//inputs for the ALU 
    wire [31:0] A;
    wire [31:0] B;
    wire [3:0] Alu_Cntrl;
    wire Cin;
//outputs from the ALU
    wire Zero; 
    wire oVerflow;
    wire Negative;
    wire Carry;
    wire [31:0] OUT;
//inputs for the Reg_file 
wire [3:0] csr_id;
wire write_en;
wire read_en;
wire csr_read_en;
wire csr_write_en;
wire [31:0] reg_write_data;
wire clk;
wire rst;
wire load;
wire [95:0] csr_trap;
wire [29:0] pc; 
wire enable_pc;
wire mip_IO;
wire mip_time;
//outputs from the Reg_file
wire mie_IO;
wire mie_time;
wire [31:0] limits1;
wire [31:0] limits2;
wire [31:0] limits3;
wire [31:0] limits4;
wire [31:0] limits5;
wire [31:0] limits6;
wire [4:0] csr_io;
wire [31:0] R1; 
wire [31:0] R2; 


controlador #(
  .bus_sz(`bus_sz),
  .Adrs_Data_sz(`Adrs_Data_sz),
  .Intr_D_sz(`Intr_D_sz),
  .cod_sz(`cod_sz),
  .mem_adrs_sz(`mem_adrs_sz),
  .bs_adrs_sz(`bs_adrs_sz),
  .cant_io(`cant_io), 
  .fifo_int_depth(`fifo_int_depth),
  .watch_dog_sz(`watch_dog_sz),
  .fifo_int_sz(`fifo_int_sz)) MBC(
  //block_inputs
    .CLK_sys(clock), 
    .Rst(reset),
    .MTIE(MTIE), 
    .MEIE(MEIE), 
    .Full(Full), 
    .Pndng(Pndng),
    .Clean(Clean), 
    .Enable(Enable), 
    .RW(RW), 
    .B(B), 
    .H(H),
    .D_pop(D_pop),
    .Address(Address),
    .Data_Write(Data_Write),
    .CSR_io(CSR_io),
    .CSR_limits(CSR_limits),
    .q(q),
    .rdy_mem(rdy_mem),
  //block_outputs
    .Mem_rdy(Mem_rdy), 
    .Push(Push), 
    .IO_Intr_push(IO_Intr_push),
    .D_push(D_push),
    .Pop(Pop), 
    .Rqs_Intr_mem(Rqs_Intr_mem),
    .Data_read(Data_read),
    .IO_Intr_D_push(IO_Intr_D_push),
    .c_en(c_en), 
    .w_en(w_en), 
    .sl(sl), 
    .clk_mem(clk_mem),
    .a_sys(a_sys),
    .d_sys(d_sys)
    );
DECO_INSTR instructions_deco(
//input
    .ld_id(ld_id),
    .inst(Data_read),
//output
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd), 
    .imm(imm),
    .codif(codif),
    );  

ALU Alu_unit (
    .A(A),
    .B(B),
    .Alu_Cntrl(Alu_Cntrl),
    .Cin(Cin),
    .Zero(Zero), 
    .oVerflow(oVerflow),
    .Negative(Negative),
    .Carry(Carry),
    .OUT(OUT) 
    );

 Banco_registros_latches Reg_File (
.csr_id(csr_id),
.rs1(rs1),
.rs2(rs2),
.rd(rd), 
.write_en(),
.read_en(),
.csr_read_en(),
.csr_write_en(),
.reg_write_data(),
.clk(),
.rst(),
.load(),
.csr_trap(),
.pc(), 
.enable_pc(),
.mip_IO(),
.mip_time(),
.mie_IO(),
.mie_time(),
.limits1(),
.limits2(),
.limits3(),
.limits4(),
.limits5(),
.limits6(),
.csr_io(),
.R1(), 
.R2() 
);

endmodule
