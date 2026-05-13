#set base_coordinates {1569.960 1304.480}
set spacing 0.025;
#Daremos un espaciado de 4 tracks
set spacing [expr 4 * $BASIC_TRACK];
set index 1;
set file [open ./scripts/allocate_ports.tcl w 0755]
foreach_in_collection each_port [get_ports] {
    set x_pos [format {%0.3f} [expr [lindex $base_coordinates 0] + 0]];
    set y_pos [format {%0.3f} [expr [lindex $base_coordinates 1] - [expr $spacing * $index]]];
    set port_name [get_attribute -class port $each_port name];
	#TAmnno de una via MET2
    	puts $file "set_port_location -coordinate {$x_pos $y_pos} -layer_name MET2 -layer_area {-0.28 -0.28 0.28 0.28} $port_name ;"
	#puts $file "set_port_location -coordinate {$x_pos $y_pos} $port_name -layer_name MET2 -layer_area {-0.28 -0.28 0.28 0.28};;"
    incr index;
}
close $file;

