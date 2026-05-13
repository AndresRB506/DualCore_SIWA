//-------------------------------------------------------------------------
//						bus_seq_item          
//-------------------------------------------------------------------------

class bus_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  
  rand bit pndng;
  rand bit [61:0] d_pop;
  rand bit pop_mbc;
  //rand bit full; //scrapped signal
  rand bit [63:0] d_psh;
  rand bit psh;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(bus_seq_item)
    `uvm_field_int(pndng,UVM_ALL_ON)
    `uvm_field_int(d_pop,UVM_ALL_ON)
    `uvm_field_int(pop_mbc,UVM_ALL_ON)
    //`uvm_field_int(full,UVM_ALL_ON)
    `uvm_field_int(d_psh,UVM_ALL_ON)
    `uvm_field_int(psh,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "bus_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint wr_rd_c { wr_en != rd_en; };
  
endclass
