//-------------------------------------------------------------------------
//						mbc_env - 
//-------------------------------------------------------------------------

`include "bus_agent.sv"
`include "mbc_ctrl_agent.sv"
`include "mbc_cpu_agent.sv"
//`include "mbc_intr_agent.sv"
`include "mbc_scoreboard.sv"

class mbc_model_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instances
  //---------------------------------------
  
  //there is one agent for each interface
  bus_agent          mbc_tx_bus_agent_inst;
  bus_agent          mbc_rx_bus_agent_inst;
  mbc_ctrl_agent     mbc_tx_ctrl_agent_inst;
  mbc_ctrl_agent     mbc_rx_ctrl_agent_inst;
  mbc_cpu_agent      mbc_tx_cpu_agent_inst;
  mbc_cpu_agent      mbc_rx_cpu_agent_inst;
  //mbc_tx_intr_agent  mbc_tx_intr_agent_inst;//these are no longer used
  //mbc_rx_intr_agent  mbc_rx_intr_agent_inst;
  
  mbc_scoreboard     mbc_scb;
  
  `uvm_component_utils(mbc_model_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - create the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mbc_tx_bus_agent_inst  = bus_agent::type_id::create("mbc_tx_bus_agent_inst", this);
    mbc_rx_bus_agent_inst  = bus_agent::type_id::create("mbc_rx_bus_agent_inst", this);
    mbc_tx_ctrl_agent_inst = mbc_ctrl_agent::type_id::create("mbc_tx_ctrl_agent_inst", this);
    mbc_rx_ctrl_agent_inst = mbc_ctrl_agent::type_id::create("mbc_rx_ctrl_agent_inst", this);
    mbc_tx_cpu_agent_inst  = mbc_cpu_agent::type_id::create("mbc_tx_cpu_agent_inst", this);
    mbc_rx_cpu_agent_inst  = mbc_cpu_agent::type_id::create("mbc_rx_cpu_agent_inst", this);
    //mbc_tx_intr_agent_inst = mbc_tx_intr_agent::type_id::create("mbc_tx_intr_agent_inst", this);
    //mbc_rx_intr_agent_inst = mbc_rx_intr_agent::type_id::create("mbc_rx_intr_agent_inst", this);
    mbc_scb  = mbc_scoreboard::type_id::create("mbc_scb", this);
    
    //set_config_int(mbc_tx_bus_agent_inst,  "is_active", UVM_ACTIVE);
    //set_config_int(mbc_tx_ctrl_agent_inst, "is_active", UVM_ACTIVE);
    //set_config_int(mbc_tx_cpu_agent_inst,  "is_active", UVM_ACTIVE);
    //set_config_int(mbc_tx_intr_agent_inst, "is_active", UVM_ACTIVE);
    
    //set_config_int(mbc_rx_bus_agent_inst,  "is_active", UVM_PASSIVE);
    //set_config_int(mbc_rx_ctrl_agent_inst, "is_active", UVM_PASSIVE);
    //set_config_int(mbc_rx_cpu_agent_inst,  "is_active", UVM_PASSIVE);
    //set_config_int(mbc_rx_intr_agent_inst, "is_active", UVM_PASSIVE);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitors and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    mbc_tx_bus_agent_inst.monitor.item_collected_port.connect(mbc_scb.tx_bus_item_collected_export);
    mbc_rx_bus_agent_inst.monitor.item_collected_port.connect(mbc_scb.rx_bus_item_collected_export);
    mbc_tx_ctrl_agent_inst.monitor.item_collected_port.connect(mbc_scb.tx_ctrl_item_collected_export);
    mbc_rx_ctrl_agent_inst.monitor.item_collected_port.connect(mbc_scb.rx_ctrl_item_collected_export);
    mbc_tx_cpu_agent_inst.monitor.item_collected_port.connect(mbc_scb.tx_cpu_item_collected_export);
    mbc_rx_cpu_agent_inst.monitor.item_collected_port.connect(mbc_scb.rx_cpu_item_collected_export);
    //bc_tx_intr_agent_inst.monitor.item_collected_port.connect(mbc_scb.tx_intr_item_collected_export);
    //mbc_rx_intr_agent_inst.monitor.item_collected_port.connect(mbc_scb.rx_intr_item_collected_export);
  endfunction : connect_phase

endclass : mbc_model_env
