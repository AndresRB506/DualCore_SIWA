//-------------------------------------------------------------------------
//						alu_env - www.verificationguide.com
//-------------------------------------------------------------------------

`include "alu_agent.sv"
`include "alu_scoreboard.sv"

class alu_model_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  alu_agent      alu_agnt;
  alu_scoreboard alu_scb;
  
  `uvm_component_utils(alu_model_env)
  
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

    alu_agnt = alu_agent::type_id::create("alu_agnt", this);
    alu_scb  = alu_scoreboard::type_id::create("alu_scb", this);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    alu_agnt.monitor.item_collected_port.connect(alu_scb.item_collected_export);
  endfunction : connect_phase

endclass : alu_model_env