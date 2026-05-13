//-------------------------------------------------------------------------
//						mbc_ctrl_agent
//-------------------------------------------------------------------------

`include "mbc_ctrl_seq_item.sv"
`include "mbc_ctrl_sequencer.sv"
`include "mbc_ctrl_sequence_lib.sv"
`include "mbc_ctrl_driver.sv"
`include "mbc_ctrl_monitor.sv"

class mbc_ctrl_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  mbc_ctrl_driver     driver;
  mbc_ctrl_sequencer  sequencer;
  mbc_ctrl_monitor    monitor;

  `uvm_component_utils(mbc_ctrl_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = mbc_ctrl_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = mbc_ctrl_driver::type_id::create("driver", this);
      sequencer = mbc_ctrl_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : mbc_ctrl_agent
