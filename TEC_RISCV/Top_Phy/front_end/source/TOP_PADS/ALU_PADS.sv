`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

`include "./top.sv"

//`include "./mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC1V8/v1_0/verilog/v1_0_0/IO_CELLS_FC1V8.v"

// `include "./mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC3V/v1_1/verilog/v1_1_0/IO_CELLS_FC3V.v"

//`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v"


module ALU_PADS #(bit_sz = 8, cntrl_sz = 4)(
    input [bit_sz-1:0] A_net,
    input [bit_sz-1:0] B_net,
    input [cntrl_sz-1:0] cntrl_net,
    input cin_net,
    input rst_net,
    input clk_net,
    output reg zero_net,
    output reg overflow_net,
    output reg negative_net,
    output reg cout_net,
    output reg [bit_sz-1:0] out_net
    );
    wire [bit_sz-1:0] a_1;
    wire [bit_sz-1:0] b_1;
    wire [bit_sz-1:0] out_1;
    wire [cntrl_sz-1:0] cntrl_1;
    wire  cin_1, cin_2;
    wire  clk_1, clk_2;
    wire  rst_1, rst_2;
    wire  overflow_1;
    wire  negative_1;
    wire  zero_1;
    wire  cout_1, cout_2;
    wire  gnd_en;

    assign gnd_en=1'b0;
    top alu_top(
        .A_top(a_1),
        .B_top(b_1),
        .Alu_Cntrl_top(cntrl_1),
        .Cin_top(cin_1),
        .Zero_top(zero_1),
        .oVerflow_top(overflow_1),
        .Carry_top(cout_1),
        .Negative_top(negative_1),
        .OUT_top(out_1),
        .clk(clk_1),
        .reset(rst_1)
        );
    // -------- Conecta los bits de A
    // - - A[0] - - 
    ICFA a1_0_inst (.PAD(A_net[0]), .PI(gnd_en), .PO(), .Y(a_1[0])); // CONECTO LAS SEÑALES DE LA NAND A TIERRA
   
    // - - A[1] - - 
    ICFA a1_1_inst (.PAD(A_net[1]), .PI(gnd_en), .PO(),.Y(a_1[1]));
    
    // - - A[2] - - 
    ICFA a1_2_inst (.PAD(A_net[2]), .PI(gnd_en), .PO(),.Y(a_1[2]));
    
    // - - A[3] - - 
    ICFA a1_3_inst (.PAD(A_net[3]), .PI(gnd_en), .PO(),.Y(a_1[3]));
    
    // - - A[4] - - 
    ICFA a1_4_inst (.PAD(A_net[4]), .PI(gnd_en), .PO(),.Y(a_1[4]));
    
    // - - A[5] - - 
    ICFA a1_5_inst (.PAD(A_net[5]), .PI(gnd_en), .PO(),.Y(a_1[5]));
    
    // - - A[6] - - 
    ICFA a1_6_inst (.PAD(A_net[6]), .PI(gnd_en), .PO(),.Y(a_1[6]));
    
    // - - A[7] - - 
    ICFA a1_7_inst (.PAD(A_net[7]), .PI(gnd_en), .PO(),.Y(a_1[7]));


    // - - B[0] - - 
    ICFA b1_0_inst (.PAD(B_net[0]), .PI(gnd_en), .PO(), .Y(b_1[0])); 
    
    // - - B[1] - - 
    ICFA b1_1_inst (.PAD(B_net[1]), .PI(gnd_en), .PO(), .Y(b_1[1]));

    // - - B[2] - - 
    ICFA b1_2_inst (.PAD(B_net[2]), .PI(gnd_en), .PO(), .Y(b_1[2]));

    // - - B[3] - - 
    ICFA b1_3_inst (.PAD(B_net[3]), .PI(gnd_en), .PO(), .Y(b_1[3]));

    // - - B[4] - - 
    ICFA b1_4_inst (.PAD(B_net[4]), .PI(gnd_en), .PO(), .Y(b_1[4]));

    // - - B[5] - - 
    ICFA b1_5_inst (.PAD(B_net[5]), .PI(gnd_en), .PO(), .Y(b_1[5]));

    // - - B[6] - - 
    ICFA b1_6_inst (.PAD(B_net[6]), .PI(gnd_en), .PO(), .Y(b_1[6]));

    // - - B[7] - - 
    ICFA b1_7_inst (.PAD(B_net[7]), .PI(gnd_en), .PO(), .Y(b_1[7]));

 
    // - - out[0] - - 
    BT2SFA out1_0_inst (.A(out_net[0]), .EN(gnd_en), .PAD(out_1[0])); 

    // - - out[1] - - 
    BT2SFA out1_1_inst (.A(out_net[1]), .EN(gnd_en), .PAD(out_1[1]));

    // - - out[2] - - 
    BT2SFA out1_2_inst (.A(out_net[2]), .EN(gnd_en), .PAD(out_1[2]));

    // - - out[3] - - 
    BT2SFA out1_3_inst (.A(out_net[3]), .EN(gnd_en), .PAD(out_1[3]));

    // - - out[4] - - 
    BT2SFA out1_4_inst (.A(out_net[4]), .EN(gnd_en), .PAD(out_1[4]));

    // - - out[5] - - 
    BT2SFA out1_5_inst (.A(out_net[5]), .EN(gnd_en), .PAD(out_1[5]));

    // - - out[6] - - 
    BT2SFA out1_6_inst (.A(out_net[6]), .EN(gnd_en), .PAD(out_1[6]));

    // - - out[7] - - 
    BT2SFA out1_7_inst (.A(out_net[7]), .EN(gnd_en), .PAD(out_1[7]));
    
   
    // - - cntrl[0] - - 
    ICFA cntrl1_0_inst (.PAD(cntrl_net[0]), .PI(gnd_en), .PO(),.Y(cntrl_1[0]));

    // - - cntrl[1] - - 
    ICFA cntrl1_1_inst (.PAD(cntrl_net[1]), .PI(gnd_en), .PO(),.Y(cntrl_1[1]));

    // - - cntrl[2] - - 
    ICFA cntrl1_2_inst (.PAD(cntrl_net[2]), .PI(gnd_en), .PO(),.Y(cntrl_1[2]));

    // - - cntrl[3] - - 
    ICFA cntrl1_3_inst (.PAD(cntrl_net[3]), .PI(gnd_en), .PO(),.Y(cntrl_1[3]));

    // - - cin - - 
    ICFA cin1_inst (.PAD(cin_net), .PI(gnd_en), .PO(), .Y(cin_1));

    // - - clk - - 
    ICFA clk1_inst (.PAD(clk_net), .PI(gnd_en), .PO(), .Y(clk_1));

    // - - rst - - 
    ICFA rst1_inst (.PAD(rst_net), .PI(gnd_en), .PO(), .Y(rst_1));

    // - - overflow - - 
    BT2SFA overflow1_inst (.A(overflow_net), .EN(gnd_en), .PAD(overflow_1));

    // - - negative - - 
    BT2SFA negative1_inst (.A(negative_net), .EN(gnd_en), .PAD(negative_1));

    // - - zero - - 
    BT2SFA zero1_inst (.A(zero_net), .EN(gnd_en), .PAD(zero_1));

    // - - cout - - 
    // Primero se conecta el level shifter al carry_out y después el pad de 3.3V 

    LSHVFU3VHDX1 LS_cout (.A(cout_net), .Q(cout_1));

    BT2SFC cout1_inst (.A(cout_1), .EN(gnd_en), .PAD(cout_2)); //UNICA SALIDA EN 3.3V PARA PROBAR UPF

endmodule


//****************************************************************************
//   technology       : xh018
//   module name      : ICFA
//   version          : 1.0.0, Thu Feb 26 14:48:09 2015
//   cell_description : Non-Inverting CMOS Input Buffer
//   last modified by : XLICDD generated
//****************************************************************************

module ICFA (PAD, PI, PO, Y);

   input     PAD, PI;
   output    PO, Y;

// Function PO: !(PAD&PI)
   nand      i0  (PO, PAD, PI);

// Function Y: PAD
   buf       i2  (Y, PAD);

// timing section:
   specify

      (PAD -=> PO) = (0.02, 0.02);
      (PI -=> PO) = (0.02, 0.02);

      (PAD +=> Y) = (0.02, 0.02);

   endspecify
endmodule



//****************************************************************************
//   technology       : xh018
//   module name      : BT2SFA
//   version          : 1.0.0, Thu Feb 26 14:48:09 2015
//   cell_description : Tri-state output Buffer, Strength 2mA @ 1.8 V, Slew
//                      Rate Control, Lowest noise (Slowest speed)
//   last modified by : XLICDD generated
//****************************************************************************

module BT2SFA (A, EN, PAD);

   input     A, EN;
   output    PAD;

// Function PAD: A; Tristate function: EN
   bufif0    i0  (PAD, A, EN);

// timing section:
   specify

      (A +=> PAD) = (0.02, 0.02);
      (EN  => PAD) = (0.02, 0.02, 0.02, 0.02, 0.02, 0.02);

   endspecify
endmodule





//****************************************************************************
//   technology       : xh018
//   module name      : BT2SFC
//   version          : 1.1.0, Tue Apr  4 09:17:16 2017
//   cell_description : Tri-state output Buffer, Strength 2mA @ 3.3 V, Slew
//                      Rate Control, Lowest noise (Slowest speed)
//   last modified by : XLICDD generated
//****************************************************************************

module BT2SFC (A, EN, PAD);

   input     A, EN;
   output    PAD;

// Function PAD: A; Tristate function: EN
   bufif0    i0  (PAD, A, EN);

// timing section:
   specify

      (A +=> PAD) = (0.02, 0.02);
      (EN  => PAD) = (0.02, 0.02, 0.02, 0.02, 0.02, 0.02);

   endspecify
endmodule




//****************************************************************************
//   technology       : xh018
//   module name      : ICFC
//   version          : 1.1.0, Tue Apr  4 09:17:16 2017
//   cell_description : Non-Inverting CMOS Input Buffer
//   last modified by : XLICDD generated
//****************************************************************************

module ICFC (PAD, PI, PO, Y);

   input     PAD, PI;
   output    PO, Y;

// Function PO: !(PAD&PI)
   nand      i0  (PO, PAD, PI);

// Function Y: PAD
   buf       i2  (Y, PAD);

// timing section:
   specify

      (PAD -=> PO) = (0.02, 0.02);
      (PI -=> PO) = (0.02, 0.02);

      (PAD +=> Y) = (0.02, 0.02);

   endspecify
endmodule



//****************************************************************************
//   technology       : 180 nm bulk CMOS
//   module name      : LSHVFU3VHDX1
//   version          : 2.1.0, Tue Sep  5 08:48:09 2017
//   cell_description : Level shifter cell low to high 3V, placement only
//                      inside 'from' voltage domain
//   last modified by : XLICDD generated
//****************************************************************************

module LSHVFU3VHDX1 (A, Q);

   input     A;
   output    Q;

// Function Q: A
   buf       i0  (Q, A);

// timing section:
   specify

      (A +=> Q) = (0.02, 0.02);

   endspecify
endmodule
