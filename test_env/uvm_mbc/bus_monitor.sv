//-------------------------------------------------------------------------
//						bus_monitor
//-------------------------------------------------------------------------

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
  bit is_active;

  `uvm_component_utils(bus_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
    //is_active = new();
    /*if (parent.is_active == UVM_ACTIVE) begin
      is_active = 1;
    end
    else begin
      is_active = 0;
    end*/
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if",vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.clk);
      wait(vif.monitor_cb.pndng   ||
           vif.monitor_cb.pop_mbc ||
           //vif.monitor_cb.full    ||
           vif.monitor_cb.psh);
      if (is_active == 1) begin
        trans_collected.pndng  = vif.monitor_cb.pndng;
      	trans_collected.d_pop  = vif.monitor_cb.d_pop;
      	//trans_collected.full   = vif.monitor_cb.full;
      end
      else begin
      	trans_collected.pop_mbc = vif.monitor_cb.pop_mbc;
      	trans_collected.d_psh   = vif.monitor_cb.d_psh;
      	trans_collected.psh     = vif.monitor_cb.psh;
      end
      item_collected_port.write(trans_collected);
    end 
  endtask : run_phase

endclass : bus_monitor
