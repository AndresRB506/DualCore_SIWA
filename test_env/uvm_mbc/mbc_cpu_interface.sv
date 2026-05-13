//-------------------------------------------------------------------------
//						mbc_cpu_interface
//-------------------------------------------------------------------------

interface mbc_cpu_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - mbc_cpu Interface - 
  	logic [25:0] address;
  	logic [31:0] d_write;
  	logic [31:0] d_read;
  
    // this signals has been scrapped
    //logic meie; //?
    //logic mtie; //?
    //logic csr_io; //?
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    output address;
    output d_write;
    input  d_read;
    //output meie;
    //output mtie;
    //output csr_io;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input address;
    input d_write;
    input d_read;
    //input meie;
    //input mtie;
    //input csr_io;
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