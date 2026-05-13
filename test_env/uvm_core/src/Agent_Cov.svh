class Agent_cov extends  uvm_agent;
	`uvm_component_utils(Agent_cov);
	string name = "Agent_cov";

	Monitor_cov monitor_inst;

	function new(string name, uvm_component parent = null);
	    super.new(name,parent);
	 endfunction

	function void build_phase(uvm_phase phase);
  		monitor_inst = Monitor_cov::type_id::create($sformatf("monitor_inst"),this);
  		monitor_inst.set_report_verbosity_level(UVM_MEDIUM);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
	endfunction

	virtual task run_phase(uvm_phase phase);
   		super.run_phase(phase);
   	endtask : run_phase
	



endclass // Agent