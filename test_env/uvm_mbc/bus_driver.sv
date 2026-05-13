//-------------------------------------------------------------------------
//						bus_driver
//-------------------------------------------------------------------------

class bus_driver extends uvm_driver #(bus_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual bus_if vif;
  `uvm_component_utils(bus_driver)
    
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
    if(!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if",vif))
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
    
      vif.driver_cb.pndng  <= req.pndng;
      vif.driver_cb.d_pop  <= req.d_pop;
      //vif.driver_cb.full   <= req.full;
    
  endtask : drive
endclass : bus_driver
