//-------------------------------------------------------------------------
//						mbc_ctrl_monitor
//-------------------------------------------------------------------------

class mbc_ctrl_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual mbc_ctrl_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(mbc_ctrl_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  mbc_ctrl_seq_item trans_collected;
  bit is_active;

  `uvm_component_utils(mbc_ctrl_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
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
    if(!uvm_config_db#(virtual mbc_ctrl_if)::get(this, "", "mbc_ctrl_if",vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.clk);
      wait(vif.monitor_cb.mem_rdy ||
           vif.monitor_cb.r_w     ||
           vif.monitor_cb.b       ||
           vif.monitor_cb.h       ||
           vif.monitor_cb.enable  ||
           vif.monitor_cb.error_drs);
      if (is_active == 1) begin
        trans_collected.r_w    = vif.monitor_cb.r_w;
      	trans_collected.b      = vif.monitor_cb.b;
      	trans_collected.h      = vif.monitor_cb.h;
        trans_collected.enable = vif.monitor_cb.enable;
      end
      else begin
      	trans_collected.mem_rdy   = vif.monitor_cb.mem_rdy;
        trans_collected.error_drs = vif.monitor_cb.error_drs;
      end
      item_collected_port.write(trans_collected);
    end 
  endtask : run_phase

endclass : mbc_ctrl_monitor
