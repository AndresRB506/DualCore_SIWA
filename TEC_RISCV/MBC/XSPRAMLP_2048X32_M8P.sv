//************************************************************************/
// Copyright        : (c) All Rights Reserved
// Company          : X-FAB Semiconductor Foundries AG 
// Address          : Haarbergstr. 67,  D-99097 Erfurt, Germany 
//
// File             : XSPRAMLP_2048X32_M8P.v
// Description      : Verilog simulation file
//                  : Low Power Single-Port RAM XSPRAMLP_2048X32_M8P
//
// Technology       : xh018 LPMOS 1.8/3.3 low power CMOS module
// Model version    : V 3.1.1
// Last Modified by : etu
// Created by       :	X-FAB FRONTEND MEMORY COMPILER
//                  :       0.18um Low Power SPRAM/SPRAMB XFMC V3.1.1
//                  :      XFMC V1.39
// on               : Mon Feb 12 21:46:19 2018
//
// Comment          : The memory supply pins are not declared in the Verilog module list.
//		      
//
//		      If the ATPG tool TetraMAX is used then the following
//		      compiler directive must be set before reading this file:
//
//		      `define ATPG_RUN 
//
//		      To handle negative values of timing checks ($setuphold) the Verilog 
//		      simulator must be started with the option +neg_tchk, otherwise the negative 
//		      values of timing checks are automaticly set to 0.
//
//		      `define NEG_TCHK
//
//		    : It is possible to initialize (pre-load) the RAM content without 
//                  : a modification of this Verilog model file. 
//                  : The following statement section shows a Verilog testbench example.
//                  : The file name "RAM_init_file" can be defined in the testbench.
//                  : The RAM instance I_XSPRAMLP_2048X32_M8P has to be adapted according to the
//                  : netlist hierarchy of the chip project.
//                  : 
//                  : ------------------------------------------------
//                  : initial 
//                  :    begin
//                  :       #0 $readmemb(RAM_init_file, I_XSPRAMLP_2048X32_M8P.sub1.RAM_matrix);
//                  :          $display("\n%t: INFO: %m: loading RAM_init_file %s\n", $realtime, RAM_init_file);
//                  :    end
//                  : ------------------------------------------------
//		    :
// ---------------------------------------------------------------------------
//		    :
//		    : The Default delay in this Verilog model is initialized according to the 
//		    : specified WORST SPEED operating conditions of the IP block. The maxdelays 
//		    : comand line option must be used to select proper value from a timing triplet
//		    : when Default delay is used.
//		    : This supports worst case system simulations on Register-Transfer-Level(RTL)
//		    : to prevent system development iterations because of simulations with not 
//		    : detected unrealistic fast IP block unit delay values. 
//		    : But this could feign an executed backannotation step.
//		    : With the compiler directive 
//		    :     
//		    :         `define DEFAULT_WORST_DELAY_OFF
//
//		    : the IP block Default delays can be set to unit delays (0.02ns).
//
//		    : Important:
//		    : The Default(!) delays in a Verilog model are only formally initialized 
//		    : timing place holder values.
//		    : A Backannotation step must be executed before timing simulations resp. 
//		    : timing analysis to replace these default timing values with the 
//		    : netlist dependent IP block timing values.
//		    : The proper value from a timing triplet in the form min:typ:max in the SDF file
//		    : must be selected with mindelays,typdelays or maxdelays option
// ---------------------------------------------------------------------------
//************************************************************************/
//######################################################################################
//#  Copyright (c) X-FAB Semiconductor Foundries AG . All rights reserved.
//#  This Memory Compiler data and the associated documentation are
//#  confidential and proprietary to X-FAB Semiconductor Foundries AG.
//#
//#  DISCLAIMER
//#  The information contained herein is provided by X-FAB Semiconductor
//#  Foundries AG  on an "AS IS" basis without any warranty.
//#
//#  X-FAB Semiconductor Foundries AG disclaims any representation that
//#  the information does not infringe any intellectual property rights or proprietary
//#  rights of any third parties.  There are no other warranties given by
//#  X-FAB, whether express, implied or statutory, including, without limitation,
//#  implied warranties of merchantability and fitness for a particular purpose.
//#
//# In no event X-FAB will be liable or responsible for any expense, losses, damages,
//# or action incurred or undertaken as a result of the receipt of the information.
//#
//#  X-FAB Semiconductor Foundries AG  reserves the right to make changes
//#  to the information at any time and without notice.
//#
//######################################################################################
// FILE_NAME		xh018-spram-XSPRAMLP_2048X32_M8P.cal
// DATE			Mon Feb 12 21:44:23 2018
// PROCESS			xh018
// MAIN_MODULE		LPMOS
// ADDITIONAL_MODULES	MET4 METMID METTHK
// IP_TYPE			spram
// IP_NAME			XSPRAMLP_2048X32_M8P
// XFP_REV			v3.1.1
// XBP_REV			v3.0.0
// XFMC_FRAME         1.39
// CUSTOMIZED         NO
// PDKCOD             1143
// TOP_MODULE         XSPRAMLP_2048X32_M8P
// MEMORY_TYPE        SPRAM
// ADDRESSES          2048
// BITS               32
// MUX                8
// LIGHT_SLEEP_MODE   YES
// CELL_SIZE_X        702.4    [um]
// CELL_SIZE_Y        713.12    [um]
// CELL_AREA          500899.05 [um^2]
// NOM_VDD18M         1.8      [V]
// WC_VDD18M          1.62      [V]
// CYCLE              20      [ns]
// MAXTEMP            125       [C]
// MAXLOAD            0.2       [pF]
// PVT_FAST           wp 1.98 -40 [] [V] [C]
// PVT_TYP            tm 1.80  25 [] [V] [C]
// PVT_SLOW           ws 1.62 175 [] [V] [C]
// L_NAV_MARK_MET1    HOLE
// L_NAV_MARK_MET1_X  3.165
// L_NAV_MARK_MET1_Y  8.200
// 
// L_NAV_MARK_MET4   HOLE
// L_NAV_MARK_MET4_X 3.165
// L_NAV_MARK_MET4_Y 8.200

`resetall
`celldefine
`suppress_faults
`enable_portfaults
`expand_vectornets
`timescale 1ns/10ps

primitive XSPRAMLP_2048X32_M8P_DFF  (Q, D, C, RN, SN, NOTIFY);

    output Q;
    input  D, C, RN, SN, NOTIFY;
    reg    Q;

// FUNCTION : POSITIVE EDGE TRIGGERED D FLIP-FLOP WITH 
//            ASYNCHRONOUS ACTIVE LOW SET AND CLEAR.

    table

//  D    C    RN    SN   NTFY : Qt  : Qt+1
// ---- ---- ----- ----- ---- : --- : ----
// data clk  rst_n set_n ntfy : Qi  : Q_out           
// ---- ---- ----- ----- ---- : --- : ----

    *	 b    1     1	  ?   :  ?  :  -  ; // data changes, clk stable
    ?	 0    1     1	  ?   :  ?  :  -  ; // clocks off


    1  (0x)   1     ?	  ?   :  1  :  1  ; // possible clk of D=1, but Q=1
    0  (0x)   ?     1	  ?   :  0  :  0  ; // possible clk of D=0, but Q=0

    ?	 ?    1     0	  ?   :  ?  :  1  ; // async set
    ?	 ?    0     1	  ?   :  ?  :  0  ; // async reset

    0  (01)   ?     1	  ?   :  ?  :  0  ; // clocking D=0
    1  (01)   1     ?	  ?   :  ?  :  1  ; // clocking D=1

   					    // reduced pessimism: 
    ?    ?  (?1)    1     ?   :  ?  :  -  ; // ignore the edges on rst_n
    ?    ?    1   (?1)    ?   :  ?  :  -  ; // ignore the edges on set_n

    1  (x1)   1     ?     ?   :  1  :  1  ; // potential pos_edge clk, potential set_n, but D=1 && Qi=1
    0  (x1)   ?     1     ?   :  0  :  0  ; // potential pos_edge clk, potential rst_n, but D=0 && Qi=0

    1  (1x)   1     ?     ?   :  1  :  1  ; // to_x_edge clk, but D=1 && Qi=1
    0  (1x)   ?     1     ?   :  0  :  0  ; // to_x_edge clk, but D=0 && Qi=0

`ifdef    ATPG_RUN

    ?	 *    1     0	  ?   :  ?  :  1  ; // clk while async set	      // ATPG_RUN
    ?	 *    0     1	  ?   :  ?  :  0  ; // clk while async reset	      // ATPG_RUN
    ?	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1		      // ATPG_RUN
    ?    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0		      // ATPG_RUN

`else
   					    // reduced pessimism: 
    1	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1    	      // Vlg
    0	 b    1   (0x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
    0	 b    1   (1x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
   (??)	 b    1     ?	  ?   :  1  :  1  ; //   set=X, D=egdes, but Q=1      // Vlg
    ?  (?0)   1     x	  ?   :  1  :  1  ; //   set=X, neg_edge clk, but Q=1 // Vlg

    0    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0    	      // Vlg
    1    b  (0x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
    1    b  (1x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
   (??)  b    ?     1	  ?   :  0  :  0  ; // reset=X, D=egdes, but Q=0      // Vlg
    ?  (?0)   x     1	  ?   :  0  :  0  ; // reset=X, neg_edge clk, but Q=0 // Vlg
 
`endif // ATPG_RUN

    endtable

endprimitive

`timescale 1ns/10ps
module XSPRAMLP_2048X32_M8P_tmax (QI, D, A, CLK, possRead, cleanWrite, Q_OK);

output [31:0]	QI;
input  [31:0]	D;
input  [10:0]	A;
input		CLK, possRead, cleanWrite, Q_OK;


reg [31:0]  QR; // Data Output Latch

// -- RAM Storage Declaration --
reg [31:0]  RAM_matrix [0:2047];

bufif1	g0 (QI[0], QR[0], Q_OK),	g1 (QI[1], QR[1], Q_OK),	g2 (QI[2], QR[2], Q_OK),
	g3 (QI[3], QR[3], Q_OK),	g4 (QI[4], QR[4], Q_OK),	g5 (QI[5], QR[5], Q_OK),
	g6 (QI[6], QR[6], Q_OK),	g7 (QI[7], QR[7], Q_OK),	g8 (QI[8], QR[8], Q_OK),
	g9 (QI[9], QR[9], Q_OK),	g10 (QI[10], QR[10], Q_OK),	g11 (QI[11], QR[11], Q_OK),
	g12 (QI[12], QR[12], Q_OK),	g13 (QI[13], QR[13], Q_OK),	g14 (QI[14], QR[14], Q_OK),
	g15 (QI[15], QR[15], Q_OK),	g16 (QI[16], QR[16], Q_OK),	g17 (QI[17], QR[17], Q_OK),
	g18 (QI[18], QR[18], Q_OK),	g19 (QI[19], QR[19], Q_OK),	g20 (QI[20], QR[20], Q_OK),
	g21 (QI[21], QR[21], Q_OK),	g22 (QI[22], QR[22], Q_OK),	g23 (QI[23], QR[23], Q_OK),
	g24 (QI[24], QR[24], Q_OK),	g25 (QI[25], QR[25], Q_OK),	g26 (QI[26], QR[26], Q_OK),
	g27 (QI[27], QR[27], Q_OK),	g28 (QI[28], QR[28], Q_OK),	g29 (QI[29], QR[29], Q_OK),
	g30 (QI[30], QR[30], Q_OK),	g31 (QI[31], QR[31], Q_OK);

`ifdef     ATPG_RUN
`else
reg [31:0]  D_X;		// unititialized data
integer addr_cnt;
`endif //  ATPG_RUN

always @(posedge CLK) if (possRead) 
begin
	QR[31:0] = RAM_matrix[A];
end
`ifdef     ATPG_RUN
always @(posedge CLK) if (cleanWrite)
begin
	RAM_matrix[A] = D[31:0];
end
`else
else if (cleanWrite)
begin
	RAM_matrix[A] = D[31:0];
	QR[31:0] = 32'hX;
// inconsistent address:
	if (^A === 1'bx)
	begin
		$display ("\n%t: ERROR: %m : RAM write with inconsistent address", $realtime);
      		for (addr_cnt = 0; addr_cnt < 2048; addr_cnt = addr_cnt +1)
        	begin
			RAM_matrix[addr_cnt] = D_X[31:0];
		end	
      	end 
  	if (A >= 2048)
      	begin
      		$display ("\n%t: WARNING: %m : RAM write to non-existent address(hex) %h", $realtime, A);
      	end 
end
else if (cleanWrite === 1'bx) begin
      RAM_matrix[A] = 32'hX;
      QR[31:0] = 32'hX;
     end      
`endif //  ATPG_RUN

endmodule // XSPRAMLP_2048X32_M8P_tmax

module XSPRAMLP_2048X32_M8P_RDY (CLK, RX, RY, WEn);
input CLK;
input WEn;
output RX;
output RY;
buf 	g0 (CLK_, CLK);
buf 	g1 (RX, CLK_);
buf 	g2 (RY, CLK_);
buf 	g3 (WEn_, WEn);

specify
	specparam
`ifdef DEFAULT_WORST_DELAY_OFF
		RDY_LOW_TIME_READ	=  (0.02),
		RDY_HIGH_TIME_READ =  (0.01),

		RDY_LOW_TIME_WRITE	=  (0.02),
		RDY_HIGH_TIME_WRITE =  (0.01);

`else
		RDY_LOW_TIME_READ	=  (1.35:2.24:4.78),
		RDY_HIGH_TIME_READ	=  (0.20:0.34:0.70),

		RDY_LOW_TIME_WRITE	=  (1.15:1.89:3.78),
		RDY_HIGH_TIME_WRITE	=  (0.21:0.35:0.72);
`endif
	if (WEn_ == 1'b1) (posedge CLK => (RX : 1'b0)) = (RDY_LOW_TIME_READ, 0);
	if (WEn_ == 1'b1) (posedge CLK => (RY : 1'b0)) = (RDY_HIGH_TIME_READ, 0);
	
	if (WEn_ == 1'b0) (posedge CLK => (RX : 1'b0)) = (RDY_LOW_TIME_READ, 0);
	if (WEn_ == 1'b0) (posedge CLK => (RY : 1'b0)) = (RDY_HIGH_TIME_READ, 0);

endspecify
endmodule


module XSPRAMLP_2048X32_M8P_RDYC (CLK, CLKD, CLKDZ);
    input CLK;
    output CLKD;
    output CLKDZ;
    buf g0 (CLK_, CLK);
	buf g1 (CLKD, CLK_);
	buf g2 (CLKDZ, CLK_);
    specify
	(posedge CLK => (CLKD : 1'b0)) = (0.01, 0);
	(posedge CLK => (CLKDZ : 1'b0)) = (0, 0);
    endspecify
endmodule

module XSPRAMLP_2048X32_M8P (Q, D, A, CLK, CEn, WEn, SL, RDY);
output [31:0]	Q;		// RAM data output

input  [31:0]	D;		// RAM data input bus
input  [10:0]	A;		// RAM address bus
input		CLK; 		// RAM clock
input		CEn;		// RAM enable
input		WEn;		// RAM  write enable, 0-active
input 		SL;	// RAM standby input
output		RDY;    // Test output

wire   [31:0]   QI;
wire   [31:0]   D_;
wire   [10:0]   A_;
`ifdef NEG_TCHK
// -- specify buffers: --
wire   [31:0]   D_d;
wire   [10:0]   A_d;

buf	
	gBufCLK (CLK_, CLK_d),
	gBufCEn (CEn_, CEn_d),
	gBufWEn (WEn_, WEn_d);
`else
buf	
	gBufCLK (CLK_, CLK),
	gBufCEn (CEn_, CEn),
	gBufWEn (WEn_, WEn);
`endif
`ifdef NEG_TCHK
	buf gBufSL (SL_, SL_d);
	buf gBufA_0_ (A_[0], A_d[0]);
	buf gBufA_1_ (A_[1], A_d[1]);
	buf gBufA_2_ (A_[2], A_d[2]);
	buf gBufA_3_ (A_[3], A_d[3]);
	buf gBufA_4_ (A_[4], A_d[4]);
	buf gBufA_5_ (A_[5], A_d[5]);
	buf gBufA_6_ (A_[6], A_d[6]);
	buf gBufA_7_ (A_[7], A_d[7]);
	buf gBufA_8_ (A_[8], A_d[8]);
	buf gBufA_9_ (A_[9], A_d[9]);
	buf gBufA_10_ (A_[10], A_d[10]);

	buf gBufD_0_ (D_[0], D_d[0]);
	buf gBufD_1_ (D_[1], D_d[1]);
	buf gBufD_2_ (D_[2], D_d[2]);
	buf gBufD_3_ (D_[3], D_d[3]);
	buf gBufD_4_ (D_[4], D_d[4]);
	buf gBufD_5_ (D_[5], D_d[5]);
	buf gBufD_6_ (D_[6], D_d[6]);
	buf gBufD_7_ (D_[7], D_d[7]);
	buf gBufD_8_ (D_[8], D_d[8]);
	buf gBufD_9_ (D_[9], D_d[9]);
	buf gBufD_10_ (D_[10], D_d[10]);
	buf gBufD_11_ (D_[11], D_d[11]);
	buf gBufD_12_ (D_[12], D_d[12]);
	buf gBufD_13_ (D_[13], D_d[13]);
	buf gBufD_14_ (D_[14], D_d[14]);
	buf gBufD_15_ (D_[15], D_d[15]);
	buf gBufD_16_ (D_[16], D_d[16]);
	buf gBufD_17_ (D_[17], D_d[17]);
	buf gBufD_18_ (D_[18], D_d[18]);
	buf gBufD_19_ (D_[19], D_d[19]);
	buf gBufD_20_ (D_[20], D_d[20]);
	buf gBufD_21_ (D_[21], D_d[21]);
	buf gBufD_22_ (D_[22], D_d[22]);
	buf gBufD_23_ (D_[23], D_d[23]);
	buf gBufD_24_ (D_[24], D_d[24]);
	buf gBufD_25_ (D_[25], D_d[25]);
	buf gBufD_26_ (D_[26], D_d[26]);
	buf gBufD_27_ (D_[27], D_d[27]);
	buf gBufD_28_ (D_[28], D_d[28]);
	buf gBufD_29_ (D_[29], D_d[29]);
	buf gBufD_30_ (D_[30], D_d[30]);
	buf gBufD_31_ (D_[31], D_d[31]);
`else
	buf gBufSL (SL_, SL);
	buf gBufA_0_ (A_[0], A[0]);
	buf gBufA_1_ (A_[1], A[1]);
	buf gBufA_2_ (A_[2], A[2]);
	buf gBufA_3_ (A_[3], A[3]);
	buf gBufA_4_ (A_[4], A[4]);
	buf gBufA_5_ (A_[5], A[5]);
	buf gBufA_6_ (A_[6], A[6]);
	buf gBufA_7_ (A_[7], A[7]);
	buf gBufA_8_ (A_[8], A[8]);
	buf gBufA_9_ (A_[9], A[9]);
	buf gBufA_10_ (A_[10], A[10]);

	buf gBufD_0_ (D_[0], D[0]);
	buf gBufD_1_ (D_[1], D[1]);
	buf gBufD_2_ (D_[2], D[2]);
	buf gBufD_3_ (D_[3], D[3]);
	buf gBufD_4_ (D_[4], D[4]);
	buf gBufD_5_ (D_[5], D[5]);
	buf gBufD_6_ (D_[6], D[6]);
	buf gBufD_7_ (D_[7], D[7]);
	buf gBufD_8_ (D_[8], D[8]);
	buf gBufD_9_ (D_[9], D[9]);
	buf gBufD_10_ (D_[10], D[10]);
	buf gBufD_11_ (D_[11], D[11]);
	buf gBufD_12_ (D_[12], D[12]);
	buf gBufD_13_ (D_[13], D[13]);
	buf gBufD_14_ (D_[14], D[14]);
	buf gBufD_15_ (D_[15], D[15]);
	buf gBufD_16_ (D_[16], D[16]);
	buf gBufD_17_ (D_[17], D[17]);
	buf gBufD_18_ (D_[18], D[18]);
	buf gBufD_19_ (D_[19], D[19]);
	buf gBufD_20_ (D_[20], D[20]);
	buf gBufD_21_ (D_[21], D[21]);
	buf gBufD_22_ (D_[22], D[22]);
	buf gBufD_23_ (D_[23], D[23]);
	buf gBufD_24_ (D_[24], D[24]);
	buf gBufD_25_ (D_[25], D[25]);
	buf gBufD_26_ (D_[26], D[26]);
	buf gBufD_27_ (D_[27], D[27]);
	buf gBufD_28_ (D_[28], D[28]);
	buf gBufD_29_ (D_[29], D[29]);
	buf gBufD_30_ (D_[30], D[30]);
	buf gBufD_31_ (D_[31], D[31]);

`endif

	buf gBufQ_0_ (Q[0], QI[0]);
	buf gBufQ_1_ (Q[1], QI[1]);
	buf gBufQ_2_ (Q[2], QI[2]);
	buf gBufQ_3_ (Q[3], QI[3]);
	buf gBufQ_4_ (Q[4], QI[4]);
	buf gBufQ_5_ (Q[5], QI[5]);
	buf gBufQ_6_ (Q[6], QI[6]);
	buf gBufQ_7_ (Q[7], QI[7]);
	buf gBufQ_8_ (Q[8], QI[8]);
	buf gBufQ_9_ (Q[9], QI[9]);
	buf gBufQ_10_ (Q[10], QI[10]);
	buf gBufQ_11_ (Q[11], QI[11]);
	buf gBufQ_12_ (Q[12], QI[12]);
	buf gBufQ_13_ (Q[13], QI[13]);
	buf gBufQ_14_ (Q[14], QI[14]);
	buf gBufQ_15_ (Q[15], QI[15]);
	buf gBufQ_16_ (Q[16], QI[16]);
	buf gBufQ_17_ (Q[17], QI[17]);
	buf gBufQ_18_ (Q[18], QI[18]);
	buf gBufQ_19_ (Q[19], QI[19]);
	buf gBufQ_20_ (Q[20], QI[20]);
	buf gBufQ_21_ (Q[21], QI[21]);
	buf gBufQ_22_ (Q[22], QI[22]);
	buf gBufQ_23_ (Q[23], QI[23]);
	buf gBufQ_24_ (Q[24], QI[24]);
	buf gBufQ_25_ (Q[25], QI[25]);
	buf gBufQ_26_ (Q[26], QI[26]);
	buf gBufQ_27_ (Q[27], QI[27]);
	buf gBufQ_28_ (Q[28], QI[28]);
	buf gBufQ_29_ (Q[29], QI[29]);
	buf gBufQ_30_ (Q[30], QI[30]);
	buf gBufQ_31_ (Q[31], QI[31]);
`ifdef ATPG_RUN
`else
integer i;
`endif

// logic:
not	gNotSupply (SL_OK, SL_);
not     gNotENM  (enable, CEn_);

`ifdef ATPG_RUN
and gAndENM (enableMem, enable, 1'b1);
`else
reg rt;
and gAndENM (enableMem, enable, rt);
`endif

not gNotWeb (WEnB, WEn_);
and gAndCleanWR  (cleanWrite, enableMem, WEnB);
and gAndPossRD  (possRead, enableMem, WEn_);

not gNotCW (cleanWriteN, cleanWrite);
and gAndRW (RW, possRead, cleanWriteN);

//*********************************

reg NOTIFY_REG, NOTIFY_A, NOTIFY_WEn;

XSPRAMLP_2048X32_M8P_tmax sub1 (.QI(QI[31:0]), .D(D_[31:0]), .A(A_[10:0]), .CLK(CLK_), .possRead(possRead), .cleanWrite(cleanWrite), .Q_OK(T_OK_Q));

// CLK short pulse generator
XSPRAMLP_2048X32_M8P_RDYC sub2 (CLK_, CLKD, CLKDZ);
xnor gCSP (CSP, CLKD, CLKDZ);
// 
XSPRAMLP_2048X32_M8P_RDY sub3 (CSP, RX, RY, WEn_);
xor	gRDY (RDYi, RX, RY);
//
buf RDYB (RDY, RDY_);
and	g36 (RDY_, RDYi, T_OK_R);
XSPRAMLP_2048X32_M8P_DFF CHK_R (T_OK_R, enable, CLK_, 1'b1, 1'b1, 1'b1);

`ifdef ATPG_RUN
`else
//parameter ram_init_file = "";
//initial
//begin
//	if(ram_init_file !== "") $readmemb(ram_init_file, sub1.RAM_matrix);
//end
`endif

XSPRAMLP_2048X32_M8P_DFF CHK_A (T_OK_A, SL_OK, CLK_, 1'b1, 1'b1, NOTIFY_A);

XSPRAMLP_2048X32_M8P_DFF CHK_Q (T_OK_QI, SL_OK, CLK_, 1'b1, 1'b1, NOTIFY_REG);

XSPRAMLP_2048X32_M8P_DFF CHK_WEn (RWL, RW, CLK_, 1'b1, 1'b1, NOTIFY_WEn);

and gAndOk (TOK, T_OK_QI, T_OK_A, RWL);
not gNotRW (NRWL, RWL);
or gOrOk (T_OK_Q, NRWL, TOK);

//**************************************************
specify
`ifdef DEFAULT_WORST_DELAY_OFF
// unit delay: 
specparam
		A_SETUP_TIME = 0.02,
		A_HOLD_TIME  = 0.02,
		CEn_SETUP_TIME = 0.02,
		CEn_HOLD_TIME  = 0.02,
		WEn_SETUP_TIME = 0.02,
		WEn_HOLD_TIME  = 0.02,
		D_SETUP_TIME   = 0.02,
		D_HOLD_TIME    = 0.02,
		CLK_LOW_TIME   = 0.02,
		CLK_HIGH_TIME  = 0.02,
		CYCLE_TIME     = 0.04,
		ACCESS_TIME    = 0.02,
		SL_SETUP_TIME = 0.02,
		SL_HOLD_TIME  = 0.02,
		RDY_HIGH_TIME_READ = 0.02,
		RDY_LOW_TIME_READ = 0.03,
		RDY_HIGH_TIME_WRITE = 0.02,
		RDY_LOW_TIME_WRITE = 0.03;

`else

// worst operating conditions according to the specification:
// PVT:          slow, 1.62V, 175C
// input slope:  0.4ns
// CLoad:        0.2pF
specparam
		A_SETUP_TIME = 2.143,
		A_HOLD_TIME  = 2.047,
		CEn_SETUP_TIME = 4.401,
		CEn_HOLD_TIME  = 0.505,
		WEn_SETUP_TIME = 1.896,
		WEn_HOLD_TIME  = 1.501,
		D_SETUP_TIME   = 1.489,
		D_HOLD_TIME    = 1.272,
		CLK_LOW_TIME   = 1.434,
		CLK_HIGH_TIME  = 0.892,
		CYCLE_TIME     = 9.696,
		ACCESS_TIME    = 6.826,
		SL_SETUP_TIME = 7.576,
		SL_HOLD_TIME  = 6.721,
		RDY_HIGH_TIME_READ = 1.068,
		RDY_LOW_TIME_READ = 5.144,
		RDY_HIGH_TIME_WRITE = 1.09,
		RDY_LOW_TIME_WRITE = 4.171;
`endif
	(posedge CLK => (Q[0] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[1] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[2] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[3] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[4] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[5] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[6] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[7] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[8] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[9] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[10] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[11] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[12] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[13] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[14] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[15] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[16] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[17] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[18] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[19] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[20] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[21] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[22] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[23] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[24] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[25] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[26] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[27] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[28] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[29] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[30] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);
	(posedge CLK => (Q[31] : 1'b0)) = (ACCESS_TIME, ACCESS_TIME);

	if((WEn==1'b1)&&(CLK!=1'b0)) (posedge CLK => (RDY : 1'b0)) = (RDY_HIGH_TIME_READ, RDY_LOW_TIME_READ);
	if((WEn==1'b0)&&(CLK!=1'b0)) (posedge CLK => (RDY : 1'b0)) = (RDY_HIGH_TIME_WRITE, RDY_LOW_TIME_WRITE);

`ifdef     NEG_TCHK
	$setuphold  (posedge CLK &&& enableMem, posedge A[0], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[0]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[0], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[0]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[1], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[1]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[1], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[1]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[2], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[2]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[2], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[2]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[3], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[3]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[3], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[3]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[4], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[4]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[4], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[4]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[5], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[5]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[5], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[5]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[6], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[6]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[6], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[6]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[7], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[7]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[7], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[7]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[8], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[8]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[8], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[8]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[9], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[9]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[9], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[9]);
	$setuphold  (posedge CLK &&& enableMem, posedge A[10], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[10]);
	$setuphold  (posedge CLK &&& enableMem, negedge A[10], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A,,, CLK_d, A_d[10]);

	$setuphold  (posedge CLK &&& cleanWrite, posedge D[0], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[0]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[0], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[0]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[1], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[1]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[1], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[1]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[2], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[2]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[2], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[2]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[3], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[3]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[3], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[3]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[4], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[4]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[4], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[4]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[5], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[5]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[5], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[5]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[6], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[6]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[6], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[6]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[7], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[7]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[7], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[7]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[8], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[8]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[8], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[8]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[9], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[9]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[9], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[9]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[10], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[10]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[10], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[10]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[11], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[11]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[11], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[11]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[12], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[12]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[12], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[12]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[13], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[13]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[13], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[13]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[14], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[14]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[14], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[14]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[15], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[15]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[15], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[15]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[16], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[16]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[16], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[16]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[17], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[17]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[17], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[17]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[18], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[18]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[18], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[18]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[19], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[19]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[19], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[19]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[20], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[20]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[20], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[20]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[21], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[21]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[21], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[21]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[22], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[22]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[22], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[22]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[23], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[23]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[23], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[23]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[24], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[24]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[24], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[24]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[25], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[25]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[25], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[25]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[26], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[26]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[26], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[26]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[27], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[27]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[27], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[27]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[28], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[28]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[28], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[28]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[29], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[29]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[29], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[29]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[30], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[30]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[30], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[30]);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[31], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[31]);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[31], D_SETUP_TIME, D_HOLD_TIME,,,, CLK_d, D_d[31]);

	$setuphold  (posedge CLK, posedge CEn, CEn_SETUP_TIME, CEn_HOLD_TIME, NOTIFY_REG,,, CLK_d, CEn_d);
	$setuphold  (posedge CLK, negedge CEn, CEn_SETUP_TIME, CEn_HOLD_TIME, NOTIFY_REG,,, CLK_d, CEn_d);


	$setuphold  (posedge CLK, posedge SL, SL_SETUP_TIME, SL_HOLD_TIME, NOTIFY_REG,,, CLK_d, SL_d);
	$setuphold  (posedge CLK, negedge SL, SL_SETUP_TIME, SL_HOLD_TIME, NOTIFY_REG,,, CLK_d, SL_d);

	$setuphold  (posedge CLK &&& enableMem, posedge WEn, WEn_SETUP_TIME, WEn_HOLD_TIME, NOTIFY_WEn,,, CLK_d, WEn_d);
	$setuphold  (posedge CLK &&& enableMem, negedge WEn, WEn_SETUP_TIME, WEn_HOLD_TIME, NOTIFY_WEn,,, CLK_d, WEn_d);

`else
	$setuphold  (posedge CLK &&& enableMem, posedge A[0], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[0], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[1], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[1], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[2], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[2], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[3], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[3], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[4], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[4], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[5], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[5], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[6], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[6], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[7], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[7], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[8], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[8], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[9], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[9], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, posedge A[10], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);
	$setuphold  (posedge CLK &&& enableMem, negedge A[10], A_SETUP_TIME, A_HOLD_TIME, NOTIFY_A);

	$setuphold  (posedge CLK &&& cleanWrite, posedge D[0], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[0], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[1], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[1], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[2], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[2], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[3], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[3], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[4], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[4], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[5], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[5], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[6], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[6], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[7], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[7], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[8], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[8], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[9], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[9], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[10], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[10], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[11], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[11], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[12], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[12], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[13], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[13], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[14], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[14], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[15], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[15], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[16], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[16], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[17], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[17], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[18], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[18], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[19], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[19], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[20], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[20], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[21], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[21], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[22], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[22], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[23], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[23], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[24], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[24], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[25], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[25], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[26], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[26], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[27], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[27], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[28], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[28], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[29], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[29], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[30], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[30], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, posedge D[31], D_SETUP_TIME, D_HOLD_TIME);
	$setuphold  (posedge CLK &&& cleanWrite, negedge D[31], D_SETUP_TIME, D_HOLD_TIME);

	$setuphold  (posedge CLK, posedge SL, SL_SETUP_TIME, SL_HOLD_TIME, NOTIFY_REG);
	$setuphold  (posedge CLK, negedge SL, SL_SETUP_TIME, SL_HOLD_TIME, NOTIFY_REG);


	$setuphold  (posedge CLK, posedge CEn, CEn_SETUP_TIME, CEn_HOLD_TIME, NOTIFY_REG);
	$setuphold  (posedge CLK, negedge CEn, CEn_SETUP_TIME, CEn_HOLD_TIME, NOTIFY_REG);

	$setuphold  (posedge CLK &&& enableMem, posedge WEn, WEn_SETUP_TIME, WEn_HOLD_TIME, NOTIFY_WEn);
	$setuphold  (posedge CLK &&& enableMem, negedge WEn, WEn_SETUP_TIME, WEn_HOLD_TIME, NOTIFY_WEn);

`endif
	$width (posedge CLK &&& enableMem, CLK_HIGH_TIME, 0, NOTIFY_REG);
	$width (negedge CLK &&& enableMem, CLK_LOW_TIME, 0, NOTIFY_REG);

	$period (posedge CLK &&& enableMem, CYCLE_TIME, NOTIFY_REG);
	$period (negedge CLK &&& enableMem, CYCLE_TIME, NOTIFY_REG);

endspecify
`ifdef ATPG_RUN
`else
initial begin
	$timeformat (-9, 2, " ns", 0);
	rt = 1'b0;
	#250 ;		// no RAM activity permitted for first 250n sec. of sim.
	rt = 1'b1;
	end
always @(posedge CLK_)
	begin
	if(rt === 1'b0)
		begin
		if (CEn_ === 1'b0 ) $display ("\n%t: ERROR: %m : RAM enabled during initial 250ns: RAM content UNDEFINED\n", $realtime); 
		end
	if((SL_OK === 1'b0)&&( enableMem === 1'b1)) begin
	$display ("\n%t: ERROR: %m : CLK rise during light sleep mode\n", $realtime);
	for(i = 0; i < 2048; i = i + 1) sub1.RAM_matrix[i] = 32'bX;
	end
	end
`endif

endmodule

`nosuppress_faults
`disable_portfaults

`endcelldefine

