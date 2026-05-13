class Monitor_cov extends uvm_monitor; 
  
  `uvm_component_utils(Monitor_cov); // Declaracion en la fabrica
  

  uvm_analysis_port #(inst_fetch_item) mon_cov_analysis_port;    // Declaracion de puerto de analisis
                                                    // Metodo de comunicar al Scoreboard
  virtual wrapper_if v_if;                                                  
  ///////////// RAL Variables /////////////
  uvm_status_e  status;
  bit [6:0] opcode;
  bit [4:0] rd;
  bit [4:0] rs1;
  bit [4:0] rs2;
  bit [2:0] func3;
  bit [6:0] func7;
  bit [31:0] full_inst;
  csr_reg_block ral_csr;

  function new (string name = "Monitor_cov", uvm_component parent=null);
      super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    if(!uvm_config_db#(virtual wrapper_if)::get(this,"","v_if",v_if))begin
      `uvm_fatal("MON","uvm_config_db::get failed wrapper_if")
    end

    if(!uvm_config_db#(csr_reg_block)::get(null, "","ral_csr", ral_csr))begin
      `uvm_fatal("MON","uvm_config_db::get failed ral_csr")
    end

    mon_cov_analysis_port=new("mon_cov_analysis_port",this);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
      Backdoor_access();
      //concurrent_task_1...
      //concurrent_task_2...
    join
  endtask

  virtual task Backdoor_access(); // Acceso a registros por medio de Backdoor
    forever begin
      @(posedge v_if.clk);
      if(tb_top.dut_wr.uut.TOP.Deco.ld_id) begin
        //@(negedge tb_top.dut_wr.uut.TOP.Deco.ld_id);
        inst_fetch_item inst_fetch_item_i = new;
        //inst_fetch_item = inst_fetch_item::type_id::create("inst_fetch_item",null)
        ral_csr.inst_fetch_reg_i.peek(status, full_inst);
        inst_fetch_item_i.opcode = full_inst [6:0];
        inst_fetch_item_i.func3 = full_inst [14:12];
        inst_fetch_item_i.func7 = full_inst [31:25];
        inst_fetch_item_i.rd = full_inst [11:7];

        //ral_csr.inst_fetch_reg_i.peek(func3, inst_fetch_item_i.func3);
        //ral_csr.inst_fetch_reg_i.peek(func7, inst_fetch_item_i.func7);
        mon_cov_analysis_port.write(inst_fetch_item_i);
        `uvm_info(get_full_name(),$sformatf("opcode = %b // func3 = %b // FULL = %b",inst_fetch_item_i.opcode, inst_fetch_item_i.func3, full_inst),UVM_DEBUG)
      end
    end
  endtask
endclass
