// ============================================================
// File: simultaneous_requests_complete_tb.sv
//
// Validacion de solicitudes simultaneas completas.
//
// Objetivo:
//   - Core 0 y Core 1 solicitan acceso simultaneamente.
//   - Ambas solicitudes permanecen activas hasta ser atendidas.
//   - El arbitro serializa las dos transacciones.
//   - Cada respuesta llega solamente al nucleo correspondiente.
//   - Ninguna solicitud se pierde.
//   - Las dos escrituras se verifican fisicamente en memoria.
//   - Posteriormente se leen ambas posiciones para verificar
//     que los datos fueron almacenados correctamente.
//
// Ruta:
//
// Core 0 ----\
//             > mbc_smp_arbiter -> MBC -> Memoria
// Core 1 ----/
//
// IMPORTANTE:
//   - No ejecuta programas RISC-V reales.
//   - No modifica MBC.sv.
//   - Utiliza inicializacion controlada del MBC.
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU_dual.sv"

module simultaneous_requests_complete_tb;

    // ========================================================
    // Clock / Reset
    // ========================================================
    logic clk;
    logic reset;

    localparam CLK_PERIOD_NS = 50;

    // Polaridad confirmada en MBC.sv
    localparam MEM_WRITE = 1'b0;
    localparam MEM_READ  = 1'b1;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end


    // ========================================================
    // Perifericos
    // ========================================================
    logic        push_spi;
    logic        push_uart;

    logic        pop_spi;
    logic        pop_uart;

    logic [64:0] D_push_spi;
    logic [64:0] D_push_uart;

    wire [64:0] D_pop_spi;
    wire [64:0] D_pop_uart;

    wire pndng_spi;
    wire pndng_uart;

    logic maip;

    wire [7:0]  full_range_level_shifter;

    wire [31:0] IS_Val;
    wire [31:0] IS_Config;
    wire [3:0]  IS_Trigger;

    wire [7:0]  Reg_GPIO_en;
    logic [7:0] Reg_GPIO_int;
    wire [7:0]  Reg_GPIO_out;


    // ========================================================
    // Variables auxiliares
    // ========================================================
    logic [31:0] read_data;

    integer tests_passed;
    integer tests_failed;

    bit trace_enable;


    // ========================================================
    // DUT
    // ========================================================
    top_CPU_riscv_dual DUT (
        .clk(clk),
        .reset(reset),

        .push_spi(push_spi),
        .push_uart(push_uart),

        .pop_spi(pop_spi),
        .pop_uart(pop_uart),

        .D_push_spi(D_push_spi),
        .D_push_uart(D_push_uart),

        .maip(maip),

        .D_pop_spi(D_pop_spi),
        .D_pop_uart(D_pop_uart),

        .pndng_spi(pndng_spi),
        .pndng_uart(pndng_uart),

        .full_range_level_shifter(full_range_level_shifter),

        .IS_Val(IS_Val),
        .IS_Config(IS_Config),
        .IS_Trigger(IS_Trigger),

        .Reg_GPIO_en(Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(Reg_GPIO_out)
    );


    // ========================================================
    // Esperar ciclos
    // ========================================================
    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask


    // ========================================================
    // Bloquear trafico natural
    // ========================================================
    task block_core_requests;
        begin
            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;
        end
    endtask


    // ========================================================
    // Liberar payload Core 0
    // ========================================================
    task release_core0_payload;
        begin
            release DUT.core0_mem_address;
            release DUT.core0_mem_d_write;
            release DUT.core0_mem_b;
            release DUT.core0_mem_h;
            release DUT.core0_mem_sign_ext;
            release DUT.core0_mem_r_w;
        end
    endtask


    // ========================================================
    // Liberar payload Core 1
    // ========================================================
    task release_core1_payload;
        begin
            release DUT.core1_mem_address;
            release DUT.core1_mem_d_write;
            release DUT.core1_mem_b;
            release DUT.core1_mem_h;
            release DUT.core1_mem_sign_ext;
            release DUT.core1_mem_r_w;
        end
    endtask


    // ========================================================
    // Liberar todos los forces
    // ========================================================
    task clear_all_forces;
        begin
            release_core0_payload();
            release_core1_payload();

            release DUT.core0_mem_enable;
            release DUT.core1_mem_enable;
        end
    endtask


    // ========================================================
    // Esperar MBC libre
    //
    // Se exigen dos ciclos consecutivos con mbc_enable=0.
    // ========================================================
    task automatic wait_mbc_idle(input int timeout_cycles);

        int i;
        int idle_cycles;
        bit idle_seen;

        begin

            idle_cycles = 0;
            idle_seen   = 1'b0;

            for (i = 0; i < timeout_cycles; i = i + 1) begin

                @(posedge clk);
                #1;

                if (DUT.mbc_enable !== 1'b1) begin

                    idle_cycles = idle_cycles + 1;

                    if (idle_cycles >= 2) begin
                        idle_seen = 1'b1;
                        i = timeout_cycles;
                    end

                end
                else begin
                    idle_cycles = 0;
                end

            end

            if (!idle_seen) begin

                $fatal(
                    1,
                    "ERROR: Timeout esperando MBC libre."
                );

            end

        end

    endtask


    // ========================================================
    // Estado general
    // ========================================================
    task automatic print_status(input string label);

        begin

            $display("");
            $display("[%0t] %s", $time, label);

            $display(
                "    core0_enable=%0b core1_enable=%0b mbc_enable=%0b",
                DUT.core0_mem_enable,
                DUT.core1_mem_enable,
                DUT.mbc_enable
            );

            $display(
                "    core0_rdy=%0b core1_rdy=%0b mbc_rdy=%0b",
                DUT.core0_mem_rdy,
                DUT.core1_mem_rdy,
                DUT.mbc_mem_rdy
            );

            $display(
                "    mbc_address=0x%0h mbc_d_write=0x%08h mbc_r_w=%0b",
                DUT.mbc_address,
                DUT.mbc_d_write,
                DUT.mbc_r_w
            );

            $display(
                "    MBC: state=%0d nxt_state=%0d",
                DUT.Memory_controller_shared.state,
                DUT.Memory_controller_shared.nxt_state
            );

            $display(
                "    MEM: cen=%0b wen=%0b a=0x%0h d=0x%08h Q=0x%08h",
                DUT.cen,
                DUT.wen,
                DUT.a,
                DUT.d,
                DUT.Q
            );

        end

    endtask


    // ========================================================
    // Solicitudes simultaneas completas
    //
    // Ambas solicitudes se levantan en el mismo flanco.
    //
    // Cuando un nucleo completa:
    //   - se comprueba su respuesta,
    //   - se baja SOLO su enable.
    //
    // La solicitud del otro nucleo permanece activa.
    // ========================================================
    task simultaneous_write_complete(
        input [24:0] addr0,
        input [31:0] data0,
        input [24:0] addr1,
        input [31:0] data1
    );

        int i;

        bit core0_accepted;
        bit core1_accepted;

        bit core0_busy_seen;
        bit core1_busy_seen;

        bit core0_write_seen;
        bit core1_write_seen;

        bit core0_done;
        bit core1_done;

        int completion_count;
        int first_completed_core;
        int second_completed_core;

        begin

            core0_accepted   = 1'b0;
            core1_accepted   = 1'b0;

            core0_busy_seen  = 1'b0;
            core1_busy_seen  = 1'b0;

            core0_write_seen = 1'b0;
            core1_write_seen = 1'b0;

            core0_done       = 1'b0;
            core1_done       = 1'b0;

            completion_count      = 0;
            first_completed_core  = -1;
            second_completed_core = -1;


            // ------------------------------------------------
            // Asegurar sistema libre
            // ------------------------------------------------
            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);


            // ------------------------------------------------
            // Preparar payload Core 0
            // ------------------------------------------------
            force DUT.core0_mem_address  = addr0;
            force DUT.core0_mem_d_write  = data0;
            force DUT.core0_mem_b        = 1'b0;
            force DUT.core0_mem_h        = 1'b0;
            force DUT.core0_mem_sign_ext = 1'b0;
            force DUT.core0_mem_r_w      = MEM_WRITE;


            // ------------------------------------------------
            // Preparar payload Core 1
            // ------------------------------------------------
            force DUT.core1_mem_address  = addr1;
            force DUT.core1_mem_d_write  = data1;
            force DUT.core1_mem_b        = 1'b0;
            force DUT.core1_mem_h        = 1'b0;
            force DUT.core1_mem_sign_ext = 1'b0;
            force DUT.core1_mem_r_w      = MEM_WRITE;


            $display("");
            $display(
                "[%0t] Solicitudes simultaneas preparadas:",
                $time
            );

            $display(
                "    Core 0: addr=0x%0h data=0x%08h",
                addr0,
                data0
            );

            $display(
                "    Core 1: addr=0x%0h data=0x%08h",
                addr1,
                data1
            );


            // ------------------------------------------------
            // Levantar AMBAS solicitudes simultaneamente
            //
            // Se hace en negedge para que ambas esten estables
            // antes del siguiente posedge.
            // ------------------------------------------------
            @(negedge clk);

            force DUT.core0_mem_enable = 1'b1;
            force DUT.core1_mem_enable = 1'b1;

            $display(
                "[%0t] INFO: Core 0 y Core 1 habilitados simultaneamente.",
                $time
            );


            // ------------------------------------------------
            // Esperar que ambas transacciones completen
            // ------------------------------------------------
            for (i = 0; i < 1200; i = i + 1) begin

                @(posedge clk);
                #1;


                // ============================================
                // Core 0 seleccionado por el arbitro
                // ============================================
                if (!core0_done &&
                    (DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === addr0) &&
                    (DUT.mbc_d_write === data0) &&
                    (DUT.mbc_r_w     === MEM_WRITE)) begin

                    if (!core0_accepted) begin

                        core0_accepted = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud Core 0 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                // ============================================
                // Core 1 seleccionado por el arbitro
                // ============================================
                if (!core1_done &&
                    (DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === addr1) &&
                    (DUT.mbc_d_write === data1) &&
                    (DUT.mbc_r_w     === MEM_WRITE)) begin

                    if (!core1_accepted) begin

                        core1_accepted = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud Core 1 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                // ============================================
                // Fase ocupada Core 0
                // ============================================
                if (core0_accepted &&
                    !core0_done &&
                    (DUT.mbc_address === addr0) &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    core0_busy_seen = 1'b1;

                end


                // ============================================
                // Fase ocupada Core 1
                // ============================================
                if (core1_accepted &&
                    !core1_done &&
                    (DUT.mbc_address === addr1) &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    core1_busy_seen = 1'b1;

                end


                // ============================================
                // Escritura fisica Core 0
                // ============================================
                if (!core0_done &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b0) &&
                    (DUT.a   === addr0[10:2]) &&
                    (DUT.d   === data0)) begin

                    if (!core0_write_seen) begin

                        core0_write_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Escritura fisica Core 0 observada: a=0x%0h data=0x%08h",
                            $time,
                            DUT.a,
                            DUT.d
                        );

                    end

                end


                // ============================================
                // Escritura fisica Core 1
                // ============================================
                if (!core1_done &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b0) &&
                    (DUT.a   === addr1[10:2]) &&
                    (DUT.d   === data1)) begin

                    if (!core1_write_seen) begin

                        core1_write_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Escritura fisica Core 1 observada: a=0x%0h data=0x%08h",
                            $time,
                            DUT.a,
                            DUT.d
                        );

                    end

                end


                // ============================================
                // Completion Core 0
                // ============================================
                if (!core0_done &&
                    core0_accepted &&
                    core0_busy_seen &&
                    core0_write_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core0_mem_rdy === 1'b1)) begin

                    // La respuesta NO debe llegar al otro core.
                    if (DUT.core1_mem_rdy === 1'b1) begin

                        $fatal(
                            1,
                            "ERROR: Respuesta Core 0 tambien llego a Core 1."
                        );

                    end

                    core0_done = 1'b1;

                    completion_count = completion_count + 1;

                    if (completion_count == 1)
                        first_completed_core = 0;
                    else
                        second_completed_core = 0;


                    $display(
                        "[%0t] PASS parcial: Core 0 atendido completamente.",
                        $time
                    );


                    // MUY IMPORTANTE:
                    // Solo Core 0 deja de solicitar.
                    // Core 1 permanece activo si aun no termino.
                    force DUT.core0_mem_enable = 1'b0;

                end


                // ============================================
                // Completion Core 1
                // ============================================
                if (!core1_done &&
                    core1_accepted &&
                    core1_busy_seen &&
                    core1_write_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core1_mem_rdy === 1'b1)) begin

                    // La respuesta NO debe llegar al otro core.
                    if (DUT.core0_mem_rdy === 1'b1) begin

                        $fatal(
                            1,
                            "ERROR: Respuesta Core 1 tambien llego a Core 0."
                        );

                    end

                    core1_done = 1'b1;

                    completion_count = completion_count + 1;

                    if (completion_count == 1)
                        first_completed_core = 1;
                    else
                        second_completed_core = 1;


                    $display(
                        "[%0t] PASS parcial: Core 1 atendido completamente.",
                        $time
                    );


                    // Solo Core 1 deja de solicitar.
                    force DUT.core1_mem_enable = 1'b0;

                end


                // ============================================
                // Ambas completaron
                // ============================================
                if (core0_done && core1_done) begin
                    i = 1200;
                end

            end


            // =================================================
            // Evaluacion
            // =================================================

            if (!core0_accepted) begin
                $fatal(
                    1,
                    "ERROR: Solicitud Core 0 nunca fue aceptada."
                );
            end


            if (!core1_accepted) begin
                $fatal(
                    1,
                    "ERROR: Solicitud Core 1 nunca fue aceptada."
                );
            end


            if (!core0_busy_seen) begin
                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada de Core 0."
                );
            end


            if (!core1_busy_seen) begin
                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada de Core 1."
                );
            end


            if (!core0_write_seen) begin
                $fatal(
                    1,
                    "ERROR: No se observo escritura fisica de Core 0."
                );
            end


            if (!core1_write_seen) begin
                $fatal(
                    1,
                    "ERROR: No se observo escritura fisica de Core 1."
                );
            end


            if (!core0_done || !core1_done) begin

                $fatal(
                    1,
                    "ERROR: No completaron ambas solicitudes. core0_done=%0b core1_done=%0b",
                    core0_done,
                    core1_done
                );

            end


            if (completion_count != 2) begin

                $fatal(
                    1,
                    "ERROR: Numero de completions incorrecto: %0d",
                    completion_count
                );

            end


            tests_passed = tests_passed + 1;


            $display("");
            $display("------------------------------------------------------------");
            $display("PASS: Solicitudes simultaneas completadas sin perdida.");
            $display(
                "      Primer nucleo atendido : Core %0d",
                first_completed_core
            );
            $display(
                "      Segundo nucleo atendido: Core %0d",
                second_completed_core
            );
            $display("------------------------------------------------------------");


            // Mantener ambos bloqueados entre pruebas.
            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            release_core0_payload();
            release_core1_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // Lectura dirigida Core 0
    //
    // Usada para verificar que la escritura del otro core
    // realmente quedo almacenada.
    // ========================================================
    task core0_read(
        input  [24:0] address,
        output [31:0] data
    );

        int i;

        bit request_seen;
        bit busy_seen;
        bit memory_read_seen;
        bit completion_seen;

        begin

            request_seen     = 1'b0;
            busy_seen        = 1'b0;
            memory_read_seen = 1'b0;
            completion_seen  = 1'b0;

            data = 32'hXXXX_XXXX;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);


            force DUT.core0_mem_address  = address;
            force DUT.core0_mem_d_write  = 32'b0;
            force DUT.core0_mem_b        = 1'b0;
            force DUT.core0_mem_h        = 1'b0;
            force DUT.core0_mem_sign_ext = 1'b0;
            force DUT.core0_mem_r_w      = MEM_READ;

            force DUT.core1_mem_enable = 1'b0;
            force DUT.core0_mem_enable = 1'b1;


            $display(
                "[%0t] READ Core 0: addr=0x%0h",
                $time,
                address
            );


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;


                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_READ)) begin

                    request_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b1) &&
                    (DUT.a   === address[10:2])) begin

                    memory_read_seen = 1'b1;

                end


                if (request_seen &&
                    busy_seen &&
                    memory_read_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core0_mem_rdy === 1'b1)) begin

                    #1;

                    data = DUT.core0_mem_d_read;

                    completion_seen = 1'b1;

                    i = 600;

                end

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Lectura Core 0 no completo."
                );

            end


            force DUT.core0_mem_enable = 1'b0;

            release_core0_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // Lectura dirigida Core 1
    // ========================================================
    task core1_read(
        input  [24:0] address,
        output [31:0] data
    );

        int i;

        bit request_seen;
        bit busy_seen;
        bit memory_read_seen;
        bit completion_seen;

        begin

            request_seen     = 1'b0;
            busy_seen        = 1'b0;
            memory_read_seen = 1'b0;
            completion_seen  = 1'b0;

            data = 32'hXXXX_XXXX;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);


            force DUT.core1_mem_address  = address;
            force DUT.core1_mem_d_write  = 32'b0;
            force DUT.core1_mem_b        = 1'b0;
            force DUT.core1_mem_h        = 1'b0;
            force DUT.core1_mem_sign_ext = 1'b0;
            force DUT.core1_mem_r_w      = MEM_READ;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b1;


            $display(
                "[%0t] READ Core 1: addr=0x%0h",
                $time,
                address
            );


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;


                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_READ)) begin

                    request_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b1) &&
                    (DUT.a   === address[10:2])) begin

                    memory_read_seen = 1'b1;

                end


                if (request_seen &&
                    busy_seen &&
                    memory_read_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core1_mem_rdy === 1'b1)) begin

                    #1;

                    data = DUT.core1_mem_d_read;

                    completion_seen = 1'b1;

                    i = 600;

                end

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Lectura Core 1 no completo."
                );

            end


            force DUT.core1_mem_enable = 1'b0;

            release_core1_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // Comparacion
    // ========================================================
    task automatic check_data(
        input string test_name,
        input [31:0] expected,
        input [31:0] actual
    );

        begin

            if (actual !== expected) begin

                tests_failed = tests_failed + 1;

                $display("");
                $display("FAIL: %s", test_name);
                $display("      Esperado = 0x%08h", expected);
                $display("      Leido     = 0x%08h", actual);

                $fatal(
                    1,
                    "ERROR: Dato de memoria incorrecto."
                );

            end
            else begin

                $display("");
                $display("PASS: %s", test_name);
                $display("      Esperado = 0x%08h", expected);
                $display("      Leido     = 0x%08h", actual);

            end

        end

    endtask


    // ========================================================
    // Monitor
    // ========================================================
    initial begin

        forever begin

            @(negedge clk);

            if (trace_enable &&
                ((DUT.mbc_enable === 1'b1) ||
                 (DUT.cen        === 1'b0))) begin

                $display(
                    "TRACE: t=%0t c0_en=%0b c1_en=%0b mbc_en=%0b addr=0x%0h data=0x%08h r_w=%0b c0_rdy=%0b c1_rdy=%0b mbc_rdy=%0b a=0x%0h d=0x%08h Q=0x%08h cen=%0b wen=%0b",
                    $time,
                    DUT.core0_mem_enable,
                    DUT.core1_mem_enable,
                    DUT.mbc_enable,
                    DUT.mbc_address,
                    DUT.mbc_d_write,
                    DUT.mbc_r_w,
                    DUT.core0_mem_rdy,
                    DUT.core1_mem_rdy,
                    DUT.mbc_mem_rdy,
                    DUT.a,
                    DUT.d,
                    DUT.Q,
                    DUT.cen,
                    DUT.wen
                );

            end

        end

    end


    // ========================================================
    // Main
    // ========================================================
    initial begin

        tests_passed = 0;
        tests_failed = 0;
        trace_enable = 1'b0;


        $display("============================================================");
        $display(" TEC-RISC-V / Siwa Simultaneous Requests Complete TB");
        $display("============================================================");
        $display(" Objetivo:");
        $display("   - Generar solicitudes simultaneas Core 0 / Core 1");
        $display("   - Mantener ambas hasta ser atendidas");
        $display("   - Verificar dos completions independientes");
        $display("   - Verificar routing de respuestas");
        $display("   - Verificar que ninguna escritura se pierde");
        $display("============================================================");


        // ----------------------------------------------------
        // Inicializacion perifericos
        // ----------------------------------------------------
        push_spi     = 1'b0;
        push_uart    = 1'b0;

        pop_spi      = 1'b0;
        pop_uart     = 1'b0;

        D_push_spi   = 65'b0;
        D_push_uart  = 65'b0;

        maip         = 1'b0;

        Reg_GPIO_int = 8'b0;


        // ----------------------------------------------------
        // Reset
        // ----------------------------------------------------
        reset = 1'b1;

        wait_cycles(8);

        reset = 1'b0;

        $display(
            "[%0t] INFO: Reset liberado.",
            $time
        );

        wait_cycles(10);


        // ----------------------------------------------------
        // Inicializacion controlada del MBC
        // ----------------------------------------------------
        force DUT.meip = 1'b1;

        force DUT.D_pop_mbc[61:60] = 2'b01;
        force DUT.D_pop_mbc[59:57] = 3'b011;

        repeat (20) @(posedge clk);

        release DUT.D_pop_mbc;
        release DUT.meip;

        repeat (10) @(posedge clk);


        // ----------------------------------------------------
        // Aislar trafico natural
        // ----------------------------------------------------
        block_core_requests();

        wait_mbc_idle(400);

        print_status(
            "Sistema aislado y listo para solicitudes simultaneas"
        );

        trace_enable = 1'b1;


        // ====================================================
        // TEST 1
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 1: Solicitudes simultaneas completas");
        $display("============================================================");

        simultaneous_write_complete(
            25'h000050,
            32'hC0C0_0050,

            25'h000060,
            32'hC1C1_0060
        );


        // Verificar los dos datos.
        //
        // Core 1 lee lo escrito por Core 0.
        core1_read(
            25'h000050,
            read_data
        );

        check_data(
            "Dato Core 0 conservado despues de contencion",
            32'hC0C0_0050,
            read_data
        );


        // Core 0 lee lo escrito por Core 1.
        core0_read(
            25'h000060,
            read_data
        );

        check_data(
            "Dato Core 1 conservado despues de contencion",
            32'hC1C1_0060,
            read_data
        );


        // ====================================================
        // TEST 2
        // Segunda ronda para comprobar que el comportamiento
        // puede repetirse.
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 2: Segunda ronda de solicitudes simultaneas");
        $display("============================================================");

        simultaneous_write_complete(
            25'h000070,
            32'h1111_AAAA,

            25'h000080,
            32'h2222_BBBB
        );


        core1_read(
            25'h000070,
            read_data
        );

        check_data(
            "Segunda ronda: dato Core 0",
            32'h1111_AAAA,
            read_data
        );


        core0_read(
            25'h000080,
            read_data
        );

        check_data(
            "Segunda ronda: dato Core 1",
            32'h2222_BBBB,
            read_data
        );


        // ====================================================
        // Resultado
        // ====================================================
        trace_enable = 1'b0;


        $display("");
        $display("============================================================");
        $display(" RESUMEN");
        $display("============================================================");
        $display(
            " Rondas simultaneas PASS : %0d",
            tests_passed
        );
        $display(
            " Errores detectados      : %0d",
            tests_failed
        );
        $display("============================================================");


        if ((tests_passed == 2) &&
            (tests_failed == 0)) begin

            $display("");
            $display("============================================================");
            $display(" SIMULTANEOUS REQUESTS COMPLETE TB PASSED");
            $display("============================================================");

        end
        else begin

            $fatal(
                1,
                "ERROR: Resultado final inesperado."
            );

        end


        clear_all_forces();

        $finish;

    end


    // ========================================================
    // VCD
    // ========================================================
    initial begin

        $dumpfile(
            "waves/simultaneous_requests_complete_tb.vcd"
        );

        $dumpvars(
            0,
            simultaneous_requests_complete_tb
        );

    end


    // ========================================================
    // Watchdog
    // ========================================================
    initial begin

        wait_cycles(15000);

        $fatal(
            1,
            "ERROR: Timeout general de simultaneous_requests_complete_tb."
        );

    end

endmodule
