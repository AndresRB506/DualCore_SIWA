// ============================================================
// File: test_env/dualcore/topcore_dual_tb.sv
// Description:
//   Testbench básico para el top externo dual-core.
//
//   Instancia:
//      topcore_tecriscv_dual
//
//   Objetivo:
//     - Verificar que el top externo dual-core compile.
//     - Verificar integración básica con SPI y UART.
//     - Mantener entradas externas en estado seguro.
//     - Generar ondas para revisión presilicio.
//
//   Este TB todavía NO carga programa por SPI.
//   Es una prueba de integración estructural.
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/TOP/topcore_tecriscv_dual.sv"

module topcore_dual_tb;

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
    // Entradas externas
    // ========================================================
    logic MISO;
    logic RX_UART;
    logic maip;

    logic [7:0] Reg_GPIO_int;

    // ========================================================
    // Salidas externas
    // ========================================================
    wire MOSI;
    wire SCLK;
    wire SCS;
    wire TX_UART;

    wire [7:0]  full_range_level_shifter;
    wire [31:0] IS_Val;
    wire [31:0] IS_Config;
    wire [3:0]  IS_Trigger;
    wire [7:0]  Reg_GPIO_en;
    wire [7:0]  Reg_GPIO_out;

    // ========================================================
    // DUT
    // ========================================================
    topcore_tecriscv_dual DUT (
        .clk(clk),
        .reset(reset),

        .MISO(MISO),
        .RX_UART(RX_UART),
        .maip(maip),

        .MOSI(MOSI),
        .SCLK(SCLK),
        .SCS(SCS),
        .TX_UART(TX_UART),

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
        MISO         = 1'b0;
        RX_UART      = 1'b1;   // UART idle normalmente es alto
        maip         = 1'b0;
        Reg_GPIO_int = 8'b0;

        reset = 1'b1;

        repeat (8) @(posedge clk);
        reset = 1'b0;

        $display("[%0t] INFO: Reset liberado en topcore dual-core.", $time);
    end

    // ========================================================
    // Monitoreo básico
    // ========================================================
    initial begin
        $display("==============================================");
        $display("  TEC-RISC-V / Siwa topcore dual-core TB");
        $display("==============================================");
        $display("  Objetivo:");
        $display("    - Compilar topcore_tecriscv_dual");
        $display("    - Integrar top dual + SPI + UART");
        $display("    - Revisar señales externas básicas");
        $display("==============================================");
    end

    // ========================================================
    // Dump de ondas
    // ========================================================
    initial begin
        $dumpfile("waves/topcore_dual_tb.vcd");
        $dumpvars(0, topcore_dual_tb);
    end

    // ========================================================
    // Watchdog simple
    // ========================================================
    initial begin
        int runtime_cycles;

        if (!$value$plusargs("RUNTIME_CYCLES=%d", runtime_cycles)) begin
            runtime_cycles = 1000;
        end

        repeat (runtime_cycles) @(posedge clk);

        $display("[%0t] INFO: Fin de simulacion topcore dual despues de %0d ciclos.",
                 $time, runtime_cycles);

        $display("==============================================");
        $display("  TOPCORE DUAL BASIC TB FINISHED");
        $display("==============================================");

        $finish;
    end

endmodule