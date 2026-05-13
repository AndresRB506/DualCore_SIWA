########################################################
# Script UPF que pega explicitamente los VDD necesarios para PADS, y Level Shifters
##########################################################

#  Primero se reconectan los PADs
#connect_supply_net pad_ring_inst/VDD_1V8_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDD}
#connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDDR}
#connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDDO}

#connect_supply_net pad_ring_inst/VDD_1V8_PADS -ports {pad_ring_inst/*_pad_inst/VDD}
#connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/*_pad_inst/VDDO}
#connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/*_pad_inst/VDDR}

# Reconexion de los Level Shifter
#connect_supply_net ucu_anlg1/VDD_3V3_UCU -ports {ucu_anlg1/*/vdd3e}
#connect_supply_net ucu_anlg1/VDD_1V8 -ports {ucu_anlg1/*/vdd}
#connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/VDD_3V3_PADS}
#connect_supply_net ucu_anlg1/VDD_3V3_UCU -ports {ucu_anlg1/VDD_3V3_UCU}
#connect_supply_net VDD_3V3_PADS -ports {VDD_3V3_PADS}
#connect_supply_net VDD_3V3_UCU -ports {VDD_3V3_UCU}

#Conexion de redes de alimentacion
## Manual aca de pines de memoria
#file:///mnt/vol_NFS_Zener/WD_ESPEC/achacon/Herramientas/X-FAB/XH018/xh018/spram/XSPRAMBLP_256X32_M8P/v4_0_1/doc/XSPRAMBLP_256X32_M8P.html#PIN_DESCRIPTION
derive_pg_connection -power_net VDD_1V8 -power_pin {vdd} -cells "top_riscv_soc/*"
derive_pg_connection -ground_net VSS -ground_pin {gnd} -cells "top_riscv_soc/*"
derive_pg_connection -power_net VDD_3V3_UCU -power_pin {vdd3e} -cells "ucu_anlg1/*"
derive_pg_connection -power_net VDD_1V8 -power_pin {vdd} -cells "ucu_anlg1/*"
derive_pg_connection -ground_net VSS -ground_pin {gnd} -cells "ucu_anlg1/*"

derive_pg_connection -power_net VDD_1V8_PADS -power_pin {VDD} -cells "pad_ring_inst/*"
derive_pg_connection -power_net VDD_3V3_PADS -power_pin {VDDO} -cells "pad_ring_inst/*"
derive_pg_connection -power_net VDD_3V3_PADS -power_pin {VDDR} -cells "pad_ring_inst/*"
derive_pg_connection -ground_net VSS -ground_pin {GNDO} -cells "pad_ring_inst/*"
derive_pg_connection -ground_net VSS -ground_pin {GNDR} -cells "pad_ring_inst/*"
derive_pg_connection -power_net top_riscv_soc/VDD_1V8SRAM -power_pin {VDD18M} -cells "top_riscv_soc/TOP/Memoria_8K"
#derive_pg_connection -power_net VDD_1V8SRAM -power_pin {VDD18M} -cells "top_riscv_soc/TOP/Memoria_8K"
derive_pg_connection -ground_net VSS -ground_pin {VSSM} -cells "top_riscv_soc/TOP/Memoria_8K"
set_voltage 3.3 -object_list {pad_ring_inst/VDD_3V3_PADS ucu_anlg1/VDD_3V3_UCU VDD_3V3_UCU VDD_3V3_PADS};
set_voltage 1.8 -object_list {ucu_anlg1/VDD_1V8 top_riscv_soc/TOP/VDD_1V8SRAM pad_ring_inst/VDD_1V8_PADS VDD_1V8SRAM VDD_1V8};
set_voltage 0.0 -object_list {ucu_anlg1/VSS top_riscv_soc/TOP/VSS pad_ring_inst/VSS top_riscv_soc/VSS VSS};

