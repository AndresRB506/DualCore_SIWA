`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2018 11:36:36 AM
// Design Name: 
// Module Name: uart_rx_tb
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
//-------------------------RECEIVER----------------------

module uart_rx_tb();

reg sys_clk, sys_rst_l,uart_REC_dataH, rd_uart_R;
wire rx_empty, uart_clk, parity_error, rec_readyH;
wire [7:0] r_data;

//==================================================================================
// 1/Baudx16;  1/2400*16*1.25
parameter bit_period = 20800;
//=================================================================================    
    Receiver iRX ( .sys_clk(sys_clk),
                   .sys_rst_l(sys_rst_l),
                   .uart_REC_dataH(uart_REC_dataH),
                   .rd_uart_R(rd_uart_R),
                   .rx_empty(rx_empty),
                   .r_data(r_data),
                   .uart_clk(uart_clk),
                   .parity_error(parity_error),
                   .rec_readyH(rec_readyH)
            );
//==================================================================================     

// Inicializa entradas
    initial begin
        sys_clk=0;
        sys_rst_l=0;
        uart_REC_dataH = 1;
        #10000
        sys_rst_l=1;
        #1000
        rd_uart_R = 0;      
    end

//==================================================================================     

//Toma un byte de entrada y lo serializa           
        task UART_WRITE_BYTE;
            input [7:0] i_data;
            integer ii;
            begin
              
              // Envio de bit de inicio
              uart_REC_dataH <= 1'b0;
              #(bit_period);
                            
              // Envio de byte
              for (ii=0; ii<8; ii=ii+1)
                begin
                  uart_REC_dataH <= i_data[ii];
                  #(bit_period);
                end
              
              // Envio de bit de paridad
              uart_REC_dataH <= 1'b0;
              #(bit_period);
                            
              // Envio de bit de parada
              uart_REC_dataH <= 1'b1;
              #(bit_period);
             end
          endtask // UART_WRITE_BYTE
                     
//==================================================================================     
           
             //-----Generar el reloj---------      
                  always begin
                       #1 sys_clk = ~sys_clk;
                  end                

//==================================================================================     

           // Prueba
           initial
             begin
               // Enviar dato al UART
               @(posedge uart_clk);
               UART_WRITE_BYTE(8'hA1);
//               @ (negedge rec_readyH)
//               rd_uart_R = 1; 
               
               @(posedge uart_clk);
               #(bit_period/1.5); 
               // Verificar que el comando fue recibido
               if (r_data == 8'hA1 && ~parity_error)
                 $display("Test Passed - Correct Byte Received - No parity error detected");
               else if (r_data == 8'hA1 && parity_error)
                 $display("Test Failed - Correct Byte Received - Parity error");
               if (r_data != 8'hA1 && ~parity_error)
                  $display("Test Failed - Incorrect Byte Received - No parity error detected");
                else if (r_data != 8'hA1 && parity_error)
                  $display("Test Failed - Incorrect Byte Received - Parity error");
               
             $finish();
             end
           
           initial 
           begin
             $dumpfile("RX_TB.vcd");
             $dumpvars(1);
           end
  
endmodule