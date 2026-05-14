// ============================================================
// File: TEC_RISCV/MBC/mbc_smp_arbiter.sv
// Description:
//   Árbitro simple para conectar dos cores RV32I al MBC
//   monocore original del Siwa.
//
// Architecture:
//
//   Core 0 ┐
//          ├── mbc_smp_arbiter ── MBC.sv ── Memory / Bus
//   Core 1 ┘
//
// Notes:
//   - No modifica internamente el MBC original.
//   - Usa arbitraje round-robin.
//   - Solo un core puede usar el MBC a la vez.
//   - La respuesta d_read/mem_rdy/error_drs se devuelve
//     únicamente al core atendido.
// ============================================================

`ifndef MBC_SMP_ARBITER_SV
`define MBC_SMP_ARBITER_SV

module mbc_smp_arbiter #(
    parameter int ADDR_WIDTH = 25,
    parameter int DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic reset,

    // ========================================================
    // Core 0 interface hacia memoria/MBC
    // ========================================================
    input  logic [ADDR_WIDTH-1:0] core0_address,
    input  logic [DATA_WIDTH-1:0] core0_d_write,
    input  logic                  core0_b,
    input  logic                  core0_h,
    input  logic                  core0_sign_ext,
    input  logic                  core0_enable,
    input  logic                  core0_r_w,

    output logic [DATA_WIDTH-1:0] core0_d_read,
    output logic                  core0_mem_rdy,
    output logic                  core0_error_drs,

    // ========================================================
    // Core 1 interface hacia memoria/MBC
    // ========================================================
    input  logic [ADDR_WIDTH-1:0] core1_address,
    input  logic [DATA_WIDTH-1:0] core1_d_write,
    input  logic                  core1_b,
    input  logic                  core1_h,
    input  logic                  core1_sign_ext,
    input  logic                  core1_enable,
    input  logic                  core1_r_w,

    output logic [DATA_WIDTH-1:0] core1_d_read,
    output logic                  core1_mem_rdy,
    output logic                  core1_error_drs,

    // ========================================================
    // Interfaz única hacia el MBC original
    // ========================================================
    output logic [ADDR_WIDTH-1:0] mbc_address,
    output logic [DATA_WIDTH-1:0] mbc_d_write,
    output logic                  mbc_b,
    output logic                  mbc_h,
    output logic                  mbc_sign_ext,
    output logic                  mbc_enable,
    output logic                  mbc_r_w,

    input  logic [DATA_WIDTH-1:0] mbc_d_read,
    input  logic                  mbc_mem_rdy,
    input  logic                  mbc_error_drs
);

    // ========================================================
    // Estados del árbitro
    // ========================================================
    typedef enum logic [1:0] {
        ARB_IDLE,
        ARB_BUSY
    } arb_state_t;

    arb_state_t state, next_state;

    // 0 = Core 0, 1 = Core 1
    logic owner;
    logic next_owner;

    // Round-robin turn:
    // 0 favorece Core 0 cuando ambos piden
    // 1 favorece Core 1 cuando ambos piden
    logic turn;

    // Señal de selección generada en IDLE
    logic grant_valid;
    logic grant_core;

    // Registros internos para congelar la transacción aceptada
    logic [ADDR_WIDTH-1:0] latched_address;
    logic [DATA_WIDTH-1:0] latched_d_write;
    logic                  latched_b;
    logic                  latched_h;
    logic                  latched_sign_ext;
    logic                  latched_r_w;

    // Última respuesta válida por core
    logic [DATA_WIDTH-1:0] core0_d_read_q;
    logic [DATA_WIDTH-1:0] core1_d_read_q;
    logic                  core0_error_drs_q;
    logic                  core1_error_drs_q;

    // ========================================================
    // Lógica de selección round-robin
    // ========================================================
    always_comb begin
        grant_valid = 1'b0;
        grant_core  = 1'b0;

        if (state == ARB_IDLE && mbc_mem_rdy) begin
            unique case ({core1_enable, core0_enable})
                2'b00: begin
                    grant_valid = 1'b0;
                    grant_core  = 1'b0;
                end

                2'b01: begin
                    grant_valid = 1'b1;
                    grant_core  = 1'b0;   // Core 0
                end

                2'b10: begin
                    grant_valid = 1'b1;
                    grant_core  = 1'b1;   // Core 1
                end

                2'b11: begin
                    grant_valid = 1'b1;
                    grant_core  = turn;   // Round-robin
                end

                default: begin
                    grant_valid = 1'b0;
                    grant_core  = 1'b0;
                end
            endcase
        end
    end

    // ========================================================
    // Máquina de estados
    // ========================================================
    always_comb begin
        next_state = state;
        next_owner = owner;

        case (state)
            ARB_IDLE: begin
                if (grant_valid) begin
                    next_state = ARB_BUSY;
                    next_owner = grant_core;
                end
            end

            ARB_BUSY: begin
                // El MBC vuelve a mem_rdy = 1 cuando termina la transacción
                if (mbc_mem_rdy) begin
                    next_state = ARB_IDLE;
                end
            end

            default: begin
                next_state = ARB_IDLE;
                next_owner = 1'b0;
            end
        endcase
    end

    // ========================================================
    // Registros secuenciales
    // ========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state             <= ARB_IDLE;
            owner             <= 1'b0;
            turn              <= 1'b0;

            latched_address   <= '0;
            latched_d_write   <= '0;
            latched_b         <= 1'b0;
            latched_h         <= 1'b0;
            latched_sign_ext  <= 1'b0;
            latched_r_w       <= 1'b0;

            core0_d_read_q    <= '0;
            core1_d_read_q    <= '0;
            core0_error_drs_q <= 1'b0;
            core1_error_drs_q <= 1'b0;
        end else begin
            state <= next_state;
            owner <= next_owner;

            // Captura de la solicitud aceptada
            if (state == ARB_IDLE && grant_valid) begin
                if (grant_core == 1'b0) begin
                    latched_address  <= core0_address;
                    latched_d_write  <= core0_d_write;
                    latched_b        <= core0_b;
                    latched_h        <= core0_h;
                    latched_sign_ext <= core0_sign_ext;
                    latched_r_w      <= core0_r_w;
                end else begin
                    latched_address  <= core1_address;
                    latched_d_write  <= core1_d_write;
                    latched_b        <= core1_b;
                    latched_h        <= core1_h;
                    latched_sign_ext <= core1_sign_ext;
                    latched_r_w      <= core1_r_w;
                end
            end

            // Captura de respuesta cuando termina la transacción
            if (state == ARB_BUSY && mbc_mem_rdy) begin
                if (owner == 1'b0) begin
                    core0_d_read_q    <= mbc_d_read;
                    core0_error_drs_q <= mbc_error_drs;
                end else begin
                    core1_d_read_q    <= mbc_d_read;
                    core1_error_drs_q <= mbc_error_drs;
                end

                // Alternancia round-robin al finalizar una transacción
                turn <= ~turn;
            end
        end
    end

    // ========================================================
    // Mux hacia el MBC original
    // ========================================================
    always_comb begin
        // Valores por defecto
        mbc_address  = latched_address;
        mbc_d_write  = latched_d_write;
        mbc_b        = latched_b;
        mbc_h        = latched_h;
        mbc_sign_ext = latched_sign_ext;
        mbc_r_w      = latched_r_w;
        mbc_enable   = 1'b0;

        // En IDLE, si se concede acceso, se manda la solicitud
        // directamente al MBC por un ciclo.
        if (state == ARB_IDLE && grant_valid) begin
            if (grant_core == 1'b0) begin
                mbc_address  = core0_address;
                mbc_d_write  = core0_d_write;
                mbc_b        = core0_b;
                mbc_h        = core0_h;
                mbc_sign_ext = core0_sign_ext;
                mbc_r_w      = core0_r_w;
                mbc_enable   = core0_enable;
            end else begin
                mbc_address  = core1_address;
                mbc_d_write  = core1_d_write;
                mbc_b        = core1_b;
                mbc_h        = core1_h;
                mbc_sign_ext = core1_sign_ext;
                mbc_r_w      = core1_r_w;
                mbc_enable   = core1_enable;
            end
        end
    end

    // ========================================================
    // Demux de respuesta hacia el core correcto
    // ========================================================
    always_comb begin
        // Por defecto, mantener última lectura conocida
        core0_d_read    = core0_d_read_q;
        core1_d_read    = core1_d_read_q;

        core0_error_drs = core0_error_drs_q;
        core1_error_drs = core1_error_drs_q;

        core0_mem_rdy   = 1'b0;
        core1_mem_rdy   = 1'b0;

        // Cuando no hay transacción activa y el MBC está libre,
        // ambos cores pueden ver que el sistema está disponible.
        if (state == ARB_IDLE && mbc_mem_rdy && !grant_valid) begin
            core0_mem_rdy = 1'b1;
            core1_mem_rdy = 1'b1;
        end

        // Durante una transacción, solo el dueño recibe mem_rdy
        // cuando el MBC termina.
        if (state == ARB_BUSY && mbc_mem_rdy) begin
            if (owner == 1'b0) begin
                core0_d_read    = mbc_d_read;
                core0_error_drs = mbc_error_drs;
                core0_mem_rdy   = 1'b1;

                core1_mem_rdy   = 1'b0;
            end else begin
                core1_d_read    = mbc_d_read;
                core1_error_drs = mbc_error_drs;
                core1_mem_rdy   = 1'b1;

                core0_mem_rdy   = 1'b0;
            end
        end
    end

endmodule

`endif