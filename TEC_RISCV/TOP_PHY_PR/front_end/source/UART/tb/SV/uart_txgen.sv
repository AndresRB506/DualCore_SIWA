`timescale 1ns / 1ps

class uart_txgen;
   uart_sb sb;
   virtual uart_ports ports;
   bit tx_done;
   bit rx_done;

   // Connects the transmitter output to recevier input
   bit loopback=0;
   // Number of frames to send to transmitter
   integer no_tx_cmds;
   // Number of frames to send to receiver
   integer no_rx_cmds;
   // Delay the reading of data from receiver
   bit rx_over_flow;
   // Send frame to transmitter before it has sent out last frame
   bit tx_over_flow;
   // Insert framming error (stop bit) in frame sent to receiver
   bit rx_frame_err;

   function new (virtual uart_ports ports);
   begin
     this.ports = ports;
     sb = new();
     tx_done = 0;
     rx_done = 0;
     no_tx_cmds = 4;  // Corresponden a la cantidad de paquetes 
     no_rx_cmds = 4;  //     				||
     rx_over_flow = 0;
     rx_frame_err = 0;
     ports.push_T = 0;
     ports.pop_R = 0;
   end
   endfunction
  
   // Main method, which starts rest of methods 
   task goTxgen();
   begin
     tx_done = 0;
     rx_done = 0;
     assertReset();
     fork 
        txDriver();  
        rxDriver();  
        txMonitor(); 
        rxMonitor(); 
     join_none
   end
                


                                  endtask
   
   // This method asserts reset ------------------------------------------------
  task assertReset();
   begin
      @ (posedge ports.sys_clk);
      ports.sys_rst_l = 1'b1;
      $write("%dns : Asserting sys_rst_l to Uart\n",$time);
      repeat (6) @ (posedge ports.sys_clk);
      ports.sys_rst_l = 1'b0;
          $write("%dns : Asserting sys_rst_l =1 to Uart\n",$time);
      end
  endtask
   //-------------------------------------------------------------------------------
   
   task txDriver();
   begin
    integer i = 0;
    integer tx_timeout = 0;
    bit [63:0] Din_fifo = 0;
    for (i = 0; i < no_tx_cmds; i ++)  begin
        Din_fifo = {$urandom(),$urandom()};
        sb.txAdd(Din_fifo);
        if (loopback == 1) begin
           sb.rxAdd(Din_fifo);
        end  
        // Check if uart is ready to accept data for transmission
         while (ports.tx_full == 1) begin
         @ (posedge ports.uart_clk);
         tx_timeout ++ ;
         if (tx_timeout > 16) begin
           $write("%dns : txDriver : Warning : tx_full is 1 for more then 16 uart_clocks\n",
             $time);
         end
        end
       tx_timeout = 0;  
       // Drive the data in UART for transmitting
        @ (posedge ports.sys_clk);
        ports.push_T = 1;
        ports.Din_fifo    = Din_fifo;
        $write("%dns : txDriver  : Transmitting data %x\n",$time, Din_fifo);
        @ (posedge ports.sys_clk);
        ports.push_T = 0;
        repeat (160) @ (posedge ports.uart_clk);
            tx_timeout=0;
    end
    tx_done = 1;
   end
   endtask
   //-------------------------------------------------------------------------------


   task rxDriver();
   begin
     bit [7:0] rec_dataH = 0;
     bit [7:0] [7:0] Paquete_Datos = 0;
     integer i,j,l = 0;
     if (loopback == 1) begin
       ports.loopback = 1;
     end 
     else begin
        ports.loopback = 0;
        for (i = 0; i < no_rx_cmds; i++)  begin
          for (l = 0; l < 8; l++)  begin
            rec_dataH = $urandom(); 
            Paquete_Datos[l] = rec_dataH;
            if (l==7) begin
              sb.rxAdd(Paquete_Datos);
            Paquete_Datos = '{default:0};
            end 
            //sb.rxAdd(Paquete_Datos);
            $write("%dns : rxDriver  : Transmitendo el dato: %x\n",$time, rec_dataH);
            @ (posedge ports.uart_clk);
            // bit de inicio
            ports.uart_REC_dataH = 0;
            for (j = 0; j < 9; j ++) begin
                repeat (16) @ (posedge ports.uart_clk); // 128 = 16 ciclos x 8 datos
                ports.uart_REC_dataH = rec_dataH[j];
            end
              @ (posedge ports.uart_clk);
            ports.uart_REC_dataH = ^rec_dataH; // bit de paridad
            repeat (16)@ (posedge ports.uart_clk);
            ports.uart_REC_dataH = 1; // bit de parada
            repeat (16) @ (posedge ports.uart_clk);
          end
        end
     end
     rx_done = 1;
   end
   endtask


   task txMonitor();
   begin
      bit [7:0] [7:0] Din_fifo = 0;
      bit [7:0] Din_byte = 0;
      integer i = 0;
      integer j = 0;
      while (1) begin
        @ (posedge ports.uart_clk);
        if (ports.uart_XMIT_dataH == 0) begin
          $write("%dns : txMonitor : Inicio tx\n",$time); //sale un ciclo despues del inicio
          //Empieza a muestrear el dato transmitido
          for (j = 0; j < 8; j ++)  begin
            repeat (7) @ (posedge ports.uart_clk); // hasta 7 para buscar el centro de cada bit
            for (i = 0; i < 8; i ++)  begin // Muestrea el paquete de 8 bits
              repeat (16) @ (posedge ports.uart_clk);  
                Din_byte[i] = ports.uart_XMIT_dataH; 
            end 
            repeat (42) @ (posedge ports.uart_clk); //  
            //$write("%dns : txMonitor : Dato muestreado %x\n",$time, Din_byte);
            Din_fifo [j] = Din_byte; 
            ////////////////////////////////////////////////////////////////////
          end
          $write("%dns : txMonitor : Paquete de datos muestreado %x\n",$time, Din_fifo);
          sb.txCompare(Din_fifo);
        end  //if
      end //while
   end
   endtask

   task rxMonitor() ; 
   begin
     bit [7:0] [7:0] Din_rec;
     bit [7:0] Byte_rec;
     integer i = 0;
     integer j = 0;
     while (1) begin
        @ (posedge ports.uart_clk);
        if (ports.uart_REC_dataH == 0) begin
          $write("%dns : rxMonitor : Inicio rx\n",$time);
          for (j = 0; j < 8; j ++)  begin
              repeat (8) @ (posedge ports.uart_clk); // hasta 7 para buscar el centro de cada bit
              for (i = 0; i < 8; i ++)  begin // Muestrea el paquete de 8 bits, n toma en cuenta el de paridad
                repeat (16) @ (posedge ports.uart_clk);  
                  Byte_rec[i] = ports.uart_REC_dataH; 
              end
              repeat (42) @ (posedge ports.uart_clk); //
              $write("%dns : rxMonitor : Dato muestreado %x\n",$time, Byte_rec);
              Din_rec[j] = Byte_rec;
          end
          $write("%dns : rxMonitor : Paquete de datos muestreado %x\n",$time, Din_rec);
          sb.rxCompare(Din_rec);
      	end //end if      	
     end // end while
   end
   endtask
    
   function bit isDone();
   begin
     if (tx_done == 1 && rx_done == 1 && ports.tx_full != 1) begin
       isDone =  1;
     end else begin
       isDone = 0;
     end
   end
   endfunction
endclass
