`include "../SPI/spi.sv"
`timescale 1ns / 10ps
/********************************************************************************
Bootstrap DCILAB 2018
Instituto Tecnologico de Costa Rica

Ing. Diego Salazar Sibaja

Modulo: TOP_SPI

Descripcion general:
*********************************************************************************/
module top_spi #(parameter FIFO_DATA=8'd65, INDEX = 3, ORIGEN = 2, DESTINO = 3, ADDR =25, DATA =32)
				(CLK, reset, pndgn, D_pop, MISO, pop, D_push, push, MOSI, SCLK, SCS);
//Entradas
input							CLK; //RELOJ
input 							reset;
input 							pndgn; //Pendiente FIFO TX
input	 	[FIFO_DATA-1:0]		D_pop;	//Datos FIFO TX
input 							MISO; //Signal of SPI
//Salidas
output	logic					pop; //Control FIFO TX
output	[FIFO_DATA-1:0]			D_push; //Datos FIFO RX
output	logic					push; //Control FIFO RX
output							MOSI; //SPI
output  						SCLK; //SPI
output 							SCS; //SPI

//*****Parametros locales
//Parametros para descomponer datos de FIFO
localparam DESTINO1 = FIFO_DATA-1;
localparam DESTINO2 = FIFO_DATA-DESTINO;
localparam ORIGEN1 	= DESTINO2-1;
localparam ORIGEN2 	= DESTINO2-ORIGEN;
localparam INDEX1 	= ORIGEN2-1;
localparam INDEX2 	= ORIGEN2-INDEX;
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


//Variables internas
logic [LOCAL_V-1:0]			state;//Estados de maquina principal
logic [FIFO_DATA-1:0]		data_pop; //Dato de FIFO
logic [FIFO_DATA-1:0]		data_push; //Dato para FIFO
logic [ADDR-2:0]			address; //Extracción de dirección //modificado a 24
logic [INDEX-1:0]			index; //Extracción de index
logic [DATA-1:0]			data; //Extracción de dato
logic [DATA-1:0]		 	t_word;//Palabra recuperada del SPI
logic [15:0]				tspi_data_config; //Palabra de configuración del SPI
logic						tspi_config_en; //Bandera de configuración del SPI
logic [2*DATA-1:0]			tspi_data_tx; //Dato de envio para el SPI -- Se envian MSB
logic						tspi_send_data; //Bandera para envio de dato
logic [ADDR-2:0]			bst_addr; //Address for bootloader
logic [DATA-1:0]			data_read; //Señal del SPI
logic 						end_send;

//Asignación de wires
assign D_push = data_push;


//Máquina de estados para pop o push en FIFO
always_ff@(posedge CLK or posedge reset)begin
	if(reset) begin
		pop <= 1'b0;
		push <= 1'b0;
		data_push <= 88'd0;
		data_pop <= 88'd0;
		tspi_send_data <= 1'b0;
		tspi_config_en <= 1'b0;
		tspi_data_config <= 16'd0;
		tspi_data_tx <= 64'd0;
		bst_addr <= 24'd0;
		t_word <= 32'd0;
		index <= 8'd0;
		address <= 24'd0;
		data <= 32'd0;
		state <= 8'd0;
	end
	else begin
		case(state)
		5'd0: begin // Inicializa valores
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= 64'd0;
			bst_addr <= 24'd0;
			t_word <= 32'd0;
			index <= 3'd0;
			address <= 24'd0;
			data <= 32'd0;
			state <= 5'd1;
		end
		5'd1:begin //Valora si existe algún dato en la FIFO
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= 3'd0;
			address <= 24'd0;
			data <= 32'd0;
			if(pndgn)begin
				state <= 5'd2;
				pop <= 1'b1;
				data_pop <= D_pop;
			end
			else begin
				state <= 5'd1;
				pop <= 1'b0;
				data_pop <= 64'd0;
			end
		end
		5'd2:begin //Evalua las secciones del dato FIFO
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 88'd0;
			data_pop <= data_pop;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= data_pop[INDEX1:INDEX2];
			address <= data_pop[ADDR1-2:ADDR2];
			data <= data_pop[DATA1:0];
			if(data_pop[DESTINO1:DESTINO2] == 2'b01)begin
				if(data_pop[INDEX1:INDEX2] == START_BST)begin
					state <= 5'd3;
				end
				else begin
					if(data_pop[INDEX1:INDEX2] == WRITE_BYTE || data_pop[INDEX1:INDEX2] == WRITE_2BYTE || data_pop[INDEX1:INDEX2] == WRITE_4BYTE)begin //Write
						state <= 5'd9;
					end
					else if(data_pop[INDEX1:INDEX2] == READ_BYTE || data_pop[INDEX1:INDEX2] == READ_2BYTE || data_pop[INDEX1:INDEX2] == READ_4BYTE)begin //Read
						state <= 8'd22;
					end
				end
			end
			else begin
				state <= 5'd1;
			end
		end
	//*************************************************************************//
	//	Maquina de estados de bootloader									   //
	//*************************************************************************//
		5'd3:begin //Configutacion del SPI
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_config <= 16'h4015;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//START_ADDR;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd4;
		end
		5'd4: begin //Envio de palabra de escritura en mem
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= {READ_COMM,bst_addr,32'hFFFFFF};
			bst_addr <= bst_addr;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd5;
		end
		5'd5: begin // Se espera que SPI termine dato y se captura
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr;
			index <= index;
			address <= bst_addr;//address;
			data <= data;
			if(end_send)begin
				state <= 8'd6;
				t_word <= data_read;
			end
			else begin
				state <= 8'd5;
				t_word <= 32'd0;
			end
		end
		5'd6: begin //Se evalua si la direccion de bootloader ya llego al final y se aumenta dirección
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr+24'd4;
			t_word <= t_word;
			index <= index;
			address <= address;
			data <= data;
			if(t_word == 32'hFFFFFFFF) begin//(t_word[7:0] == 8'hFF) begin //CAMBIO
				state <= 5'd8;
			end
			else begin
				state <= 5'd7;
			end
		end
		5'd7: begin //Se genera palabra para push y se realiza push
			pop <= 1'b0;
			push <= 1'b1;
			data_push <= {1'b0,MMU,SPI,WRITE_4BYTE,1'b0,address,t_word[7:0],t_word[15:8],t_word[23:16],t_word[31:24]};//cambio//t_word};
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr;
			t_word <= t_word;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd1;
		end
		
		5'd8:begin //Se envio a FIFO la palabra de finalizacion de SPI y se devuelve al estado 01
			pop <= 1'b0;
			push <= 1'b1;
			data_push <= {1'b0,MMU,SPI,END_BST,25'd0,32'd0};
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr;
			t_word <= t_word;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd1;
		end

	//*************************************************************************//
	//	Maquina de estados de escritura-write								   //
	//*************************************************************************//
		5'd9: begin //Configuracion SPI de comando de WR_EN para mem
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_config <= 16'h0815;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd10;
		end
		5'd10:begin //Se envia comando de WR_EN y se espera que se termine de enviar
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= {WRITE_EN,56'd0};
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd11;
		end
		5'd11: begin //Se envia comando de WR_EN y se espera que se termine de enviar
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx; //modificada
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			if(end_send)begin
				state <= 8'd12;
			end
			else begin
				state <= 8'd11;
			end
		end
		5'd12: begin //Se configura el SPI segun la cantidad de bytes a escribir
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd13;
			if(index==WRITE_4BYTE)begin
				tspi_data_config <= 16'h4015;
			end
			else begin
				if(index==WRITE_2BYTE)begin
					tspi_data_config <= 16'h3015;
				end
				else if(index==WRITE_BYTE)begin
					tspi_data_config <= 16'h2815;
				end
			end
		end
		5'd13: begin //Se envia el dato a escribir
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 88'd0;
			data_pop <= 88'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd14;
			if(index==WRITE_4BYTE)begin
				tspi_data_tx <= {WRITE_COMM,address,data[7:0],data[15:8],data[23:16],data[31:24]};//CAMBIO//data};
			end
			else begin
				if(index==WRITE_2BYTE)begin
					tspi_data_tx <= {WRITE_COMM,address,data[7:0],data[15:8],16'd0};//CAMBIO//data[15:0],16'd0};
				end
				else if(index==WRITE_BYTE)begin
					tspi_data_tx <= {WRITE_COMM,address,data[7:0],24'd0};
				end
			end
		end
		5'd14: begin //Se espera a que se envie el dato
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 88'd0;
			data_pop <= 88'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx; //modificada
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			if(end_send)begin
				state <= 5'd15;  ///PASAR A NUEVO ESTADO DE WRITE DISABLE
			end
			else begin
				state <= 5'd14;
			end
		end
		///////////////////////
		// WRITE DISABLE
		//////////////////////
		8'd15: begin //Configuracion SPI de comando de WR_EN para mem
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_config <= 16'h0815;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd16;
		end
		5'd16:begin //Se envia comando de WR_EN y se espera que se termine de enviar
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= {WRITE_DB,56'd0};
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd17;
		end
		5'd17: begin //Se envia comando de WR_EN y se espera que se termine de enviar
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;//modificada
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			if(end_send)begin
				state <= 5'd18;
			end
			else begin
				state <= 5'd17;
			end
		end
		///////////////////////
		// READ_STATUS
		//////////////////////
		5'd18: begin //Configuracion SPI de comando de READ_STATUS para mem
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_config <= 16'h1015;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd19;
		end
		5'd19:begin //Se envia comando de READ_STATUS y se espera que se termine de enviar
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= {READ_STAT,56'hFFFFFFFFFFFFFF};
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd20;
		end
		5'd20: begin //Se recibe respuesta del comando READ_STATUS
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx; //modificada
			bst_addr <= bst_addr;//24'd0;
			//t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			if(end_send)begin
				state <= 5'd21;
				t_word <= data_read;
			end
			else begin
				state <= 5'd20;
				t_word <= 32'd0;
			end
		end

		5'd21: begin //Se evalua que la mem ya tenga lista la escritura segun el valor de READ_STATUS
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 88'd0;
			data_pop <= 88'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= t_word ;
			index <= index;
			address <= address;
			data <= data;
			if(t_word[0])begin
				state <= 5'd18;
			end
			else begin
				state <= 5'd1;
			end
		end

	//*************************************************************************//
	//	Maquina de estados de lectura-read									   //
	//*************************************************************************//
		5'd22:begin //Configutacion del SPI
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b1;
			tspi_data_config <= 16'h4015;
			tspi_data_tx <= 64'd0;
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd23;
		end
		5'd23: begin //Envio de palabra de lectura en mem
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 64'd0;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b1;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= {READ_COMM,address,32'hFFFFFFFF};
			bst_addr <= bst_addr;//24'd0;
			t_word <= 32'd0;
			index <= index;
			address <= address;
			data <= data;
			state <= 5'd24;
		end
		5'd24: begin // Se espera que SPI termine dato y se captura
			pop <= 1'b0;
			push <= 1'b0;
			data_push <= 88'd0;
			data_pop <= 88'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr;
			index <= index;
			address <= address;
			data <= data;
			if(end_send)begin
				state <= 5'd25; //OJO CON EL CAMBIO 23
				t_word <= data_read;
			end
			else begin
				state <= 5'd24; // 24
				t_word <= 32'd0;
			end
		end
		8'd25: begin //Se genera palabra para push y se realiza push
			pop <= 1'b0;
			push <= 1'b1;
			data_pop <= 64'd0;
			tspi_send_data <= 1'b0;
			tspi_config_en <= 1'b0;
			tspi_data_config <= 16'd0;
			tspi_data_tx <= tspi_data_tx;
			bst_addr <= bst_addr;
			t_word <= t_word;
			index <= index;
			address <= address;
			data <= data;
			state <= 8'd1;
			if(index == READ_4BYTE)begin
				data_push <= {1'b0,MMU,SPI,READ_4BYTE,1'b1,address,t_word[7:0],t_word[15:8],t_word[23:16],t_word[31:24]};//CAMBIO,t_word};
			end
			else begin
				if(index == READ_2BYTE)begin
					data_push <= {1'b0,MMU,SPI,READ_2BYTE,1'b1,address,16'd0,t_word[23:16],t_word[31:24]};//cambio t_word[31:16]};
				end
				else if(index ==READ_BYTE)begin
					data_push <= {1'b0,MMU,SPI,READ_BYTE,1'b1,address,24'd0,t_word[31:24]};
				end
			end
		end
		default: state <= 8'd0;
		endcase
	end 
end

spi spi1(
	.CLK(CLK),
	.reset(reset),
	.MISO(MISO),
	.data_config(tspi_data_config),
	.config_enable(tspi_config_en),
	.data_send(tspi_data_tx),
	.send_data(tspi_send_data),
	.data_read(data_read),
	.MOSI(MOSI),
	.CS(SCS),
	.SCK(SCLK),
	.end_send(end_send)
);


endmodule