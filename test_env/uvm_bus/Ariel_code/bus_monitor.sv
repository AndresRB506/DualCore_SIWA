class bus_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual bus_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(bus_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  bus_seq_item trans_collected;

  `uvm_component_utils(bus_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      
      @(posedge vif.MONITOR.clk);
      $display("valor monitor1 pndng_mbc:", vif.monitor_cb.pndng_mbc);
      $display("valor monitor1 pndng_spi:", vif.monitor_cb.pndng_spi);
      $display("valor monitor1 pndng_uart:", vif.monitor_cb.pndng_uart);
      if(vif.monitor_cb.pndng_mbc==1 && vif.monitor_cb.push_mbc==1) begin
        trans_collected.D_push_mbc = vif.monitor_cb.D_push_mbc;
        trans_collected.pndng_mbc = vif.monitor_cb.pndng_mbc;
        trans_collected.push_mbc = vif.monitor_cb.push_mbc;
        trans_collected.pop_mbc = vif.monitor_cb.pop_mbc;
        //$display("Monitor Data MBC: %h",vif.monitor_cb.D_push_mbc);
        $display("valor monitor pndng_mbc:", vif.monitor_cb.pndng_mbc);
      
        @(posedge vif.MONITOR.clk);
        $display("------------------------CAMBIOM1-----------------------------------");
      end
      if(vif.monitor_cb.pndng_spi==1 && vif.monitor_cb.push_spi==1) begin
        trans_collected.D_push_spi = vif.monitor_cb.D_push_spi;
        trans_collected.pndng_spi = vif.monitor_cb.pndng_spi;
        trans_collected.push_spi = vif.monitor_cb.push_spi;
        trans_collected.pop_spi = vif.monitor_cb.pop_spi;
        //$display("Monitor Data SPI: %h",vif.monitor_cb.D_push_spi);
        $display("valor monitor pndng_spi:", vif.monitor_cb.pndng_spi);
      
        @(posedge vif.MONITOR.clk);
        $display("------------------------CAMBIOM2-----------------------------------");
      end
      if(vif.monitor_cb.pndng_uart==1 && vif.monitor_cb.push_uart==1) begin
        trans_collected.D_push_uart = vif.monitor_cb.D_push_uart;
        trans_collected.pndng_uart = vif.monitor_cb.pndng_uart;
        trans_collected.push_uart = vif.monitor_cb.push_uart;
        trans_collected.pop_uart = vif.monitor_cb.pop_uart;
        //$display("Monitor Data UART: %h",vif.monitor_cb.D_push_uart);
        $display("valor monitor pndng_uart:", vif.monitor_cb.pndng_uart);
        @(posedge vif.MONITOR.clk);
      end
     
	  item_collected_port.write(trans_collected);
      end 
  endtask : run_phase

endclass : bus_monitor
