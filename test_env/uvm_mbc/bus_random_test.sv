//-------------------------------------------------------------------------
//						bus_random_test  
//-------------------------------------------------------------------------
class bus_random_test extends bus_model_base_test;

  `uvm_component_utils(bus_random_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  bus_random_base_sequence seq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "bus_random_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    seq = bus_random_base_sequence::type_id::create("seq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
      seq.start(env.bus_agent.sequencer);
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : bus_random_test