//-------------------------------------------------------------------------
//						mbc_cpu_sequencer - 
//-------------------------------------------------------------------------

class mbc_cpu_sequencer extends uvm_sequencer#(mbc_cpu_seq_item);

  `uvm_component_utils(mbc_cpu_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass