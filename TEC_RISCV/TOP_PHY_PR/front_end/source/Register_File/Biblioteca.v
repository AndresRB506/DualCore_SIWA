
/*--------------------------------------------------------------------------*/
/*Latch con rst a 0*/
/*--------------------------------------------------------------------------*/
module latch(clk,d,q,rst);
//Entradas y Salidas
	input clk;
	input  d;
	input rst;
	output reg  q;
//Logica
	always @ (clk, d, rst)
		if (rst) q <= 1'b0;
		else if (clk) q <= d;
endmodule


/*--------------------------------------------------------------------------*/
/*Latch con rst a 1*/
/*--------------------------------------------------------------------------*/
module latch_rst1(clk,d,q,rst);
//Entradas y Salidas
	input clk;
	input  d;
	input rst;
	output reg  q;
//Logica
	always @ (clk, d, rst)
		if (rst) q <= 1'b1;
		else if (clk) q <= d;
endmodule



/******************************************************************************/
/*Compuerta triestado*/
/******************************************************************************/
module tristategate(input_x, enable, output_x);
//Entradas y salidas
	input input_x;
	input enable;
	output output_x;

//Logicas
	assign output_x = enable ? input_x : {1'bz};
endmodule



/******************************************************************************/
/*Compuerta triestado*/
/******************************************************************************/
module tristategate_negado(input_x, enable, output_x);
//Entradas y salidas
	input input_x;
	input enable;
	output output_x;

//Logicas
	assign output_x = enable ?   {1'bz} : input_x;
endmodule


/****************************************************************************/
/*Latch triestado con dos salidas sin rst usados para el banco general*/
/**************************************************************************/
module latchtriestado(In,Out1,Out2,En1,En2,Write,rst);
//Entradsa
	input In;
	input En1;
	input En2;
	input Write;
        input rst;
	output Out1;
	output Out2;

	logic q;

	always@(Write or In or rst) begin
              if(rst)begin
                q <= 0;
              end else begin
  		if(Write) begin
   		  q <= In;
  		end
	      end
        end
	assign Out1 = En1?q:{1'bz};
	assign Out2 = En2?q:{1'bz};
endmodule

/******************************************************/
/*latch tri estado con una sola salida y con rst a 0; Usado en los CSR*/
/******************************************************/

module latch_tri_estado(In,Out1,En1,Write,rst);
//Entradas y Salidas
	input In;
	input En1;
	input rst;
	input Write;
	output Out1;

//Cables
	wire conect;

//Salida 1
	tristategate tristategate1(
		.input_x(conect),
		.enable(En1),
		.output_x(Out1)
	);
//Salida2
	latch latch1 (
		.clk(Write),
		.d(In),
		.q(conect),
		.rst(rst)
	);
endmodule



/*************************************************************************/
/*Latch tri estado para aquellos que tienen salida a Hardware y al sistema con rst a 0 */
/*************************************************************************/

module latch_tri_rst0_Hard(In,Out1_tri,En1,Write,rst,Out_latch);
//Entradas y Salidas
	input In;
	input En1;
	input rst;
	input Write;
	output Out1_tri;
	output Out_latch;
//Cables
	wire conect;

//Salida 1
	tristategate tristategate1(
		.input_x(conect),
		.enable(En1),
		.output_x(Out1_tri)
	);
//Salida2
	latch latch1 (
		.clk(Write),
		.d(In),
		.q(conect),
		.rst(rst)
	);
	assign Out_latch = conect;
endmodule


/*************************************************************************/
/*Latch tri estado para aquellos que tienen salida a Hardware y al sistema con rst a 0 */
/*************************************************************************/

module latch_tri_rst1_Hard(In,Out1_tri,En1,Write,rst,Out_latch);
//Entradas y Salidas
	input In;
	input En1;
	input rst;
	input Write;
	output Out1_tri;
	output Out_latch;
//Cables
	wire conect;

//Salida 1
	tristategate tristategate1(
		.input_x(conect),
		.enable(En1),
		.output_x(Out1_tri)
	);
//Salida2
	latch_rst1 latch1 (
		.clk(Write),
		.d(In),
		.q(conect),
		.rst(rst)
	);
	assign Out_latch = conect;
endmodule
/******************************************************/
/*Decodificador */
/******************************************************/

module Decodificador#(parameter width=2)(addres_in, out);
	parameter ad=$clog2(width);
//Entradas y Salidas
	input  [ad-1:0]addres_in ;
	output [width-1:0] out;

//Logicas
	assign out = (1'b1 << addres_in );
endmodule

/***********************************************************************************************/
/*Banco de registros CSR*/
/***********************************************************************************************/
module csr_file #(parameter width=32, parameter number_reg=12)(Din, Dout1, addres1, Write_en, clk, rst , mip_IO, mip_time, mie_IO, mie_time, comparation, timer, full_range_level_shifter, IS_Val, IS_Config, IS_Trigger, Mie_analogic, mip_analogic,Reg_GPIO_en,Reg_GPIO_int,Reg_GPIO_out, en_bus);
	parameter ad=$clog2(number_reg);
	input [width-1:0] Din;
	input [ad-1:0]addres1;
	input Write_en;
	input rst;
	input clk;
// Load y csr_trap registro para las interrupciones y excepciones
//Entradas del mip
	input mip_IO;
	input mip_time;
	input mip_analogic;
//Entradas timer
	input [31:0] timer;
//Entrada GPIO
//Salida compracion register
	output [31:0] comparation;
//Salidas Mie
	output mie_IO;
	output Mie_analogic;
	output mie_time;
	output [width-1:0] Dout1;
//Salidas registro de Uruguay
	output [7:0] full_range_level_shifter;
	output [31:0] IS_Val;
	output [31:0] IS_Config;
	output [3:0] IS_Trigger;
	output logic [7:0] Reg_GPIO_en;
    input [7:0] Reg_GPIO_int;
	output [7:0] Reg_GPIO_out;
//Salida habilitador del bus
	output  en_bus;
//Variables intermedias
	wire [number_reg-1:0] Sal_and_write; //Es menos 2 debido a que el registro 0 no se escribe
	wire [number_reg-1:0] conect_deco_latch1;
	wire one;
	wire zero;
	wire wire_en_bus;

//Variables GPIO_pad
	logic [7:0] Q_conf;
	logic [7:0] wire_GPIO_latch_in;

	assign zero=1'b0;
	assign one=1'b1;
	assign en_bus=wire_en_bus;



	Decodificador #(.width(number_reg)) Deco_csr(
		.addres_in(addres1),
		.out(conect_deco_latch1)
	);
	genvar i, j;
	generate

		for (i=0; i<number_reg; i=i+1)begin :Conexion_cables_lectura_escritura
			assign Sal_and_write[i] = (conect_deco_latch1[i] & Write_en & ~clk);
		end


	/********************************Mie/Mip/IO****************************************/
	//Direccion:0
		for(j=0;j<width; j=j+1) begin : Registro_Mie
			if(j==0) begin: rf0
				latch_tri_rst0_Hard latch_Mie_Time(
					.In(Din[j]),
					.En1(conect_deco_latch1[0]),
					.rst(rst),
					.Write(Sal_and_write[0]),
					.Out_latch(mie_time),
					.Out1_tri(Dout1[j])
				);
			end
			else if (j==1) begin: rf1
				latch_tri_rst0_Hard latch_Mie_IO(
					.In(Din[j]),
					.En1(conect_deco_latch1[0]),
					.rst(rst),
					.Write(Sal_and_write[0]),
					.Out_latch(mie_IO),
					.Out1_tri(Dout1[j])
				);
			end
			else if(j==2) begin: rf2
				tristategate tristategate_mip_IO(
					.input_x(mip_time),
					.enable(conect_deco_latch1[0]),
					.output_x(Dout1[j])
					);
			end
			else if (j==3) begin: rf3
				tristategate tristategate_mip_IO(
					.input_x(mip_IO),
					.enable(conect_deco_latch1[0]),
					.output_x(Dout1[j])
					);
			end
			else if (j==4) begin: rf4
				latch_tri_rst0_Hard latch_Mie_analogic(
					.In(Din[j]),
					.En1(conect_deco_latch1[0]),
					.rst(rst),
					.Write(Sal_and_write[0]),
					.Out_latch(Mie_analogic),
					.Out1_tri(Dout1[j])
				);
                        end
			else if (j==5) begin: rf5
				tristategate tristategate_mip_analogic(
					.input_x(mip_analogic),
					.enable(conect_deco_latch1[0]),
					.output_x(Dout1[j])
					);

			end
			else if((j>7) & (j<16)) begin: rf12
          always_comb begin
				  Reg_GPIO_en[j-8] <= Q_conf[j-8];
          end
				latch_tri_rst0_Hard latch_Mie_IO(
					.In(Din[j]),
					.En1(conect_deco_latch1[0]),
					.rst(rst),
					.Write(Sal_and_write[0]),
					.Out_latch(Q_conf[j-8]),
					.Out1_tri(Dout1[j])
					);

			end // else GPIO
			else if (j==16) begin: habilitador_bus
				latch_tri_rst1_Hard latch_habilitador_bus(
					.In(Din[j]),
					.En1(conect_deco_latch1[0]),
					.rst(rst),
					.Write(Sal_and_write[0]),
					.Out_latch(wire_en_bus),
					.Out1_tri(Dout1[j])
					);
			end
			else begin: rf6
			tristategate tristategate_Registro_0(
				.input_x(zero),
				.enable(conect_deco_latch1[0]),
				.output_x(Dout1[j])
				);

			end

		end

	/****************************mepc*********************************************/
	//Este registro debe ser escribible desde  hardware
	//Direccion:1
		for(j=0;j<width; j=j+1) begin : Regsitrio_mepc
			if(j<2)begin: rf7
			tristategate tristategate_mepc(
				.input_x(zero),
				.enable(conect_deco_latch1[1]),
				.output_x(Dout1[j])
				);
			end
			else begin: rf8
				latch_tri_estado latches_mepc(
					.In(Din[j]),
					.Out1(Dout1[j]),
					.En1(conect_deco_latch1[1]),
					.Write(Sal_and_write[1]),
					.rst(rst)
				);

			end
		end
		/******************************Interruption1***************************/
		//Contiene la Data de la interrupciÃ³n que ocurrÃ­o
		//Direccion:2
			for(j=0;j<width; j=j+1) begin : Regsitrio_interruption1
				latch_tri_estado latches_interruption1(
					.In(Din[j]),
					.Out1(Dout1[j]),
					.En1(conect_deco_latch1[2]),
					.Write(Sal_and_write[2]),
					.rst(rst)
				);
			end
	/*************************************Interrup2****************************************/
	//Contiene la Data de la interrupciÃ³n que ocurrÃ­o
	//Direccion:3
		for(j=0;j<width; j=j+1) begin : Regsitrio_interrup2
				latch_tri_estado latches_mcause(
					.In(Din[j]),
					.Out1(Dout1[j]),
					.En1(conect_deco_latch1[3]),
					.Write(Sal_and_write[3]),
					.rst(rst)
	        	);
		end

	/******************************GPIO***************************/
	//Direccion:4
		for(j=0;j<width; j=j+1) begin : Regsitrio_GPIO
			if(j<8) begin: rf11
			//Logica GPIO
          always_comb begin
				  wire_GPIO_latch_in[j] <= (Q_conf[j]) ? Reg_GPIO_int[j] : Din[j];
          end
				latch_tri_rst0_Hard latch_Mie_IO(
					.In(wire_GPIO_latch_in[j]),
					.En1(conect_deco_latch1[4]),
					.rst(rst),
					.Write(Sal_and_write[4]),
					.Out_latch(Reg_GPIO_out[j]),
					.Out1_tri(Dout1[j])
					);


			end // if(j<8)
			else begin: rf13
				tristategate tristategate_zeroo(
					.input_x(zero),
					.enable(conect_deco_latch1[4]),
					.output_x(Dout1[j])
					);

			end // else
	   end
	/*************************************Mvtec****************************************/
	//Todo el registro es capaz de escribirse por software y ser leÃ­do de la misma manera
	//Direccion:5
		for(j=0;j<width; j=j+1) begin : Regsitrio_mvtec
			if (j>1) begin: rf14
				latch_tri_estado latches_mvtec(
					.In(Din[j]),
					.Out1(Dout1[j]),
					.En1(conect_deco_latch1[5]),
					.Write(Sal_and_write[5]),
					.rst(rst)
				);
			end // if (j>2)
			else begin: rf15
				tristategate tristategate_mvtec(
					.input_x(zero),
					.enable(conect_deco_latch1[5]),
					.output_x(Dout1[j])
					);

			end // else
		end
	/*********************************Comparacion***************************************/
	//Direccion:6
		for(j=0;j<width; j=j+1) begin : Registro_Comparacion
			latch_tri_rst0_Hard latch_Comparacion(
				.In(Din[j]),
				.En1(conect_deco_latch1[6]),
				.rst(rst),
				.Write(Sal_and_write[6]),
				.Out_latch(comparation[j]),
				.Out1_tri(Dout1[j])
			);
		end // Registro_Comparacion
	/*********************************Valor timer************************************/
	//Direccion:7
		for(j=0;j<width; j=j+1) begin : Valor_timer
			tristategate tristate_timer(
					.input_x(timer[j]),
					.enable(conect_deco_latch1[7]),
					.output_x(Dout1[j])
					);
		end // Valor_timer
		/**********************full range level shifter********************************/
		//Registro de Uruguay
		//Direccion:8
		for(j=0;j<width; j=j+1) begin : full_range_level_shift
				if(j<8) begin:rf16
					latch_tri_rst0_Hard latch_full_range(
							.In(Din[j]),
							.En1(conect_deco_latch1[8]),
							.rst(rst),
							.Write(Sal_and_write[8]),
							.Out_latch(full_range_level_shifter[j]),
							.Out1_tri(Dout1[j])
							);
				end
				else begin:rf17
					tristategate Zero_tristate_full_range(
							.input_x(zero),
							.enable(conect_deco_latch1[8]),
							.output_x(Dout1[j])
							);
				end
		end
		/**********************IS_Valr********************************/
		//Registro de Uruguay
		//Direccion:9
		for(j=0;j<width; j=j+1) begin : IS_Va
					latch_tri_rst0_Hard latch_IS_Val(
							.In(Din[j]),
							.En1(conect_deco_latch1[9]),
							.rst(rst),
							.Write(Sal_and_write[9]),
							.Out_latch(IS_Val[j]),
							.Out1_tri(Dout1[j])
							);
		end
		/**********************IS_Config********************************/
		//Registro de Uruguay
		//Direccion:10
		for(j=0;j<width; j=j+1) begin : IS_Confi
					latch_tri_rst0_Hard latch_IS_Config(
							.In(Din[j]),
							.En1(conect_deco_latch1[10]),
							.rst(rst),
							.Write(Sal_and_write[10]),
							.Out_latch(IS_Val[j]),
							.Out1_tri(Dout1[j])
							);
		end
		/**********************IS_Trigger********************************/
		//Registro de Uruguay
		//Direccion:11
		for(j=0;j<width; j=j+1) begin : IS_Trigge
				if(j<4) begin: rf18
					latch_tri_rst0_Hard latch_IS_Trigger(
							.In(Din[j]),
							.En1(conect_deco_latch1[11]),
							.rst(rst),
							.Write(Sal_and_write[11]),
							.Out_latch(IS_Trigger[j]),
							.Out1_tri(Dout1[j])
							);
				end
				else begin: rf19
					tristategate Zero_tristate_IS_Trigger(
							.input_x(zero),
							.enable(conect_deco_latch1[11]),
							.output_x(Dout1[j])
							);
				end
		end





	endgenerate
endmodule




/***********************************************************************************************/
/*Banco de registros General*/
/***********************************************************************************************/

module Reg_32_bit#(parameter width=32, parameter number_reg=32)(Din, Dout1, Dout2, addres1, addres2, addres3,  Write_en, clk,rst);
	parameter ad=$clog2(number_reg);
	input [width-1:0] Din;
	input [ad-1:0]addres1;
	input [ad-1:0]addres2;
	input [ad-1:0]addres3;
	input Write_en;
	input clk;
        input rst;
	output [width-1:0] Dout1;
	output [width-1:0] Dout2;
//Variables intermedias
	wire [width-1:1] Sal_and_write; //Es menos 2 debido a que el registro 0 no se escribe
	wire [width-1:0] conect_deco_latch1;
	wire [width-1:0] conect_deco_latch2;
	wire [width-1:0] conect_deco_latch3;
	//wire [width-1:0] Zero_register;
	wire Zero_register;
	wire Zero_register_out;

	assign Zero_register = 1'b0;
	Decodificador #(.width(number_reg)) Decodificador1(
		.addres_in(addres1),
		.out(conect_deco_latch1)
	);

	Decodificador #(.width(number_reg)) Decodificador2(
		.addres_in(addres2),
		.out(conect_deco_latch2)
	);

	Decodificador #(.width(number_reg)) Deco_escritura(
		.addres_in(addres3),
		.out(conect_deco_latch3)
	);

	genvar i, j;
	generate

		for (i=1; i<number_reg; i=i+1)begin :Conexion_cables_escritura
			assign Sal_and_write[i] = (conect_deco_latch3[i] & Write_en & ~clk);
		end


		for (i=1; i<number_reg ; i=i+1)begin :latches1
			for(j=0; j<width; j=j+1)begin : latches2
				latchtriestado latchesa(
                                        .rst(rst),
					.In(Din[j]),
					.Out1(Dout1[j]),
					.Out2(Dout2[j]),
					.En1(conect_deco_latch1[i]),
					.En2(conect_deco_latch2[i]),
					.Write(Sal_and_write[i])
				);
			end
		end

	//registro zero


		for(j=0;j<width; j=j+1) begin : Regsitros_Zero
		tristategate tristategate_zero1(
			.input_x(Zero_register),
			.enable(conect_deco_latch1[0]),
			.output_x(Dout1[j])
			);
			tristategate tristategate_zero2(
				.input_x(Zero_register),
				.enable(conect_deco_latch2[0]),
				.output_x(Dout2[j])
				);
		end

	endgenerate



endmodule
