`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITCR
// Engineer: Dayhana Sanchez Jimenez
// 
// Create Date: 02/12/2018 09:23:21 AM
// Design Name: UART
// Module Name: baud
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module generate a signal used as enabler to control the u_rec and the x_mit modules.
// It creates a frequency divider which depends of the baud rate.
//
// BAUD.v//------------------------------------------------------------
//
// www.cmosexod.com
// 4/13/2001 (c) 2001
// Jeung Joon Lee
//
// This is the "baud-rate-genrator"
// The "uart_clk" is the output clock feeding the
// receiver and transmitter modules of the UART.
//
// By design, the purpose of the "uart_clk" is to 
// take in the "sys_clk" and generate a clock 
// which is 16 x BaudRate, where BaudRate is the
// desired UART baud rate. 
// 
// Dependencias: 

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------



module baud #(parameter XTAL_CLK = 20000000, //20MHz es la frec max del micro
                        BAUD = 2400,
                        CLK_DIV = XTAL_CLK / (BAUD * 16 * 2),
                        CW   = 9)(
     input  logic sys_clk,
     input  logic sys_rst_l,
     output logic  uart_clk                                
);

logic [CW-1:0] clk_div;

//        CLK_DIV 328

always_ff @(posedge sys_clk or posedge sys_rst_l)
  if (sys_rst_l) begin
    clk_div  <= 0;
    uart_clk <= 0; 
  end 
  else if (clk_div == CLK_DIV) begin
    clk_div  <= 0;
    uart_clk <= ~uart_clk;
  end 
  else begin
    clk_div  <= clk_div + 1;
    uart_clk <= uart_clk;
  end

endmodule
