// ============================================================
// File: TEC_RISCV/TOP/TecRiscv_top_CPU_dual.sv
// Description:
//   Top interno dual-core para TEC-RISC-V / Siwa.
//
//   Este módulo instancia dos núcleos TEC-RISC-V homogéneos
//   y los conecta a un único MBC original mediante un árbitro
//   SMP simple.
//
// Architecture:
//
//   tec_riscv_core core0 ┐
//                         ├── mbc_smp_arbiter ── MBC.sv ── memoria compartida
//   tec_riscv_core core1 ┘                         │
//                                                   └── bus interno SPI/UART
//
// Notes:
//   - Usa un solo MBC.
//   - Usa una sola memoria compartida.
//   - Usa un solo bus interno.
//   - Core 0 queda como dueño inicial de I/O, GPIO e interrupciones externas.
//   - Core 1 queda habilitado para ejecución y acceso a memoria compartida.
// ============================================================

`ifndef TEC_RISCV_TOP_CPU_DUAL_SV
`define TEC_RISCV_TOP_CPU_DUAL_SV

`include "../CPU/tec_riscv_core.sv"
`include "../MBC/mbc_smp_arbiter.sv"
`include "../MBC/MBC.sv"
`include "../BUS_Micro/Bus_Micro.sv"
`include "../TOP/coremark_mem_model.sv"

module top_CPU_riscv_dual (
    input  wire        clk,
    input  wire        reset,

    input  wire        push_spi,
    input  wire        push_uart,

    input  wire        pop_spi,
    input  wire        pop_uart,

    input  wire [64:0] D_push_spi,
    input  wire [64:0] D_push_uart,

    input  wire        maip,

    output wire [64:0] D_pop_spi,
    output wire [64:0] D_pop_uart,

    output wire        pndng_spi,
    output wire        pndng_uart,

    output wire [7:0]  full_range_level_shifter,
    output wire [31:0] IS_Val,
    output wire [31:0] IS_Config,
    output wire [3:0]  IS_Trigger,
    output wire [7:0]  Reg_GPIO_en,
    input  wire [7:0]  Reg_GPIO_int,
    output wire [7:0]  Reg_GPIO_out
);

    // ========================================================
    // Parámetro de memoria.
    // En el top monocore original se usa max = 20 para correr
    // coremark con memoria más grande.
    // ========================================================
    parameter max = 20;

    // ========================================================
    // Señales Core 0 hacia árbitro
    // ========================================================
    wire [24:0] core0_mem_address;
    wire [31:0] core0_mem_d_write;
    wire        core0_mem_b;
    wire        core0_mem_h;
    wire        core0_mem_sign_ext;
    wire        core0_mem_enable;
    wire        core0_mem_r_w;

    wire [31:0] core0_mem_d_read;
    wire        core0_mem_rdy;
    wire        core0_mem_error_drs;

    wire        core0_pop_intrpt;

    wire [7:0]  core0_full_range_level_shifter;
    wire [31:0] core0_IS_Val;
    wire [31:0] core0_IS_Config;
    wire [3:0]  core0_IS_Trigger;
    wire [7:0]  core0_Reg_GPIO_en;
    wire [7:0]  core0_Reg_GPIO_out;

    wire [31:0] core0_debug_pc;
    wire [31:0] core0_debug_addrs_reg;
    wire [6:0]  core0_debug_codif_inst;
    wire        core0_debug_mem_enable;
    wire        core0_debug_mem_rdy;

    // ========================================================
    // Señales Core 1 hacia árbitro
    // ========================================================
    wire [24:0] core1_mem_address;
    wire [31:0] core1_mem_d_write;
    wire        core1_mem_b;
    wire        core1_mem_h;
    wire        core1_mem_sign_ext;
    wire        core1_mem_enable;
    wire        core1_mem_r_w;

    wire [31:0] core1_mem_d_read;
    wire        core1_mem_rdy;
    wire        core1_mem_error_drs;

    wire        core1_pop_intrpt;

    wire [7:0]  core1_full_range_level_shifter;
    wire [31:0] core1_IS_Val;
    wire [31:0] core1_IS_Config;
    wire [3:0]  core1_IS_Trigger;
    wire [7:0]  core1_Reg_GPIO_en;
    wire [7:0]  core1_Reg_GPIO_out;

    wire [31:0] core1_debug_pc;
    wire [31:0] core1_debug_addrs_reg;
    wire [6:0]  core1_debug_codif_inst;
    wire        core1_debug_mem_enable;
    wire        core1_debug_mem_rdy;

    // ========================================================
    // Señales del árbitro hacia el MBC original
    // ========================================================
    wire [24:0] mbc_address;
    wire [31:0] mbc_d_write;
    wire        mbc_b;
    wire        mbc_h;
    wire        mbc_sign_ext;
    wire        mbc_enable;
    wire        mbc_r_w;

    wire [31:0] mbc_d_read;
    wire        mbc_mem_rdy;
    wire        mbc_error_drs;

    // ========================================================
    // Señales del MBC hacia memoria compartida
    // ========================================================
    wire [max-3:0] a;
    wire [31:0]    d;
    wire [31:0]    Q;
    wire           RDY;

    wire           clk_mem;
    wire           cen;
    wire           sl;
    wire           wen;

    // ========================================================
    // Señales del MBC hacia bus interno
    // ========================================================
    wire [64:0] D_push_mbc;
    wire        push_mbc;
    wire        pop_mbc;
    wire [64:0] D_pop_mbc;
    wire        meip;

    wire        pop_bus;
    wire        clk_bus;

    // En el monocore original:
    //   pop <= pop_mbc | pop_intrpt;
    //
    // En esta primera versión dual-core, solo Core 0 puede
    // hacer pop de interrupciones/bus. Esto evita que Core 0
    // y Core 1 intenten consumir el mismo paquete del bus.
    assign pop_bus = pop_mbc | core0_pop_intrpt;

    // En el monocore original:
    //   clk_bus = en_bus & clk;
    //
    // En esta primera versión, el bus queda activo con clk.
    // Si más adelante se expone en_bus desde cada core, se puede
    // cambiar a:
    //   assign clk_bus = (core0_en_bus | core1_en_bus) & clk;
    assign clk_bus = clk;

    // ========================================================
    // Core 0
    // Core 0 recibe interrupciones externas y paquetes del bus.
    // También controla las salidas GPIO/IS/level shifter.
    // ========================================================
    tec_riscv_core core0 (
        .clk(clk),
        .reset(reset),

        .maip(maip),
        .meip(meip),
        .D_pop_mbc(D_pop_mbc),

        .pop_intrpt_core(core0_pop_intrpt),

        .mem_address(core0_mem_address),
        .mem_d_write(core0_mem_d_write),
        .mem_b(core0_mem_b),
        .mem_h(core0_mem_h),
        .mem_sign_ext(core0_mem_sign_ext),
        .mem_enable(core0_mem_enable),
        .mem_r_w(core0_mem_r_w),

        .mem_d_read(core0_mem_d_read),
        .mem_rdy(core0_mem_rdy),
        .mem_error_drs(core0_mem_error_drs),

        .full_range_level_shifter(core0_full_range_level_shifter),
        .IS_Val(core0_IS_Val),
        .IS_Config(core0_IS_Config),
        .IS_Trigger(core0_IS_Trigger),
        .Reg_GPIO_en(core0_Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(core0_Reg_GPIO_out),

        .debug_pc(core0_debug_pc),
        .debug_addrs_reg(core0_debug_addrs_reg),
        .debug_codif_inst(core0_debug_codif_inst),
        .debug_mem_enable(core0_debug_mem_enable),
        .debug_mem_rdy(core0_debug_mem_rdy)
    );

    // ========================================================
    // Core 1
    // Core 1 comparte memoria y puede ejecutar código paralelo.
    // En esta primera integración no atiende interrupciones I/O
    // para evitar conflictos de bus/periféricos.
    // ========================================================
    tec_riscv_core core1 (
        .clk(clk),
        .reset(reset),

        .maip(1'b0),
        .meip(1'b0),
        .D_pop_mbc(65'b0),

        .pop_intrpt_core(core1_pop_intrpt),

        .mem_address(core1_mem_address),
        .mem_d_write(core1_mem_d_write),
        .mem_b(core1_mem_b),
        .mem_h(core1_mem_h),
        .mem_sign_ext(core1_mem_sign_ext),
        .mem_enable(core1_mem_enable),
        .mem_r_w(core1_mem_r_w),

        .mem_d_read(core1_mem_d_read),
        .mem_rdy(core1_mem_rdy),
        .mem_error_drs(core1_mem_error_drs),

        .full_range_level_shifter(core1_full_range_level_shifter),
        .IS_Val(core1_IS_Val),
        .IS_Config(core1_IS_Config),
        .IS_Trigger(core1_IS_Trigger),
        .Reg_GPIO_en(core1_Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(core1_Reg_GPIO_out),

        .debug_pc(core1_debug_pc),
        .debug_addrs_reg(core1_debug_addrs_reg),
        .debug_codif_inst(core1_debug_codif_inst),
        .debug_mem_enable(core1_debug_mem_enable),
        .debug_mem_rdy(core1_debug_mem_rdy)
    );

    // ========================================================
    // Árbitro SMP
    // Selecciona qué core puede usar el MBC original.
    // ========================================================
    mbc_smp_arbiter #(
        .ADDR_WIDTH(25),
        .DATA_WIDTH(32)
    ) MBC_SMP_ARB (
        .clk(clk),
        .reset(reset),

        // Core 0
        .core0_address(core0_mem_address),
        .core0_d_write(core0_mem_d_write),
        .core0_b(core0_mem_b),
        .core0_h(core0_mem_h),
        .core0_sign_ext(core0_mem_sign_ext),
        .core0_enable(core0_mem_enable),
        .core0_r_w(core0_mem_r_w),

        .core0_d_read(core0_mem_d_read),
        .core0_mem_rdy(core0_mem_rdy),
        .core0_error_drs(core0_mem_error_drs),

        // Core 1
        .core1_address(core1_mem_address),
        .core1_d_write(core1_mem_d_write),
        .core1_b(core1_mem_b),
        .core1_h(core1_mem_h),
        .core1_sign_ext(core1_mem_sign_ext),
        .core1_enable(core1_mem_enable),
        .core1_r_w(core1_mem_r_w),

        .core1_d_read(core1_mem_d_read),
        .core1_mem_rdy(core1_mem_rdy),
        .core1_error_drs(core1_mem_error_drs),

        // MBC original
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
    // Memoria compartida
    // Misma idea usada por el top monocore original con
    // coremark_mem_model.
    // ========================================================
    coremark_mem_model Memoria_Compartida (
        .Q(Q),
        .D(d),
        .A(a),
        .CLK(clk_mem),
        .CEn(cen),
        .WEn(wen),
        .SL(sl),
        .RDY(RDY)
    );

    // ========================================================
    // MBC original compartido
    // El MBC no se modifica. El árbitro decide qué core
    // conecta sus señales al MBC.
    // ========================================================
    mbc #(
        .max(max)
    ) Memory_controller_shared (
        .clk(clk),
        .reset(reset),

        .address(mbc_address),
        .d_write(mbc_d_write),
        .b(mbc_b),
        .h(mbc_h),
        .sign_ext(mbc_sign_ext),
        .enable(mbc_enable),
        .r_w(mbc_r_w),

        .d_pop(D_pop_mbc[61:0]),
        .pndng(meip),

        .q(Q),

        .d_read(mbc_d_read),
        .a(a),
        .d(d),

        .d_psh(D_push_mbc),
        .psh(push_mbc),
        .mem_rdy(mbc_mem_rdy),
        .pop_mbc(pop_mbc),
        .error_drs(mbc_error_drs),

        .clk_mem(clk_mem),
        .cen(cen),
        .sl(sl),
        .wen(wen)
    );

    // ========================================================
    // Bus interno compartido
    // SPI y UART siguen conectados a un solo bus interno.
    // ========================================================
    tec_riscv_bus Bus (
        .clk(clk_bus),
        .reset(reset),

        .pndng_mbc(meip),
        .pndng_spi(pndng_spi),
        .pndng_uart(pndng_uart),

        .push_mbc(push_mbc),
        .push_spi(push_spi),
        .push_uart(push_uart),

        .pop_mbc(pop_bus),
        .pop_spi(pop_spi),
        .pop_uart(pop_uart),

        .D_pop_mbc(D_pop_mbc),
        .D_pop_spi(D_pop_spi),
        .D_pop_uart(D_pop_uart),

        .D_push_mbc(D_push_mbc),
        .D_push_spi(D_push_spi),
        .D_push_uart(D_push_uart)
    );

    // ========================================================
    // Salidas externas de configuración/periféricos
    // En esta primera versión, Core 0 es dueño de estas salidas.
    // Esto evita conflictos si ambos cores intentaran modificar
    // GPIO o registros de estimulación al mismo tiempo.
    // ========================================================
    assign full_range_level_shifter = core0_full_range_level_shifter;
    assign IS_Val                   = core0_IS_Val;
    assign IS_Config                = core0_IS_Config;
    assign IS_Trigger               = core0_IS_Trigger;
    assign Reg_GPIO_en              = core0_Reg_GPIO_en;
    assign Reg_GPIO_out             = core0_Reg_GPIO_out;

endmodule

`endif