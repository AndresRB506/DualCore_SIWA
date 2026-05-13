`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 06:13:23 PM
// Design Name: UART
// Module Name: uart_to_fifo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Register to pass data from uart to fifo. It is made independent, for later
// evaluate if it is changed for a RAM  
// 
// Dependencies: 

// Descripcion: Registro para pasar datos del uart a la fifo. Se realiza de forma independiente
// para posteriormente evaluar si se cambia por una ram.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Those register have an enable signal

///////////////////////////////////////////////////////////////////////
// Definition of the prll D register 
///////////////////////////////////////////////////////////////////////

module prll_d_reg_ena #(parameter bits = 32)(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic [bits-1:0] D_in,
  output logic [bits-1:0] D_out
);
  genvar i;
  generate
    for(i = 0; i < bits; i=i+1) begin:bit_
      dff_async_rst_ena prll_regstr_(.data(D_in[i]),.clk(clk),.reset(reset), .enable(enable), .q(D_out[i]));
    end
  endgenerate
endmodule

////////////////////////////////////////////////////////////////////////
// Definicion de Flip Flop D asincrono
////////////////////////////////////////////////////////////////////////
  
module dff_async_rst_ena (
    input logic data,
    input logic clk,
    input logic enable,
    input logic reset,
    output reg q
);

always_ff @ ( posedge clk or posedge reset)
  if (reset) begin
    q <= 1'b0;
  end  
  else if (enable) begin
    q <= data;
  end

endmodule


/////////////////////////////////////////////////////////////////////////

module uart_to_fifo_reg #(parameter pos_array = 8,// 10 bytes de la fifo solo interesan 8 los otros 2 se descartan
                                    data_fifo  =64,   // 8  bytes 8*8
                                    byte_out = 8)( // 1 byte
    input logic [pos_array-1:0] enable, 
    input logic sys_rst_l,
    input logic sys_clk,
    input logic [byte_out-1:0] Din, // this data comes from FIFO
    output logic [data_fifo-1:0] Dout 
);
   
 logic [byte_out-1:0] array [pos_array-1:0];
   
  genvar i;
 generate
    for (i =0; i < pos_array; i=i+1) begin: utf_reg
       prll_d_reg_ena#(8) prll_d_reg(.D_in(Din), .clk(sys_clk), .reset(sys_rst_l), .enable(enable[i]), .D_out(array[i]));
       assign Dout [(7+i*8):(8*i)] = array[i];
    end
 endgenerate
 
endmodule
