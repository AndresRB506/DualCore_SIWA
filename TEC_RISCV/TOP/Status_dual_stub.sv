// ============================================================
// File: TEC_RISCV/TOP/Status_dual_stub.sv
// Description:
//   Stub de tasks de debug usadas por control.sv.
//
//   En el flujo monocore original, Status.sv define las tasks
//   status_deco() y status_gpr(), pero también contiene
//   referencias jerárquicas fijas a Test_Top.uut.TOP.
//
//   En el top dual-core esa jerarquía no existe, por lo que
//   se usa este stub para permitir la compilación presilicio
//   sin modificar Status.sv original.
// ============================================================

`ifndef STATUS_DUAL_STUB_SV
`define STATUS_DUAL_STUB_SV

task status_deco();
begin
    // Stub intencionalmente vacío para integración dual-core.
end
endtask

task status_gpr();
begin
    // Stub intencionalmente vacío para integración dual-core.
end
endtask

`endif
