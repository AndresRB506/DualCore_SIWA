########################################################
# Script UPF que pega explicitamente los VDD necesarios para PADS, y Level Shifters
##########################################################

#  Primero se reconectan los PADs
#connect_supply_net pad_ring_inst/VDD_1V8_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDD}
connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDDR}
connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/pad_bit_?__inout_pad_inst/VDDO}

#connect_supply_net pad_ring_inst/VDD_1V8_PADS -ports {pad_ring_inst/*_pad_inst/VDD}
connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/*_pad_inst/VDDO}
connect_supply_net pad_ring_inst/VDD_3V3_PADS -ports {pad_ring_inst/*_pad_inst/VDDR}

# Reconexion de los Level Shifter
#connect_supply_net ucu_anlg1/VDD_3V3_UCU -ports {ucu_anlg1/*/vdd3e}
#connect_supply_net ucu_anlg1/VDD_1V8 -ports {ucu_anlg1/*/vdd}

