`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 06:13:23 PM
// Design Name: UART
// Module Name: fifo_to_uart_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Register to pass data from fifo to transmitter. It is made independent to evaluate if it is changed by a ram.
// In this module all the registers share the same clk
// 
// Dependencies: 

// Descripcion: Registro para pasar datos de la fifo al transmisor. Se realiza de forma independiente
// para posteriormente evaluar si se cambia por una ram. En este modulo todos los registros comparten 
// el mismo clk
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// Definition of a D flip flop with asyncronous reset  //
/////////////////////////////////////////////////////////

module dff_async_rsta (
  input data,
  input clk,
  input reset,
  output reg q);

  always @ ( posedge clk or posedge reset)
    if (reset) begin
      q <= 1'b0;
    end  else begin
      q <= data;
    end

endmodule

///////////////////////////////////////////////////////////////////////
// Definition of the prll D register 
///////////////////////////////////////////////////////////////////////

module prll_d_rega #(parameter bits = 32)(
  input clk,
  input reset,
  input [bits-1:0] D_in,
  output [bits-1:0] D_out
);
  genvar i;
  generate
    for(i = 0; i < bits; i=i+1) begin:bit_
      dff_async_rsta prll_regstr_(.data(D_in[i]),.clk(clk),.reset(reset),.q(D_out[i]));
    end
  endgenerate

endmodule

///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////


module fifo_to_uart_reg #(parameter pos_array = 8,// 
                                    data_fifo  =64,   // 8  bytes 8*8
                                    byte_out = 8)( // 1 byte
    input logic sys_clk,
    input logic pop_T, // señal para cargar los registros
    input logic sys_rst_l,
    input logic [data_fifo-1:0] Din, // dato de entrada viene de la fifo
    output logic [data_fifo-1:0] Dout //Dout dato de salida de cada registro
);
   
 logic [byte_out-1:0] array [pos_array-1:0];


 //conexion de varios registros paralelos, con entrada y salida de datos independiente
 //y con el mismo reset y clk para todos los registros.     
  genvar i;
 generate
    for (i =0; i < pos_array; i=i+1) begin: ftu_reg
       prll_d_rega#(8) prll_d_reg(.D_in(Din[(7+i*8):(8*i)]), .clk(pop_T), .reset(sys_rst_l), .D_out(array[i]));
       assign Dout [(7+i*8):(8*i)] = array[i];
      end           
 endgenerate
 
endmodule
