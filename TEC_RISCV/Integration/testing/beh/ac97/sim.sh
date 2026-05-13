#!/usr/bin/env bash
vcs -full64 -debug_access+all +v2k +vcs+vcdpluson -f source_list -l vcs.log; #+vcs+dumpvars+test.vcd +systemverilogext+sv; # +saif
./simv > simulation.log
mv vcdplus.vpd test.vpd
if [ -f test.vpd ]; then
	vpd2vcd -full64 test.vpd test.vcd
	vcd2saif -64 -input test.vcd -output test.saif
fi

