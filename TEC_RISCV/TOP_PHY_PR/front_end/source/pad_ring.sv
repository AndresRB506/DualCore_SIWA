
//Modulo de interconexion de pads
// 
// PADs y Level Shifters
//`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC1V8/v1_0/verilog/v1_0_0/IO_CELLS_FC1V8.v"

//`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_FC3V/v1_1/verilog/v1_1_0/IO_CELLS_FC3V.v"

//`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v"

module pad_ring (input clk_pad,
		 input reset_pad,
		 input MISO_pad),
		 input RX_UART_pad,
		 output MOSI_pad,
		 output SCLK_pad,
		 output SCS_pad,
		 output TX_UART_pad,
	         input gpio_pad
);

// PAD inputs
ICFA clk_pad_inst (.PAD(clk_pad), .PI(gnd_en), .PO(), .Y(clk)); // 
ICFA reset_pad_inst (.PAD(reset_pad), .PI(gnd_en), .PO(), .Y(reset)); 
ICFA MISO_pad_inst (.PAD(MISO_pad), .PI(gnd_en), .PO(), .Y(MISO)); 
ICFA RX_UART_pad_inst (.PAD(RX_UART_pad), .PI(gnd_en), .PO(), .Y(RX_UART)); 

// PAD outputs

BT2SFA MOSI_pad_inst (.PAD(MOSI_pad), .EN(gnd_en), .A(MOSI));
BT2SFA SCLK_pad_inst (.PAD(SCLK_pad), .EN(gnd_en), .A(SCLK));
BT2SFA SCS_pad_inst (.PAD(SCS_pad), .EN(gnd_en), .A(SCS));
BT2SFA TX_UART_pad_inst (.PAD(TX_UART_pad), .EN(gnd_en), .A(TX_UART));

// BID PADs 
// Check this later for GPIO real directions

genvar pad_i;
generate
  for (pad_i=0; pad_i<8; pad_i=pad_i+1)
	begin :pad_bit
		ICFA ICFA_pad_inst (.PAD(gpio_pad[pad_i]), .PI(gnd_en), .PO(), .Y(gpio[pad_i])); 
        end
endgenerate

endmodule
