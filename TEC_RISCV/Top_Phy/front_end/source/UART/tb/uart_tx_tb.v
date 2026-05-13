`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2018 10:37:10 AM
// Design Name: 
// Module Name: uart_tx_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  Simulación del tx con fifo
// //  // cuando la señal wr_uart_T esta activa, escribe el dato en el bufer
//  // cuando la se;al rd esta activa, libera el espacio en al buffer y avanza una poscicion
  
//  // cuando xmit_doneH es asertada, permite leer un nuevo dato de la FIFO
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//--------------------Transmitter-------------------------

module uart_tx_tb();

reg sys_clk, sys_rst_l, wr_uart_T;
reg [7:0] w_data;
wire  uart_XMIT_dataH, tx_full, uart_clk, xmit_doneH, BP;




//==================================================================================
// 1/Baudx16;  1/2400*16*1.25
parameter bit_period = 20800;
//integer Pass=1'b0;
//integer dato_entrada=1'b0;
//==================================================================================

Transmitter uart_tx_tb ( .sys_clk(uart_clk),
                  .sys_rst_l(sys_rst_l),
                  .wr_uart_T(wr_uart_T),
                  .w_data(w_data),
                  .uart_XMIT_dataH(uart_XMIT_dataH),
                  .tx_full(tx_full),
                  .uart_clk(uart_clk),
                  .xmit_doneH(xmit_doneH),
                  .BP(BP)
                   ); 
                   
baud iBAUD(	.sys_clk(sys_clk),
                               .sys_rst_l(sys_rst_l),        
                               .baud_clk(uart_clk)
                           );    
        
//==================================================================================

        //-----Generar el reloj--------- 
   always begin
            #1 sys_clk = ~sys_clk;
    end
            
//==================================================================================       
             
     initial begin
        sys_clk = 1'b0;
        sys_rst_l=1'b0; 
        wr_uart_T = 1'b0;
        w_data = 8'h00;
        #10000
        sys_rst_l=1'b1;  
        wr_uart_T = 1'b1;
        @(posedge uart_clk)
        wr_uart_T = 1'b0;
        
  //---------Se escriben datos en la FIFO     
        #900000
        w_data = 8'hB2;
        @(posedge uart_clk)
            wr_uart_T = 1'b1;
        @(posedge uart_clk)
            wr_uart_T = 1'b0;
            
        #900000
        w_data = 8'hA1;
        @(posedge uart_clk)
            wr_uart_T = 1'b1;
        @(posedge uart_clk)
            wr_uart_T = 1'b0;
        
//---------Se escriben datos en la FIFO
        
 
end

           
endmodule