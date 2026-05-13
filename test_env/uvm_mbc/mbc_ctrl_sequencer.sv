//-------------------------------------------------------------------------
//						mbc_ctrl_sequencer - 
//-------------------------------------------------------------------------

class mbc_ctrl_sequencer extends uvm_sequencer#(mbc_ctrl_seq_item);

  `uvm_component_utils(mbc_ctrl_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass