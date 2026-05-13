class Reg_Control extends  uvm_reg;
	`uvm_object_utils(Reg_Control)

	uvm_reg_field status;

	function new (string name = "Reg_Control");
		super.new(name, 8, UVM_NO_COVERAGE);
	endfunction

	function void build;
		status = uvm_reg_field::type_id::create("status");
		status.configure(.parent(this),.size(8),.lsb_pos(0),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
	endfunction : build
		
endclass : Reg_Control

class inst_fetch_reg extends uvm_reg;
	`uvm_object_utils(inst_fetch_reg)
	uvm_reg_field status;
	/*
	uvm_reg_field opcode;
	uvm_reg_field rd;
	uvm_reg_field rs1;
	uvm_reg_field rs2;
	uvm_reg_field func3;
	uvm_reg_field func7;
*/
	function new (string name = "inst_fetch_reg");
		super.new(name, 32, UVM_NO_COVERAGE);
	endfunction

	function void build;
		status = uvm_reg_field::type_id::create("status");
		status.configure(.parent(this),.size(32),.lsb_pos(0),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));

		/*
		opcode = uvm_reg_field::type_id::create("opcode");
		opcode.configure(.parent(this),.size(7),.lsb_pos(0),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
		rd = uvm_reg_field::type_id::create("rd");
		rd.configure(.parent(this),.size(5),.lsb_pos(7),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
		
		func3 = uvm_reg_field::type_id::create("func3");
		func3.configure(.parent(this),.size(3),.lsb_pos(12),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
		rs1 = uvm_reg_field::type_id::create("rs1");
		rs1.configure(.parent(this),.size(5),.lsb_pos(15),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
		rs2 = uvm_reg_field::type_id::create("rs2");
		rs2.configure(.parent(this),.size(5),.lsb_pos(20),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));
		func7 = uvm_reg_field::type_id::create("func7");
		func7.configure(.parent(this),.size(7),.lsb_pos(25),
						.access("RW"),.volatile(0),.reset(1),
						.has_reset(1),.is_rand(1),
						.individually_accessible(1));

		add_hdl_path_slice(.name("opcode"), .offset(0), .size(7));
		add_hdl_path_slice(.name("rd"), .offset(7), .size(5));
		add_hdl_path_slice(.name("func3"), .offset(12), .size(3));
		add_hdl_path_slice(.name("rs1"), .offset(15), .size(5));
		add_hdl_path_slice(.name("rs2"), .offset(20), .size(5));
		add_hdl_path_slice(.name("func7"), .offset(25), .size(7));
		*/
	endfunction : build
	
endclass : inst_fetch_reg


class csr_reg_block_base extends uvm_reg_block;
	`uvm_object_utils(csr_reg_block_base)
	rand Latch_RAL Latch_array [32];
	function new(string name = "csr_reg_block_base");
		super.new(name);
	endfunction 
	extern function void build();
endclass : csr_reg_block_base

class ral_interrupt1 extends csr_reg_block_base;
	`uvm_object_utils(ral_interrupt1)
	function new(string name = "ral_interrupt1");
		super.new(name);
	endfunction 
	function build();
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			Latch_array [k] = Latch_RAL::type_id::create($sformatf("Latch_array[%0d]",k));
			Latch_array [k].configure(this, null, "");
			Latch_array [k].build();
			Latch_array [k].add_hdl_path_slice($sformatf(
										"Regsitrio_interruption1[%0d].latches_interruption1.Out1",k),0, 
										Latch_array[k].get_n_bits());
		end
		add_hdl_path("tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr");
		lock_model();
	endfunction

endclass


class ral_interrupt2 extends csr_reg_block_base;
	`uvm_object_utils(ral_interrupt2)
	function new(string name = "ral_interrupt2");
		super.new(name);
	endfunction 
	function build();
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			Latch_array [k] = Latch_RAL::type_id::create($sformatf("Latch_array[%0d]",k));
			Latch_array [k].configure(this, null, "");
			Latch_array [k].build();
			Latch_array [k].add_hdl_path_slice($sformatf(
										"Regsitrio_interrup2[%0d].latches_mcause.Out1",k),0, 
										Latch_array[k].get_n_bits());
		end
		add_hdl_path("tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr");
		lock_model();
	endfunction

endclass

class gpio extends csr_reg_block_base;
	`uvm_object_utils(gpio)
	function new(string name = "gpio");
		super.new(name);
	endfunction 
	function build();
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			Latch_array [k] = Latch_RAL::type_id::create($sformatf("Latch_array[%0d]",k));
			Latch_array [k].configure(this, null, "");
			Latch_array [k].build();
			if (k < 8) Latch_array [k].add_hdl_path_slice($sformatf(
										"Regsitrio_GPIO[%0d].rf11.latch_Mie_IO.latch1.q",k),0, 
										Latch_array[k].get_n_bits());
			else Latch_array [k].add_hdl_path_slice($sformatf(
										"Regsitrio_GPIO[%0d]..rf13.tristategate_zeroo.input_x",k),0, 
										Latch_array[k].get_n_bits());

			
		end
		add_hdl_path("tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr");
		lock_model();
	endfunction

endclass
//Regsitrio_GPIO[31].rf13.tristategate_zeroo.input_x
//Regsitrio_GPIO[7].rf11.latch_Mie_IO.latch1.q
//Test_Top.uut.TOP.Reg_file.Reg_csr.Regsitrio_interruption1[31].latches_interruption1.latch1.q,

class timer_valor extends csr_reg_block_base;
	`uvm_object_utils(timer_valor)
	function new(string name = "timer_valor");
		super.new(name);
	endfunction 
	function build();
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			Latch_array [k] = Latch_RAL::type_id::create($sformatf("Latch_array[%0d]",k));
			Latch_array [k].configure(this, null, "");
			Latch_array [k].build();
			Latch_array [k].add_hdl_path_slice($sformatf(
										"Valor_timer[%0d].tristate_timer.input_x",k),0, 
										Latch_array[k].get_n_bits());
		end
		add_hdl_path("tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr");
		lock_model();
	endfunction

endclass


class timer_comp extends csr_reg_block_base;
	`uvm_object_utils(timer_comp)
	function new(string name = "timer_comp");
		super.new(name);
	endfunction 
	function build();
		for (int i = 0; i<32; i++) begin
			automatic int k = i;
			Latch_array [k] = Latch_RAL::type_id::create($sformatf("Latch_array[%0d]",k));
			Latch_array [k].configure(this, null, "");
			Latch_array [k].build();
			Latch_array [k].add_hdl_path_slice($sformatf(
										"Registro_Comparacion[%0d].latch_Comparacion.latch1.q",k),0, 
										Latch_array[k].get_n_bits());
		end
		add_hdl_path("tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr");
		lock_model();
	endfunction

endclass


class csr_reg_block extends  uvm_reg_block;  // ****** CSR REG ARRAY *********
	`uvm_object_utils(csr_reg_block)

	rand Reg_Control control_sm;
	rand ral_interrupt1 ral_interrupt1_i;
	rand ral_interrupt2 ral_interrupt2_i;
	rand gpio gpio_i;
	rand timer_valor timer_valor_i;
	rand timer_comp timer_comp_i;
	rand inst_fetch_reg inst_fetch_reg_i;

	function new (string name = "csr_reg_block");
		super.new(name,build_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build;
		control_sm = Reg_Control::type_id::create("control_sm");
		control_sm.configure(this, null, "");
		control_sm.build();
		control_sm.add_hdl_path_slice("central_control.cur_state",0, control_sm.get_n_bits());
		//add_hdl_path("tb_top.dut_wr.uut.TOP.central_control");
		//lock_model();

		inst_fetch_reg_i = inst_fetch_reg::type_id::create("inst_fetch_reg_i");
		inst_fetch_reg_i.configure(this, null, "");
		inst_fetch_reg_i.build();
		inst_fetch_reg_i.add_hdl_path_slice("Deco.inst_reg",0, inst_fetch_reg_i.get_n_bits());
		add_hdl_path("tb_top.dut_wr.uut.TOP");
		lock_model();

		ral_interrupt1_i = ral_interrupt1::type_id::create("ral_interrupt1_i");
		ral_interrupt1_i.build();

		ral_interrupt2_i = ral_interrupt2::type_id::create("ral_interrupt2_i");
		ral_interrupt2_i.build();

		gpio_i = gpio::type_id::create("gpio_i");
		gpio_i.build();

		timer_valor_i = timer_valor::type_id::create("timer_valor_i");
		timer_valor_i.build();

		timer_comp_i = timer_comp::type_id::create("timer_comp_i");
		timer_comp_i.build();

	endfunction : build

	task csr_reg_backdoor (input csr_reg_block_base csr_block,
									output bit [31:0] csr_data);
		uvm_status_e  status;
		foreach (csr_block.Latch_array[i]) begin
			csr_block.Latch_array[i].peek(status, csr_data[i]);
		end
	endtask : csr_reg_backdoor
endclass : csr_reg_block
