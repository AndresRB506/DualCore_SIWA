task core_coverage_collection(core_coverage_class core_cov);

	/////////////////////////////////// Monitoring of Coverage Metrics //////////////////////////////////////////

    //Asign a new value each clock

    //$display("Core Coverage CLK %b",core_cov.clk);
    //$display("Core Coverage CLK %d",core_cov.);
	core_cov.ctrl_fsm_state = topcore_tb.uut.TOP.central_control.cur_state[7:0];

endtask : core_coverage_collection