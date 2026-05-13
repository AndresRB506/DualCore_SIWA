//-------------------------------------------------------------------------
//						alu_seq_item - www.verificationguide.com 
//-------------------------------------------------------------------------

class alu_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit [31:0] Data_A;
  rand bit [31:0] Data_B;
  rand bit [3:0]  ALU_CTRL;
  rand bit Cin;
  bit [31:0] result;
  bit Overflow;
  bit Carry;
  bit Negative;
  bit Zero;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(alu_seq_item)
  `uvm_field_int(Data_A,UVM_ALL_ON)
  `uvm_field_int(Data_B,UVM_ALL_ON)
  `uvm_field_int(ALU_CTRL,UVM_ALL_ON)
  `uvm_field_int(Cin,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "alu_seq_item");
    super.new(name);
  endfunction
  constraint ajuste {
    //ALU_CTRL<=4'b1101;
    //ALU_CTRL>=4'b0000;
  }
  constraint Valores{
    
    }
  
  
endclass
