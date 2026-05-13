class instruction_class;

	string name;
	real repetitions;
	real cpi;
	real average_cpi;

	function new (string inst_name);
		name = inst_name;
		cpi = 0;
		repetitions = 0;
		average_cpi = 0;
	endfunction : new

	function increment_cpi (int new_cpi);
		cpi = cpi + new_cpi;
		repetitions++;
	endfunction : increment_cpi

	function calculate_average_cpi ();
		if (repetitions != 0) begin
			average_cpi = (cpi/repetitions);
		end
		else begin
			average_cpi = 0;
		end
	endfunction : calculate_average_cpi

endclass : instruction_class