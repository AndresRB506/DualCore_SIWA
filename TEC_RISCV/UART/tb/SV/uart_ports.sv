`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 03/21/2018 09:22:48 PM
// Design Name: 
// Module Name: uart_ports
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`ifndef UART_PORTS_SV
`define UART_PORTS_Sv

interface uart_ports (
    input wire sys_clk,
    input wire uart_clk,
    output logic sys_rst_l,
    
    //ports del transmisor
    input wire uart_XMIT_dataH,
    output logic [63:0] Din_fifo,
    output logic push_T,// tx
    input wire tx_full,
    
    //ports del receptor
    output logic uart_REC_dataH,
    output logic pop_R, // rx
    input wire [63:0] Dout,
    input logic pndng_R,
    
    output logic loopback
    );
endinterface

`endif
