//-------------------------------------------------------------------------
//						mbc_ctrl_interface
//-------------------------------------------------------------------------

interface mbc_ctrl_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - mbc_ctrl Interface - 
    logic mem_rdy;
    logic r_w;
    logic b;
    logic h;
    logic enable;
    logic error_drs;
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    input  mem_rdy;
    output r_w;
    output b;
    output h;
    output enable;
    input  error_drs;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input mem_rdy;
    input r_w;
    input b;
    input h;
    input enable;
    input error_drs;
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
endinterface
