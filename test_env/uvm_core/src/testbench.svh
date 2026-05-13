`timescale 1ns/10ps
`include "uvm_macros.svh"
import uvm_pkg::*;
// Predictor Files //
`include "../support/Reference_Model.sv"

// Enviroment Files //
`include "Reg_General.svh"
`include "Reg_CSR.svh"

`include "wrapper_if.svh"
`include "RTL_MEM_Wrapper.svh"
`include "Test_Item.svh"
`include "coverage_classes.svh"
`include "Driver.svh"
`include "Monitor.svh"
`include "Monitor_cov.svh"
`include "Scoreboard.svh"
`include "Sequence.svh"
`include "Agent.svh"
`include "Agent_Cov.svh"
`include "Enviroment.svh"
`include "test_base.svh"


module tb_top;
  //import uvm_pkg::*;
  //import test::*;
  
  bit clk_tb;
  always #5 clk_tb <= ~clk_tb;
  
  wrapper_if dut_if(clk_tb);
  RTL_MEM_Wrapper dut_wr (._if (dut_if));
  csr_reg_block ral_csr;
  reg_file_block ral_general;


  initial begin
    uvm_config_db#(virtual wrapper_if)::set(null, "*","v_if", dut_if);
    ral_csr = new();
    ral_csr.build();
    uvm_config_db#(csr_reg_block)::set(null, "*","ral_csr", ral_csr);
    ral_general = new();
    ral_general.build();
    uvm_config_db#(reg_file_block)::set(null, "*","ral_general", ral_general);



    run_test("test_base");
  end
  
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0,tb_top);
  end
  
endmodule
