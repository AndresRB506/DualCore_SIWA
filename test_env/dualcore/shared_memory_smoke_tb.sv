// ============================================================
// File: test_env/dualcore/shared_memory_smoke_tb.sv
// Description:
//   Prueba inicial de acceso compartido a memoria para
//   top_CPU_riscv_dual.
//
//   Esta prueba NO ejecuta todavía programas RISC-V reales.
//   En su lugar, fuerza temporalmente las señales internas de
//   solicitud de memoria de core0 y core1 para verificar que:
//
//     - Core 0 pueda solicitar acceso al MBC.
//     - Core 1 pueda solicitar acceso al MBC.
//     - Una solicitud simultánea no bloquee el sistema.
//     - El MBC/árbitro produzca mem_rdy.
//     - La simulación termine sin deadlock.
//
//   Es una prueba funcional presilicio intermedia entre el
//   smoke test y la ejecución real de software dual-core.
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU_dual.sv"

module shared_memory_smoke_tb;

    // ========================================================
    // Clock / Reset
    // ========================================================
    logic clk;
    logic reset;

    localparam CLK_PERIOD_NS = 50; // 20 MHz aproximado

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    // ========================================================
    // Señales de periféricos apagadas para esta prueba
    // ========================================================
    logic        push_spi;
    logic        push_uart;
    logic        pop_spi;
    logic        pop_uart;
    logic [64:0] D_push_spi;
    logic [64:0] D_push_uart;

    wire [64:0] D_pop_spi;
    wire [64:0] D_pop_uart;
    wire        pndng_spi;
    wire        pndng_uart;

    logic        maip;

    wire [7:0]  full_range_level_shifter;
    wire [31:0] IS_Val;
    wire [31:0] IS_Config;
    wire [3:0]  IS_Trigger;
    wire [7:0]  Reg_GPIO_en;
    logic [7:0] Reg_GPIO_int;
    wire [7:0]  Reg_GPIO_out;

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
    // Utilidades
    // ========================================================
    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    task automatic clear_forces;
        begin
            release DUT.core0_mem_address;
            release DUT.core0_mem_d_write;
            release DUT.core0_mem_b;
            release DUT.core0_mem_h;
            release DUT.core0_mem_sign_ext;
            release DUT.core0_mem_enable;
            release DUT.core0_mem_r_w;

            release DUT.core1_mem_address;
            release DUT.core1_mem_d_write;
            release DUT.core1_mem_b;
            release DUT.core1_mem_h;
            release DUT.core1_mem_sign_ext;
            release DUT.core1_mem_enable;
            release DUT.core1_mem_r_w;
        end
    endtask

    task force_core0_request(
        input [24:0] address,
        input [31:0] data,
        input        rw
    );
        begin
            force DUT.core0_mem_address  = address;
            force DUT.core0_mem_d_write  = data;
            force DUT.core0_mem_b        = 1'b0;
            force DUT.core0_mem_h        = 1'b0;
            force DUT.core0_mem_sign_ext = 1'b0;
            force DUT.core0_mem_r_w      = rw;
            force DUT.core0_mem_enable   = 1'b1;
        end
    endtask

    task force_core1_request(
        input [24:0] address,
        input [31:0] data,
        input        rw
    );
        begin
            force DUT.core1_mem_address  = address;
            force DUT.core1_mem_d_write  = data;
            force DUT.core1_mem_b        = 1'b0;
            force DUT.core1_mem_h        = 1'b0;
            force DUT.core1_mem_sign_ext = 1'b0;
            force DUT.core1_mem_r_w      = rw;
            force DUT.core1_mem_enable   = 1'b1;
        end
    endtask

    task automatic wait_for_any_ready(input int timeout_cycles);
        int i;
        bit ready_seen;
        begin
            ready_seen = 1'b0;

            for (i = 0; i < timeout_cycles; i = i + 1) begin
                @(posedge clk);

                if (DUT.core0_mem_rdy || DUT.core1_mem_rdy || DUT.mbc_mem_rdy) begin
                    ready_seen = 1'b1;
                    $display("[%0t] INFO: Ready detectado. core0_rdy=%0b core1_rdy=%0b mbc_rdy=%0b",
                             $time,
                             DUT.core0_mem_rdy,
                             DUT.core1_mem_rdy,
                             DUT.mbc_mem_rdy);
                    i = timeout_cycles;
                end
            end

            if (!ready_seen) begin
                $display("[%0t] ERROR: No se detecto mem_rdy dentro del timeout.", $time);
                $fatal;
            end
        end
    endtask

task automatic print_status(input string label);
    begin
        $display("[%0t] %s", $time, label);
        $display("    core0_enable=%0b core1_enable=%0b mbc_enable=%0b",
                 DUT.core0_mem_enable,
                 DUT.core1_mem_enable,
                 DUT.mbc_enable);

        $display("    core0_rdy=%0b core1_rdy=%0b mbc_rdy=%0b",
                 DUT.core0_mem_rdy,
                 DUT.core1_mem_rdy,
                 DUT.mbc_mem_rdy);

        $display("    mbc_address=0x%0h mbc_d_write=0x%0h",
                 DUT.mbc_address,
                 DUT.mbc_d_write);

        $display("    MBC: state=%0d nxt_state=%0d cond=%0b cond_sel=%0d",
                 DUT.Memory_controller_shared.state,
                 DUT.Memory_controller_shared.nxt_state,
                 DUT.Memory_controller_shared.cond,
                 DUT.Memory_controller_shared.cond_sel);

        $display("    MEM: cen=%0b wen=%0b RDY=%0b clk_mem=%0b a=0x%0h d=0x%0h Q=0x%0h",
                 DUT.cen,
                 DUT.wen,
                 DUT.RDY,
                 DUT.clk_mem,
                 DUT.a,
                 DUT.d,
                 DUT.Q);
    end
endtask

    // ========================================================
    // Estímulos
    // ========================================================
    initial begin
        $display("==============================================");
        $display("  TEC-RISC-V / Siwa Shared Memory Smoke TB");
        $display("==============================================");
        $display("  Objetivo:");
        $display("    - Forzar solicitudes de Core 0 y Core 1");
        $display("    - Verificar paso por arbitro y MBC");
        $display("    - Detectar mem_rdy");
        $display("    - Evitar deadlock");
        $display("==============================================");

        push_spi     = 1'b0;
        push_uart    = 1'b0;
        pop_spi      = 1'b0;
        pop_uart     = 1'b0;
        D_push_spi   = 65'b0;
        D_push_uart  = 65'b0;
        maip         = 1'b0;
        Reg_GPIO_int = 8'b0;

        reset = 1'b1;
        wait_cycles(8);
        reset = 1'b0;

        $display("[%0t] INFO: Reset liberado.", $time);

        wait_cycles(10);

        // ============================================================
	// Inicializacion controlada del MBC original
	// ============================================================
	// No se modifica el hardware MBC.sv.
	// El testbench fuerza temporalmente una condicion valida de fin de boot
	// para aislar la prueba de la ruta Core-Arbiter-MBC-Memoria.

	force DUT.meip = 1'b1;
	force DUT.D_pop_mbc[61:60] = 2'b01;   // Transaccion SPI valida
	force DUT.D_pop_mbc[59:57] = 3'b011;  // Fin de boot

	repeat (20) @(posedge clk);
	print_status("Despues de forzar condicion de fin de boot del MBC");

	release DUT.D_pop_mbc;
	release DUT.meip;
	
	repeat (10) @(posedge clk);
	print_status("Despues de liberar inicializacion controlada");

	// ============================================================
	// Test 1: Core 0 solicita memoria
	// ============================================================

	$display("\nTEST 1: Solicitud forzada desde Core 0");



        force_core0_request(25'h000010, 32'hAAAA_0001, 1'b1);
        print_status("Core 0 request aplicada");

        wait_cycles(2);
        print_status("Despues de 2 ciclos");

        wait_for_any_ready(300);

        clear_forces();
        wait_cycles(10);

        // ====================================================
        // Test 2: Core 1 solicita memoria
        // ====================================================
        $display("\nTEST 2: Solicitud forzada desde Core 1");

        force_core1_request(25'h000020, 32'hBBBB_0002, 1'b1);
        print_status("Core 1 request aplicada");

        wait_cycles(2);
        print_status("Despues de 2 ciclos");

        wait_for_any_ready(80);

        clear_forces();
        wait_cycles(10);

        // ====================================================
        // Test 3: Solicitud simultanea
        // ====================================================
        $display("\nTEST 3: Solicitud simultanea Core 0 + Core 1");

        force_core0_request(25'h000030, 32'hC0C0_0003, 1'b1);
        force_core1_request(25'h000040, 32'hD1D1_0004, 1'b1);
        print_status("Solicitudes simultaneas aplicadas");

        wait_cycles(2);
        print_status("Despues de 2 ciclos");

        wait_for_any_ready(100);

        clear_forces();
        wait_cycles(20);

        $display("\n==============================================");
        $display("  SHARED MEMORY SMOKE TB FINISHED");
        $display("==============================================");

        $finish;
    end

    // ========================================================
    // Dump de ondas
    // ========================================================
    initial begin
        $dumpfile("waves/shared_memory_smoke_tb.vcd");
        $dumpvars(0, shared_memory_smoke_tb);
    end

    // ========================================================
    // Watchdog
    // ========================================================
    initial begin
        wait_cycles(2000);
        $display("[%0t] ERROR: Timeout general de shared_memory_smoke_tb.", $time);
        $fatal;
    end

endmodule
