`include "bus_agent.sv"
`include "bus_scoreboard.sv"

class bus_model_env extends uvm_env;

  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  bus_agent      bus_agnt;
  bus_scoreboard bus_scb;
  
  `uvm_component_utils(bus_model_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    bus_agnt = bus_agent::type_id::create("bus_agnt", this);
    bus_scb  = bus_scoreboard::type_id::create("bus_scb", this);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    bus_agnt.monitor.item_collected_port.connect(bus_scb.item_collected_export);
  endfunction : connect_phase

endclass : bus_model_env