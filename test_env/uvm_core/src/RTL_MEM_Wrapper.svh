//////////////////////////////////////////
//	RTL_MEM_Wrapper						//
//	Modulo donde se unifica el codigo	//
//	RTL de SIWA y IP de memoria			//
//	Programador: Javier Espinoza Rivera	//
// 	Supervisor: Roberto Molina 			//
//////////////////////////////////////////

`include "../../Verificacion_RISCV_TEC/TEC_RISCV/TOP/topcore_tecriscv.sv"
`include "../../Verificacion_RISCV_TEC/test_env/core_spi_uart/IS25WP032D.v"



module RTL_MEM_Wrapper (wrapper_if _if);
	wire MISO;
	wire MOSI;
	wire SCLK;
	wire SCS;
	
	topcore_tecriscv uut(
	.clk(_if.clk),
	.reset(_if.reset),
	.MISO(MISO),
	.RX_UART(_if.RX_UART),
	.maip(_if.maip),
	.MOSI(MOSI),
	.SCLK(SCLK),
	.SCS(SCS),
	.TX_UART(_if.TX_UART),
	.full_range_level_shifter(_if.full_range_level_shifter),
	.IS_Val(_if.IS_Val),
	.IS_Config(_if.IS_Config),
	.IS_Trigger(_if.IS_Trigger),
	.Reg_GPIO_en(_if.Reg_GPIO_en),
	.Reg_GPIO_int(_if.Reg_GPIO_int),
	.Reg_GPIO_out(_if.Reg_GPIO_out)
	);

	IS25WP032D mem(
		.SCLK(SCLK),
		.CS(SCS),
		.SI(MOSI),
		.SO(MISO),
		.WP(1'b1),
		.SIO3(1'b1));

endmodule : RTL_MEM_Wrapper