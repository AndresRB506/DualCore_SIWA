`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sanchez Jimenez
// 
// Create Date: 04/12/2018 09:23:21 AM
// Design Name: UART
// Module Name: uart_to_fifo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control module between utg_reg, u_reg and fifo2

// Descripcion: Modulo de control entre el registro utf, el u_rec y la fifo2
// 
// Dependencias: modulos u_rec.v fifo.v baud.v
// Dependencies: modules u_rec.v fifo.v baud.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// Actualizado 30 de abril. Cambios la señal push hacia la fifo debe durar solo un ciclo de reloj del sistema
//////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------

module log_utf #(parameter pos_array =8, 
                            data_fifo  =64, // 8 bytes -> 64 bits
                            data  =8
                        )( 
    input logic flag_sincr,
    input logic sys_clk,
    input logic rec_ready, 
    input logic sys_rst_l,
    output logic push,  
    output logic rst,
    output logic [pos_array-1:0] enable_reg 
    );
        
    logic rst_cont_byte, ena_cont_byte;
    logic [$clog2(pos_array)-1:0] cont_byte;
    logic [data-1:0] array [data-1:0];
    logic push_en, set_push, rst_push, reset_push; 
    
   //Parameters
    enum logic [1:0]
      { IDLE  = 2'b00,
        CARGA = 2'b01,
        ENVIO = 2'B10,
        STOP  = 2'B11} state, next_state;
    
    localparam HI = 1'b1,
               LO = 1'b0,
               X  = 1'bx,
               Z  = 1'bz;

    // maquina push
    enum logic [1:0]
    	    { idle= 2'b00,
    	      desact_push = 2'b01,
              desact_rst_push = 2'b10} p_state, p_next_state;
              
 // Registro push--------------------------------------------------------
 always_ff @ (posedge sys_clk) begin
    if (rst_push | sys_rst_l)
        push_en = LO;
    else if (set_push)
        push_en = HI;
    else 
        push_en = LO;
 end   
  //---------------------------------------------------------------------
  
    // FSM para señal push
    always_ff @ (posedge sys_clk or posedge sys_rst_l) begin
    	if (sys_rst_l) begin
    	    p_state <= idle;
        end
    	else 
    	    p_state <= p_next_state;
    end

    always_comb begin 
 	push = LO;
 	p_next_state = p_state;
    rst_push = LO;
 	case (p_state)
 	    idle: begin
 	    	if (push_en) begin
 	    	    push = HI;
 	    	    p_next_state= desact_push;
 	        end
 	        else begin
 	            p_next_state = idle;
            end
 	    end
 	    desact_push: begin
 	    	push = LO;
 	    	p_next_state = desact_rst_push;
 	    	rst_push = HI;
 	    end
 	    desact_rst_push: begin
 	    	if (reset_push) begin
 	    	    rst_push = LO;
 	    	    p_next_state = idle;
 	    	end
 	    	else
 	    	    p_next_state = desact_rst_push;
 	    end
        default : begin
            push = LO;
            p_next_state = idle;
            rst_push = LO;
        end
 	endcase
     end
    	      
  // Deco de activacion de los registros del uft reg
  always_ff @ (posedge sys_clk) begin
    if (rec_ready && flag_sincr)
        enable_reg[cont_byte] = 1'b1;
    else 
    	enable_reg = {pos_array{1'b0}};
  end
  //--------------------------------------------------------- 
    
    //Contador de bytes ---------------------------------------
    always_ff @ (posedge sys_clk or posedge sys_rst_l) begin
        if (sys_rst_l)
            cont_byte <=0;
        else if (flag_sincr) begin
		    if (rst_cont_byte)
		        cont_byte <=0;
		    else if (ena_cont_byte)
		        cont_byte <= cont_byte+1;
		    else cont_byte <= cont_byte;
		end
    end
    //--------------------------------------------------------- 
    
    // State Variable
    always_ff @ (posedge sys_clk or posedge sys_rst_l) begin
        if (sys_rst_l)
            state <= IDLE;
        else if (flag_sincr)
            state <= next_state;
    end 
    
    // FSM
    always_comb begin
        // Defaults
        next_state    = state;
        ena_cont_byte = LO;
        rst_cont_byte = LO;
        rst           = LO;
        set_push      = LO;
        reset_push    = LO;
        
        case (state)
            IDLE: begin
                if (rec_ready) begin// if receive a complete package
                    next_state = CARGA;
                    ena_cont_byte = HI;
                end
                else begin
                    next_state = IDLE;
                    rst = HI; // reset array
                end                    
            end
            
            CARGA: begin
                if (rec_ready) begin  
                    if (cont_byte == (pos_array-1)) begin
                        next_state= ENVIO;
                    end
                    else 
                        ena_cont_byte = HI;
                end
                else 
                    next_state = CARGA;                
            end
            
            ENVIO: begin
                set_push = HI;
                rst_cont_byte = HI;
                next_state = STOP;
            end
            
            STOP: begin
                reset_push=HI;
                next_state = IDLE;
            end
        endcase
    end
    
endmodule
