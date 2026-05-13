`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 05/03/2018 10:49:03 AM
// Design Name: UART
// Module Name: detector_flanco
// Description: This module is in charged to detect the posedge of uart_clk, so that active all the 
// modules that depent of thi signal.
//
// Descripcion: Modulo encargado de detectar el flanco de subida de la señal uart_clk, de manera que
// active todos los modulos que dependen de dicha señal
// 
// Dependencies: baud.v
////////////////////////////////////////////////////////////////////////////////// 
module detector_flanco (
    input  logic sys_clk,
    input  logic sys_rst_l,
    input  logic uart_clk,
    output logic  flag_sincr );

logic  [1:0] flag_detector;

always_ff @(posedge sys_clk or posedge sys_rst_l)begin
	if(sys_rst_l)begin
		flag_detector = 2'b00;
	end
	else begin
		flag_detector = {uart_clk,flag_detector[1]}; // toma el bit anterior
	end
end

always_comb begin
	if (flag_detector == 2'b10)
		flag_sincr = 1'b1;
	else
		flag_sincr = 1'b0;
end 

endmodule
