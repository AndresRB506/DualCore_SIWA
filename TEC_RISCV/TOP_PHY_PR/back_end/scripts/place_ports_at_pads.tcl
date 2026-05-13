####################################################################
#                                                                  #
# Description        :  Script to Place the Ports based on         #
#                       the Pad Pin Location                       #
# Version            :  1.2                                        #
# Completion Date    :  03 Mar 2019				   #
# Modified Date	     :  03 Mar 2019                                #
#                                                                  #
####################################################################

# Usage:
# source place_ports_at_pads.tcl
# Se necesita ver como metemos esto dentro de un lazo
# El problema son los nombres de los PADS y sus pines, que no coinciden con los puertos asignados. 
# Habria que pensar como meterlos en una lista o coleccion
# Dejamos para referencia el ejemplo del Script de Synopsys usado como referencia

#proc place_ports {} {

 # foreach_in_collection port [get_ports -all V*] {

#    if {[sizeof_collection [get_pins -all -leaf -of_object [get_object_name $port]]] != 0} {

# Use the following command if you use 2007.03 or earlier versions 
#    set_port_location $port -coord "[lindex [get_attribute [index [get_pins -leaf -of_object [get_object_name $port]] 0] center] 0]"

# Use the following command if you use 2007.12 or later versions 
#     set_port_location $port -coord [get_attribute [index [get_pins -all -leaf -of_object [get_object_name $port]] 0] center]

#   set_port_location $port -coord "[get_location [index [get_pins -leaf -of_object [get_object_name $port]] 0]]"

#    } else {

 #     echo [format "\nWarning: The port %s is not connected to any pad pins\n" [get_object_name $port]]
 #     set_port_location $port -coord {0 0}

 #   }
 # }
#}
set port [get_ports -all VSS]
set_port_location $port -coord [get_attribute [index [get_pins -all vss_left_1/GNDOR] 0] center];
#get_ports -all VDD_*; #Reporta los siguientes puertos
#{VDD_1V8 VDD_1V8SRAM VDD_3V3_PADS VDD_1V8_PADS}
set port [get_ports -all VDD_1V8]
set_port_location $port -coord [get_attribute [index [get_pins -all vdd_1v8_core_left/VDDC] 0] center];
set port [get_ports -all VDD_1V8SRAM]
set_port_location $port -coord [get_attribute [index [get_pins -all vdd_1v8_sram_left/VDDC] 0] center];
set port [get_ports -all VDD_1V8_PADS]
set_port_location $port -coord [get_attribute [index [get_pins -all vdd_1v8_pad_left/VDD] 0] center];
set port [get_ports -all VDD_3V3_PADS]
set_port_location $port -coord [get_attribute [index [get_pins -all vdd_3v3_pad_down/VDDOR] 0] center];









