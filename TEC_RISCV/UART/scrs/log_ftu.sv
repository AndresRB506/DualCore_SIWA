`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 06:13:23 PM
// Design Name: UART
// Module Name: fifo_to_uart_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control module between ftu reg, x_mit and fifo2
// 
// Dependencies: 

// Descripcion: Modulo de control entre el registro ftu, el xmit y la fifo2
// Dependencias: baud.v, fifo_T.v, xmit.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//Actualizado 30 abril. Cambios: La señal pop hacia la fifo dura un solo un ciclo de reloj del sistema
//////////////////////////////////////////////////////////////////////////////////


module log_ftu #(parameter pos_array = 8,
                           data_fifo  =64,   // 8 bytes 8 *8
                           byte_out = 8)( // 1 byte
    input logic flag_sincr,
    input logic sys_clk,
    input logic xmit_done, 
    input logic pndng, 
    input logic sys_rst_l,
    input logic [data_fifo-1:0] D_reg, // from ftu reg
    output logic [byte_out-1:0] Dout, // to xmit 
    output logic xmit, 
    output logic pop 
   
);

logic [$clog2(pos_array)-1:0] cont_byte;
logic [byte_out-1:0] array [pos_array-1:0];
logic rst, rst_cont_byte, ena_cont_byte; 
logic pop_en, set_pop, rst_pop, reset_pop; // fifo
logic flag_four_eight, four_eight;

genvar i;
generate 
    for (i =0; i < pos_array; i=i+1) begin :l_ftu
        assign array[i] = D_reg[(7+i*8):(8*i)];
    end
 endgenerate
 
assign Dout [byte_out-1:0] = array[cont_byte];

//--------------------------------------------------------- 

 // Parameters
 localparam 
      HI = 1'b1,
      LO = 1'b0,
      Z  = 1'bz;
 
 enum logic [2:0]
  { IDLE     = 3'b000,
    POP_DATA = 3'b001,
    QTY_BYTE = 3'b010,
    START    = 3'b011,
    WAIT     = 3'b100,
    SEND     = 3'b101,
    STOP     = 3'b110 } state, next_state;
 
 // maquina pop
 enum logic [1:0]
  { idle = 2'b00,
    desact_pop = 2'b01,
    desact_rst_pop = 2'b10 } p_state, p_next_state;
    
 //Transmitted byte counter---------------------------------------
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
 //---------------------------------------------------------------------
 // estimate bytes to send
 always_ff @(posedge sys_clk or posedge sys_rst_l) begin
    if (sys_rst_l) 
        four_eight <= 1'b0;
    else if (flag_four_eight) begin // Si hay un dato nuevo
        if(|D_reg[55:32] ==1'b0)
            four_eight<= 1'b0;
        else       four_eight<= 1'b1;
    end
end
 //---------------------------------------------------------------------
 // Register pop--------------------------------------------------------
 always_ff @ (posedge sys_clk) begin
    if (sys_rst_l | rst_pop)
        pop_en = LO;
    else if (set_pop)
        pop_en = HI;
    else 
        pop_en = LO;
 end   
  //---------------------------------------------------------------------

 // FSM  pop--------------------------------------------------- 
always_ff @ (posedge sys_clk or posedge sys_rst_l) begin
    if (sys_rst_l) begin
        p_state <= idle;
    end
    else 
        p_state <= p_next_state;
end     
             
 always_comb begin 
     pop = LO;
     p_next_state = p_state;
     rst_pop = LO;
     case (p_state)
         idle: begin
             if (pop_en) begin
                 pop = HI;
                 p_next_state= desact_pop;
             end
             else
                 p_next_state = idle;
         end
         desact_pop: begin
             pop = LO;
             p_next_state = desact_rst_pop;
             rst_pop=HI;
         end
         desact_rst_pop:  begin
             if (reset_pop) begin
                 rst_pop=LO;
                 p_next_state = idle;
             end
             else 
             	 p_next_state = desact_rst_pop;
         end
         default: begin
         	pop = LO;
     		p_next_state = idle;
    	 	rst_pop = LO;
         end
     endcase
 end
 //---------------------------------------------------------------------
 
 // State Variable
 always_ff @ (posedge sys_clk or posedge sys_rst_l) begin
 	if (sys_rst_l) begin
    	state <= IDLE;
    end
    else if (flag_sincr)
        state <= next_state;
 end
  //--------------------------------------------------------- 
 
 // FSM    
 always_comb begin 
     // Defaults
     next_state    = state;
     ena_cont_byte = LO;
     rst_cont_byte = LO;
     rst           = LO;
     set_pop       = LO;
     xmit          = LO;
     reset_pop     = LO;
     flag_four_eight= LO;  
     case (state)
         IDLE: begin //0
            if (pndng) begin
                next_state = POP_DATA;
            end
            else begin
                next_state = IDLE;
                rst = HI; // reset array
                rst_cont_byte = HI;
            end    
         end
         
         POP_DATA: begin //1
            set_pop = HI;  
            next_state = QTY_BYTE;
         end

         QTY_BYTE: begin // 2   
            reset_pop = HI;
            flag_four_eight = HI;
            next_state = START;
         end

         START: begin //3
            xmit = HI;
            next_state = WAIT;
         end
         
         WAIT: begin //4
            if (four_eight==1'b0) begin
                if (xmit_done) begin
                    if (cont_byte == pos_array-5) begin //pos_array=8, de 0 a 3 = 4 bytes para enviar
                        next_state = STOP; 
                   end
                    else begin
                        next_state = SEND;
                        ena_cont_byte = HI;
                    end
                end
                else begin
                    next_state = WAIT;
                end
            end
            else begin
                if (xmit_done) begin
                    if (cont_byte == pos_array-1) begin
                        next_state = STOP; 
                   end
                    else begin
                        next_state = SEND;
                        ena_cont_byte = HI;
                    end
                end
                else begin
                    next_state = WAIT;
                end
            end
         end
         
         SEND: begin //5
            xmit=HI;
            next_state = WAIT;
         end
         
         STOP: begin //6            
            rst_cont_byte = HI;
            next_state = IDLE;
         end
         
         default: begin
             next_state    = IDLE;
	     ena_cont_byte = LO;
	     rst_cont_byte = LO;
	     rst           = LO;
	     set_pop       = LO;
	     xmit          = LO;
	     reset_pop     = LO;
	     flag_four_eight = LO;  
         end
     endcase
  end
endmodule


