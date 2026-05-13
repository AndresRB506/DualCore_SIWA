//=========================================================================
// bus sequence library 
//=========================================================================
class bus_random_base_sequence extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_random_base_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "bus_random_base_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    req = bus_seq_item::type_id::create("req");
    `uvm_do(req)
  endtask
endclass
