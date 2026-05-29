// ============================================================
// File: TEC_RISCV/CPU/tec_riscv_core.sv
// Description:
//   Núcleo TEC-RISC-V extraído de TecRiscv_top_CPU.sv,
//   sin MBC, sin memoria y sin bus interno.
//
//   Este módulo representa únicamente la lógica privada de
//   un core:
//     - control
//     - decoder
//     - ALU
//     - register file
//     - PC
//     - timer
//     - lógica de writeback / CSR / ALU muxes
//
//   La interfaz hacia memoria/MBC queda expuesta hacia afuera
//   para poder conectar dos cores a un árbitro SMP.
//
// Architecture target:
//
//   tec_riscv_core core0 ┐
//                        ├── mbc_smp_arbiter ── MBC.sv
//   tec_riscv_core core1 ┘
//
// Notes:
//   - No instancia MBC.
//   - No instancia memoria.
//   - No instancia Bus.
//   - Cada instancia tiene su propio PC, register file,
//     control, ALU, timer y CSRs.
// ============================================================

`ifndef TEC_RISCV_CORE_SV
`define TEC_RISCV_CORE_SV

`include "../DECO_INSTR/DECO_INSTR.sv"
`include "../ALU/ALU_2.sv"
`include "../Register_File/Banco_de_registros_latches.v"
`include "../TOP/Status_dual_stub.sv"
`include "../TOP/control.sv"

module tec_riscv_core_timer #(
    parameter bits = 32
)(
    input  wire clock,
    input  wire reset,
    output reg  [bits-1:0] count
);
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= {bits{1'b0}};
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule


module tec_riscv_core (
    input  wire clk,
    input  wire reset,

    // ========================================================
    // Interrupciones / señales externas compartidas
    // ========================================================
    input  wire        maip,          // interrupción analógica
    input  wire        meip,          // interrupción I/O desde bus/MBC
    input  wire [64:0] D_pop_mbc,     // paquete recibido desde bus hacia MBC/core

    // Señal de pop generada por el core al atender interrupción
    output wire        pop_intrpt_core,

    // ========================================================
    // Interfaz hacia MBC / árbitro SMP
    // ========================================================
    output wire [24:0] mem_address,
    output wire [31:0] mem_d_write,
    output wire        mem_b,
    output wire        mem_h,
    output wire        mem_sign_ext,
    output wire        mem_enable,
    output wire        mem_r_w,

    input  wire [31:0] mem_d_read,
    input  wire        mem_rdy,
    input  wire        mem_error_drs,

    // ========================================================
    // Salidas CSR / periféricos desde Register File
    // Nota:
    //   En dual-core, el top superior deberá decidir si usa
    //   las salidas del core0, core1 o un mux.
    // ========================================================
    output wire [7:0]  full_range_level_shifter,
    output wire [31:0] IS_Val,
    output wire [31:0] IS_Config,
    output wire [3:0]  IS_Trigger,
    output wire [7:0]  Reg_GPIO_en,
    input  wire [7:0]  Reg_GPIO_int,
    output wire [7:0]  Reg_GPIO_out,

    // ========================================================
    // Señales opcionales de debug presilicio
    // ========================================================
    output wire [31:0] debug_pc,
    output wire [31:0] debug_addrs_reg,
    output wire [6:0]  debug_codif_inst,
    output wire        debug_mem_enable,
    output wire        debug_mem_rdy
);

    // ========================================================
    // Parámetros CSR usados por la lógica original
    // ========================================================
    parameter mcause_a = 2;
    parameter mcause_b = 3;
    parameter mepc     = 1;
    parameter mtvec    = 5;

    // ========================================================
    // Señales desde decoder
    // ========================================================
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [4:0]  rd;
    wire [31:0] imm_out;
    wire [6:0]  codif_inst_deco;
    wire [3:0]  csr;

    // ========================================================
    // Señales desde ALU
    // ========================================================
    wire        zero_alu;
    wire        overflow;
    wire        negative;
    wire        carry;
    wire [31:0] alu_out;

    // ========================================================
    // Señales desde Register File
    // ========================================================
    wire [31:0] comparation;
    wire        meie;
    wire        mtie;
    wire        maie;
    wire        en_bus;
    wire [31:0] R1;
    wire [31:0] d_write;
    wire [31:0] CSR;

    // ========================================================
    // Señales desde control
    // ========================================================
    wire        r_1_w_0_mbc;
    wire        b_mbc;
    wire        h_mbc;
    wire        enable_mbc;
    wire        pop_intrpt;
    wire        ld_id_instrl_deco;
    wire        ld_addrs;
    wire        ld_pc;
    wire        s_addrs;
    wire [1:0]  s_pc1;
    wire [1:0]  s_pc2;
    wire [2:0]  s_alu;
    wire [3:0]  s_reg_w;
    wire [2:0]  s_csr;
    wire        write_reg_fl;
    wire        csr_write;
    wire        rst_tmr;
    wire [3:0]  cntrl_alu;
    wire        sign_ext;
    wire        inv_r1;

    // ========================================================
    // Timer
    // ========================================================
    wire [31:0] count_timer;
    wire        clk_timer;
    wire        reset_timer;
    reg         mtip;

    // ========================================================
    // Señales internas generadas en el core
    // ========================================================
    reg  [31:0] reg_write_data;
    reg  [3:0]  csr_id;
    reg  [31:0] alu_b;
    wire [31:0] alu_a;
    reg  [31:0] pc_pre;
    reg  [31:0] addrs_reg;
    reg  [31:0] r1_c;
    wire        Cin;
    reg  [31:0] pc;
    wire        int_A;
    wire        int_T;
    wire        int_E;
    wire        ld_pc_clk;

    // ========================================================
    // Control central
    // ========================================================
    control central_control (
        .clk(clk),
        .reset(reset),
        .codif_inst_deco(codif_inst_deco),
        .mem_rdy_mem_cntrlr(mem_rdy),
        .error_drs_mem_cntrlr(mem_error_drs),
        .Zero_alu(zero_alu),
        .int_A(int_A),
        .int_T(int_T),
        .int_E(int_E),
        .r_1_w_0_mbc(r_1_w_0_mbc),
        .b_mbc(b_mbc),
        .h_mbc(h_mbc),
        .enable_mbc(enable_mbc),
        .pop_intrpt(pop_intrpt),
        .ld_id_instrl_deco(ld_id_instrl_deco),
        .ld_addrs(ld_addrs),
        .ld_pc(ld_pc),
        .s_addrs(s_addrs),
        .s_pc1(s_pc1),
        .s_pc2(s_pc2),
        .s_alu(s_alu),
        .sign_ext(sign_ext),
        .s_reg_w(s_reg_w),
        .s_csr(s_csr),
        .write_reg_fl(write_reg_fl),
        .csr_write(csr_write),
        .rst_tmr(rst_tmr),
        .cntrl_alu(cntrl_alu),
        .inv_r1(inv_r1)
    );

    // ========================================================
    // Decoder
    // ========================================================
    DECO_INSTR Deco (
        .reset(reset),
        .ld_id(ld_id_instrl_deco),
        .inst(mem_d_read),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm_out),
        .codif(codif_inst_deco),
        .csr(csr)
    );

    // ========================================================
    // ALU
    // ========================================================
    ALU_2 #(
        .bits_size(32),
        .cntrl_size(4)
    ) Alu (
        .A(alu_a),
        .B(alu_b),
        .Alu_Cntrl(cntrl_alu),
        .Cin(Cin),
        .Zero(zero_alu),
        .oVerflow(overflow),
        .Negative(negative),
        .Carry(carry),
        .OUT(alu_out)
    );

    // ========================================================
    // Register File
    // ========================================================
    Banco_registros_latches Reg_file (
        .csr_id(csr_id),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write(write_reg_fl),
        .csr_write(csr_write),
        .reg_write_data(reg_write_data),
        .clk(clk),
        .rst(reset),
        .mip_IO(meip),
        .mip_time(mtip),
        .timer(count_timer),
        .comparation(comparation),
        .mie_IO(meie),
        .Mie_analogic(maie),
        .mip_analogic(maip),
        .mie_time(mtie),
        .R1(R1),
        .R2(d_write),
        .CSR(CSR),
        .full_range_level_shifter(full_range_level_shifter),
        .IS_Val(IS_Val),
        .IS_Config(IS_Config),
        .IS_Trigger(IS_Trigger),
        .Reg_GPIO_en(Reg_GPIO_en),
        .Reg_GPIO_int(Reg_GPIO_int),
        .Reg_GPIO_out(Reg_GPIO_out),
        .en_bus(en_bus)
    );

    // ========================================================
    // Timer privado del core
    // ========================================================
    tec_riscv_core_timer temporizador_core (
        .clock(clk_timer),
        .reset(reset_timer),
        .count(count_timer)
    );

    always @(posedge clk or posedge reset_timer) begin
        if (reset_timer) begin
            mtip <= 1'b0;
        end else begin
            mtip <= (count_timer >= comparation) ? 1'b1 : 1'b0;
        end
    end

    assign clk_timer   = mtie & clk & ~mtip;
    assign reset_timer = reset | rst_tmr;

    // ========================================================
    // Interfaz hacia MBC / árbitro
    // ========================================================
    assign mem_address  = addrs_reg[24:0];
    assign mem_d_write  = d_write;
    assign mem_b        = b_mbc;
    assign mem_h        = h_mbc;
    assign mem_sign_ext = sign_ext;
    assign mem_enable   = enable_mbc;
    assign mem_r_w      = r_1_w_0_mbc;

    assign pop_intrpt_core = pop_intrpt;

    // ========================================================
    // Writeback mux
    // ========================================================
    always @(*) begin
        case (s_reg_w) // synopsys infer_mux
            0: begin
                reg_write_data = {{31{1'b0}}, zero_alu};
            end

            1: begin
                reg_write_data = imm_out;
            end

            2: begin
                reg_write_data = alu_out;
            end

            3: begin
                reg_write_data = R1;
            end

            4: begin
                reg_write_data = {
                    {1'b0},
                    D_pop_mbc[56:32],
                    D_pop_mbc[59:57],
                    {1'b0},
                    D_pop_mbc[61:60]
                };
            end

            5: begin
                reg_write_data = D_pop_mbc[31:0];
            end

            6: begin
                reg_write_data = mem_d_read;
            end

            7: begin
                reg_write_data = CSR;
            end

            8: begin
                reg_write_data = pc;
            end

            9: begin
                reg_write_data = {
                    imm_out[11:0],
                    rs2,
                    rs1,
                    codif_inst_deco,
                    {3'b000}
                };
            end

            10: begin
                reg_write_data = {{27{1'b0}}, rd};
            end

            11: begin
                reg_write_data = {{29{1'b0}}, {3'b100}};
            end

            12: begin
                reg_write_data = {{29{1'b0}}, {3'b011}};
            end

            13: begin
                reg_write_data = {{29{1'b0}}, {3'b101}};
            end

            default: begin
                reg_write_data = 32'b0;
            end
        endcase
    end

    // ========================================================
    // CSR mux
    // ========================================================
    always @(*) begin
        case (s_csr) // synopsys infer_mux
            0: begin
                csr_id = csr;
            end

            1: begin
                csr_id = mcause_a;
            end

            2: begin
                csr_id = mcause_b;
            end

            3: begin
                csr_id = mepc;
            end

            4: begin
                csr_id = mtvec;
            end

            default: begin
                csr_id = csr;
            end
        endcase
    end

    // ========================================================
    // ALU B mux
    // ========================================================
    always @(*) begin
        case (s_alu) // synopsys infer_mux
            0: begin
                alu_b = d_write;
            end

            1: begin
                alu_b = 32'd4;
            end

            2: begin
                alu_b = imm_out;
            end

            3: begin
                alu_b = 32'd1;
            end

            4: begin
                alu_b = CSR;
            end

            default: begin
                alu_b = 32'b0;
            end
        endcase
    end

    // ========================================================
    // Address register
    // Mismo comportamiento lógico que en el top original:
    //   addrs_reg <= pc    si s_addrs = 1
    //   addrs_reg <= alu_out si s_addrs = 0
    // ========================================================
    always @(posedge ld_addrs or posedge reset) begin
        if (reset) begin
            addrs_reg <= 32'b0;
        end else begin
            addrs_reg <= (s_addrs) ? pc : alu_out;
        end
    end

    // ========================================================
    // Interrupciones
    // ========================================================
    assign Cin   = 1'b0;
    assign int_A = maie & maip;
    assign int_T = mtie & mtip;
    assign int_E = meie & meip;

    // ========================================================
    // PC/ALU A path
    // ========================================================
    always @(*) begin
        case (s_pc2) // synopsys infer_mux
            0: begin
                r1_c = pc;
            end

            1: begin
                r1_c = R1;
            end

            2: begin
                r1_c = imm_out;
            end

            default: begin
                r1_c = 32'b0;
            end
        endcase
    end

    assign alu_a = (inv_r1) ? ~r1_c : r1_c;

    always @(*) begin
        case (s_pc1) // synopsys infer_mux
            1: begin
                pc_pre = imm_out;
            end

            0: begin
                pc_pre = alu_out;
            end

            2: begin
                pc_pre = CSR;
            end

            default: begin
                pc_pre = alu_out;
            end
        endcase
    end
    // ========================================================
    // PC register
    // El diseño original implementa el PC de 32 bits como
    // 32 flip-flops individuales dff_async_rst, uno por cada
    // bit de pc[31:0].
    //
    // Para mantener la misma estructura del monocore sin
    // escribir manualmente las 32 instancias, se usa un bloque
    // generate. Cada instancia de tec_riscv_core tendrá su
    // propio PC privado.
    //
    // La señal ld_pc_clk conserva la lógica original:
    //     ld_pc_clk = ld_pc & ~clk
    // ========================================================

    assign ld_pc_clk = ld_pc & ~clk;

    genvar pc_i;

    generate
        for (pc_i = 0; pc_i < 32; pc_i = pc_i + 1) begin : PC_REGISTER
            dff_async_rst pc_ff (
                .data(pc_pre[pc_i]),
                .clk(ld_pc_clk),
                .reset(reset),
                .q(pc[pc_i])
            );
        end
    endgenerate

    // ========================================================
    // Debug outputs
    // ========================================================
    assign debug_pc         = pc;
    assign debug_addrs_reg  = addrs_reg;
    assign debug_codif_inst = codif_inst_deco;
    assign debug_mem_enable = enable_mbc;
    assign debug_mem_rdy    = mem_rdy;

endmodule

`endif
