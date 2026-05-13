class bus_device_uart_test extends bus_model_base_test;

  `uvm_component_utils(bus_device_uart_test)
  
   device_uart seq;

  
  function new(string name = "bus_device_uart_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    seq = device_uart::type_id::create("seq");
  endfunction : build_phase
  
   task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
     seq.start(env.bus_agnt.sequencer);
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : bus_device_uart_test