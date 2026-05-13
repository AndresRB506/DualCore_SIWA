		//###################################################################################
		//  Definicion de la estructura general de un paquete generico
		//#################################################################################
                // el tamano del paquete debe ser definido en le test:  `define PCKG_SZ XX 
		  typedef struct {
		    bit [7:0] trgt;
		    bit [`PCKG_SZ-9:0] pyld; 
		  } pck;


		//###################################################################################
		//  Definicion de la inteface de entrada del fifo para cargar datos desde un queue
		//##################################################################################

			module input_interface_controller #(parameter pck_sz) (
			  input dta_pndng,
			  input clk,
			  input reset,
			  input [pck_sz:0] pck,
			  input fifo_full,
			  output reg [pck_sz:0]D_push,
			  output reg push,
			  );
			  typedef enum logic[1:0] {inicio=0,carga=1,fifo_push=2,espera=3 } estado;
			  estado FSM_estado;
			  
			  // maquina de estados
			  always@(posedge clk, posedge reset) begin
			    if(reset) begin
		      FSM_estado = inicio;
		    end else begin
		     case (FSM_estado)
		       inicio:begin
			 if(~fifo_full&&dta_pndng)begin
			   FSM_estado <= carga;
			 end else
			   FSM_estado <= inicio;
			 end
		       end
		       carga:begin
			 D_push <= pck;
			 FSM_estado <= push
		       end
		       fifo_push:begin
			 FSM_estado <= espera;
		       end
		       espera:begin
			 FSM_estado <= inicio;
		       end
		     endcase
		    end
		  end
		  
		  always_comb begin
		    push <= (FSM_estado == push)?{1'b1}:{1'b0}:
		  end
		endmodule

	//###############################################################################################
	//  Definicion de la estructura de datos que contendra los mensajes por enviar en cada interface 
	//###############################################################################################

	class queue #(parameter int num_msgs = 4,parameter int pck_sz, parameter int bus_id=0, parameter int driver_id=0);
	    protected bit pndng_msgs;
	    protected int index;
	    pck data [num_msgs];
	    
	    function bit push(pck mensaje);
	      if(index < (num_msgs)) begin
		data[index] = mensaje;
		index = index+1;
		pndng_msgs = {1'b1}; 
		$display("The message %h targeting the driver %g was added to the input queue of the bus %g driver %g at time %g" mensaje.pyld, mensaje.trgt,bus_id, driver_id,$time);
		return 0;
	      end else begin
		$display("Error there is no space left in the input queue for bus %g in the driver %g at time %g" bus_id, driver_id,$time);
		return 1;
	      end
	    endfunction
	    
	    function bit pop(int bt, int drvr);
	      if(index > 0)begin
		index = index -1;
		pndng_msgs = (index == 0)?{1'b0}:{1'b1}; 
		return 0;
	      end else begin
		$display("Error there is nothing to pop from the queue in bus %g ID %g at time %g" bus_id,driver_id,$time);
		return 1;
	      end
	    endfunction

	    function pck current(int bt, int drvr);
	      if(index != 0)begin
		return data[index-1];
	      end else begin
		$display("ERROR: The queue for bit %g drvr %g is empty, nothing to return at time %g",bus_id,driver_id,$time);
		 return data[0];
	      end
	    endfunction
	    
	    function bit get_pndng();
	      return  pndng_msgs;
	    endfunction
	    
	    function init (int numero_drivers, int numero_iteraciones);
	      int driver =0;
	      int iteracion =0;
	      bit[pck_sz-9:0] payload [4];
              payload[0] = {pck_sz/4{4'b1010}};
              payload[1] = {pck_sz/4{4'b0101}};
              payload[2] = {pck_sz/4{4'b0000}};
              payload[3] = {pck_sz/4{4'b1111}};
      for (driver=0;driver<numero_drivers;drivers++)begin
        for (iteracion=0;iteracion<numero_iteraciones;iteracion++)begin
           pck mensaje;
           mensaje.trgt=driver;
           foreach(payload[i])begin
             melnsaje.pyld=payload[i];
             this.push (mensaje);
           end
        end      
      end
      return 0;
    endfunction
   
endclass


//###############################################################
// Definición de un scoreboard básico
//##############################################################

  class scoreboard #(parameter int num_msgs = 100,parameter int pck_sz);
   typedef struct{
     bit [7:0] trgt;
     bit [`PCKG_SZ-9:0] pyld;
     bit complete;
     int src;
     int tm_rcvd;
     int tm_snd;
     int bus;
   }score;
   
   protected score sb[num_msgs];
   protected int index =0;
   
   function bit send(bit[7:0] trgt, int src, int tm_snd, int bus, bit[pck_sz-9:0] pyld);
     if(index<num_msgs)begin
       sb[index].trgt = trgt;
       sb[index].src = src;
       sb[index].tm_snd = tm_snd;
       sb[index].bus = bus;
       sb[index].pyld = pyld;
       sb[index].tm_rcvd =0;
       sb[index].complete =0;
       index=index+1;
       return 0;
     end else begin
       $display("The scoreboard overflowed at time %g" $time);
       return 1;
     end
   endfunction 
    
   function int received(bit[7:0] trgt,bit[pck_sz-9:0] pyld, int bus);
     if(index!=0)begin
       int i =0;
       int completed_transactions = 0;
       for(i=0;i<=index;i=i+1)begin
         if((sb[i].trgt == trgt) && (sb[i].pyld == pyld) && (sb[i].complete == 0) && (sb[i].bus==bus) && (sb[i].tm_rcvd == 0)) begin
           sb[i].tm_rcvd = $time;
           sb[i].complete = 1;
           return completed_transactions+1;
         end
         if(sb[i].completed==1)begin
           completed_transactions=completed_transactions+1;
         end
       end
       if(index<num_msgs)begin
         sb[index].trgt = trgt;
         sb[index].src = 0;
         sb[index].tm_snd = 0;
         sb[index].bus = bus;
         sb[index].pyld = pyld;
         sb[index].tm_rcvd =$time;
         sb[index].complete =0;
         return completed_transactions;
       end else begin 
         $display("The scoreboard overflowed at time %g" $time);
         return completed_transactions;
       end
     end else begin
         sb[index].trgt = trgt;
         sb[index].src = 0;
         sb[index].tm_snd = 0;
         sb[index].bus = bus;
         sb[index].pyld = pyld;
         sb[index].tm_rcvd =$time;
         sb[index].complete =0;
         return completed_transactions;
     end
   endfunction

   function bit status();
     bit test_status = 1;
     $display("BEGIN_REPORT");
     $display("status,time_send,time_rcvd,bus,source_ID,receiver_ID,delay_clk_cycles,msg_payload,msg_trgt");
     foreach(sb[i])begin
       $display("%g,%g,%g,%g,%g,%g,%g,%h,%g",sb[i].complete,sb[i].tm_snd,sb[i].tm_rcvd,sb[i].bus,sb[i].src,sb[i].rcvd,(sb[i].tm_rcvd-sb[i].tm_snd-1)/2,sb[i].pyld,sb[i].trgt);
       if(~sb[i].complete)begin
         test_status = 0;
       end
     end
     if(test_status)begin
       $display("TEST STATUS = PASS");
     end else begin
       $display("TEST STATUS = FAIL");
     end
     $display("END_REPORT");
     return 0;
   endfunction  
   
    
  
  endclass

//###############################################################
// Definición de la interface del bus de salida de cada interfaz
//##############################################################

  module input_interface_controller #(parameter pck_sz) (
    input dta_pndng,
    input[pck_sz:0] D_pop,
    ourput reg push
    );
    always@(posedge clk)begin
    end

  endmodule

