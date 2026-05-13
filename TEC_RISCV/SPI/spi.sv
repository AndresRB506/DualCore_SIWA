`timescale 1ns / 10ps
/********************************************************************************
Bootstrap DCILAB 2018
Instituto Tecnologico de Costa Rica

Ing. Diego Salazar Sibaja

Modulo: SPI

Descripcion general:
*********************************************************************************/


module spi#(parameter DATA_IN=64, DATA_OUT=32)(CLK, reset, MISO, data_config, config_enable,data_send, send_data, data_read, MOSI,CS,SCK, end_send);

input 							CLK; 			//Señal de reloj
input							reset;
input		 					MISO;			//MISO
input 			[15:0]			data_config; 	//Señal de configuración de SPI
input							config_enable;	//Bandera de configuración SPI
input			[DATA_IN-1:0]	data_send;		//dato de envio
input 							send_data;
output	logic 	[DATA_OUT-1:0]	data_read;		//dato de recepcion
output	logic					MOSI;			//MOSI
output 	logic 					CS;				//Chip Select
output 	logic 					SCK;
output  logic					end_send;


//*****Parametros locales
localparam DIV_CLK1		= 8'd1;
localparam DIV_CLK2		= 8'd3;
localparam DIV_CLK3		= 8'd7;
localparam DIV_CLK4		= 8'd15;
localparam DIV_CLK5		= 8'd31;
localparam SHIFT_SIZETX	= 8'd64;
localparam SHIFT_SIZERX	= 8'd32;
localparam COUNT_SIZE	= 8'd8;
localparam DATA_LOC 	= 8'd8;
localparam START		= 32'd0;
localparam LOAD 		= 32'd1;
localparam OPER			= 32'd2;
localparam END 			= 32'd3;
localparam END1			= 32'd4;

//*****Variables internas
logic [15:0]				conf ; 		//Configuración SPI
logic [DATA_LOC-1:0]		counter_clk;	//Contador para generar SPICLK
logic [DATA_IN-1:0]			tx_shiftreg;	//Registro para serializar los datos de salida
logic [1:0]					flag_edge_detector; //Detector de flanco
logic						tx_loaddata;    //Bandera para carga de dato en TX shift reg
logic [DATA_LOC-1:0]		bits_count;		//Contador de bits
logic [DATA_OUT-1:0]		rx_shiftreg;		//Reg shift de datos de recepcion
logic						clk_enable; 	//Habilitacion de reloj
logic						state0;			//Bandera para reiniciar valores de envio de byte
logic [DATA_LOC-1:0]		state;
logic						MISO1;
logic [DATA_LOC-1:0]		counter_CS; 	//Contador para tiempo mínimo de CS




//*****Configuración SPI
always@(negedge CLK or posedge reset) begin
	if(reset)begin
		conf <= 16'd0;
	end
	else begin
		if(config_enable) begin
			conf   <= data_config;
		end
		else begin
			conf   <= conf;
		end
	end
end

always@(negedge CLK or posedge reset) begin
	if(reset)begin
		MISO1 = 1'b0;
	end
	else begin
		MISO1 = MISO;
	end
end

//*****Generador de reloj SPI //REORDENAR
always@(posedge CLK or posedge reset) begin
	if(reset)begin
		if(conf[1]) begin
			SCK	<= 1'b0;
		end
		else begin
			SCK	<= 1'b1;
		end
		counter_clk <= 8'h00;
	end
	else begin
		if(clk_enable && !conf[7]) begin
			if(conf[6:4] == 3'd0 && counter_clk == DIV_CLK2) begin
				SCK	<= ~SCK;
				counter_clk <= 8'h00;
			end 
			else begin
				if(conf[6:4] == 3'd1 && counter_clk == DIV_CLK2) begin
					SCK	<= ~SCK;
					counter_clk <= 8'h00;
				end 
				else begin
					if(conf[6:4]== 3'd2 && counter_clk == DIV_CLK3) begin
						SCK	<= ~SCK;
						counter_clk <= 8'h00;
					end 
					else begin
						if(conf[6:4] == 3'd3 && counter_clk == DIV_CLK4) begin
							SCK	<= ~SCK;
							counter_clk <= 8'h00;
						end 
						else begin
							if(conf[6] == 1'b1 && counter_clk == DIV_CLK5) begin
								SCK	<= ~SCK;
								counter_clk <= 8'h00;
							end 
							else begin
								counter_clk <= counter_clk + 8'h01;
							end
						end
					end
				end
			end
		end
		else begin
			counter_clk	<= 8'h0; 
			if(conf[1]) begin
				SCK	<= 1'b0;
			end
			else begin
				SCK	<= 1'b1;
			end
		end	
	end
end


//*****Contadores
always@(posedge CLK or posedge reset) begin
	if(reset)begin
		bits_count <= 1'b0;
	end
	else begin
		if((flag_edge_detector == 2'b10 && !conf[7] && bits_count == conf[15:8]) || state0)begin
			bits_count <= 0;
		end
		else if(flag_edge_detector == 2'b10 && !conf[7] && bits_count != conf[15:8])begin
			bits_count <= bits_count + 1'b1;
		end
	end
end


//*****Detector de flanco
always@(negedge CLK or posedge reset) begin
	if(reset)begin
		flag_edge_detector = 2'd0;
	end 
	else begin
		flag_edge_detector = {SCK,flag_edge_detector[1]};
	end
end	


 //*****Registro y registro shift RX
always@(posedge CLK or posedge reset) begin
	if (reset)begin
		rx_shiftreg = 0;
		data_read = 0;
	end
	else begin
		if(flag_edge_detector == 2'b10 && !conf[7])begin //MODIFICAR
			if(conf[2])begin
				rx_shiftreg = {rx_shiftreg[SHIFT_SIZERX-2:0],MISO1};
			end
			else begin
				rx_shiftreg = {MISO1,rx_shiftreg[SHIFT_SIZERX-1:1]};
			end
			data_read = rx_shiftreg;
		end
		else begin
			rx_shiftreg = rx_shiftreg;
			data_read = data_read;
		end
	end

end 

//*****Registro y registro shift TX
always@(posedge CLK or posedge reset) begin
	if(reset) begin
	  tx_shiftreg = 64'hFFFFFFFFFFFFFFFF;  
	  MOSI = 1'b1; 
	end  
	else begin
		if(tx_loaddata) begin //load data into transmission_reg
			tx_shiftreg = data_send; 
			if(conf[2])begin
				MOSI = tx_shiftreg[SHIFT_SIZETX-1]; 
			end
			else begin
				MOSI = tx_shiftreg[0];
			end 
		end 
		else begin
			if(flag_edge_detector == 2'b01 && !conf[7] && bits_count != 8'h00 )begin
				if(conf[2])begin
					tx_shiftreg = {tx_shiftreg[SHIFT_SIZETX-2:0],1'b1}; 
					MOSI = tx_shiftreg[SHIFT_SIZETX-1]; 
				end
				else begin
					tx_shiftreg = {1'b1,tx_shiftreg[SHIFT_SIZETX-1:1]}; 
					MOSI = tx_shiftreg[0];
				end
			end
			else begin
				tx_shiftreg = tx_shiftreg;  
	  			MOSI = MOSI;
			end
		end
	end
end

//*****Maquina para envio y recepcion de datos // INCLUIR DIVISION DE DATA Y DIRECCIPON
always @(negedge CLK or posedge reset)begin
	if(reset)begin
		tx_loaddata <= 1'b0;
		end_send <= 1'b0;
		state <= START;
		state0 <= 1'b1;
		clk_enable <= 1'b0;
		counter_CS <= 8'd0;
		if(conf[3])begin
			CS <= 1'b0;
		end
		else begin
			CS <= 1'b1;
		end
	end
	else begin
		if(!conf[0] || conf[7])begin
			tx_loaddata <= 1'b0;
			end_send <= 1'b0;
			state <= START;
			state0 <= 1'b1;
			clk_enable <= 1'b0;
			counter_CS <= 8'd0;
			if(conf[3])begin
				CS <= 1'b0;
			end
			else begin
				CS <= 1'b1;
			end
		end

		else begin
			case(state)
			START:begin
				end_send <= 1'b0;
				state0 <= 1'b1;
				clk_enable <= 1'b0;
				counter_CS <= 8'd0;
				if(conf[3])begin
					CS <= 1'b0;
				end
				else begin
					CS <= 1'b1;
				end
				if(send_data)begin
					state <= LOAD;
					tx_loaddata <= 1'b1;
				end
				else begin
					state <= START;
					tx_loaddata <= 1'b0;
				end
			end
			LOAD: begin
				end_send <= 1'b0;
				state0 <= 1'b0;
				clk_enable <= 1'b1;
				tx_loaddata <= 1'b0;
				state <= OPER;
				counter_CS <= 8'd0;
				if(conf[3])begin
					CS <= 1'b0;
				end
				else begin
					CS <= 1'b1;
				end
			end
			OPER: begin
				tx_loaddata <= 1'b0;
				counter_CS <= 8'd0;
				end_send <= 1'b0;
				if(conf[3])begin
					CS <= 1'b1;
				end
				else begin
					CS <= 1'b0;
				end
				if(bits_count == conf[15:8])begin
					state <= END;
					state0 <= 1'b1;
					clk_enable <= 1'b0;
				end
				else begin
					state <= OPER;
					state0 <= 1'b0;
					clk_enable <= 1'b1;
				end
			end
			END: begin
				tx_loaddata <= 1'b0;
				state0 <= 1'b1;
				clk_enable <= 1'b0;
				counter_CS <= counter_CS + 8'd1;
				if(conf[3])begin
					CS <= 1'b0;
				end
				else begin
					CS <= 1'b1;
				end
				if(counter_CS == 8'd16)begin
					state <= END1;
					end_send <= 1'b1;
				end
				else begin
					state <= END;
					end_send <= 1'b0;
				end
			end
			END1: begin
				tx_loaddata <= 1'b0;
				end_send <= 1'b0;
				state0 <= 1'b1;
				clk_enable <= 1'b0;
				counter_CS <= 8'd0;
				state <= START;
				if(conf[3])begin
					CS <= 1'b0;
				end
				else begin
					CS <= 1'b1;
				end			
			end
			default: state <= START;
			endcase
		end
	end
end



endmodule
