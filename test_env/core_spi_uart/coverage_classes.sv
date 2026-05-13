class instruction_coverage_class;

	bit [6:0]  opcode;
    bit [11:0] imm;
    bit [19:0] imm2;
    bit [20:0] offset;
    bit [12:0] offset_b;
    bit [2:0]  funct3;
    bit [4:0]  rs1;
    bit [4:0]  rs2;
    bit [4:0]  rd;
    bit [6:0]  funct7;
    bit [4:0]  shamt;
    bit [11:0] csr_reg;
    bit [4:0]  zimm;
    bit [31:0] reg_content;

    covergroup instruction_cov;

        opcode_cov   : coverpoint opcode;
        imm_cov      : coverpoint imm {
        	option.auto_bin_max = 64;
        }
        imm2_cov     : coverpoint imm2 { //imm with different size
            option.auto_bin_max = 1024;
        }
        offset_cov   : coverpoint offset { // for JAL only
            option.auto_bin_max = 2048;
        }
        offset_b_cov : coverpoint offset_b { //offset for branches
            option.auto_bin_max = 128;
        }
        funct3_cov   : coverpoint funct3;
        rs1_cov      : coverpoint rs1 {
        	ignore_bins ignore_values = {0}; //$zero register is excluded since it won't change
        }
        rs2_cov      : coverpoint rs2 {
        	ignore_bins ignore_values = {0};
        }
        rd_cov       : coverpoint rd {
        	ignore_bins ignore_values = {0};
        }
        funct7_cov   : coverpoint funct7;
        shamt_cov    : coverpoint shamt;
        csr_reg      : coverpoint csr_reg {
        	bins mip_mie 				  = {0};
        	bins mepc 					  = {1};
        	bins mcause1 				  = {2};
        	bins mcause2 				  = {3};
        	bins gpio 					  = {4};
        	bins mvtec 					  = {5};
        	bins comp_timer 			  = {6};
        	bins val_timer 				  = {7};
        	bins full_range_level_shifter = {8};
        	bins IS_Val 				  = {9};
        	bins IS_Config 				  = {10};
        	bins IS_Trigger 			  = {11};
        	ignore_bins ignore_values = {[12:4095]};
        }
        zimm_cov     : coverpoint zimm;
        reg_cont_cov : coverpoint reg_content {
        	option.auto_bin_max = 65536;
        }
         
    endgroup : instruction_cov

    function new ();
   		instruction_cov = new;
    endfunction : new

endclass : instruction_coverage_class

class core_coverage_class;

	bit clk;
	bit [7:0] ctrl_fsm_state;

	covergroup core_cov @(posedge clk);
		ctrl_fsm_cov : coverpoint ctrl_fsm_state {
			option.auto_bin_max = 256;
			ignore_bins ignore_values = {[195:255]};
		}
	endgroup : core_cov

    function new (bit clk);
    	this.clk = clk;
   		core_cov = new;
    endfunction : new

endclass : core_coverage_class