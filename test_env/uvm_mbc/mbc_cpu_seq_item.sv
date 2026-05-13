//-------------------------------------------------------------------------
//						mbc_cpu_seq_item          
//-------------------------------------------------------------------------

class mbc_cpu_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  
  rand bit [25:0] address;
  rand bit [31:0] d_write;
  rand bit [31:0] d_read;
  /*rand bit meie; //scrapped signals
  rand bit mtie;
  rand bit csr_io;*/
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(mbc_cpu_seq_item)
  	`uvm_field_int(address,UVM_ALL_ON)
  	`uvm_field_int(d_write,UVM_ALL_ON)
  	`uvm_field_int(d_read,UVM_ALL_ON)
    /*`uvm_field_int(meie,UVM_ALL_ON)
  	`uvm_field_int(mtie,UVM_ALL_ON)
  	`uvm_field_int(csr_io,UVM_ALL_ON)*/
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_cpu_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint wr_rd_c { wr_en != rd_en; };
  
endclass
