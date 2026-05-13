//=========================================================================
// mbc_ctrl sequence library 
//=========================================================================
class mbc_ctrl_random_base_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_random_base_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_random_base_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    req = mbc_ctrl_seq_item::type_id::create("req");
    `uvm_do(req)
  endtask
endclass
