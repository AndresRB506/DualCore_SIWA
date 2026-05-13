`timescale 1ns / 10ps

`define SYNTHESIZE 

`ifndef SYNTHESIZE
  `include "../../UART/scrs/baud.sv"
  `include "../../UART/scrs/detector_flanco.sv"
  `include "../../UART/scrs/fifo_to_uart_reg.sv"
  `include "../../UART/scrs/log_ftu.sv"
  `include "../../UART/scrs/log_utf.sv"
  `include "../../UART/scrs/uart_to_fifo_reg.sv"
  `include "../../UART/scrs/u_rec.sv"
  `include "../../UART/scrs/u_xmit.sv"
`else 
  `include "../UART/scrs/baud.sv"
  `include "../UART/scrs/detector_flanco.sv"
  `include "../UART/scrs/fifo_to_uart_reg.sv"
  `include "../UART/scrs/log_ftu.sv"
  `include "../UART/scrs/log_utf.sv"
  `include "../UART/scrs/uart_to_fifo_reg.sv"
  `include "../UART/scrs/u_rec.sv"
  `include "../UART/scrs/u_xmit.sv"

`endif


//////////////////////////////////////////////////////////////////////////////////
// Company:  ITCR
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 02/15/2018 10:49:03 AM
// Design Name: UART
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Descripción: Este módulo top contiene los módulos principales del UART, 
// los cuales son el baud generator, el Transmitter, el Receiver, las fifo, los registros intermedios y la lógica

// Description: This module contains the principals modules of UART, which are
// baud generator, Transmitter, Receiver, the fifos, the intermediates register and logic 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//=========================UART======================================================================================

module uart #(parameter WORD_LEN = 8, // Word size
                        byte_datos = 8, 
                        data_fifo = 64, //  \ parameters of the FIFO
                        depth = 16,//       /
                        XTAL_CLK = 20000000, // System frecuency
                        BAUD = 19200, // baud rate
                        CLK_DIV = XTAL_CLK / (BAUD * 16 * 2),
                        CW   = 9, // Counter word
                        pos_array=8) // positions of the array ff_utf and ff_ftu
            ( 
              sys_clk,
              sys_rst_l,
              TX_UART,
              RX_UART,
              pndng_T,
              D_pop_fT,
              pop_T,
              D_push_fR,
              push_fR
              );

//=========================================================================      
//Entradas de sistema
//=========================================================================      
input   sys_clk;
input   sys_rst_l;
//UART
output  TX_UART;
input   RX_UART;
//FIFO Control
input   pndng_T;
input   [data_fifo:0]   D_pop_fT;
output  pop_T;
output  [data_fifo:0]   D_push_fR;
output  push_fR;

assign D_push_fR[64] = 0;

//=========================================================================                                  
// Internal signals
//=========================================================================      
//Baud generator 
logic uart_clk;
// Transmitter
logic pndng_T, pop_T, xmit_doneH, xmit;     
logic [byte_datos-1:0] xmit_dataH;
//Receiver
logic rec_readyH;
logic [byte_datos-1:0] rec_dataH;

//=========================================================================      
// Señal del sincronizador
//=========================================================================      
logic flag_sincr;
// Transmitter
logic [data_fifo-1:0] Dout_ftu;
//Receiver 
logic rst; 
logic [data_fifo-1:0] Din_utf;
logic [pos_array-1:0] enable_reg;

//=========================================================================      
// Instantiate the Baud Rate Generator
//=========================================================================      
///////////////////////////////////////////////////////////////////////////
//                              baud                                     //
///////////////////////////////////////////////////////////////////////////
baud #(.XTAL_CLK(XTAL_CLK), .BAUD(BAUD), .CLK_DIV(CLK_DIV), .CW(CW)) baud (
  .sys_clk(sys_clk),
  .sys_rst_l(sys_rst_l),                
  .uart_clk(uart_clk)
);
                
//=========================================================================      
// Instantiate detector de flancos
//=========================================================================      
///////////////////////////////////////////////////////////////////////////
//                     detector_flanco                                   //
///////////////////////////////////////////////////////////////////////////
detector_flanco detector_flanco(
	.sys_clk(sys_clk),
  .sys_rst_l(sys_rst_l),
  .uart_clk(uart_clk),
  .flag_sincr(flag_sincr)
);
///////////////////////////////////////////////////////////////////////////                       
//                             fifo_to_uart_reg                          //
///////////////////////////////////////////////////////////////////////////
fifo_to_uart_reg #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) ftu_reg (
  .sys_clk(sys_clk),
  .pop_T(pop_T),
  .sys_rst_l(sys_rst_l),
  .Din(D_pop_fT[63:0]),
  .Dout(Dout_ftu)
); 
///////////////////////////////////////////////////////////////////////////                       
//                             log_ftu                                   //
///////////////////////////////////////////////////////////////////////////
log_ftu #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) log_ftu (
  .sys_clk(sys_clk),
  .flag_sincr(flag_sincr),
  .xmit_done(xmit_doneH),
  .pndng(pndng_T),
  .sys_rst_l(sys_rst_l),
  .D_reg(Dout_ftu),
  .Dout(xmit_dataH),
  .xmit(xmit),
  .pop(pop_T)
);
///////////////////////////////////////////////////////////////////////////
//                              xmit                                     //
///////////////////////////////////////////////////////////////////////////
u_xmit #(.WORD_LEN(WORD_LEN)) u_xmit (        
  // in
  .sys_clk(sys_clk),
  .flag_sincr(flag_sincr),
  .sys_rst_l(sys_rst_l), 
  .xmitH(xmit),
  .xmit_dataH(xmit_dataH),
  // out
  .uart_xmitH(TX_UART), 
  .xmit_doneH(xmit_doneH)
);

//=========================================================================         
// Instantiate urec-uart_to_fifo_reg-fifo_R 
//=========================================================================      
///////////////////////////////////////////////////////////////////////////
//                              u_rec                                    //
///////////////////////////////////////////////////////////////////////////
u_rec #(.WORD_LEN_PLUS1(WORD_LEN+1)) u_rec (
  .sys_rst_l(sys_rst_l),
  .sys_clk(sys_clk),
  .flag_sincr(flag_sincr),
  .uart_dataH(RX_UART),
  .rec_dataH(rec_dataH),
  .rec_readyH(rec_readyH)
);                  
///////////////////////////////////////////////////////////////////////////
//                              log_utf                                  //
///////////////////////////////////////////////////////////////////////////  
log_utf #(.pos_array(pos_array)) log_utf (
  .flag_sincr(flag_sincr),
  .sys_clk (sys_clk),
  .rec_ready(rec_readyH),
  .sys_rst_l(sys_rst_l),
  .push(push_fR),
  .rst(rst),
  .enable_reg(enable_reg)
);
///////////////////////////////////////////////////////////////////////////
//                              uart_to_fifo_reg                         //
///////////////////////////////////////////////////////////////////////////
uart_to_fifo_reg #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) utf_reg (
  .enable(enable_reg),
  .sys_rst_l(rst),
  .Din(rec_dataH),
  .sys_clk(sys_clk),
  .Dout(D_push_fR[63:0])
);

endmodule

