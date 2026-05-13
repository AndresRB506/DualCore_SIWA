####################################################################
#                                                                  #
# Description        :  Script to Place the Ports based on         #
#                       the Pad Pin Location                       #
# Version            :  1.2                                        #
# Completion Date    :  01 Feb 2008 				   #
# Modified Date	     :  07 Nov 2008                                #
#                                                                  #
####################################################################

# Usage:
# source place_ports.tcl
# place_ports

proc place_ports {} {

  foreach_in_collection port [get_ports -all *] {

    if {[sizeof_collection [get_pins -all -leaf -of_object [get_object_name $port]]] != 0} {

# Use the following command if you use 2007.03 or earlier versions 
#    set_port_location $port -coord "[lindex [get_attribute [index [get_pins -leaf -of_object [get_object_name $port]] 0] center] 0]"

# Use the following command if you use 2007.12 or later versions 
#     set_port_location $port -coord [get_attribute [index [get_pins -all -leaf -of_object [get_object_name $port]] 0] center]
	set_port_location $port -coord [get_attribute [index [get_pins -all -leaf -of_object [get_object_name $port]] 0] center]
#   set_port_location $port -coord "[get_location [index [get_pins -leaf -of_object [get_object_name $port]] 0]]"

    } else {

      echo [format "\nWarning: The port %s is not connected to any pad pins\n" [get_object_name $port]]
      set_port_location $port -coord {0 0}

    }
  }
}
