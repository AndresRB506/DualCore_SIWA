//-------------------------------------------------------------------------
//						mbc_cpu_seq_item          
//-------------------------------------------------------------------------

class mbc_ctrl_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  
  rand bit mem_rdy;
  rand bit r_w;
  rand bit b;
  rand bit h;
  rand bit enable;
  rand bit error_drs;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(mbc_ctrl_seq_item)
    `uvm_field_int(mem_rdy,UVM_ALL_ON)
    `uvm_field_int(r_w,UVM_ALL_ON)
    `uvm_field_int(b,UVM_ALL_ON)
    `uvm_field_int(h,UVM_ALL_ON)
  	`uvm_field_int(enable,UVM_ALL_ON)
    `uvm_field_int(error_drs,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint wr_rd_c { wr_en != rd_en; };
  
endclass
