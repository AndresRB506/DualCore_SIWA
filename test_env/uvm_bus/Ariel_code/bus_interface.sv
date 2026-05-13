interface bus_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic [64:0] D_push_mbc;
  logic [64:0] D_push_spi;
  logic [64:0] D_push_uart;
  logic pndng_mbc;
  logic pndng_spi;
  logic pndng_uart;
  logic push_mbc;
  logic push_spi;
  logic push_uart;
  logic pop_mbc;
  logic pop_spi;
  logic pop_uart;
  logic [64:0] D_pop_mbc;
  logic [64:0] D_pop_spi;
  logic [64:0] D_pop_uart;


  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output D_push_mbc;
    output D_push_spi;
    output D_push_uart;
    input pndng_mbc;
    input pndng_spi;
    input pndng_uart;
    output push_mbc;
    output push_spi;
    output push_uart;
    output pop_mbc;
    output pop_spi;
    output pop_uart;
    input  D_pop_mbc;
    input  D_pop_spi; 
    input  D_pop_uart; 
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input pndng_mbc;
    input pndng_spi;
    input pndng_uart;
    input push_mbc;
    input push_spi;
    input push_uart;
    input pop_mbc;
    input pop_spi;
    input pop_uart;
    input D_push_mbc;
    input D_push_spi;
    input D_push_uart;
    input D_pop_mbc;  
    input D_pop_spi;
    input D_pop_uart;
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