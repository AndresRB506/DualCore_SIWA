// ============================================================
// File: test_env/dualcore/top_dual_minimal_tb.sv
// Description:
//   Testbench mínimo para validar integración presilicio
//   del top interno dual-core.
//
//   Instancia directamente:
//      top_CPU_riscv_dual
//
//   No prueba todavía SPI/UART externos.
//   No carga todavía programas por SPI.
//   Sirve como primer smoke test de compilación/simulación.
//
// Architecture under test:
//
//   top_CPU_riscv_dual
//   ├── tec_riscv_core core0
//   ├── tec_riscv_core core1
//   ├── mbc_smp_arbiter
//   ├── MBC original
//   ├── memoria compartida
//   └── bus interno
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU_dual.sv"

module top_dual_minimal_tb;

    // ========================================================
    // Clock / Reset
    // ========================================================
    logic clk;
    logic reset;

    localparam CLK_PERIOD_NS = 50;  // 20 MHz aprox.

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    // ========================================================
    // Señales SPI/UART internas hacia top_CPU_riscv_dual
    // En esta prueba mínima quedan inactivas.
    // ========================================================
    logic        push_spi;
    logic        push_uart;
    logic        pop_spi;
    logic        pop_uart;

    logic [64:0] D_push_spi;
    logic [64:0] D_push_uart;

    wire  [64:0] D_pop_spi;
    wire  [64:0] D_pop_uart;

    wire         pndng_spi;
    wire         pndng_uart;

    // ========================================================
    // Señales externas/periféricos
    // ========================================================
    logic        maip;

    wire  [7:0]  full_range_level_shifter;
    wire  [31:0] IS_Val;
    wire  [31:0] IS_Config;
    wire  [3:0]  IS_Trigger;

    wire  [7:0]  Reg_GPIO_en;
    logic [7:0]  Reg_GPIO_int;
    wire  [7:0]  Reg_GPIO_out;

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
    // Estímulos iniciales
    // ========================================================
    initial begin
        push_spi     = 1'b0;
        push_uart    = 1'b0;
        pop_spi      = 1'b0;
        pop_uart     = 1'b0;

        D_push_spi   = 65'b0;
        D_push_uart  = 65'b0;

        maip         = 1'b0;
        Reg_GPIO_int = 8'b0;

        reset        = 1'b1;

        repeat (5) @(posedge clk);
        reset = 1'b0;

        $display("[%0t] INFO: Reset liberado. Iniciando simulacion dual-core minima.", $time);
    end

    // ========================================================
    // Monitoreo básico
    // ========================================================
    initial begin
        $display("==============================================");
        $display("  TEC-RISC-V / Siwa Dual-Core Minimal TB");
        $display("==============================================");
        $display("  Objetivo:");
        $display("    - Compilar top dual-core");
        $display("    - Levantar reset");
        $display("    - Verificar que no haya errores fatales");
        $display("==============================================");
    end

    // ========================================================
    // Dump de ondas
    // ========================================================
    initial begin
        $dumpfile("waves/top_dual_minimal_tb.vcd");
        $dumpvars(0, top_dual_minimal_tb);
    end

    // ========================================================
    // Timeout
    // ========================================================
    initial begin
        int runtime_cycles;

        if (!$value$plusargs("RUNTIME_CYCLES=%d", runtime_cycles)) begin
            runtime_cycles = 500;
        end

        repeat (runtime_cycles) @(posedge clk);

        $display("[%0t] INFO: Fin de simulacion minimal dual-core despues de %0d ciclos.",
                 $time, runtime_cycles);

        $finish;
    end

endmodule