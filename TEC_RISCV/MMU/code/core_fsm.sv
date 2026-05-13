`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Máquina de estados del core
// Module Name: core_fsm
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module core_fsm #(parameter Address_size = 32, parameter FIFO_size=80,
                  parameter Data_size = 32, parameter inf_size = 8,
                  parameter d_intr_size=72, parameter adrs_size = 24, 
                  parameter amount_io=5, parameter adrs_mem_size = 11)(
    input sys_clk, reset,
    input Boot_rdy, Authrzd_flg,
    input Go_error_core, Full, MTIE,
    input Enable, RW, B, H, RDY,
    input Read_done, Watch_dg_flg,
    input [Data_size-1:0] Data_Write, Q,
    input [Address_size-1:0] Address, 
    input [amount_io:0][31:0] CSR_limits,
    input [Data_size-1:0] CSR_io,
    input [Data_size-1:0] Data_Read_bus,
    output reg Mem_rdy_core, RW_Mem_core, Mem_en_core,
    output reg Rqs_error_intr_core, Push_core, 
    output reg [Data_size-1:0] D_sys_core, Data_Read_core,
    output reg [adrs_mem_size-1:0] A_sys_core,
    output reg [FIFO_size-1:0] D_push_core,
    output reg [d_intr_size-1:0] D_Intr_core,
    output reg Wt_for_read,
    output reg [31:0] watch_dog_reg,
    output reg [inf_size-1:0] CD_IO
    );

    reg [31:0] mtime_a, mtime_b, mtimecmp_a, mtimecmp_b;
    reg time_intr;
    reg [adrs_size-1:0] adrs_cod;
	reg adrs_error;
    reg RW_reg, Enable_reg, B_reg, H_reg;
	reg [Address_size-1:0] Address_reg;
	reg [Data_size-1:0] Data_Write_reg;	
    reg [Data_size-1:0] Data_out_reg;
    reg cambio, kp_wtng, H_cod;
    reg rqs_time_intr, rqs_error_intr;
    reg time_io_intr_push, error_io_intr_push;
    reg [d_intr_size-1:0] d_intr_error, d_intr_time;
    reg mmio_detctd;                //El IO al que el core quiere accesar es un MMIO, por lo que si hay una lecura se debe esperar el retorno de un dato.
    reg csr_limit_error;            //Para que el error debido a que el límite de CSR es menor al límite de mapeo de memoria solo suceda una vez.

    localparam [1:0][11:0] lim_mapeo = {12'd5,12'd2048};          //Valores del tamaño de la memoria y los CSR de time
    
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // *	Comienza la lógica para el decodificador del mapeo						   *
	// *	Este decodificador es parametrizable y depende de la cantidad de IO's	   *
	// *	 y del tamaño de cada uno de ellos										   *
	// *	Este decodificador también permite levantar una bandera que indica si la   *
	// *	 dirección dada se pasa de la dirección máxima del mapeo				   *
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    wire [Address_size-1:0] ADRS = {2'd0,Address[Address_size-1:2]};
    wire [amount_io+1:0][inf_size-1:0] CD_IO_prov;
    wire [amount_io+1:0][inf_size-1:0] CD_IO_or;
    wire [amount_io+1:0] mmio_detct_prov;
    wire [amount_io+1:0] mmio_detct_or;
    wire [amount_io+1:0][adrs_size-1:0] adrs_cod_prov;
    wire [amount_io+1:0][adrs_size-1:0] adrs_cod_or;
    wire [amount_io-1:0][31:0] lim_ant;
    wire [amount_io-1:0][31:0] lim_sig;
    genvar i;
    generate 
        for (i=0; i<=(amount_io+1); i=i+1) begin: map_decoder
            if(i>=amount_io) begin: mem_and_csr
                assign CD_IO_prov[i] = 0;
                assign mmio_detct_prov[i] = 1'b0;
                if(i==amount_io) begin: ram
                    assign adrs_cod_prov[i] = (ADRS < lim_mapeo[0]) ? ADRS : 0;
                end else begin: csr_time
                    assign adrs_cod_prov[i] = ((ADRS >= lim_mapeo[0]) && (ADRS < (lim_mapeo[0]+lim_mapeo[1]))) ? (ADRS-lim_mapeo[0]) : 0;
                end
            end else begin: ios
                assign lim_ant[i] = CSR_limits[i];
                assign lim_sig[i] = CSR_limits[i+1];
                assign CD_IO_prov[i] = ((ADRS >= lim_ant[i]) && (ADRS < lim_sig[i])) ? i+1 : 0;
                assign mmio_detct_prov[i] = ( (|CD_IO_prov[i]) && CSR_io[i] ) ? 1'b1 : 1'b0;
                assign adrs_cod_prov[i] = ((ADRS >= lim_ant[i]) && (ADRS < lim_sig[i])) ? (ADRS-lim_ant[i]) : 0;
            end
            if(i==0) begin: first
                assign CD_IO_or[i] = CD_IO_prov[i];
                assign mmio_detct_or[i] = mmio_detct_prov[i];
                assign adrs_cod_or[i] = adrs_cod_prov[i];
            end else begin: next
                assign CD_IO_or[i] = CD_IO_or[i-1] | CD_IO_prov[i];
                assign mmio_detct_or[i] = mmio_detct_or[i-1] | mmio_detct_prov[i];
                assign adrs_cod_or[i] = adrs_cod_or[i-1] | adrs_cod_prov[i];
            end
            if(i==(amount_io+1)) begin: last
                assign CD_IO = CD_IO_or[i];
                assign mmio_detctd = mmio_detct_or[i];
                assign adrs_cod = {adrs_cod_or[i][adrs_size-3:0],Address[1:0]};
            end

        end
    endgenerate
 	
	// *-*-*-*-*-*-*-*-*-*   	FIN DEL DECODIFICADOR DEL MAPEO	   *-*-*-*-*-*-*-*-*-*
	 


    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // *    Para asegurarse que hay no se ejecute la misma instrucción en el procesador      *
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    always @(posedge sys_clk) begin
        if ((RW_reg != RW)||(B_reg != B)||(H_reg != H)||(Enable_reg != Enable)||(Address_reg != Address)||(Data_Write_reg !=Data_Write)) cambio = 1'b1;
        else cambio = 1'b0;
    end

    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // *    Coloca en el registro interno el dato a escribir en memoria o bien el dato que se ha leído de    * 
    // *        memoria, el dato ya se encuentra modificado según corresponda.                               *
    // *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    always @(posedge RDY) begin
        if (RW_reg) begin
            case (adrs_cod[1:0]) 
                2'b00: begin                    
                    casex ({B_reg,H_reg}) 
                        2'b00: Data_out_reg = Data_Write_reg;
                        2'b01: Data_out_reg = {Q[31:16],Data_Write_reg[15:0]};
                        2'b1x: Data_out_reg = {Q[31:8],Data_Write_reg[7:0]};
                    endcase
                end
                2'b01: Data_out_reg = {Q[31:16],Data_Write_reg[7:0],Q[7:0]};
                2'b10: begin
                    casex ({B_reg,H_reg})                        
                        2'b01: Data_out_reg = {Data_Write_reg[15:0],Q[15:0]};
                        2'b1x: Data_out_reg = {Q[31:24],Data_Write_reg[7:0],Q[15:0]};
                        default: Data_out_reg = {Q[31:24],Data_Write_reg[7:0],Q[15:0]};
                    endcase
                end
                2'b11: Data_out_reg = {Data_Write_reg[7:0],Q[23:0]};
                default: Data_out_reg = {Data_size{1'b0}};
            endcase
        end else begin
            case (adrs_cod[1:0]) 
                2'b00: begin
                    casex ({B_reg,H_reg}) 
                        2'b00: Data_out_reg = Q[31:0];
                        2'b01: Data_out_reg = {16'd0,Q[15:0]};
                        2'b1x: Data_out_reg = {24'd0,Q[7:0]};
                    endcase
                end
                2'b01: Data_out_reg = {24'd0,Q[15:8]};
                2'b10: begin
                    casex ({B_reg,H_reg})
                        2'b01: Data_out_reg = {16'd0,Q[31:16]};
                        2'b1x: Data_out_reg = {24'd0,Q[23:16]};
                        default: Data_out_reg = {24'd0,Q[23:16]};
                    endcase
                end
                2'b11: Data_out_reg = {24'd0,Q[31:24]};
                default: Data_out_reg = {Data_size{1'b0}};
            endcase
        end
    end

    always@(*) begin
        Rqs_error_intr_core = (rqs_error_intr | rqs_time_intr);
        if(time_intr) D_Intr_core = d_intr_time;
        else D_Intr_core = d_intr_error;
        if(B) H_cod = 1'b1;
        else H_cod = H;
    end

	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// *	Creación de los estados de la máquina	 *
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    enum logic [2:0] {boot_wait = 3'b110,
                             enable_wait = 3'b101,
                             read_rdy_wait = 3'b010,
                             push_wait = 3'b001,
                             send_error = 3'b100,
                             wait_memory = 3'b111,
                             done_rdy = 3'b011} state, state_ant;
    
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// *	Inicio de la lógica de la FSM	 *
	// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    always @(posedge sys_clk, posedge reset) begin
        if (reset) begin
            watch_dog_reg <= 32'd0;
			{Push_core,Mem_rdy_core, RW_Mem_core, Mem_en_core} <= 4'd0;
            {rqs_time_intr, rqs_error_intr} <= 2'd0;
            {time_io_intr_push, error_io_intr_push} <= 2'd0;
            d_intr_error <= {d_intr_size{1'b0}};
            d_intr_time <= {d_intr_size{1'b0}};
            D_sys_core <= {Data_size{1'b0}};            
            Data_Read_core <= {Data_size{1'b0}};
            A_sys_core <= {adrs_mem_size{1'b0}};
            D_push_core <= {FIFO_size{1'b0}};
            {mtimecmp_a,mtimecmp_b,mtime_a,mtime_b} <= 128'd0;
			{RW_reg, Enable_reg, B_reg, H_reg} <= 4'd0;
            Address_reg <= {Address_size{1'b0}};
            Data_Write_reg <= {Data_size{1'b0}};
			kp_wtng <= 1'b0;
            time_intr <= 1'b0;
            Wt_for_read <= 1'b0;
            csr_limit_error <= 1'b0;
			state <= boot_wait;
            state_ant <= boot_wait;
        end else begin
            if (MTIE) begin       //Contador CSR
                if({mtime_b,mtime_a} >= {mtimecmp_b,mtimecmp_a}) begin
                    {mtime_b,mtime_a} <= 64'd0;
                    time_intr <= 1'b1;
                    d_intr_time <= {8'h00,8'h80,24'd0,32'd0};
                    rqs_time_intr <= 1'b1;
                    time_io_intr_push <= 1'b1;
                end else {mtime_b,mtime_a} <= {mtime_b,mtime_a} + 2'd1;
            end else begin
                {mtime_b,mtime_a} <= 64'd0;
            end
            case (state)
                boot_wait: begin					// Estado de espera en caso inicial, en donde el boot no se ha terminado
                    if (Boot_rdy) state <= enable_wait;
                    else state <= boot_wait;
                end
                enable_wait: begin					//Cuando el boot termina este es el estado de inicio, en donde espera por la señal de enable, dada por el control
                    Mem_rdy_core <= 1'b0;
                    Push_core <= 1'd0;
                    if((CSR_limits[0] < (lim_mapeo[0] + lim_mapeo[1])) && (csr_limit_error == 1'b0)) begin //Primer CSR menor que los límites fijos
                        d_intr_error <= {8'h00,8'h04,24'd0,32'd0};
                        rqs_error_intr <= 1'b1;
                        csr_limit_error <= 1'b1;                //No vuelve a enviar este error
                        error_io_intr_push <= 1'b1;
                        state <= send_error;
                        state_ant <= state;
                    end else begin                      //No hay interrupciones previas para el uso del bloque
                        if (Enable) begin		
                            RW_reg <= RW;				//Guarda el valor del RW para el estado push_wait en donde es necesario para discriminar el estado siguiente
                            Enable_reg <= Enable;
                            B_reg <= B;
                            H_reg <= H;
                            Address_reg <= Address;
                            Data_Write_reg <= Data_Write;	
                            if (cambio) begin                       //Cambio es por si en el siguiente ciclo de reloj, cuando ya un dato se ha procesado, el enable se mantiene activado pero los datos son los mismos, es decir, el procesador no ha cambiado la información. Con solo que cambie alguno de los datos que son relevantes para las acciones (B. H. RW, Address, Data_Write) se va a denotar el cambio y el procesamiento de la información se realiza.
                                if(Authrzd_flg) begin                   //Dirección alineada
                                    if(Address[Address_size-1:2] >= CSR_limits[amount_io]) begin       //Dirección sobre pasa límite máximo
                                        d_intr_error <= {8'h00,8'h01,Address[adrs_size-1:0],32'd0};
                                        rqs_error_intr <= 1'b1;
                                        error_io_intr_push <= 1'b1;
                                        state <= send_error;
                                        state_ant <= send_error;
                                    end else if (Address[Address_size-1:2] >= CSR_limits[0]) begin   //Corresponde al mapeo de un IO
                                        if (RW) begin                   //Escritura
                                            D_push_core <= {CD_IO,{inf_size{1'b0}},3'd0,RW,2'd0,B,H_cod,adrs_cod,Data_Write};
                                        end else begin                  //Lectura
                                            if(mmio_detctd) Wt_for_read <= 1'b1;
                                            D_push_core <= {CD_IO,{inf_size{1'b0}},3'd0,RW,2'd0,B,H_cod,adrs_cod,{Data_size{1'b0}}};
                                        end
                                        if(time_intr) begin
                                            state <= send_error;
                                            state_ant <= push_wait;
                                        end
                                        else state <= push_wait;
                                    end else if((Address[Address_size-1:2] >= lim_mapeo[0]) && (Address[Address_size-1:2] < (lim_mapeo[0]+lim_mapeo[1]))) begin    //Corresponde a un CSR
                                        if(RW) begin
                                            if (adrs_cod[adrs_size-1:2] == 'd0) mtimecmp_a <= Data_Write;
                                            else if (adrs_cod[adrs_size-1:2] == 'd1) mtimecmp_b <= Data_Write;
                                            else if (adrs_cod[adrs_size-1:2] == 'd4) watch_dog_reg <= Data_Write;
                                        end else begin
                                            case (adrs_cod[adrs_size-1:2])
                                                'd0: Data_Read_core <= mtimecmp_a; 
                                                'd1: Data_Read_core <= mtimecmp_b;
                                                'd2: Data_Read_core <= mtime_a;
                                                'd3: Data_Read_core <= mtime_b;
                                                'd4: Data_Read_core <= watch_dog_reg;
                                            endcase
                                        end
                                        Mem_rdy_core <= 1'b1;
                                        if(time_intr) begin
                                            state <= send_error;
                                            state_ant <= enable_wait;
                                        end else state <= enable_wait;
                                    end else if(Address[Address_size-1:2] < lim_mapeo[0]) begin                      //Corresponde a memoria de programa 
                                        A_sys_core <= adrs_cod[adrs_mem_size+1:2];
                                        if(RW) begin
                                            if({B,H} == 2'b00) begin
                                                {RW_Mem_core, Mem_en_core} <= 2'b11;
                                                D_sys_core <= Data_Write;
                                                if(time_intr) begin
                                                    state <= send_error; 
                                                    state_ant <= wait_memory;
                                                end else state <= wait_memory;
                                            end else begin
                                                RW_Mem_core <= 1'b0;
                                                {Mem_en_core,kp_wtng} <= 'hf;
                                                if(time_intr) begin
                                                    state <= send_error; 
                                                    state_ant <= wait_memory;
                                                end else state <= wait_memory;
                                            end
                                        end else begin
                                            RW_Mem_core <= 1'b0;
                                            Mem_en_core <= 1'b1;
                                            if(time_intr) begin
                                                state <= send_error; 
                                                state_ant <= wait_memory;
                                            end else state <= wait_memory;
                                        end
                                    
                                    end else begin                              //No corresponde a ninguna dirección de memoria válida
                                        d_intr_error <= {8'h00,8'h01,Address[adrs_size-1:0],32'd0};
                                        rqs_error_intr <= 1'b1;
                                        state <= send_error;
                                        state_ant <= send_error;
                                    end
                                end else begin                          //Dirección está desalineada
                                    d_intr_error <= {8'h00,8'h02,Address[adrs_size-1:0],32'd0};
                                    rqs_error_intr <= 1'b1;
                                    error_io_intr_push <= 1'b1;
                                    state <= send_error;
                                    state_ant <= send_error;
                                end
                            end else begin 
                                if (time_intr) begin
                                    state_ant <= enable_wait;
                                    state <= send_error;
                                end else state <= enable_wait;
                            end
                        end else begin          //No se encuentran habilitadas las acciones del core
                            if (time_intr) begin
                                state_ant <= enable_wait;
                                state <= send_error;
                            end else state <= enable_wait;      
                        end
                    end 
                     
                end
                read_rdy_wait: begin
                    Push_core <= 1'b0;
                    if(Read_done) begin
                        Data_Read_core <= Data_Read_bus;
                        Wt_for_read <= 1'b0;
                        Mem_rdy_core <= 1'b1;
                        if (time_intr) begin
                            state_ant <= enable_wait;
                            state <= send_error;
                        end else state <= enable_wait;
                    end else if (Watch_dg_flg) begin
                        Wt_for_read <= 1'b0;
                        d_intr_error <= {8'h00,8'h05,24'd0,32'd0};
                        rqs_error_intr <= 1'b1;
                        error_io_intr_push <= 1'b1;
                        state <= send_error;
                        state_ant <= send_error;
                    end else if (time_intr) begin
                        state_ant <= read_rdy_wait;
                        state <= send_error;
                    end else state <= read_rdy_wait;
                end
                push_wait: begin					//Estado de espera de la señal del manejador cuando se quiere realizar un push al bus
                    if (Full) begin
                        if(Wt_for_read) Wt_for_read <= 1'b0;
                        d_intr_error<= {8'h00,8'h03,24'd0,32'd0};
                        rqs_error_intr <= 1'b1;
                        error_io_intr_push <= 1'b1;
                        state <= send_error;
                        state_ant <= send_error;
                    end else begin
                        Push_core <= 1'b1;
                        if (Wt_for_read) begin
                            state <= read_rdy_wait;
                        end else begin
                            Data_Read_core <= {Data_size{1'b0}};
                            state <= enable_wait;
                            Mem_rdy_core <= 1'b1;
                        end
                    end
                end
                send_error: begin		//Estado de espera a que el manejador de errores responda a este bloque
                    if (Go_error_core) begin
                        if(time_intr) begin
                            rqs_time_intr <= 1'b0;
                            time_io_intr_push <= 1'b0;
                            time_intr <= 1'b0;
                            state <= state_ant;
                        end else begin
                            rqs_error_intr <= 1'b0;
                            error_io_intr_push <= 1'b0;
                            state <= enable_wait;
                            Data_Read_core <= {Data_size{1'b0}};
                            if (d_intr_error == {8'h00,8'h04,24'd0,32'd0}) Mem_rdy_core <= 1'b0;
                            else begin
                                Mem_rdy_core <= 1'b1;
                                if (RW_reg == 1'b0) Data_Read_core <= {Data_size{1'b0}};
                            end
            
                        end
                    end else state <= send_error;
                end
                wait_memory: begin
                    if(RDY) begin
                        if(RW_reg) begin
                            if(kp_wtng) begin
                                RW_Mem_core <= 1'b1;
                                D_sys_core <= Data_out_reg;
                                kp_wtng <= 1'b0;
                                state <= done_rdy;
                            end else begin
                                Mem_rdy_core <= 1'b1;
                                Mem_en_core <= 1'b0;
                                state <= done_rdy;
                            end
                        end else begin
                            Data_Read_core <= Data_out_reg;
                            Mem_en_core <= 1'b0;
                            Mem_rdy_core <= 1'b1;
                            state <= done_rdy;
                        end
                    end else begin
                        state <= wait_memory;
                    end
                end
                done_rdy: begin
                    if(RDY==1'b0) begin
                        if(Mem_rdy_core) begin
                            state <= enable_wait;
                            Mem_rdy_core <= 1'b0;
                        end else state <= wait_memory;
                    end else state <= done_rdy;
                end
				default: begin
					state <= enable_wait;	
				end
            endcase
        end
    end 
	
	// *-*-*-*-*-*-*-*-*-*  	FIN DE LA LÓGICA DE LA FSM	    *-*-*-*-*-*-*-*-*-* 

endmodule
