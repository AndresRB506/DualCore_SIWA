// ============================================================
// File: shared_memory_cross_read_tb.sv
//
// Validacion de escritura y lectura cruzada mediante memoria
// compartida.
//
// Ruta evaluada:
//
//   Core 0 / Core 1
//          |
//          v
//   mbc_smp_arbiter
//          |
//          v
//       MBC original
//          |
//          v
//   Memoria compartida
//
// IMPORTANTE:
// - No ejecuta programas RISC-V.
// - Fuerza las interfaces internas de memoria de ambos cores.
// - No modifica MBC.sv.
// - Bloquea temporalmente el trafico natural de los cores.
// - Comprueba escritura fisica antes de aceptar mem_rdy.
// - Compara automaticamente dato escrito contra dato leido.
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU_dual.sv"

module shared_memory_cross_read_tb;

    // ========================================================
    // Clock / Reset
    // ========================================================
    logic clk;
    logic reset;

    localparam CLK_PERIOD_NS = 50;

    // ========================================================
    // Polaridad de r_w confirmada a partir de MBC.sv
    //
    // r_w = 0 -> escritura
    // r_w = 1 -> lectura
    // ========================================================
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
    // Bloquear solicitudes naturales de ambos cores
    //
    // Se mantienen forzadas en cero durante toda la prueba.
    // Cada transaccion habilita temporalmente solo el core
    // que se desea utilizar.
    // ========================================================
    task block_core_requests;
        begin

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

        end
    endtask


    // ========================================================
    // Liberar payload Core 0.
    //
    // mem_enable NO se libera aqui. Permanece forzado en 0
    // entre transacciones para impedir trafico natural.
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
    // Liberar todos los forces al final
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
    // Esperar que el arbitro/MBC quede sin una transaccion
    // activa.
    //
    // Se requieren dos ciclos consecutivos con mbc_enable=0.
    // Esto evita iniciar una prueba mientras termina una
    // transaccion natural anterior.
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

                $display(
                    "[%0t] ERROR: Timeout esperando MBC/arbitro libre.",
                    $time
                );

                $fatal;

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
                "    MBC: state=%0d nxt_state=%0d cond=%0b cond_sel=%0d",
                DUT.Memory_controller_shared.state,
                DUT.Memory_controller_shared.nxt_state,
                DUT.Memory_controller_shared.cond,
                DUT.Memory_controller_shared.cond_sel
            );

            $display(
                "    MEM: cen=%0b wen=%0b RDY=%0b a=0x%0h d=0x%08h Q=0x%08h",
                DUT.cen,
                DUT.wen,
                DUT.RDY,
                DUT.a,
                DUT.d,
                DUT.Q
            );

        end

    endtask


    // ========================================================
    // CORE 0 WRITE
    // ========================================================
    task core0_write(
        input [24:0] address,
        input [31:0] data
    );

        int i;

        bit request_seen;
        bit busy_seen;
        bit memory_write_seen;
        bit completion_seen;

        begin

            request_seen      = 1'b0;
            busy_seen         = 1'b0;
            memory_write_seen = 1'b0;
            completion_seen   = 1'b0;

            // Ambos cores estan bloqueados.
            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);

            $display("");
            $display(
                "[%0t] WRITE Core 0: addr=0x%0h data=0x%08h",
                $time,
                address,
                data
            );

            force DUT.core0_mem_address  = address;
            force DUT.core0_mem_d_write  = data;
            force DUT.core0_mem_b        = 1'b0;
            force DUT.core0_mem_h        = 1'b0;
            force DUT.core0_mem_sign_ext = 1'b0;
            force DUT.core0_mem_r_w      = MEM_WRITE;

            // Solo Core 0 puede solicitar.
            force DUT.core1_mem_enable = 1'b0;
            force DUT.core0_mem_enable = 1'b1;


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;

                // --------------------------------------------
                // Confirmar que ESTA solicitud llego al MBC
                // --------------------------------------------
                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_WRITE)) begin

                    if (!request_seen) begin

                        request_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud WRITE Core 0 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                // --------------------------------------------
                // Confirmar periodo ocupado de esta operacion
                // --------------------------------------------
                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                // --------------------------------------------
                // Confirmar escritura fisica en memoria
                //
                // MBC:
                // cen=0 -> memoria habilitada
                // wen=0 -> escritura
                //
                // max=11 => palabra = address[10:2]
                // --------------------------------------------
                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b0) &&
                    (DUT.a   === address[10:2]) &&
                    (DUT.d   === data)) begin

                    if (!memory_write_seen) begin

                        memory_write_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Escritura fisica observada: a=0x%0h data=0x%08h cen=%0b wen=%0b",
                            $time,
                            DUT.a,
                            DUT.d,
                            DUT.cen,
                            DUT.wen
                        );

                    end

                end


                // --------------------------------------------
                // Solo aceptar completion DESPUES de:
                //
                // 1. ver solicitud correcta,
                // 2. observar MBC ocupado,
                // 3. observar escritura fisica,
                // 4. recibir nueva respuesta.
                // --------------------------------------------
                if (request_seen &&
                    busy_seen &&
                    memory_write_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core0_mem_rdy === 1'b1)) begin

                    completion_seen = 1'b1;

                    $display(
                        "[%0t] INFO: Escritura Core 0 completada correctamente.",
                        $time
                    );

                    i = 600;

                end

            end


            if (!request_seen) begin

                $fatal(
                    1,
                    "ERROR: Solicitud WRITE Core 0 nunca llego al MBC."
                );

            end


            if (!busy_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada para WRITE Core 0."
                );

            end


            if (!memory_write_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo cen=0/wen=0 con direccion y dato esperados para Core 0."
                );

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Timeout esperando finalizacion WRITE Core 0."
                );

            end


            // Desactivar solicitud dirigida.
            force DUT.core0_mem_enable = 1'b0;

            release_core0_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // CORE 1 WRITE
    // ========================================================
    task core1_write(
        input [24:0] address,
        input [31:0] data
    );

        int i;

        bit request_seen;
        bit busy_seen;
        bit memory_write_seen;
        bit completion_seen;

        begin

            request_seen      = 1'b0;
            busy_seen         = 1'b0;
            memory_write_seen = 1'b0;
            completion_seen   = 1'b0;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);

            $display("");
            $display(
                "[%0t] WRITE Core 1: addr=0x%0h data=0x%08h",
                $time,
                address,
                data
            );

            force DUT.core1_mem_address  = address;
            force DUT.core1_mem_d_write  = data;
            force DUT.core1_mem_b        = 1'b0;
            force DUT.core1_mem_h        = 1'b0;
            force DUT.core1_mem_sign_ext = 1'b0;
            force DUT.core1_mem_r_w      = MEM_WRITE;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b1;


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;


                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_WRITE)) begin

                    if (!request_seen) begin

                        request_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud WRITE Core 1 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b0) &&
                    (DUT.a   === address[10:2]) &&
                    (DUT.d   === data)) begin

                    if (!memory_write_seen) begin

                        memory_write_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Escritura fisica observada: a=0x%0h data=0x%08h cen=%0b wen=%0b",
                            $time,
                            DUT.a,
                            DUT.d,
                            DUT.cen,
                            DUT.wen
                        );

                    end

                end


                if (request_seen &&
                    busy_seen &&
                    memory_write_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core1_mem_rdy === 1'b1)) begin

                    completion_seen = 1'b1;

                    $display(
                        "[%0t] INFO: Escritura Core 1 completada correctamente.",
                        $time
                    );

                    i = 600;

                end

            end


            if (!request_seen) begin

                $fatal(
                    1,
                    "ERROR: Solicitud WRITE Core 1 nunca llego al MBC."
                );

            end


            if (!busy_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada para WRITE Core 1."
                );

            end


            if (!memory_write_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo cen=0/wen=0 con direccion y dato esperados para Core 1."
                );

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Timeout esperando finalizacion WRITE Core 1."
                );

            end


            force DUT.core1_mem_enable = 1'b0;

            release_core1_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // CORE 0 READ
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

            request_seen    = 1'b0;
            busy_seen       = 1'b0;
            memory_read_seen = 1'b0;
            completion_seen = 1'b0;

            data = 32'hXXXX_XXXX;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b0;

            wait_mbc_idle(400);

            $display("");
            $display(
                "[%0t] READ Core 0: addr=0x%0h",
                $time,
                address
            );

            force DUT.core0_mem_address  = address;
            force DUT.core0_mem_d_write  = 32'b0;
            force DUT.core0_mem_b        = 1'b0;
            force DUT.core0_mem_h        = 1'b0;
            force DUT.core0_mem_sign_ext = 1'b0;
            force DUT.core0_mem_r_w      = MEM_READ;

            force DUT.core1_mem_enable = 1'b0;
            force DUT.core0_mem_enable = 1'b1;


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;


                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_READ)) begin

                    if (!request_seen) begin

                        request_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud READ Core 0 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                // Lectura fisica:
                // cen=0 y wen=1
                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b1) &&
                    (DUT.a   === address[10:2])) begin

                    if (!memory_read_seen) begin

                        memory_read_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Acceso READ fisico observado: a=0x%0h Q=0x%08h",
                            $time,
                            DUT.a,
                            DUT.Q
                        );

                    end

                end


                if (request_seen &&
                    busy_seen &&
                    memory_read_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core0_mem_rdy === 1'b1)) begin

                    #1;

                    data = DUT.core0_mem_d_read;

                    completion_seen = 1'b1;

                    $display(
                        "[%0t] INFO: Lectura Core 0 completada. data=0x%08h",
                        $time,
                        data
                    );

                    i = 600;

                end

            end


            if (!request_seen) begin

                $fatal(
                    1,
                    "ERROR: Solicitud READ Core 0 nunca llego al MBC."
                );

            end


            if (!busy_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada para READ Core 0."
                );

            end


            if (!memory_read_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo acceso fisico READ para Core 0."
                );

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Timeout esperando finalizacion READ Core 0."
                );

            end


            force DUT.core0_mem_enable = 1'b0;

            release_core0_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // CORE 1 READ
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

            $display("");
            $display(
                "[%0t] READ Core 1: addr=0x%0h",
                $time,
                address
            );

            force DUT.core1_mem_address  = address;
            force DUT.core1_mem_d_write  = 32'b0;
            force DUT.core1_mem_b        = 1'b0;
            force DUT.core1_mem_h        = 1'b0;
            force DUT.core1_mem_sign_ext = 1'b0;
            force DUT.core1_mem_r_w      = MEM_READ;

            force DUT.core0_mem_enable = 1'b0;
            force DUT.core1_mem_enable = 1'b1;


            for (i = 0; i < 600; i = i + 1) begin

                @(posedge clk);
                #1;


                if ((DUT.mbc_enable  === 1'b1) &&
                    (DUT.mbc_address === address) &&
                    (DUT.mbc_r_w     === MEM_READ)) begin

                    if (!request_seen) begin

                        request_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Solicitud READ Core 1 aceptada por arbitro/MBC.",
                            $time
                        );

                    end

                end


                if (request_seen &&
                    (DUT.mbc_mem_rdy === 1'b0)) begin

                    busy_seen = 1'b1;

                end


                if (request_seen &&
                    (DUT.cen === 1'b0) &&
                    (DUT.wen === 1'b1) &&
                    (DUT.a   === address[10:2])) begin

                    if (!memory_read_seen) begin

                        memory_read_seen = 1'b1;

                        $display(
                            "[%0t] INFO: Acceso READ fisico observado: a=0x%0h Q=0x%08h",
                            $time,
                            DUT.a,
                            DUT.Q
                        );

                    end

                end


                if (request_seen &&
                    busy_seen &&
                    memory_read_seen &&
                    (DUT.mbc_mem_rdy   === 1'b1) &&
                    (DUT.core1_mem_rdy === 1'b1)) begin

                    #1;

                    data = DUT.core1_mem_d_read;

                    completion_seen = 1'b1;

                    $display(
                        "[%0t] INFO: Lectura Core 1 completada. data=0x%08h",
                        $time,
                        data
                    );

                    i = 600;

                end

            end


            if (!request_seen) begin

                $fatal(
                    1,
                    "ERROR: Solicitud READ Core 1 nunca llego al MBC."
                );

            end


            if (!busy_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo fase ocupada para READ Core 1."
                );

            end


            if (!memory_read_seen) begin

                $fatal(
                    1,
                    "ERROR: No se observo acceso fisico READ para Core 1."
                );

            end


            if (!completion_seen) begin

                $fatal(
                    1,
                    "ERROR: Timeout esperando finalizacion READ Core 1."
                );

            end


            force DUT.core1_mem_enable = 1'b0;

            release_core1_payload();

            wait_mbc_idle(400);

        end

    endtask


    // ========================================================
    // Comparacion automatica
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
                $display("------------------------------------------------------------");
                $display("FAIL: %s", test_name);
                $display("      Esperado = 0x%08h", expected);
                $display("      Leido     = 0x%08h", actual);
                $display("------------------------------------------------------------");

                $fatal(
                    1,
                    "ERROR: Comparacion de memoria compartida incorrecta."
                );

            end
            else begin

                tests_passed = tests_passed + 1;

                $display("");
                $display("------------------------------------------------------------");
                $display("PASS: %s", test_name);
                $display("      Esperado = 0x%08h", expected);
                $display("      Leido     = 0x%08h", actual);
                $display("------------------------------------------------------------");

            end

        end

    endtask


    // ========================================================
    // Monitor de la interfaz fisica de memoria
    // ========================================================
    initial begin

        forever begin

            @(negedge clk);

            if (trace_enable &&
                ((DUT.mbc_enable === 1'b1) ||
                 (DUT.cen        === 1'b0))) begin

                $display(
                    "TRACE MEM: t=%0t state=%0d mbc_en=%0b addr=0x%0h a=0x%0h d=0x%08h Q=0x%08h cen=%0b wen=%0b mbc_r_w=%0b mbc_rdy=%0b",
                    $time,
                    DUT.Memory_controller_shared.state,
                    DUT.mbc_enable,
                    DUT.mbc_address,
                    DUT.a,
                    DUT.d,
                    DUT.Q,
                    DUT.cen,
                    DUT.wen,
                    DUT.mbc_r_w,
                    DUT.mbc_mem_rdy
                );

            end

        end

    end


    // ========================================================
    // Estimulos
    // ========================================================
    initial begin

        tests_passed = 0;
        tests_failed = 0;
        trace_enable = 1'b0;


        $display("============================================================");
        $display(" TEC-RISC-V / Siwa Shared Memory Cross Read TB");
        $display("============================================================");
        $display(" Objetivo:");
        $display("   - Core 0 escribe y Core 1 lee");
        $display("   - Core 1 escribe y Core 0 lee");
        $display("   - Confirmar acceso fisico a memoria");
        $display("   - Comparar dato escrito contra dato leido");
        $display("============================================================");


        // ====================================================
        // Inicializacion perifericos
        // ====================================================
        push_spi     = 1'b0;
        push_uart    = 1'b0;

        pop_spi      = 1'b0;
        pop_uart     = 1'b0;

        D_push_spi   = 65'b0;
        D_push_uart  = 65'b0;

        maip         = 1'b0;

        Reg_GPIO_int = 8'b0;


        // ====================================================
        // Reset
        // ====================================================
        reset = 1'b1;

        wait_cycles(8);

        reset = 1'b0;

        $display(
            "[%0t] INFO: Reset liberado.",
            $time
        );

        wait_cycles(10);


        // ====================================================
        // Inicializacion controlada del MBC
        // ====================================================
        force DUT.meip = 1'b1;

        force DUT.D_pop_mbc[61:60] = 2'b01;
        force DUT.D_pop_mbc[59:57] = 3'b011;

        repeat (20) @(posedge clk);

        print_status(
            "Despues de forzar condicion de fin de boot del MBC"
        );

        release DUT.D_pop_mbc;
        release DUT.meip;

        repeat (10) @(posedge clk);

        print_status(
            "Despues de liberar inicializacion controlada"
        );


        // ====================================================
        // Aislar por completo trafico natural de los cores
        // antes de iniciar las pruebas dirigidas.
        // ====================================================
        block_core_requests();

        wait_mbc_idle(400);

        print_status(
            "Sistema aislado y listo para pruebas dirigidas"
        );

        trace_enable = 1'b1;


        // ====================================================
        // TEST 1
        // Core 0 WRITE -> Core 1 READ
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 1: Core 0 escribe -> Core 1 lee");
        $display("============================================================");

        core0_write(
            25'h000010,
            32'h1234_ABCD
        );

        core1_read(
            25'h000010,
            read_data
        );

        check_data(
            "Core 0 -> Core 1, addr 0x000010",
            32'h1234_ABCD,
            read_data
        );


        // ====================================================
        // TEST 2
        // Core 1 WRITE -> Core 0 READ
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 2: Core 1 escribe -> Core 0 lee");
        $display("============================================================");

        core1_write(
            25'h000020,
            32'hA5A5_5A5A
        );

        core0_read(
            25'h000020,
            read_data
        );

        check_data(
            "Core 1 -> Core 0, addr 0x000020",
            32'hA5A5_5A5A,
            read_data
        );


        // ====================================================
        // TEST 3
        // Segundo patron Core 0 -> Core 1
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 3: Segundo patron Core 0 -> Core 1");
        $display("============================================================");

        core0_write(
            25'h000030,
            32'hCAFE_BABE
        );

        core1_read(
            25'h000030,
            read_data
        );

        check_data(
            "Core 0 -> Core 1, addr 0x000030",
            32'hCAFE_BABE,
            read_data
        );


        // ====================================================
        // TEST 4
        // Segundo patron Core 1 -> Core 0
        // ====================================================
        $display("");
        $display("============================================================");
        $display("TEST 4: Segundo patron Core 1 -> Core 0");
        $display("============================================================");

        core1_write(
            25'h000040,
            32'hDEAD_BEEF
        );

        core0_read(
            25'h000040,
            read_data
        );

        check_data(
            "Core 1 -> Core 0, addr 0x000040",
            32'hDEAD_BEEF,
            read_data
        );


        // ====================================================
        // Resultado final
        // ====================================================
        trace_enable = 1'b0;

        $display("");
        $display("============================================================");
        $display(" RESUMEN");
        $display("============================================================");
        $display(" Tests PASS : %0d", tests_passed);
        $display(" Tests FAIL : %0d", tests_failed);
        $display("============================================================");


        if ((tests_passed == 4) &&
            (tests_failed == 0)) begin

            $display("");
            $display("============================================================");
            $display(" SHARED MEMORY CROSS READ TB PASSED");
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
    // Dump de ondas
    // ========================================================
    initial begin

        $dumpfile(
            "waves/shared_memory_cross_read_tb.vcd"
        );

        $dumpvars(
            0,
            shared_memory_cross_read_tb
        );

    end


    // ========================================================
    // Watchdog general
    // ========================================================
    initial begin

        wait_cycles(10000);

        $display(
            "[%0t] ERROR: Timeout general de shared_memory_cross_read_tb.",
            $time
        );

        $fatal;

    end

endmodule
