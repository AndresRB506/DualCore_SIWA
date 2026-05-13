class bus_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit [64:0] D_push_mbc;
  rand bit [64:0] D_push_spi;
  rand bit [64:0] D_push_uart;
  rand bit [64:0] D_push_anlg;
  rand bit       pndng_mbc;
  rand bit       pndng_spi;
  rand bit       pndng_uart;
  rand bit       pndng_anlg;
  rand bit       push_mbc;
  rand bit       push_spi;
  rand bit       push_uart;
  rand bit       push_anlg;
  rand bit       pop_mbc;
  rand bit       pop_spi;
  rand bit       pop_uart;
  rand bit       pop_anlg;
       bit [64:0] D_pop_mbc;
       bit [64:0] D_pop_spi;
       bit [64:0] D_pop_uart;
       bit [64:0] D_pop_anlg;

    

  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(bus_seq_item)
  `uvm_field_int(D_push_mbc,UVM_ALL_ON)
  `uvm_field_int(D_push_spi,UVM_ALL_ON)
  `uvm_field_int(D_push_uart,UVM_ALL_ON)
  `uvm_field_int(pndng_mbc,UVM_ALL_ON)
  `uvm_field_int(pndng_spi,UVM_ALL_ON)
  `uvm_field_int(pndng_uart,UVM_ALL_ON)
  `uvm_field_int(push_mbc,UVM_ALL_ON)
  `uvm_field_int(push_spi,UVM_ALL_ON)
  `uvm_field_int(push_uart,UVM_ALL_ON)
  `uvm_field_int(pop_mbc,UVM_ALL_ON)
  `uvm_field_int(pop_spi,UVM_ALL_ON)
  `uvm_field_int(pop_uart,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "bus_seq_item");
    super.new(name);
  endfunction
  

  
  
endclass