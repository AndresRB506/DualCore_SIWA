

class Agent extends  uvm_agent;
	`uvm_component_utils(Agent);
	string name = "Agent";

	Driver driver_inst;
	Monitor monitor_inst;

	uvm_sequencer #(drv_item) sequencer_inst;

	function new(string name, uvm_component parent = null);
	    super.new(name,parent);
	 endfunction

	function void build_phase(uvm_phase phase);
  		driver_inst = Driver ::type_id::create($sformatf("driver_inst"),this);
  		driver_inst.set_report_verbosity_level(UVM_LOW);
  		monitor_inst = Monitor::type_id::create($sformatf("monitor_inst"),this);
  		monitor_inst.set_report_verbosity_level(UVM_MEDIUM);
  		sequencer_inst = uvm_sequencer #(drv_item)::type_id::create($sformatf("sequencer_inst"), this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
	endfunction

	virtual task run_phase(uvm_phase phase);
   		super.run_phase(phase);
   		

   	endtask : run_phase
	



endclass // Agent

