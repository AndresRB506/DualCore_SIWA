//////////////////////////////////////////
//	Interface: wrapper_if				//
//	Interface que permite comunicar el	//
//	entorno de prueba con el RTL		//
//	Programador: Javier Espinoza Rivera	//
// 	Supervisor: Roberto Molina 			//
//////////////////////////////////////////

interface wrapper_if(input clk);
	logic reset;
	logic  [7:0] gpio;
	logic [7:0] full_range_level_shifter;
	logic [31:0] IS_Val;
	logic [31:0] IS_Config;
	logic [3:0] IS_Trigger;
	logic maip;
	logic [7:0] Reg_GPIO_en;
	logic [7:0] Reg_GPIO_int;
	logic [7:0] Reg_GPIO_out;
	logic TX_UART;
	logic RX_UART;
	
endinterface : wrapper_if
