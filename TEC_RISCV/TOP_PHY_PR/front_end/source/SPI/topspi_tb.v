`timescale 1ns / 1ps

module topspi_tb;

//Entradas
reg						CLK; //RELOJ
reg 					reset;
reg 					pndgn; //Pendiente FIFO TX
reg	 	[63:0]			D_out;	//Datos FIFO TX
reg						full_tx; //Bandera Full TX FIFO donde se sacan datos
reg 					MISO; //Signal of SPI

//Salidas
wire					pop; //Control FIFO TX
wire [63:0]				D_in; //Datos FIFO RX
wire					push; //Control FIFO RX
wire					MOSI; //SPI
wire					SCLK; //SPI
wire					SCS; //SPI

//*****Parametros locales
parameter FIFO_DATA=8'd65, INDEX = 3, ORIGEN = 2, DESTINO = 3, ADDR =25, DATA =32;
//Parametros para descomponer datos de FIFO
localparam DESTINO1 = FIFO_DATA-1;
localparam DESTINO2 = FIFO_DATA-DESTINO;
localparam ORIGEN1 	= DESTINO2-1;
localparam ORIGEN2 	= DESTINO2-ORIGEN;
localparam INDEX1 	= ORIGEN2-1;
localparam INDEX2 	= ORIGEN2-INDEX;
localparam INDEX3	= INDEX2-4;
localparam ADDR1 	= INDEX2-1;
localparam ADDR2 	= INDEX2-ADDR;
localparam DATA1 	= ADDR2-1;
//Variables locales
localparam LOCAL_V = 8'd5;
//Comandos para memoria IS25WP032D
localparam WRITE_EN = 8'h06;
localparam WRITE_DB = 8'h04;
localparam WRITE_COMM = 8'h02;
localparam READ_COMM = 8'h03;
localparam READ_STAT = 8'h05;
//Codigo de bytes para envio
localparam FOURBYTE	= 4'h0;
localparam TWOBYTE	= 4'h1;
localparam ONEBYTE	= 4'h3;
//Codido de dispositivos
localparam SPI 		= 2'b01;
localparam MMU		= 2'b00;
//Códigos de Index
localparam READ_BYTE = 3'h1;
localparam READ_2BYTE = 3'h2;
localparam READ_4BYTE = 3'h0;
localparam WRITE_BYTE = 3'h5;
localparam WRITE_2BYTE = 3'h6;
localparam WRITE_4BYTE = 3'h4;
localparam START_BST 	= 3'h7;
localparam END_BST 		= 3'h3;


top_spi uut(
	.CLK(CLK),
	.reset(reset),
	.pndgn(pndgn),
	.D_out(D_out),
	.full_tx(full_tx),
	.MISO(MISO),
	.pop(pop),
	.D_in(D_in),
	.push(push),
	.MOSI(MOSI),
	.SCLK(SCLK),
	.SCS(SCS)
);

initial begin
	//$vcdpluson;
	//$dumpfile("top_spi.vcd");
	//$dumpvars(0,top_spi);
	CLK=0;
	reset = 0;
	pndgn =0;
	D_out = 64'd0;
	full_tx = 0;
	MISO = 0;
	repeat (2) begin
		@(negedge CLK);
	end
	reset = 1;
	repeat (2) begin
		@(negedge CLK);
	end
	reset = 0;
	repeat (32) begin
		@(negedge CLK);
	end
	pndgn =1;
	D_out = {1'b0,SPI,MMU,START_BST,25'h555555,32'hAAAAAAAA};
	repeat (2) begin
		@(negedge CLK);
	end
	pndgn =0;
	repeat (800) begin
		@(negedge CLK);
	end
	pndgn =1;
	D_out = {1'b0,SPI,MMU,START_BST,25'h555555,32'hAAAAAAAA};
	repeat (2) begin
		@(negedge CLK);
	end
	pndgn =0;
	repeat (800) begin
		@(negedge CLK);
	end
	pndgn =1;
	D_out = {1'b0,SPI,MMU,START_BST,25'h555555,32'hAAAAAAAA};
	repeat (2) begin
		@(negedge CLK);
	end
	pndgn =0;
	MISO=1;
	repeat (800) begin
		@(negedge CLK);
	end
	$display("All tests completed successfully\n\n");
	
	$finish;
end

always begin
	#25 CLK = ~CLK;
end

//always begin
//	#50 MISO = ~MISO;
//end

endmodule
