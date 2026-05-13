//=========================================================================
// mbc_cpu sequence library 
//=========================================================================
class mbc_cpu_random_base_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(mbc_cpu_random_base_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_cpu_random_base_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    req = mbc_cpu_seq_item::type_id::create("req");
    `uvm_do(req)
  endtask
endclass
