class inst_fetch_cov_collector extends uvm_subscriber #(inst_fetch_item);
	`uvm_component_utils(inst_fetch_cov_collector)
	inst_fetch_item inst;
	uvm_analysis_imp #(inst_fetch_item, inst_fetch_cov_collector) cov_analysis_port;

	covergroup inst_c;
		option.per_instance = 1;
		cp1: coverpoint inst.opcode {
		option.weight = 1;
		type_option.weight = 1;
						bins r_type = 		{7'b0110011};
						bins i_type = 		{7'b0010011};
						bins s_type = 		{7'b0100011};
						bins b_type = 		{7'b0010011};
						bins auipc_type = 	{7'b0010111};
						bins jal_type = 	{7'b1101111};
						bins jalr_type =	{7'b1100111};
						bins l_type = 		{7'b0000011};
						bins lui_type = 	{7'b0110111};
						}
		cp2: coverpoint inst.func3 {
		option.weight = 1;
		type_option.weight = 1;
						bins b_func3 = {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
						bins l_func3 = {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
						bins s_func3 = {3'b000, 3'b001, 3'b010};
						bins i_func3 = {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111};
						bins i_sr_func3 = {3'b101};
						bins r_func3 = {3'b001, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111};
						bins r_sr_add_func3 = {3'b000, 3'b101};
		}
		cp3: coverpoint inst.func7 {
		option.weight = 1;
		type_option.weight = 1;
						bins i_func7 = {7'b0100000,7'b0000000}; //Cross with func3 = 3'b101
						bins r_func7 = {7'b0100000,7'b0000000}; //Cross with func3 = 3'b000 and 3'b101
		}
		cp1_x_cp2_cp3: cross cp1,cp2,cp3 {
		option.weight = 1;
		type_option.weight = 1;
							bins s = binsof(cp1.s_type) && binsof(cp2.s_func3);
							bins r = binsof(cp1.r_type) && binsof(cp2.r_func3);
							bins i = binsof(cp1.i_type) && binsof(cp2.i_func3);
							bins r_3_7 = binsof(cp1.r_type) && binsof(cp2.r_sr_add_func3) && binsof(cp3.r_func7);
							bins i_3_7 = binsof(cp1.i_type) && binsof(cp2.i_sr_func3) && binsof(cp3.i_func7);
							bins b = binsof(cp1.b_type) && binsof(cp2.b_func3);
							bins l = binsof(cp1.l_type) && binsof(cp2.l_func3);
							bins lui = binsof(cp1.lui_type);
							bins jalr = binsof(cp1.jalr_type);
							bins jal = binsof(cp1.jal_type);
							bins auipc = binsof(cp1.auipc_type);

		}
	endgroup : inst_c

	covergroup rd_cg;
		rd_cp: coverpoint inst.rd;
	endgroup : rd_cg


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cov_analysis_port = new("cov_analysis_port", this);
		
	endfunction

	function new (string name = "inst_fetch_cov_collector", uvm_component parent = null);
		super.new(name, parent);
		inst_c = new();
    	rd_cg = new();
	endfunction : new

	virtual function void write(inst_fetch_item inst_i);
		inst = inst_i;
		inst_c.sample();
		if((inst_i.opcode != 7'b0100011) || (inst_i.opcode !=7'b0010011)) begin
			rd_cg.sample();
		end 
		`uvm_info(get_full_name(),$sformatf("OLD Coverage %0d", inst_c.get_coverage()), UVM_LOW)
	endfunction : write
endclass: inst_fetch_cov_collector

