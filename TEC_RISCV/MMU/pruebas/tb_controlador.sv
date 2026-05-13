`timescale 1ns / 1ns
`define BUS_SZ 80
`define ADRS_DATA_SZ 32
`define INTR_SZ 72
`define COD_SZ 8
`define MEM_ADRS_SZ 11
`define ADRS_BUS_SZ 24
`define TAM_MAX_IO 12
`define CANT_IO 5
`define WATCH_DOG_SZ 32
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Módulo General
// Module Name: tb_controlador
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: CMB, bus_fsm, core_fsm, handler, error_handler, fifo, mem_sgnl_gen, XSPRAMLP_2048X32_M8P 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_controlador();
    //Entradas del sistema
    reg reloj, reset, mtie, meie;
    reg full, pndng;
    reg [`BUS_SZ-1:0] d_pop;
    reg clean;
    reg enable, rw, b, h;
    reg [`ADRS_DATA_SZ-1:0] address;
    reg [`ADRS_DATA_SZ-1:0] data_write;
    reg [`WATCH_DOG_SZ-1:0] watch_dog;
    reg [`ADRS_DATA_SZ-1:0] csr_io;
    reg [`CANT_IO:0][`ADRS_DATA_SZ-1:0] csr_lim;
    //Salidas del módulo
    wire mem_rdy;
    wire [`ADRS_DATA_SZ-1:0] data_read;
    wire pop, push;
    wire [`BUS_SZ-1:0] d_push;
    wire rqs_intr_mem, io_intr_push;
    wire [`INTR_SZ-1:0] io_intr_d_push;

//Entradas de la memoria
    wire C_En, W_En, Sl, Clk_Mem;
    reg [`MEM_ADRS_SZ-1:0] A_Sys;
    reg [`ADRS_DATA_SZ-1:0] D_Sys;

//---------------Salidas internas de los módulos---------------
    //Salidas de la memoria
    wire [`ADRS_DATA_SZ-1:0] Q_m;
    wire Rdy_Mem;
    controlador #(.bus_sz(80), .Adrs_Data_sz(32), 
             .Intr_D_sz(72), .cod_sz(8),
             .mem_adrs_sz(11), .bs_adrs_sz(24), 
             .cant_io(5), .fifo_int_depth(3),
             .watch_dog_sz(32), .fifo_int_sz(72)) inst_controller(
    .CLK_sys(reloj), .Rst(reset),
    .MTIE(mtie), .MEIE(meie), .Full(full), .Pndng(pndng),
    .Clean(clean), .Enable(enable), .RW(rw), .B(b), .H(h),
    .D_pop(d_pop),
    .Address(address),
    .Data_Write(data_write),
    .CSR_io(csr_io),
    .CSR_limits(csr_lim),
    .Mem_rdy(mem_rdy), .Push(push), .IO_Intr_push(io_intr_push),
    .D_push(d_push),
    .Pop(pop), .Rqs_Intr_mem(rqs_intr_mem),
    .Data_read(data_read),
    .IO_Intr_D_push(io_intr_d_push),
    //Para la memoria ponerla externamente
    .q(Q_m),
    .rdy_mem(Rdy_Mem),
    .c_en(C_En), .w_en(W_En), .sl(Sl), .clk_mem(Clk_Mem),
    .a_sys(A_Sys),
    .d_sys(D_Sys)
    );

     XSPRAMLP_2048X32_M8P memoria(.Q(Q_m), .D(D_Sys), .A(A_Sys), .CLK(Clk_Mem), .CEn(C_En), .WEn(W_En), .SL(Sl), .RDY(Rdy_Mem));

    integer contador;
    integer i, ciclo_bus, ciclo_core, ciclo_mmio, ciclo_time;
    reg [`COD_SZ-1:0] cd_io, cd_mod;
    logic swtch;
    reg [31:0] base = 32'd4096;
    reg [31:0] tam_io = 32'd64;
    reg [11:0][`COD_SZ-1:0] codigos = {8'h03,8'h01,8'h00,8'h13,8'h11,8'h10,8'h14,8'h18,8'h20,8'h21,8'h05,8'h22};         //Los últimos dos son códigos erróneos
    reg [4:0][`COD_SZ-1:0] io_cod = {8'h80,8'h00,8'h01,8'h02,8'h03};
    initial begin
        $dumpfile ("controlador.vcd");
        $dumpvars (0,inst_controller);
        ciclo_bus = 0; ciclo_core = 0; ciclo_mmio = 0; ciclo_time = 0; cd_io = 0; cd_mod = 0; swtch = 0;
        reloj = 1'b0; reset = 1'b0; meie = 1'b0;
        full = 1'b0; pndng = 1'b0; d_pop = 'd0;
        clean = 1'b0; enable = 1'b0; rw = 1'b1; 
        b = 1'b0; h = 1'b0; address = 'd0; mtie = 1'b0;
        watch_dog = 'd0; csr_io = 'haa;
        for(i=0;i<=`CANT_IO;i=i+1) begin
            csr_lim[i] = base + i*tam_io;
        end
        data_write = 'd0; contador = 0;
        #10 reset = 1'b1;
        #42 reset = 1'b0;
        #200 ;      //Tiempo necesario para que la memoria comience a funcionar
        address = $random($random());
        data_write = $random({$random()});
        i = 0;
        repeat(2053) begin          //Escritura en memoria del boot, hay unas direcciones que no existen para probar que el sistema funciona.
            Bus_process (
                .adrs({i,2'd0}),
                .data(i),
                .code(codigos[6]),
                .source(io_cod[2]),
                .boot_rdy(0)
            );
            #70 i=i+1;
        end
        $display("Se ha cargado toda la memoria con datos");
        Bus_process (               //Genera el dato para terminar el proceso de booteo
            .adrs({i,2'd0}),
            .data(i),
            .code(codigos[4]),
            .source(io_cod[2]),
            .boot_rdy(0)
        );
        $display("Se termina el boot");
        #70 ;
        contador = 0;
        repeat(2048) begin              //Lectura de todas las direcciones de memoria
            Core_process (
                .dir({contador,2'd0}),
                .dat_w(0),
                .bt(0),. hl(0), .rw_a(0)
            );
            #15 $display("Dirección: %d; Dato: %d",address, data_read);
            #45 contador = contador+1;
        end
        repeat(40) begin            //Manejo de datos provenientes de los IOs
            Bus_process (
                .adrs($random()),
                .data($random($random())),
                .code(codigos[{$random()}%11]),
                .source(io_cod[{$random()}%4]),
                .boot_rdy(1)
            );
            if(meie) $display("Dato ingreso: %h; Dato interrupción: %h",d_pop,io_intr_d_push);
            #70 meie = ~meie;
        end
        swtch=1;
        repeat(90) begin        //Escrituras y lecturas de un byte en memoria
            if(swtch) contador = {$random()}%2047;
            Core_process (
                .dir({contador,swtch,1'b0}),
                .dat_w({$random()}%255),
                .bt(swtch),. hl(0), .rw_a(swtch)
            );
            #70 swtch=~swtch;
        end

        contador = 4100;
        csr_io = 'd0;
        swtch = 1;
        repeat(11) begin             //Escritura y lectura en los PMIOs por parte del core
            Core_process (
                .dir({contador,2'b0}),
                .dat_w({$random()}),
                .bt(0),. hl(0), .rw_a(swtch)
            );
            #70 if(swtch==1'b0) contador = contador+64;
            swtch=~swtch;
        end
        Core_process (
            .dir('h143),
            .dat_w({$random()}),
            .bt(1),. hl(1), .rw_a(0)
        );
        #70 ;
        Core_process (
            .dir('h140),
            .dat_w({$random()}),
            .bt(0),. hl(0), .rw_a(0)
        );
        #70 ;
        Core_process (
            .dir('h143),
            .dat_w({$random()}),
            .bt(1),. hl(1), .rw_a(1)
        );
        #70 ;
        Core_process (
            .dir('h143),
            .dat_w({$random()}),
            .bt(1),. hl(1), .rw_a(0)
        );
        #70 ;
        Core_process (
            .dir('h140),
            .dat_w({$random()}),
            .bt(0),. hl(0), .rw_a(0)
        );
        #70 ;
        meie = 1'b1;
        repeat(4) begin
            read_mmio(
                .direction({'d4300,2'd0}),
                .d_wrt($random()),
                .cant_dat({$random()}%4)
            );
            #15 meie = ~meie;
        end
        #100 ;
        Time_csr(
            .csr_adrs({'d2048,2'd0}),
            .dato({$random()}%450)
        );
        fork
            begin
                repeat(280) begin
                    #70 ;
                    Core_process (
                        .dir({$random()}%18000),
                        .dat_w({$random()}),
                        .bt($random()),. hl({$random()}), .rw_a({$random($random())})
                    );
                end
            end
            begin
                repeat(210) begin
                    Bus_process (
                        .adrs($random()),
                        .data($random($random())),
                        .code(codigos[{$random()}%11]),
                        .source(io_cod[{$random()}%4]),
                        .boot_rdy(1)
                    );
                    #70 meie = $random();
                end
            end
        join
        #50 ;
        repeat(5) begin
            read_mmio(
                .direction({{4096+{$random()}%310},2'd0}),
                .d_wrt($random()),
                .cant_dat({$random()}%4)
            );
            #70 meie = $random();
        end
        fork
            begin
                Time_csr(
                    .csr_adrs({'d2048,2'd0}),
                    .dato({$random()}%250)
                );
            end
            begin
               #400 ;
                fork
                    begin
                        repeat(260) begin
                            #90 ;
                            Core_process (
                                .dir({$random()}%18000),
                                .dat_w({$random()}),
                                .bt($random()),. hl({$random()}), .rw_a({$random($random())})
                            );
                        end
                    end
                    begin
                        repeat(160) begin
                            Bus_process (
                                .adrs($random()),
                                .data($random($random())),
                                .code(codigos[{$random()}%11]),
                                .source(io_cod[{$random()}%4]),
                                .boot_rdy(1)
                            );
                            #90 meie = $random();
                        end
                    end
                join
            end
        join
        #100 ;
        Time_csr(
            .csr_adrs({'d2048,2'd0}),
            .dato({$random()}%450)
        );
        #90 $finish;
    end

    always
    #25 reloj = ~reloj;

    task automatic Bus_process (
        input logic [23:0] adrs,
        input logic [31:0] data,
        input logic [7:0] code,
        input logic [7:0] source,
        input logic boot_rdy
        );
        pndng = 1'b1;
        d_pop = {io_cod[3],source,code,adrs,data};
        if(boot_rdy) begin
            for (ciclo_bus=0; ciclo_bus<500000; ciclo_bus=ciclo_bus+1) begin
                @(negedge reloj);
                wait(pop | rqs_intr_mem);
                if (rqs_intr_mem) begin 
                    #15 clean = 1'b1;
                    wait(io_intr_push);
                    if (io_intr_d_push == {source,code,adrs,data}) begin
                        wait(pop);
                        ciclo_bus = 99999999;
                    end
                end else ciclo_bus=9999999;
            end
            clean = 1'b0;
            
        end else wait(pop);
        #15 pndng = 1'b0;

    endtask : Bus_process

    task automatic read_mmio(
        input logic [31:0] direction,
        input logic [31:0] d_wrt,
        input logic [2:0] cant_dat
        );
        Core_process (
            .dir({2052,2'd0}),
            .dat_w({$random()}),
            .bt($random()),. hl({$random()}), .rw_a({$random($random())})
        );
        csr_io = 'hffffff;
        rw = 1'b0;
        b = 1'b1;
        h = 1'b0;
        address = direction;
        data_write = d_wrt;
        enable = 1'b1;
        for(ciclo_mmio=0; ciclo_mmio<500000; ciclo_mmio=ciclo_mmio+1) begin
            @(negedge reloj);
            wait(push);
            #57 ;
            cd_io = d_push[`BUS_SZ-1:`BUS_SZ-`COD_SZ];
            if(cant_dat>=cd_io) cant_dat=cd_io-1;
            cd_mod = cd_io-cant_dat;
            repeat(6) begin
                if(cd_mod<=cd_io) begin
                        Bus_process (
                        .adrs($random($random())),
                        .data($random($random())),
                        .code(codigos[{$random()}%11]),
                        .source(cd_mod),
                        .boot_rdy(1)
                    );
                    #65 cd_mod = cd_mod+1;
                end
            end
            wait(mem_rdy);
            enable = 1'b0;
            if(meie) begin
                repeat(cant_dat) begin
                    #32 wait(rqs_intr_mem);
                    #15 clean = 1'b1;
                    wait(io_intr_push);
                    #25 clean = 1'b0;
                end
               #17 ciclo_mmio=999999;
            end else begin
                #200 ciclo_mmio=999999;
            end
        end
        csr_io = 'h000000;
        #50 ;
    endtask : read_mmio
 
    task automatic Core_process (
        input logic [31:0] dir,
        input logic [31:0] dat_w,
        input logic bt, hl, rw_a
        );

        rw = rw_a;
        b = bt;
        h = hl;
        address = dir;
        data_write = dat_w;
        enable = 1'b1;
        for(ciclo_core=0; ciclo_core<500000; ciclo_core=ciclo_core+1) begin
            @(negedge reloj);
            wait(mem_rdy | rqs_intr_mem);
            if(rqs_intr_mem) begin
                #15 clean=1'b1;
                wait(io_intr_push);
                if(io_intr_d_push[`INTR_SZ-1:`INTR_SZ-8] == 8'd0) begin
                    wait(mem_rdy);
                    ciclo_core = 999999;
                end
            end else ciclo_core = 999999;
        end
        clean = 1'b0;
        
        #15 enable = 1'b0;
            
    endtask : Core_process

    task automatic Time_csr(
        input logic [31:0] csr_adrs,
        input logic [31:0] dato
        );
        rw = 1'b1;
        b = 1'b1;
        h = 1'b0;
        address = csr_adrs;
        data_write = dato;
        enable = 1'b1;
        @(negedge reloj);
        wait(mem_rdy);
        #10 enable = 1'b0;
        mtie = 1'b1;
        for(ciclo_time=0;ciclo_time<900000;ciclo_time=ciclo_time+1) begin
            @(negedge reloj);
            wait(rqs_intr_mem);
            #15 clean = 1'b1;
            wait(io_intr_push);
            #10 ;
            if(io_intr_d_push[`INTR_SZ-9:`INTR_SZ-16] == 8'h80) begin
                #70 mtie = 1'b0;
                ciclo_time = 9999999;
            end
            #20 clean=1'b0;
        end
        
    endtask : Time_csr

endmodule


