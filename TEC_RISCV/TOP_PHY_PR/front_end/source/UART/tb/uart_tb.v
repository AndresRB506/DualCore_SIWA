`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Dayhana Sánchez J
// 
// Create Date: 02/23/2018 10:14:54 AM
// Design Name: UART
// Module Name: uart_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 

// Description: Se realiza una prueba básica en la cual se compruebe el funcionamiento
// de todos los módulos que componen el UART, para esto se introduce un dato de 8 bits
// en el transmisor, la salida de éste se realimenta al receptor y se comprueba que 
// este dato sea el mismo ingresado al receptor.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tb( );
    reg sys_clk, sys_rst_l, wr_uart_T, rd_uart_R;//, uart_REC_dataH;
    reg [7:0] w_data; 
    wire uart_clk, uart_XMIT_dataH, tx_full, rx_empty, xmit_doneH, rec_readyH,parity_error;
    wire [7:0] r_data;
//==================================================================    
    // 1/Baudx16;  1/2400*16*1.25
    parameter bit_period = 20800;

//==================================================================    
    
    uart uart_tb (	.sys_clk(sys_clk),
                    .sys_rst_l(sys_rst_l),
                    .uart_clk (uart_clk), //From baud rate
    
                    // Transmitter Signals
                    .w_data(w_data),          // Entrada de datos a FIFO_T
                    .wr_uart_T(wr_uart_T),       // wr FIFO_T
                    .uart_XMIT_dataH(uart_XMIT_dataH), //Salida del bloque
                    .tx_full(tx_full)    ,     // Status FIFO_T
                    .xmit_doneH(xmit_doneH),
                    
                    // Receiver
                    .rd_uart_R(rd_uart_R),      // Entrada a FIFO_R
                    .uart_REC_dataH(uart_XMIT_dataH), // Entrada al rx
                    .r_data(r_data),            // Salida de datos en paralelo
                    .rx_empty(rx_empty),        //
                    .rec_readyH(rec_readyH),
                    .parity_error(parity_error)    
                );

//================================================================== 

  //==================================================================================             
     //-----Generar el reloj---------      
          always begin
               #1 sys_clk = ~sys_clk;
          end                
    //================================================================================== 
    
// Se inicializan las variables de entrada   
   initial begin
        sys_clk = 1'b0;
        sys_rst_l = 1'b0;
        //uart_REC_dataH = 1'b1; // si no se recibe nada, la señal está en alto
        wr_uart_T = 1'b0;
        rd_uart_R = 1'b0;
        #10000
        sys_rst_l = 1'b1;
        #100
        
        //====================================================
        @(posedge uart_clk);
        @(posedge uart_clk);
       w_data = 8'hAA; 
       wr_uart_T = 1'b1;  
       @(posedge uart_clk); 
       wr_uart_T = 1'b0;         

//Primera lectura no se realiza, ya que el puntero se encuentra en la posicion 0 originalmente      
//       @(posedge rec_readyH); 
//       rd_uart_R = 1'b1;
//       @(posedge uart_clk)
//       rd_uart_R = 1'b0;
        
        //Se verifica el primer byte recibido
        @(negedge rec_readyH);
        if (r_data == 8'hAA)
             $display("Test 1 Passed - Correct Byte Received");
        else 
            $display("Test 1 Failed - Incorrect Byte Received"); 
        @(posedge uart_clk)
//          //====================================================    


        @(posedge uart_clk);
        @(posedge uart_clk);
       w_data = 8'h33; 
       wr_uart_T = 1'b1;  
       @(posedge uart_clk); 
       wr_uart_T = 1'b0;         
       
       @(posedge rec_readyH); 
       rd_uart_R = 1'b1;
       @(posedge uart_clk)
       rd_uart_R = 1'b0;
        
        //Se verifica el primer byte recibido
        @(negedge rec_readyH);
        if (r_data == 8'h33)
             $display("Test 2 Passed - Correct Byte Received");
        else 
            $display("Test 2 Failed - Incorrect Byte Received"); 
        @(posedge uart_clk)
//          //==================================================== 

     
        @(posedge uart_clk);
        @(posedge uart_clk);
        w_data = 8'hF1; 
        wr_uart_T = 1'b1;  
        @(posedge uart_clk); 
        wr_uart_T = 1'b0;         
        
        @(posedge rec_readyH); 
        rd_uart_R = 1'b1;
        @(posedge uart_clk)
        rd_uart_R = 1'b0;
        
        //Se verifica el primer byte recibido
        @(negedge rec_readyH);
        if (r_data == 8'hF1)
             $display("Test 3 Passed - Correct Byte Received");
        else 
            $display("Test 3 Failed - Incorrect Byte Received"); 
        @(posedge uart_clk)
//          //==================================================== 


                
                repeat(10)begin
                    #(bit_period);
                end

     $finish();

    end 
    
 
       
endmodule