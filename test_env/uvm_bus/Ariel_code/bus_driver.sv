`define DRIV_IF vif.DRIVER.driver_cb

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
    if(!uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif))
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
    `DRIV_IF.push_mbc <= 0;
    `DRIV_IF.push_spi <= 0;
    `DRIV_IF.push_uart <= 0;
    `DRIV_IF.D_push_mbc <= 0;
    `DRIV_IF.D_push_spi <= 0;
    `DRIV_IF.D_push_uart <= 0;
    `DRIV_IF.pop_mbc <= 0;
    `DRIV_IF.pop_spi <= 0;
    `DRIV_IF.pop_uart <= 0;
    @(posedge vif.DRIVER.clk);
    
    `DRIV_IF.push_mbc <= req.push_mbc;
    //`DRIV_IF.pndng_mbc <= req.pndng_mbc;
    `DRIV_IF.D_push_mbc <= req.D_push_mbc;
    `DRIV_IF.pop_mbc <= req.pop_mbc;
    $display("valor driver pndng_mbc:", req.pndng_mbc);
    $display("valor driver push_mbc:", req.push_mbc);
    
    
  
    @(posedge vif.DRIVER.clk);
    $display("------------------------CAMBIOD1-----------------------------------");
    
    //`DRIV_IF.pndng_spi<= req.pndng_spi;
    `DRIV_IF.push_spi<= req.push_spi;
    `DRIV_IF.D_push_spi<= req.D_push_spi;
    `DRIV_IF.pop_spi <= req.pop_spi;
    $display("valor driver pndng_spi:", vif.monitor_cb.pndng_spi);
    
     @(posedge vif.DRIVER.clk);
    $display("------------------------CAMBIOD2-----------------------------------");
    //`DRIV_IF.pndng_uart <= req.pndng_uart;
    `DRIV_IF.push_uart <= req.push_uart;
    `DRIV_IF.D_push_uart <= req.D_push_uart;
    `DRIV_IF.pop_uart <= req.pop_uart;
    $display("valor driver pndng_uart:", vif.monitor_cb.pndng_uart);
    
  endtask : drive
endclass : bus_driver