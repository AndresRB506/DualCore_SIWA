`define DEBUG
`timescale 1ns/10ps
`include "../TOP/Tec_Riscv_pads_phy_no_pg.v"
//`include "../TOP/topcore_tecriscv.sv"
//`include "../TOP/Status.sv"
`include "../TOP/XSPRAMLP_2048X32_M8P.sv"
`include "../TOP/IS25WP032D.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_F3V/v2_1/verilog/v2_1_0/IO_CELLS_F3V_UPF.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v"
//`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC3V/v1_1/verilog/v1_1_0/IO_CELLS_FC3V.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/verilog/v2_1_0/D_CELLS_HDLL.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/verilog/v2_1_0/VLG_PRIMITIVES.v"

module Test_Top;

	logic clk;
	logic reset;
	wire  MISO;
	logic RX_UART;
	logic maip;
	wire MOSI;
	wire SCLK;
	wire SCS;
	wire TX_UART;
	wire [7:0] full_range_level_shifter;
        wire [31:0] IS_Val;
        wire [31:0] IS_Config;
        wire [3:0] IS_Trigger;
	wire [7:0] gpio;
        wire [7:0] Reg_GPIO;

 top_riscv_tec_pads uut (
	.clk_pad(clk),
	.reset_pad(reset),
	.MISO_pad(MISO),
	.RX_UART_pad(RX_UART),
	.maip_pad(maip),
	.MOSI_pad(MOSI),
	.SCLK_pad(SCLK),
	.SCS_pad(SCS),
	.TX_UART_pad(TX_UART),
	.full_range_level_shifter(full_range_level_shifter),
        .IS_Val(IS_Val),
        .IS_Config(IS_Config),
        .IS_Trigger(IS_Trigger),
        .gpio_pad(Reg_GPIO)
        );


	IS25WP032D mem(
		.SCLK(SCLK),
		.CS(SCS),
		.SI(MOSI),
		.SO(MISO),
		.WP(1'b1),
		.SIO3(1'b1));

  initial begin
     reset <= 1;
     clk <= 0;
//     Reg_GPIO<=0;
     maip <=0;
     RX_UART <= 1;
  end
    
  always #100 clk = ~clk;
  always@(posedge clk) begin
    prueba ();
  end 
  task prueba();
  
     if($time < 350000) begin
       reset <= 1;
       RX_UART <= 1;
     end else begin 
       reset <= 0;
       if($time >100000000) begin
         $finish;
       end
     end
     

  endtask


endmodule
