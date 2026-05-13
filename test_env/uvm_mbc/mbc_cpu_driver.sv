//-------------------------------------------------------------------------
//						mbc_cpu_driver
//-------------------------------------------------------------------------

class mbc_cpu_driver extends uvm_driver #(mbc_cpu_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual mbc_cpu_if vif;
  `uvm_component_utils(mbc_cpu_driver)
    
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
    if(!uvm_config_db#(virtual mbc_cpu_if)::get(this, "", "mbc_cpu_if",vif))
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
    
      vif.driver_cb.address   <= req.address;
      vif.driver_cb.d_write   <= req.d_write;
      //vif.driver_cb.meie   <= req.meie;
      //vif.driver_cb.mtie   <= req.mtie;
      //vif.driver_cb.csr_io <= req.cr_io;
    
  endtask : drive
endclass : mbc_cpu_driver
