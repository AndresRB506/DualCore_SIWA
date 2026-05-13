`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Bus FSM
// Module Name: bus_fsm
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bus_fsm #(parameter data_size=32, parameter adrs_to_mem_size=11, 
                 parameter inf_size= 8, parameter bus_size=8*10, 
                 parameter d_intr_size=72, parameter adrs_bs_size = 24,
                 parameter fifo_int_size=72)(
    input sys_clk, reset, 
    input Go_error_bus, Pndng, RDY,
    input [data_size-1:0] Q,
    input [bus_size-1:0] Dat_pop,
	input Authrzd_flg, MEIE, Wt_for_read,
    input [inf_size-1:0] CD_IO,
    input Full_int, Pndng_int,
    output reg Mem_en_bus, RW_Mem_bus, Rqs_error_intr_bus,
    output reg Push_bus, Pop_bus,
    output reg [adrs_to_mem_size-1:0] A_sys_bus,
    output reg [data_size-1:0] D_sys_bus,
    output reg [bus_size-1:0] D_Push_bus,
    output reg [d_intr_size-1:0] D_Intr_bus,
    output reg Boot_rdy,
	output reg [1:0] Cod_vrfr_bus, Dir_vrfr_bus,
    output reg [data_size-1:0] Data_Read_bus,
    output reg Read_done,
    output reg Push_int,
    output reg [fifo_int_size-1:0] D_Push_int
    );

    localparam lim_mem = 'd2048;            //Tamaño de la memoria de programa
    
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // *    Registros internos para el manejo del flujo de funcionamiento    *
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    reg [inf_size-1:0] Cod_op;
    reg [data_size-1:0] data;
    reg [adrs_bs_size-1:0] dir;
    reg [inf_size-1:0] Dest;
    reg kp_wtng;
    reg [data_size-1:0] data_mem_prov;

    always @(posedge RDY) begin
        case(dir[1:0])
            2'b00: begin
                casex(Cod_op[1:0])
                    2'b01: data_mem_prov = {Q[31:16],data[15:0]};
                    2'b1x: data_mem_prov = {Q[31:8],data[7:0]};
                endcase
            end
            2'b01: data_mem_prov = {Q[31:16],data[15:8],Q[7:0]};
            2'b10: begin
                casex(Cod_op[1:0])
                    2'b01: data_mem_prov = {data[15:0],Q[15:0]};
                    2'b1x: data_mem_prov = {Q[31:24],data[7:0],Q[15:0]};
                endcase
            end
            2'b11: data_mem_prov = {data[7:0],Q[23:0]};
            default: data_mem_prov = {data_size{1'b0}};
        endcase
    end
    
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// *	Creación de los estados de la máquina	 *
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    enum logic [2:0] {external_wait = 3'b001,
                        internal_wait = 3'b010,
                        ask_for_read  = 3'b000,
                        push_wait  = 3'b101,
                        wait_memory  = 3'b111,
                        send_error  = 3'b100} state;
    
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// *	Inicio de la lógica de la FSM	 *
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    always @(posedge sys_clk, posedge reset) begin
        if (reset) begin
            Read_done <= 1'b0;
            D_Push_int <={fifo_int_size{1'b0}};
            Push_int <= 1'b0;
            Data_Read_bus <= {data_size{1'b0}};
            {Mem_en_bus, RW_Mem_bus, Rqs_error_intr_bus} <= 3'd0;
            {Pop_bus, Push_bus} <= 2'd0;
            A_sys_bus <= {adrs_to_mem_size{1'd0}};
			D_sys_bus <= {data_size{1'b0}};
            D_Push_bus <= {8'h01,8'h00,8'h14,{adrs_bs_size{1'b0}},{data_size{1'b0}}};
			{Cod_vrfr_bus, Dir_vrfr_bus} <= 4'd0;
            D_Intr_bus <= {d_intr_size{1'b0}};
			{Cod_vrfr_bus,Dir_vrfr_bus} <= 4'd0;
            Cod_op <= {inf_size{1'b0}};
			data <= {data_size{1'b0}};
            dir <= {adrs_bs_size{1'b0}};
            Dest <= {inf_size{1'b0}};
            Boot_rdy <= 1'd0;
            kp_wtng <= 1'b0;
            state <= push_wait;
        end 
        else begin
            case (state) 
                internal_wait: begin
                    Pop_bus <= 1'b0;
                    Read_done <= 1'b0;
                    if(Read_done && Wt_for_read) state <= internal_wait;
                    else if(Pop_bus && Pndng_int) state <= internal_wait;
                    else if(Pndng_int) begin
                        state <= ask_for_read;						
                        Cod_op <= Dat_pop[adrs_bs_size+data_size+inf_size-1:adrs_bs_size+data_size];
                        Dest <= Dat_pop[adrs_bs_size+data_size+2*inf_size-1:adrs_bs_size+data_size+inf_size];
                        data <= Dat_pop[data_size-1:0]; 
                        dir <= Dat_pop[adrs_bs_size+data_size-1:data_size];
                        Cod_vrfr_bus <= Dat_pop[adrs_bs_size+data_size+1:adrs_bs_size+data_size];
                        Dir_vrfr_bus <= Dat_pop[data_size+1:data_size];
                    end else state <= external_wait;
                end
                external_wait: begin
                    {Push_bus,Pop_bus, Push_int} <= 3'd0;
                    D_Push_bus <= {bus_size{1'b0}};
                    if (Pndng) begin 
                        state <= ask_for_read;						
                        Cod_op <= Dat_pop[adrs_bs_size+data_size+inf_size-1:adrs_bs_size+data_size];
                        Dest <= Dat_pop[adrs_bs_size+data_size+2*inf_size-1:adrs_bs_size+data_size+inf_size];
                        data <= Dat_pop[data_size-1:0]; 
                        dir <= Dat_pop[adrs_bs_size+data_size-1:data_size];
                        Cod_vrfr_bus <= Dat_pop[adrs_bs_size+data_size+1:adrs_bs_size+data_size];
                        Dir_vrfr_bus <= Dat_pop[data_size+1:data_size];
                    end else state <= external_wait;
                end
                ask_for_read: begin
                    if (Boot_rdy) begin     //Boot ya está finalizado
                        if(Wt_for_read) begin    
                            if (CD_IO == Dest) begin
                                Read_done <= 1'b1;
                                Data_Read_bus <= data;
                                state <= internal_wait;
                                Pop_bus <= 1'b1;
                            end else begin
                                Read_done <= 1'b0;
                                D_Push_int <= {Dest,Cod_op,dir,data};
                                Push_int <= 1'b1;
                                if (Full_int) begin
                                    D_Intr_bus <= {8'h00,8'h06,24'd0,32'd0};
                                    Rqs_error_intr_bus <= 1'b1;
                                    state <= send_error;
                                end else begin
                                    Pop_bus <= 1'b1;
                                    state <= external_wait;
                                end
                            end
                        end else if (MEIE == 1'b0) begin         //No está habilitada las interrupciones externas
                            Pop_bus <= 1'b1;
                            if(Pndng_int) state <= internal_wait;
                            else state <= external_wait;
                        end else begin
                            D_Intr_bus <= {Dest,Cod_op,dir,data};
                            Rqs_error_intr_bus <= 1'b1;
                            state <= send_error;
                        end
                    end else begin      //Boot no ha terminado
                        if (Dest == 'h01) begin     //Verifica que el dato provenga del SPI
                            if (Cod_op=='h10 || Cod_op=='h11 || Cod_op=='h13) begin     //En el booteo solo se aceptan escrituras en memoria de programa
                                if (dir[adrs_bs_size-1:2] >= lim_mem) begin //Dirección inválida, superior al límite de memoria
                                    Pop_bus <= 1'b1;
                                    state <= external_wait;
                                end else begin      //Dirección válida
                                    if (Authrzd_flg) begin   //Dirección alineada
                                        A_sys_bus <= dir[adrs_to_mem_size+1:2];
                                        Mem_en_bus <= 2'b1;
                                        if(Cod_op=='h10) begin
                                            RW_Mem_bus <= 1'b1;
                                            D_sys_bus <= data;
                                        end else begin
                                            RW_Mem_bus <= 1'b0;
                                            kp_wtng <= 1'b1;
                                        end
                                        state <= wait_memory;
                                    end else begin      //Dirección desalineada
                                        Pop_bus <= 1'b1;
                                        state <= external_wait;
                                    end
                                end
                            end else if(Cod_op=='h18) begin     //Código de finalización de booteo
                                Pop_bus <= 1'b1;
                                Boot_rdy <= 1'b1;
                                state <= external_wait;
                            end else begin
                                Pop_bus <= 1'b1;
                                state <= external_wait;
                            end
                        end else begin
                            Pop_bus <= 1'b1;
                            state <= external_wait;
                        end
                    end     //Fin del proceso cuando el boot no ha terminado de cargarse
                end
                wait_memory: begin
                    if (RDY) begin
                        if(kp_wtng) begin
                            RW_Mem_bus <= 1'b1;
                            D_sys_bus <= data_mem_prov;
                            kp_wtng <= 1'b0;
                            state <= wait_memory;
                        end else begin
                            Mem_en_bus <= 1'b0;
                            Pop_bus <= 1'b1;
                            state <= external_wait;
                        end
                    end else state <= wait_memory;
                end
                send_error: begin
                    if (Go_error_bus) begin
                        Pop_bus <= 1'b1;
                        Rqs_error_intr_bus <= 1'b0;
                        if (Wt_for_read) state <= external_wait;
                        else begin
                            if (Pndng_int) state <= internal_wait;
                            else state <= external_wait;
                        end
                    end else state <= send_error;
                end
                push_wait: begin                //No se verifica que la bandera de Full esté en alto debido a que este estado solo se utiliza al iniciar el sistema, 
                    Push_bus <= 1'b1;           // cuando sucede el reset, por lo que las FIFOs del bus deben estar vacías
                    state <= external_wait;
                end
                default: begin
                    Read_done <= 1'b0;
                    Data_Read_bus <= {data_size{1'b0}};
                    {Mem_en_bus, RW_Mem_bus, Rqs_error_intr_bus} <= 3'd0;
                    {Pop_bus, Push_bus} <= 2'd0;
                    A_sys_bus <= {adrs_to_mem_size{1'd0}};
                    D_sys_bus <= {data_size{1'b0}};
                    D_Intr_bus <= {d_intr_size{1'b0}};
                    {Cod_vrfr_bus,Dir_vrfr_bus} <= 4'd0;
                    Cod_op <= {inf_size{1'b0}};
                    data <= {data_size{1'b0}};
                    dir <= {adrs_bs_size{1'b0}};
                    Dest <= {inf_size{1'b0}};
                    state <= external_wait;
                end
            endcase
        end
    end
    
    
endmodule
