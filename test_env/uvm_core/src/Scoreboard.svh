class Scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(Scoreboard)
	int executed_inst;
	string exe_inst_queue [$];
	string prediction     [$];
    string inst_queue     [$];
    string csr_predict    [$];
    string uart_predict   [$];
    string spi_predict    [$];
    mon_sb reg_read_result [$];
    mon_sb mon_sb_Q [$];
    typedef enum {pc,mcause1,mip_mie,mepc,mcause2,gpio,mvtec,comp_timer,
                val_timer,full_range_level_shifter,IS_Val,IS_Config,
                IS_Trigger} e_csr_regs;
	function new(string name="Scoreboard", uvm_component parent=null);
		super.new(name,parent);
	endfunction : new

	uvm_analysis_imp #(mon_sb, Scoreboard) sb_analysis_port;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sb_analysis_port = new("sb_analysis_port", this);

		reference_model(inst_queue,prediction,executed_inst,
						exe_inst_queue,csr_predict,uart_predict,
						spi_predict);
		$display("prediction Size = %0d", prediction.size());
		strQ_to_monsbQ(prediction, csr_predict, mon_sb_Q);
		//print_hex(mon_sb_Q);
		//$display("Out Q = ",mon_sb_Q.size());
		//$display("Out Q = ",csr_predict.size());

		//print_prediction(prediction);

	endfunction : build_phase

	virtual function void check_phase(uvm_phase phase);
		int reg_file = 0;
		$display("Excec Size %d",reg_read_result.size());
		gen_reg_assert (reg_read_result, 
						mon_sb_Q);
	endfunction : check_phase

	virtual function write(mon_sb mon_sb_i);
		if(mon_sb_i.reset == 1)  `uvm_info("SB", $sformatf("Analisys Port Activity : RST=%0d",mon_sb_i.reset),UVM_LOW)
		else begin
			`uvm_info("SB", $sformatf("Analisys Port Activity : Fetch3"),UVM_HIGH)
			for(int i = 0; i < 32; i++) begin
				`uvm_info("SB",$sformatf("%0d General [%0d] RAL = %h",
							$time,i,mon_sb_i.reg_values[i]),UVM_HIGH)
			end
			`uvm_info("SB",$sformatf("%0d Int1 RAL = %h",
							$time,mon_sb_i.interrupt1),UVM_HIGH)
			reg_read_result.push_back(mon_sb_i);
		end
	endfunction : write

	task gen_reg_assert (input mon_sb reg_read_result [$], 
						input mon_sb mon_sb_Q [$]);
		
		int RF_PASS = $fopen("../sim_result_files/RF_PASS.csv","w");
		int RF_MISS = $fopen("../sim_result_files/RF_MISS.csv","w");
		int RF_SUM = $fopen("../sim_result_files/RF_SUM.csv","w");
	
		int reg_cont = 0;
		mon_sb temp_pred;
		mon_sb temp_read;
		$fwrite(RF_PASS,"Time,Status,Register File,Register,Expected Value,Mirrored Value\n");
		$fwrite(RF_MISS,"Time,Status,Register File,Register,Expected Value,Mirrored Value\n");
 		while(mon_sb_Q.size() > 0) begin
 			temp_pred = mon_sb_Q.pop_front();
			temp_read = reg_read_result.pop_front();
			
			for(int i = 0; i < 32; i++)begin
				automatic int k = i;
				assert (temp_pred.reg_values[k] == temp_read.reg_values[i]) begin
					`uvm_info(get_full_name(),$sformatf("%d BIEN %h = %h",reg_cont,temp_pred.reg_values[k],
														temp_read.reg_values[i]), UVM_HIGH);
					$fwrite(RF_PASS,$sformatf("%0d,PASS,%0d,x%0d,%h,%h\n",temp_read.event_time,reg_cont,k,temp_pred.reg_values[k],
														temp_read.reg_values[i]));
				end

				else begin
					`uvm_error(get_full_name(),$sformatf("FAIL,%0d,%h,%h",
						reg_cont,temp_pred.reg_values[k],temp_read.reg_values[i]))
					$fwrite(RF_PASS,$sformatf("%0d,FAIL,%0d,%h,%h\n",temp_read.event_time,reg_cont,temp_pred.reg_values[k],
														temp_read.reg_values[i]));
				end
			end
			reg_cont += 1;
			
		end
		$fclose(RF_PASS);
	endtask : gen_reg_assert

	function void strQ_to_monsbQ (	input string prediction [$],
									input string csr_predict [$],
									output mon_sb mon_sb_Q [$]);
		int needed = 1;
		int csr_count = 0;
		int reg_cont = 0;
		string temp_str;
		mon_sb mon_sb = new;
		while(prediction.size() > 0) begin	
			if (reg_cont < 32) begin
				temp_str = prediction.pop_front();
				mon_sb.reg_values[reg_cont] = temp_str.atohex();
				`uvm_info("SB",$sformatf("Reg %d String = %0s Hex = %h ",reg_cont,
							temp_str, mon_sb.reg_values[reg_cont]), UVM_DEBUG)
				reg_cont += 1;
			end
			else begin
				if ((csr_count < 13) && (csr_predict.size() > 0)) begin
					temp_str = csr_predict.pop_front();
					//$display("Out Q = %s",temp_str);
					case (csr_count)
						mcause1: begin
							mon_sb.interrupt1 = temp_str.atohex();
							`uvm_info("SB",$sformatf("Int1 %d String = %0s Hex = %h ",reg_cont,
							temp_str, mon_sb.interrupt1), UVM_HIGH)
						end
					endcase
					csr_count += 1;
				end
				else begin
					mon_sb_Q.push_back(mon_sb);
					reg_cont = 0;
					csr_count = 0;
					if(needed == 1) begin
						mon_sb = new;
					end
				end
			end
		end
	endfunction : strQ_to_monsbQ


	task print_hex(input mon_sb mon_sb_Q [$]);
		int reg_cont = 0;
		mon_sb temp_pred;
		while(mon_sb_Q.size() > 0) begin
			temp_pred = mon_sb_Q.pop_front();
			for(int i = 0; i < 32; i++)begin
				$display("Reg %d Pos %d Cont %h", reg_cont, i, temp_pred.reg_values[i]);
			end
			reg_cont += 1;
		end
	endtask : print_hex
	task print_prediction(string prediction [$]);
		string val;
		int reg_cont = 0;
		int reg_file = 0;
		while(prediction.size() > 0) begin
			if (reg_cont < 32) begin
				$display("%0d Reg[%0d] = %s", reg_file, reg_cont,prediction.pop_front());
				reg_cont += 1;
			end
			else begin
				reg_cont = 0;
				reg_file += 1;
			end
			
		end
		
	endtask
		
	
endclass : Scoreboard