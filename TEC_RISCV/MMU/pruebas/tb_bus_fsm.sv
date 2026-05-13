`timescale 1ns / 1ns
`define DATA_SZ 32
`define INF_SZ 8
`define FIFO_SZ 72
`define ADRS_BS_SZ 24
`define ADRS_TO_MEM_SZ 11
`define BUS_SZ 80
`define D_INTR_SZ 64

//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Testbench bus FSM
// Module Name: bus_fsm_tb
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bus_fsm_tb( );
    
    reg CLK_s,RST;
    reg go_error_bs;
    reg pndng;
    reg rdy;
    reg [`DATA_SZ-1:0] q;
    reg [`BUS_SZ-1:0] data_pop;
    reg [`INF_SZ-1:0] cd_io;
    reg authrzd_flg, wt_for_read, meie, full_int, pndng_int;

    wire mem_en_bus, rw_mem_bus;
    wire [`ADRS_TO_MEM_SZ-1:0] a_sys_bus;
    wire [`DATA_SZ-1:0] d_sys_bus, data_read_bus;
    wire [`BUS_SZ-1:0] d_push_bus;
    wire io_intr_push_bs, push_bs, pop_bs;
    wire rqs_error_intr_bs;
    wire [`D_INTR_SZ-1:0] d_intr_bus;
    wire boot_rdy;
    wire [1:0] cod_vrfr_bus, dir_vrfr_bus;
    wire read_done, push_int;
    wire [`FIFO_SZ-1:0] d_push_int;

    always @(*) begin
		casex (cod_vrfr_bus)			//Para el core:{B,H}
			2'b00: begin
            	if (dir_vrfr_bus == 2'b00) authrzd_flg = 1'b1;//Para el core en el if Address[1:0]
                else authrzd_flg = 1'b0;
			end
			2'b01: begin
				if ((dir_vrfr_bus == 2'b00) || (dir_vrfr_bus == 2'b10)) authrzd_flg =1'b1;
				else authrzd_flg = 1'b0;                               
			end
			2'b1x: authrzd_flg = 1'b1;
		endcase
	end
    bus_fsm #(.data_size(`DATA_SZ),.adrs_to_mem_size(`ADRS_TO_MEM_SZ),
        .inf_size(`INF_SZ), .bus_size(`BUS_SZ), .d_intr_size(`D_INTR_SZ), 
        .adrs_bs_size(`ADRS_BS_SZ), .fifo_int_size(`FIFO_SZ)) bus_fsm_inst(
        .sys_clk(CLK_s), .reset(RST), .Go_error_bus(go_error_bs), 
        .Pndng(pndng), .RDY(rdy), .Q(q), .Dat_pop(data_pop), .Authrzd_flg(authrzd_flg),
        .MEIE(meie), .Wt_for_read(wt_for_read),
        .CD_IO(cd_io), .Full_int(full_int), .Pndng_int(pndng_int),
        .Mem_en_bus(mem_en_bus),.RW_Mem_bus(rw_mem_bus),.Rqs_error_intr_bus(rqs_error_intr_bs),
        .IO_Intr_push_bus(io_intr_push_bs), .Push_bus(push_bs), .Pop_bus(pop_bs),
        .A_sys_bus(a_sys_bus), .D_sys_bus(d_sys_bus), .D_Push_bus(d_push_bus),
        .D_Intr_bus(d_intr_bus), .Boot_rdy(boot_rdy),
        .Cod_vrfr_bus(cod_vrfr_bus), .Dir_vrfr_bus(dir_vrfr_bus),
        .Data_Read_bus(data_read_bus), .Read_done(read_done),
        .Push_int(push_int), .D_Push_int(d_push_int)
        );

    reg [11:0][`INF_SZ-1:0] codigos = {8'h03,8'h01,8'h00,8'h13,8'h11,8'h10,8'h14,8'h18,8'h20,8'h21,8'h05,8'h22}; //Los últimos dos son códigos erróneos
    reg [4:0][`INF_SZ-1:0] io_cod = {8'h80,8'h00,8'h01,8'h02,8'h03};
    reg [`ADRS_BS_SZ-1:0] adrs_frm_pckg;
    reg [`DATA_SZ-1:0] data_frm_pckg;
    integer i; 
    initial begin
        {authrzd_flg,go_error_bs,RST,CLK_s,pndng,rdy} = 6'd0;
        meie = 1'b1;
        wt_for_read = 1'b0;
        full_int = 1'b0;
        pndng_int = 1'b0;
        adrs_frm_pckg = 'd0;
        data_frm_pckg = 'd0;
        q = 32'd0;
        data_pop = 80'd0;
        cd_io = 8'd0;
        //for(i=0;i<12;i=i+1) begin
        //    $display("Código %d: %h",i,codigos[i]);
        //end
        #10 RST = ~RST;
        #100 RST = ~RST;
        $display("*-*-*-*-*-*-*-*-*-*-*- Inicio de pruebas -*-*-*-*-*-*-*-*-*-*-*");
        for(i=0;i<5;i=i+1) begin
            repeat(10) begin
                adrs_frm_pckg = {$random($random())}%8800;//Direcciones de memoria hasta 8191
                data_frm_pckg = $random($random());
                data_pop = {io_cod[$urandom%4],io_cod[2+$urandom%2],codigos[8-i],adrs_frm_pckg,data_frm_pckg};
                rdy = 1'b0;
                go_error_bs = 1'd0;
                $display("Nuevo dato");
                repeat(50) begin
                    {pndng, full_int} = $random();
                    @(negedge CLK_s);
                    if(pop_bs || mem_en_bus || boot_rdy) begin
                        #15 ;
                        if (boot_rdy) begin
                            $display("Boot terminado");
                            break;
                        end else if(pop_bs) begin
                            $display("Hubo un error");
                            break;
                        end else begin
                            #65 rdy = 1'b1;
                            $display("Escritura en memoria");
                            wait(pop_bs);
                            $display("Lista la escritura");
                            break;
                        end
                    end
                end
                if(boot_rdy) begin
                    i=50;
                    $display("El boot se ha finalizado");
                    break;
                end
            end
        end

        #50 ;
        if(rqs_error_intr_bs) begin
            go_error_bs = 1'b1;
            wait(pop_bs);
        end
        #50 ;
        repeat(25) begin
            $display("Dato ingresado");
            go_error_bs = 1'd0;
            adrs_frm_pckg = {$random($random())}%8800;//Direcciones de memoria hasta 8191
            data_frm_pckg = $random($random());
            data_pop = {io_cod[$urandom%4],io_cod[{$random({$random()})}%4],codigos[{$random($random())}%11],adrs_frm_pckg,data_frm_pckg};
            repeat(50) begin
                {pndng,full_int} = $random();
                @(negedge CLK_s);
                if(rqs_error_intr_bs) begin
                    #65 ;
                    go_error_bs = 1'b1;
                    #15 ;
                    wait(pop_bs);
                    $display("Operación terminada");
                    break;
                end
            #50 ;
            end
        end
                
        #250 $finish;      
    end
    

    always 
    #25 CLK_s = ~CLK_s;
    
endmodule
