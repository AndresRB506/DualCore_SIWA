//-------------------------------------------------------------------------
//						bus_interface that can connect to several modules
//-------------------------------------------------------------------------

interface bus_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - Bus Interface - 
    logic pndng;
    logic [61:0] d_pop; //why is it different than data_push?
    logic pop_mbc;
    //logic full; //this signal has been scrapped
    logic [63:0] d_psh;
    logic psh;
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    output pndng;
    output d_pop;
    input  pop_mbc;
    //output full;
    input  d_psh;
    input  psh;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input pndng;
    input d_pop;
    input pop_mbc;
    //input full;
    input d_psh;
    input psh;
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