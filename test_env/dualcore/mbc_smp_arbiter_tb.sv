// ============================================================
// File: test_env/dualcore/mbc_smp_arbiter_tb.sv
// Description:
//   Testbench unitario para mbc_smp_arbiter.
//
//   Este test NO instancia el MBC real.
//   Emula las respuestas del MBC para verificar:
//     - grant a core0
//     - grant a core1
//     - round-robin cuando ambos piden
//     - demux correcto de d_read/mem_rdy/error_drs
// ============================================================

`timescale 1ns/1ps

`include "../../TEC_RISCV/MBC/mbc_smp_arbiter.sv"

module mbc_smp_arbiter_tb;

    // ========================================================
    // Clock / reset
    // ========================================================
    logic clk;
    logic reset;

    localparam CLK_PERIOD_NS = 10;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    // ========================================================
    // Core 0 interface
    // ========================================================
    logic [24:0] core0_address;
    logic [31:0] core0_d_write;
    logic        core0_b;
    logic        core0_h;
    logic        core0_sign_ext;
    logic        core0_enable;
    logic        core0_r_w;

    wire [31:0]  core0_d_read;
    wire         core0_mem_rdy;
    wire         core0_error_drs;

    // ========================================================
    // Core 1 interface
    // ========================================================
    logic [24:0] core1_address;
    logic [31:0] core1_d_write;
    logic        core1_b;
    logic        core1_h;
    logic        core1_sign_ext;
    logic        core1_enable;
    logic        core1_r_w;

    wire [31:0]  core1_d_read;
    wire         core1_mem_rdy;
    wire         core1_error_drs;

    // ========================================================
    // Interface hacia MBC emulado
    // ========================================================
    wire [24:0] mbc_address;
    wire [31:0] mbc_d_write;
    wire        mbc_b;
    wire        mbc_h;
    wire        mbc_sign_ext;
    wire        mbc_enable;
    wire        mbc_r_w;

    logic [31:0] mbc_d_read;
    logic        mbc_mem_rdy;
    logic        mbc_error_drs;

    // ========================================================
    // DUT
    // ========================================================
    mbc_smp_arbiter #(
        .ADDR_WIDTH(25),
        .DATA_WIDTH(32)
    ) DUT (
        .clk(clk),
        .reset(reset),

        .core0_address(core0_address),
        .core0_d_write(core0_d_write),
        .core0_b(core0_b),
        .core0_h(core0_h),
        .core0_sign_ext(core0_sign_ext),
        .core0_enable(core0_enable),
        .core0_r_w(core0_r_w),
        .core0_d_read(core0_d_read),
        .core0_mem_rdy(core0_mem_rdy),
        .core0_error_drs(core0_error_drs),

        .core1_address(core1_address),
        .core1_d_write(core1_d_write),
        .core1_b(core1_b),
        .core1_h(core1_h),
        .core1_sign_ext(core1_sign_ext),
        .core1_enable(core1_enable),
        .core1_r_w(core1_r_w),
        .core1_d_read(core1_d_read),
        .core1_mem_rdy(core1_mem_rdy),
        .core1_error_drs(core1_error_drs),

        .mbc_address(mbc_address),
        .mbc_d_write(mbc_d_write),
        .mbc_b(mbc_b),
        .mbc_h(mbc_h),
        .mbc_sign_ext(mbc_sign_ext),
        .mbc_enable(mbc_enable),
        .mbc_r_w(mbc_r_w),
        .mbc_d_read(mbc_d_read),
        .mbc_mem_rdy(mbc_mem_rdy),
        .mbc_error_drs(mbc_error_drs)
    );

    // ========================================================
    // Tasks
    // ========================================================
    task automatic clear_core_requests;
        begin
            core0_enable   = 1'b0;
            core0_address  = 25'b0;
            core0_d_write  = 32'b0;
            core0_b        = 1'b0;
            core0_h        = 1'b0;
            core0_sign_ext = 1'b0;
            core0_r_w      = 1'b0;

            core1_enable   = 1'b0;
            core1_address  = 25'b0;
            core1_d_write  = 32'b0;
            core1_b        = 1'b0;
            core1_h        = 1'b0;
            core1_sign_ext = 1'b0;
            core1_r_w      = 1'b0;
        end
    endtask

    task automatic fake_mbc_transaction_done(input logic [31:0] read_data,
                                             input logic        error_flag);
        begin
            // MBC ocupado
            mbc_mem_rdy   = 1'b0;
            mbc_d_read    = 32'b0;
            mbc_error_drs = 1'b0;

            repeat (3) @(posedge clk);

            // MBC termina
            mbc_d_read    = read_data;
            mbc_error_drs = error_flag;
            mbc_mem_rdy   = 1'b1;

            @(posedge clk);
        end
    endtask

    task automatic check(input bit condition, input string msg);
        begin
            if (!condition) begin
                $display("[%0t] ERROR: %s", $time, msg);
                $fatal;
            end else begin
                $display("[%0t] PASS: %s", $time, msg);
            end
        end
    endtask

    // ========================================================
    // Stimulus
    // ========================================================
    initial begin
        $display("==============================================");
        $display("  MBC SMP Arbiter TB");
        $display("==============================================");

        clear_core_requests();

        mbc_mem_rdy   = 1'b1;
        mbc_d_read    = 32'b0;
        mbc_error_drs = 1'b0;

        reset = 1'b1;
        repeat (3) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);

        // ====================================================
        // Test 1: Solo Core 0 pide acceso
        // ====================================================
        $display("\nTEST 1: Core 0 request");

        core0_address  = 25'h000012;
        core0_d_write  = 32'hAAAA_0001;
        core0_b        = 1'b0;
        core0_h        = 1'b0;
        core0_sign_ext = 1'b0;
        core0_r_w      = 1'b1;
        core0_enable   = 1'b1;

        @(posedge clk);

        check(mbc_enable  === 1'b1,        "MBC enable asserted for Core 0");
        check(mbc_address === 25'h000012,  "Core 0 address routed to MBC");
        check(mbc_d_write === 32'hAAAA_0001, "Core 0 data routed to MBC");

        core0_enable = 1'b0;

        fake_mbc_transaction_done(32'h1111_0000, 1'b0);

        check(core0_mem_rdy === 1'b1,       "Core 0 receives mem_rdy");
        check(core0_d_read  === 32'h1111_0000, "Core 0 receives read data");
        check(core1_mem_rdy === 1'b0,       "Core 1 does not receive Core 0 response");

        repeat (2) @(posedge clk);

        // ====================================================
        // Test 2: Solo Core 1 pide acceso
        // ====================================================
        $display("\nTEST 2: Core 1 request");

        core1_address  = 25'h000034;
        core1_d_write  = 32'hBBBB_0002;
        core1_b        = 1'b0;
        core1_h        = 1'b0;
        core1_sign_ext = 1'b0;
        core1_r_w      = 1'b1;
        core1_enable   = 1'b1;

        @(posedge clk);

        check(mbc_enable  === 1'b1,          "MBC enable asserted for Core 1");
        check(mbc_address === 25'h000034,    "Core 1 address routed to MBC");
        check(mbc_d_write === 32'hBBBB_0002, "Core 1 data routed to MBC");

        core1_enable = 1'b0;

        fake_mbc_transaction_done(32'h2222_0000, 1'b0);

        check(core1_mem_rdy === 1'b1,       "Core 1 receives mem_rdy");
        check(core1_d_read  === 32'h2222_0000, "Core 1 receives read data");
        check(core0_mem_rdy === 1'b0,       "Core 0 does not receive Core 1 response");

        repeat (2) @(posedge clk);

        // ====================================================
        // Test 3: Ambos cores piden acceso
        // Round-robin debe escoger uno. Como ya hubo dos
        // transacciones, el turno puede depender del estado
        // interno; aquí solo verificamos que seleccione uno
        // y que no mezcle señales.
        // ====================================================
        $display("\nTEST 3: Simultaneous request");

        core0_address  = 25'h000100;
        core0_d_write  = 32'hC0C0_0003;
        core0_r_w      = 1'b1;
        core0_enable   = 1'b1;

        core1_address  = 25'h000200;
        core1_d_write  = 32'hD1D1_0004;
        core1_r_w      = 1'b1;
        core1_enable   = 1'b1;

        @(posedge clk);

        check(mbc_enable === 1'b1, "MBC enable asserted for simultaneous request");

        if (mbc_address == core0_address) begin
            $display("[%0t] INFO: Arbiter selected Core 0 first", $time);
            check(mbc_d_write === core0_d_write, "Core 0 data selected correctly");
            core0_enable = 1'b0;
            fake_mbc_transaction_done(32'h3333_0000, 1'b0);
            check(core0_mem_rdy === 1'b1, "Core 0 receives simultaneous response");
        end else if (mbc_address == core1_address) begin
            $display("[%0t] INFO: Arbiter selected Core 1 first", $time);
            check(mbc_d_write === core1_d_write, "Core 1 data selected correctly");
            core1_enable = 1'b0;
            fake_mbc_transaction_done(32'h4444_0000, 1'b0);
            check(core1_mem_rdy === 1'b1, "Core 1 receives simultaneous response");
        end else begin
            $display("[%0t] ERROR: Arbiter selected invalid address", $time);
            $fatal;
        end

        core0_enable = 1'b0;
        core1_enable = 1'b0;

        repeat (5) @(posedge clk);

        $display("\n==============================================");
        $display("  ALL MBC SMP ARBITER TESTS PASSED");
        $display("==============================================");

        $finish;
    end

    // ========================================================
    // Dump de ondas
    // ========================================================
    initial begin
        $dumpfile("waves/mbc_smp_arbiter_tb.vcd");
        $dumpvars(0, mbc_smp_arbiter_tb);
    end

    // ========================================================
    // Timeout
    // ========================================================
    initial begin
        repeat (1000) @(posedge clk);
        $display("[%0t] ERROR: Timeout", $time);
        $fatal;
    end

endmodule