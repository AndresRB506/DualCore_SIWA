`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2018 07:31:37 PM
// Design Name: 
// Module Name: UART_TB
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

module top();
//Se;ales en orde
reg sys_clk;
wire sys_rst_l;
//tx
wire push_T;
wire [63:0] Din;
wire uart_XMIT_dataH;
wire tx_full;
//rx
wire uart_REC_dataH;
wire pndng_R;
wire pop_R;
wire [63:0] Dout;
wire rx_full;
wire loopback;



//instancia interfaz ports
uart_ports ports (
    //Señales de control
    .sys_clk(sys_clk),
    .uart_clk(uart.uart_clk),
    .sys_rst_l(sys_rst_l),
//--- Instancia xmit_ports
            .uart_XMIT_dataH(uart_XMIT_dataH),
            .Din_fifo(Din),
            .push_T(push_T),
            .tx_full(tx_full),            
    // Receiver 
           .uart_REC_dataH(uart_REC_dataH),
           .pop_R(pop_R),
           .Dout(Dout),
           .pndng_R(pndng_R),
           .loopback(loopback)       
);

uart_top tbtop (ports);

initial begin
	$dumpfile ("uart.vcd");
	$dumpvars(0,uart); // (<level>, instancia del modulo)
    sys_clk =0;
    end

// loopback control logic
assign ports.uart_REC_dataH = (loopback) ? uart_XMIT_dataH : 1;
assign rx_full=0;
always begin
  #25 sys_clk = ~sys_clk;
end 


//DUT ///////////////////////////////////////////////////////////////////////////
uart uart (         .sys_clk(sys_clk),
                    .sys_rst_l(sys_rst_l),
                  //  .uart_clk (uart_clk), //From baud rate

                    // Transmitter Signals
                    .uart_XMIT_dataH(uart_XMIT_dataH), //Salida del bloque
                    .tx_full(tx_full)    ,     // Status FIFO_T
                    .push_T(push_T),
                    .Din(Din),
                        
                    // Receiver
                    .uart_REC_dataH(uart_REC_dataH), // Entrada al rx
                    .rx_full (rx_full),
                    .pop_R(pop_R),
                    .Dout(Dout),
                    .pndng_R(pndng_R)
                );
           
endmodule
