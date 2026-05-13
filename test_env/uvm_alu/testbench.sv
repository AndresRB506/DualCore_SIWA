//`include "../../TEC_RISCV/ALU/design.sv"
//`include "design.sv"
//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//---------------------------------------------------------------
//including interfcae and testcase files
`include "alu_interface.sv"
`include "alu_model_base_test.sv"
`include "tests.sv"

//---------------------------------------------------------------

module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  alu_if intf();
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  ALU_2 DUT (
    .A(intf.Data_A),
    .B(intf.Data_B),
    .Alu_Cntrl(intf.ALU_CTRL),
    .OUT(intf.result),
    .oVerflow(intf.Overflow),
    .Zero(intf.Zero),
    .Carry(intf.Carry),
    .Negative(intf.Negative),
    .Cin(intf.Cin)
   );
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual alu_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end
endmodule