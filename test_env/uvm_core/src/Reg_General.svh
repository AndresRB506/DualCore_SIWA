class Latch_RAL extends  uvm_reg;
	`uvm_object_utils(Latch_RAL)

	uvm_reg_field status;

	function new (string name = "Latch_RAL");
		super.new(name, 1, UVM_NO_COVERAGE);
	endfunction

	function void build;
		status = uvm_reg_field::type_id::create("status");
		status.configure(.parent(this),.size(1),.lsb_pos(0),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
	endfunction : build
		
endclass : Latch_RAL

class general_reg_block extends  uvm_reg_block; // Block equivalente a un registro 32bits
	`uvm_object_utils(general_reg_block)
	int reg_pos;
	rand Latch_RAL Latch_General_array [32]; //32 bits

	function new (string name = "general_reg_block");
		super.new(name,build_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build(int reg_pos_i);
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			this.reg_pos = reg_pos_i;
			Latch_General_array [k] = Latch_RAL::type_id::create($sformatf(
											"Latch_General_array[%0d]",k));
			Latch_General_array [k].configure(this, null, "");
			Latch_General_array [k].build();
			Latch_General_array [k].add_hdl_path_slice($sformatf(
										"latches2[%0d].latchesa.q",k),0, 
										Latch_General_array[k].get_n_bits());
		end
		add_hdl_path($sformatf("tb_top.dut_wr.uut.TOP.Reg_file.Reg_integer.latches1[%0d]",
								reg_pos));
		lock_model();

	endfunction : build
endclass : general_reg_block

class reg_file_block extends  uvm_reg_block; // Block equivalente a banco de registros de 32bits
	`uvm_object_utils(reg_file_block)
	int reg_pos;
	rand general_reg_block Reg_General_array [31]; //Arreglo de 31 registros

	function new (string name = "reg_file_block");
		super.new(name,build_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build;
		for (int i = 0; i<31; i++) begin //Se tienen 31 registros
			automatic int k = i;
			Reg_General_array [k] = new($sformatf("general_reg_block_%0d",k));
			Reg_General_array[k].build(k+1);
		end

		lock_model();

	endfunction : build
endclass : reg_file_block