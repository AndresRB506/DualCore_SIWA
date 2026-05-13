`timescale 1ns / 1ns
`define ADRS_CORE_SZ 32
`define MAX_IO 12
`define DATA_SZ 32
`define INF_SZ 8
`define FIFO_SZ 80
`define ADRS_FROM_FIFO_SZ 8*3
`define AMOUNT_IO 3
`define ADRS_MEM_SZ 11
`define D_INTR_SZ 72
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Create Date: 03/15/2018 06:37:27 PM
// Module Name: tb_core_fsm
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_core_fsm();
    
    //Entradas del módulo de la máquina de estados
    reg reloj, rst;
    reg boot_rdy, authrzd_flg;
    reg go_error_core;
    reg full, cnt_en_csr;
    reg enable, rw, b, h;
    reg [`ADRS_CORE_SZ-1:0] adrs_core;
    reg [`DATA_SZ-1:0] data_write, q;
    reg rdy;
    reg read_done, watch_dog_flg;
    reg [`AMOUNT_IO:0][31:0] csr_limits;
    reg [`DATA_SZ-1:0] csr_io;
    reg [`DATA_SZ-1:0] data_read_bus;
    //Salidas de la máquina de estados
    wire [`FIFO_SZ-1:0] d_push_core;
    wire [`DATA_SZ-1:0] d_sys_core;
    wire [`ADRS_MEM_SZ-1:0] a_sys_core;
    wire rdy_csr, mem_rdy_core;
    wire rqs_error_intr_core;
    wire push_core, io_intr_push_core;
    wire [`D_INTR_SZ-1:0] d_intr_core;
    wire [`DATA_SZ-1:0] data_read_core;
    wire rw_mem_core, mem_en_core;
    wire wt_for_read;
    wire [`INF_SZ-1:0] cd_io;

    always @(*) begin
		casex ({b,h})			//Para el core:{B,H}
			2'b00: begin
            	if (adrs_core[1:0] == 2'b00) authrzd_flg = 1'b1;//Para el core en el if Address[1:0]
                else authrzd_flg = 1'b0;
			end
			2'b01: begin
				if ((adrs_core[1:0] == 2'b00) || (adrs_core[1:0] == 2'b10)) authrzd_flg =1'b1;
				else authrzd_flg = 1'b0;                               
			end
			2'b1x: authrzd_flg = 1'b1;
		endcase
	end

    core_fsm #(.Address_size(`ADRS_CORE_SZ), .max_io(`MAX_IO),
                  .Data_size(`DATA_SZ), .inf_size(`INF_SZ),
                  .d_intr_size(`D_INTR_SZ), .adrs_size(`ADRS_FROM_FIFO_SZ), 
                  .amount_io(`AMOUNT_IO), .adrs_mem_size(`ADRS_MEM_SZ),
                  .FIFO_size(`FIFO_SZ)) maq_est_core(
    .sys_clk(reloj), .reset(rst),
    .Boot_rdy(boot_rdy), .Authrzd_flg(authrzd_flg),
    .Go_error_core(go_error_core), .Full(full),
    .MTIE(cnt_en_csr),
    .Enable(enable), .RW(rw), .B(b), .H(h), .RDY(rdy),
    .Read_done(read_done), .Watch_dg_flg(watch_dog_flg),
    .Data_Write(data_write), .Q(q),    
    .Address(adrs_core), 
    .CSR_limits(csr_limits), .CSR_io(csr_io), .Data_Read_bus(data_read_bus),
    .D_sys_core(d_sys_core), .A_sys_core(a_sys_core),
    .Mem_rdy_core(mem_rdy_core),
    .D_push_core(d_push_core),
    .Rqs_error_intr_core(rqs_error_intr_core), 
    .Push_core(push_core), .IO_Intr_push_core(io_intr_push_core), 
    .D_Intr_core(d_intr_core), .Data_Read_core(data_read_core),
    .RW_Mem_core(rw_mem_core), .Mem_en_core(mem_en_core),
    .Wt_for_read(wt_for_read), .CD_IO(cd_io)
    );

    integer ran_adrs, i;
    reg ciclo;
    initial begin
        {read_done,watch_dog_flg} = 2'd0;
        csr_io = $random($random());
        data_read_bus = $random($realtime);
        {reloj, rst} = 2'd0;
        {full,go_error_core,boot_rdy, cnt_en_csr,rdy} = 4'd0;
        {enable, rw, b, h} = 4'd0;
        adrs_core = 'd1;
        data_write = {`DATA_SZ{1'b0}};
        q = {`DATA_SZ{1'b0}};
        ciclo = 1'b1;
        csr_limits[0] = 'd2050;
        csr_limits[1] = 'd5000;
        csr_limits[2] = 'd6352;
        csr_limits[3] = 'd8352;
        #5 rst = ~rst;
        #5 rst = ~rst;
        $display("-----------------------------------------------------------");
        $display("-------------------Inicio de la simulación-----------------");
        $display("-----------------------------------------------------------");
        #190 boot_rdy = 1'b1;
        enable = 1'b1;
        rw = 1'b1;
        adrs_core = 'd8197;
        data_write = 'd15;
        {b,h} = 2'b10;
        wait(rqs_error_intr_core);
        enable = 0;
        #28 go_error_core = 1;
        wait(rqs_error_intr_core == 1'b0);
        #15 go_error_core = 0;
        $display("Error por el CSR");
        csr_limits[0] = 2300;
        enable = 1'b1;
        rw = 1'b1;
        adrs_core = 'd8192;
        data_write = 'd15;
        {b,h} = 2'b10;
        #85 ;
        wait(mem_rdy_core);
        #15 cnt_en_csr = 1'b1;
        $display("Escritura en un CSR time y habilita a que comience a contar");
        enable = 1'b0;
        #59 ;
        repeat(30) begin
            {rw,b,h} = {$random()};
            full = 1'b0;
            go_error_core = 1'd0;
            ran_adrs = $random($random());
            adrs_core = ran_adrs[15:0];
            data_write = $random($random());
            q = $random({$random()});
            #50 enable = 1'b1;
            $display("Entrada | adrs_core, data_write, rw, b, h, full");
            $display("Data | %h, %h, %d, %d, %d, %d",adrs_core,data_write,rw,b,h,full);
            for(i=0;i<50;i=i+1) begin
                if (push_core || rqs_error_intr_core || mem_en_core || mem_rdy_core) i=70;
                else if(rdy_csr) cnt_en_csr = 1'b0;
                #5 ;
            end
            enable  = 1'b0;
            if (rqs_error_intr_core) begin
                $display("Solicitud de error");
                go_error_core = 1'b1;
            end else if (push_core) begin
                $display("Genera un push");
                $display("D_push: %h",d_push_core);
            end else if(mem_en_core) begin
                $display("Uso de memoria");
                rdy = 1'b1;
                if(rw == 1'b1) begin
                    rdy = 1'b0;
                    #100 rdy = 1'b1;
                    $display("Lista la escritura");
                end
            end else if (mem_rdy_core) begin
                $display("Acceso al CSR");
            end
            #5 go_error_core = 1'd0;
            #55 
            wait(mem_rdy_core || rqs_error_intr_core);
            if (rqs_error_intr_core) begin
                $display("Solicitud de error");
                go_error_core = 1'b1;
            end else $display("Se da un Mem_rdy");
            #65 ;
        end
        $display("Terminó!!!!");
        #42 $finish;
    end

    always
    #25 reloj = ~reloj;
endmodule
