//-------------------------------------------------------------------------
//						alu_driver - www.verificationguide.com
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.driver_cb

class alu_driver extends uvm_driver #(alu_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual alu_if vif;
  `uvm_component_utils(alu_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    
    @(posedge vif.DRIVER.clk);
    vif.ALU_CTRL <= req.ALU_CTRL;
    vif.Data_A <= req.Data_A;
    vif.Data_B <= req.Data_B;
    vif.Cin <= req.Cin;
    
    
  endtask : drive
endclass : alu_driver
