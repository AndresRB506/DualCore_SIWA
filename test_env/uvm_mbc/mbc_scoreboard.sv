//-------------------------------------------------------------------------
//						mbc_scoreboard - 
//-------------------------------------------------------------------------

//these are used to "implement" multiple write functions
`uvm_analysis_imp_decl(_tx_bus)
`uvm_analysis_imp_decl(_rx_bus)
`uvm_analysis_imp_decl(_tx_mbc_ctrl)
`uvm_analysis_imp_decl(_rx_mbc_ctrl)
`uvm_analysis_imp_decl(_tx_mbc_cpu)
`uvm_analysis_imp_decl(_rx_mbc_cpu)

class mbc_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu's to store the pkt's recived from monitor
  //---------------------------------------
  bus_seq_item       tx_bus_pkt_queue[$];
  bus_seq_item       rx_bus_pkt_queue[$];
  mbc_ctrl_seq_item  tx_mbc_ctrl_pkt_queue[$];
  mbc_ctrl_seq_item  rx_mbc_ctrl_pkt_queue[$];
  mbc_cpu_seq_item   tx_mbc_cpu_pkt_queue[$];
  mbc_cpu_seq_item   rx_mbc_cpu_pkt_queue[$];

  //---------------------------------------
  //ports to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp_tx_bus#(bus_seq_item, mbc_scoreboard) tx_bus_item_collected_export;
  uvm_analysis_imp_rx_bus#(bus_seq_item, mbc_scoreboard) rx_bus_item_collected_export;
  uvm_analysis_imp_tx_mbc_ctrl#(mbc_ctrl_seq_item, mbc_scoreboard) tx_ctrl_item_collected_export;
  uvm_analysis_imp_rx_mbc_ctrl#(mbc_ctrl_seq_item, mbc_scoreboard) rx_ctrl_item_collected_export;
  uvm_analysis_imp_tx_mbc_cpu#(mbc_cpu_seq_item, mbc_scoreboard) tx_cpu_item_collected_export;
  uvm_analysis_imp_rx_mbc_cpu#(mbc_cpu_seq_item, mbc_scoreboard) rx_cpu_item_collected_export;
  //uvm_analysis_imp#(mbc_seq_item, mbc_scoreboard) tx_intr_item_collected_export;
  //uvm_analysis_imp#(mbc_seq_item, mbc_scoreboard) rx_intr_item_collected_export;
  
  `uvm_component_utils(mbc_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create ports
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      tx_bus_item_collected_export = new("tx_bus_item_collected_export", this);
      rx_bus_item_collected_export = new("rx_bus_item_collected_export", this);
      tx_ctrl_item_collected_export = new("tx_ctrl_item_collected_export", this);
      rx_ctrl_item_collected_export = new("rx_ctrl_item_collected_export", this);
      tx_cpu_item_collected_export = new("tx_cpu_item_collected_export", this);
      rx_cpu_item_collected_export = new("rx_cpu_item_collected_export", this);
      //tx_intr_item_collected_export = new("tx_intr_item_collected_export", this);
      //rx_intr_item_collected_export = new("rx_intr_item_collected_export", this);
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the bus pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_tx_bus(bus_seq_item pkt);
    //pkt.print();
    tx_bus_pkt_queue.push_back(pkt);
  endfunction : write_tx_bus

  //---------------------------------------
  // write task - recives the bus pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_rx_bus(bus_seq_item pkt);
    //pkt.print();
    rx_bus_pkt_queue.push_back(pkt);
  endfunction : write_rx_bus

  //---------------------------------------
  // write task - recives the mbc_ctrl pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_tx_mbc_ctrl(mbc_ctrl_seq_item pkt);
    //pkt.print();
    tx_mbc_ctrl_pkt_queue.push_back(pkt);
  endfunction : write_tx_mbc_ctrl

  //---------------------------------------
  // write task - recives the mbc_ctrl pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_rx_mbc_ctrl(mbc_ctrl_seq_item pkt);
    //pkt.print();
    rx_mbc_ctrl_pkt_queue.push_back(pkt);
  endfunction : write_rx_mbc_ctrl

  //---------------------------------------
  // write task - recives the mbc_cpu pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_tx_mbc_cpu(mbc_cpu_seq_item pkt);
    //pkt.print();
    tx_mbc_cpu_pkt_queue.push_back(pkt);
  endfunction : write_tx_mbc_cpu

  //---------------------------------------
  // write task - recives the mbc_cpu pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_rx_mbc_cpu(mbc_cpu_seq_item pkt);
    //pkt.print();
    rx_mbc_cpu_pkt_queue.push_back(pkt);
  endfunction : write_rx_mbc_cpu

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    //mbc_seq_item mbc_pkt;
    
    forever begin
      //wait(pkt_queue.size() > 0);
      //mbc_pkt = pkt_queue.pop_front();
      
// The predictive reference model goes here
      
    end
  endtask : run_phase
endclass : mbc_scoreboard
