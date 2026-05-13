`ifndef FIFOS
   `include "../FIFO_Latches/fifo.sv"
    `define FIFOS
`endif
`include "../MMU/code/core_fsm.sv"
`include "../MMU/code/bus_fsm.sv"
`include "../MMU/code/mem_sgnl_gen.sv"
`include "../MMU/code/error_handler.sv"

module controlador #(parameter bus_sz=80, parameter Adrs_Data_sz=32, 
             parameter Intr_D_sz=72, parameter cod_sz=8,
             parameter mem_adrs_sz=11, parameter bs_adrs_sz = 24, 
             parameter cant_io=5, parameter fifo_int_depth=3,
             parameter watch_dog_sz=32, parameter fifo_int_sz=72)(
    input CLK_sys, Rst,
    input MTIE, MEIE, Full, Pndng,
    input Clean, Enable, RW, B, H,
    input [bus_sz-1:0] D_pop,
    input [Adrs_Data_sz-1:0] Address,
    input [Adrs_Data_sz-1:0] Data_Write,
    input [Adrs_Data_sz-1:0] CSR_io,
    input [cant_io:0][Adrs_Data_sz-1:0] CSR_limits,
    output logic Mem_rdy, Push, IO_Intr_push,
    output logic [bus_sz-1:0] D_push,
    output logic Pop, Rqs_Intr_mem,
    output logic [Adrs_Data_sz-1:0] Data_read,
    output logic [Intr_D_sz-1:0] IO_Intr_D_push,
    //Para la memoria ponerla externamente
    input [Adrs_Data_sz-1:0] q,
    input rdy_mem,
    output logic c_en, w_en, sl, clk_mem,
    output logic [mem_adrs_sz-1:0] a_sys,
    output logic [Adrs_Data_sz-1:0] d_sys

    );

//---------------Entradas internas de los módulos---------------
    //Entradas de la máquina de estados "Core FSM"
    logic boot_rdy;
    logic authrzd_flg_core;
    logic go_error_core;
    logic watch_dg_flg;
    logic read_done;
    logic rdy_core;                           //Proveniente de la memoria
    logic [Adrs_Data_sz-1:0] q_core;          //Proveniente de la memoria
    //Entradas de la máquina de estados "Bus FSM"
    logic go_error_bus;
    logic [bus_sz-1:0] d_pop_selctd;
    reg full_int, pndng_int;
    logic rdy_bus;
    logic [Adrs_Data_sz-1:0] q_bus;          //Proveniente de la memoria
    logic authrzd_flg_bus;
    //Entradas al generador de señales para la memoria
    logic rw_mem, mem_en;
    //Entradas al verificador de alineamiento
    logic [1:0] dir_vrfr, cod_vrfr;
    //Entradas del FIFO interno
    reg push_int;
    reg pop_int;
    reg[fifo_int_sz-1:0] d_push_int;

//---------------Salidas internas de los módulos---------------
    //Salidas de la máquina de estados "Core FSM"
    logic rw_mem_core, mem_en_core;          //Hacia la memoria
    logic [Adrs_Data_sz-1:0] d_sys_core;     //Hacia la memoria
    logic [mem_adrs_sz-1:0] a_sys_core;      //Hacia la memoria
    logic push_core;
    logic [bus_sz-1:0] d_push_core;
    logic rqs_error_intr_core;
    logic [Intr_D_sz-1:0] d_intr_core;
    logic wt_for_read;
    logic [watch_dog_sz-1:0] WD_reg;
    logic [cod_sz-1:0] cd_io;
    //Salidas de la máquina de estados "Bus FSM"
    logic rw_mem_bus, mem_en_bus;            //Hacia la memoria
    logic [Adrs_Data_sz-1:0] d_sys_bus;      //Hacia la memoria
    logic [mem_adrs_sz-1:0] a_sys_bus;       //Hacia la memoria
    logic rqs_error_intr_bus;
    logic push_bus, pop_bus;
    logic [bus_sz-1:0] d_push_bus;
    logic [Intr_D_sz-1:0] d_intr_bus;
    logic [1:0] cod_vrfr_bus, dir_vrfr_bus;
    logic [Adrs_Data_sz-1:0] data_read_bus;
    //Salidas del generador de señales para la memoria
    logic rdy_dvc;
    //Salidas verificador de alineamiento
    logic align;
    //Salidas del FIFO interno
    logic [fifo_int_sz-1:0] d_pop_int;

    core_fsm #(.Address_size(Adrs_Data_sz), .FIFO_size(bus_sz),
                  .Data_size(Adrs_Data_sz), .inf_size(cod_sz),
                  .d_intr_size(Intr_D_sz), .adrs_size(bs_adrs_sz), 
                  .amount_io(cant_io), .adrs_mem_size(mem_adrs_sz)) maq_core(
        .sys_clk(CLK_sys), .reset(Rst), .Boot_rdy(boot_rdy), .Authrzd_flg(authrzd_flg_core),
        .Go_error_core(go_error_core), .Full(Full), .MTIE(MTIE),
        .Enable(Enable), .RW(RW), .B(B), .H(H), .RDY(rdy_core),
        .Read_done(read_done), .Watch_dg_flg(watch_dg_flg),
        .Data_Write(Data_Write), .Q(q_core), .Address(Address), .CSR_limits(CSR_limits),
        .CSR_io(CSR_io), .Data_Read_bus(data_read_bus),
        .Mem_rdy_core(Mem_rdy), .RW_Mem_core(rw_mem_core), 
        .Mem_en_core(mem_en_core), .Rqs_error_intr_core(rqs_error_intr_core), 
        .Push_core(push_core), .D_sys_core(d_sys_core),
        .Data_Read_core(Data_read), .A_sys_core(a_sys_core), .D_push_core(d_push_core),
        .D_Intr_core(d_intr_core), .Wt_for_read(wt_for_read), .watch_dog_reg(WD_reg),.CD_IO(cd_io)
    );

    bus_fsm #(.data_size(Adrs_Data_sz), .adrs_to_mem_size(mem_adrs_sz), 
                 .inf_size(cod_sz), .bus_size(bus_sz), 
                 .d_intr_size(Intr_D_sz), .adrs_bs_size(bs_adrs_sz), 
                 .fifo_int_size(fifo_int_sz)) maq_bus(
        .sys_clk(CLK_sys), .reset(Rst), .Go_error_bus(go_error_bus), 
        .MEIE(MEIE), .Pndng(Pndng), .RDY(rdy_bus), .Q(q_bus), .Dat_pop(d_pop_selctd),
        .Authrzd_flg(authrzd_flg_bus), .Wt_for_read(wt_for_read), .CD_IO(cd_io),
        .Full_int(full_int), .Pndng_int(pndng_int),
        .Mem_en_bus(mem_en_bus), .RW_Mem_bus(rw_mem_bus), 
        .Rqs_error_intr_bus(rqs_error_intr_bus), 
        .Push_bus(push_bus), .Pop_bus(pop_bus), .A_sys_bus(a_sys_bus),
        .D_sys_bus(d_sys_bus), .D_Push_bus(d_push_bus), .D_Intr_bus(d_intr_bus),
        .Boot_rdy(boot_rdy), .Cod_vrfr_bus(cod_vrfr_bus), .Dir_vrfr_bus(dir_vrfr_bus),
        .Data_Read_bus(data_read_bus), .Read_done(read_done), .Push_int(push_int),
        .D_Push_int(d_push_int)
    );

    cnt_watch_dog #(.watch_dg_size(watch_dog_sz)) Watch_DG_Counter(
        .sys_clk(CLK_sys), .reset(Rst), .Read_Wait(wt_for_read),
        .Watch_Dog(WD_reg),
        .Watch_dg_flg(watch_dg_flg)
    );

    always@(*) begin:sel_mem_sgnl
        if(boot_rdy) begin
            rw_mem = rw_mem_core;
            mem_en = mem_en_core;
            rdy_core = rdy_dvc;
            rdy_bus = 1'b0;
            dir_vrfr = Address[1:0];
            cod_vrfr = {B,H};
            q_core = q;
            q_bus = 'd0;
            Push = push_core;
            D_push = d_push_core;
            authrzd_flg_bus = 1'b0;
            authrzd_flg_core = align;
            a_sys = a_sys_core;
            d_sys = d_sys_core;
        end else begin
            rw_mem = rw_mem_bus;
            mem_en = mem_en_bus;
            rdy_bus = rdy_dvc;
            rdy_core = 1'b0;
            dir_vrfr = dir_vrfr_bus;
            cod_vrfr = cod_vrfr_bus;
            q_core = 'd0;
            q_bus = q;
            Push = push_bus;
            D_push = d_push_bus;
            authrzd_flg_bus = align;
            authrzd_flg_core = 1'b0;
            a_sys = a_sys_bus;
            d_sys = d_sys_bus;
        end
    end

    always@(*) begin:int_ext_select
        if(pndng_int && (wt_for_read == 1'b0)) begin
            d_pop_selctd = {8'd0,d_pop_int};
            Pop = 1'b0;
            pop_int = pop_bus;
        end else begin
            d_pop_selctd = D_pop;
            Pop = pop_bus;
            pop_int = 1'b0;
        end
    end

    fifo_flops #(.depth(fifo_int_depth), .bits(fifo_int_sz)) fifo_int(
        .Din(d_push_int),
        .Dout(d_pop_int),
        .push(push_int),
        .pop(pop_int),
        .full(full_int),
        .pndng(pndng_int),
        .rst(Rst),
        .clk(CLK_sys)
    );


    mem_sgnl_gen gen_sgnl(
        .sys_clk(CLK_sys), .reset(Rst),
        .RW_Mem(rw_mem), .Mem_en(mem_en), .RDY(rdy_mem),
        .CEn(c_en), 
        .WEn(w_en), .SL(sl), .CLK(clk_mem), .rdy_to_dvc(rdy_dvc)
    );


    error_handler #(.dat_size(Intr_D_sz)) error_manejador(
        .reset(Rst), .clean(Clean), .sys_clk(CLK_sys),
        .Rqs_bs(rqs_error_intr_bus), .Rqs_cr(rqs_error_intr_core),
        .Data_cr(d_intr_core), .Data_bs(d_intr_bus),
        .Go_cr(go_error_core), .Go_bs(go_error_bus),
        .Sgnl(IO_Intr_push), .Data(IO_Intr_D_push)
    );

    always@(*) begin
        Rqs_Intr_mem = (rqs_error_intr_bus | rqs_error_intr_core);
    end
        
    algnmnt_vrfr verf_algn(
        .Dir(dir_vrfr), .Cod(cod_vrfr),
        .Authrzd_flg(align)
    );

endmodule


// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// *    Bloque que verifica si la dirección se encuentra alineada respecto a cuantos datos se quieren leer   *
// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

module algnmnt_vrfr (
	input [1:0] Dir, Cod,
	output logic Authrzd_flg);

	always @(*) begin
		casex (Cod)			//Para el core:{B,H}
			2'b00: begin
            	if (Dir == 2'b00) Authrzd_flg = 1'b1;//Para el core en el if Address[1:0]
                else Authrzd_flg = 1'b0;
			end
			2'b01: begin
				if ((Dir == 2'b00) || (Dir == 2'b10)) Authrzd_flg =1'b1;
				else Authrzd_flg = 1'b0;                               
			end
			2'b1x: Authrzd_flg = 1'b1;
		endcase
	end
    
endmodule


// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// *    Bloque contador del watch dog    *
// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

module cnt_watch_dog #(parameter watch_dg_size = 32)(
    input sys_clk, reset, Read_Wait,
    input [watch_dg_size-1:0] Watch_Dog,
    output logic Watch_dg_flg);

    logic [watch_dg_size-1:0] base;

    always@(posedge sys_clk, posedge reset) begin
        if(reset) begin
            base <= {watch_dg_size{1'b0}};
            Watch_dg_flg <= 1'b0;
        end else begin
            if(Read_Wait) begin
                if (Watch_dg_flg == 1'b0) base <= base + {{(watch_dg_size-1){1'b0}},1'b1};
                if (base >= Watch_Dog) begin
                    Watch_dg_flg <= 1'b1;
                end
            end else begin
                base <= {watch_dg_size{1'b0}};
                Watch_dg_flg <= 1'b0;
            end
        end
    end
endmodule

