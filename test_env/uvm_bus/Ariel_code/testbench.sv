// Code your testbench here
// or browse Examples
//including interfcae and testcase files
`include "bus_interface.sv"
`include "bus_base_test.sv"
`include "bus_device_mbc_test.sv"
`include "bus_device_spi_test.sv"
`include "bus_device_uart_test.sv"
`include "bus_device_mbctospi_test.sv"
`include "bus_device_mbctouart_test.sv"
`include "bus_device_spitombc_test.sv"
`include "bus_device_spitouart_test.sv"
`include "bus_device_uarttombc_test.sv"
`include "bus_device_uarttospi_test.sv"


//---------------------------------------------------------------

module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit reset;
  wire pndng_mbc;
  wire pndng_spi;
  wire pndng_uart;

  bit  push_mbc;
  bit  push_spi;
  bit  push_uart;

  bit  pop_mbc;
  bit  pop_spi;
  bit  pop_uart;

  wire  [64:0] D_pop_mbc;
  wire  [64:0] D_pop_spi;
  wire  [64:0] D_pop_uart;

  logic [64:0] D_push_mbc;
  logic [64:0] D_push_spi;
  logic [64:0] D_push_uart;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset = 1;
    push_mbc = 0;
    push_spi = 0;
    push_uart = 0;
    pop_mbc = 0;
    pop_spi = 0;
    pop_uart = 0;
    D_push_mbc = 0;
    D_push_spi = 0;
    D_push_uart = 0;
    #50 reset =0;
    /*push_mbc = 1;
    D_push_mbc = 50;
    #5
    push_mbc = 0;
    D_push_mbc = 0;*/
  end
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  bus_if intf(clk,reset);
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  tec_riscv_bus DUT (
    .clk(intf.clk),
    .reset(intf.reset),
    .pndng_mbc(pndng_mbc),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),
    .push_mbc(intf.push_mbc),
    .push_spi(intf.push_spi),
    .push_uart(intf.push_uart),
    .pop_mbc(intf.pop_mbc),
    .pop_spi(intf.pop_spi),
    .pop_uart(intf.pop_uart),
    .D_pop_mbc(intf.D_pop_mbc),
    .D_pop_spi(intf.D_pop_spi),
    .D_pop_uart(intf.D_pop_uart),
    .D_push_mbc(intf.D_push_mbc),
    .D_push_spi(intf.D_push_spi),
    .D_push_uart(intf.D_push_uart)

    /*.clk(clk),
    .reset(reset),
    .pndng_mbc(pndng_mbc),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),*/
    /*.push_mbc(push_mbc),
    .push_spi(push_spi),
    .push_uart(push_uart),*/
    /*.pop_mbc(pop_mbc),
    .pop_spi(pop_spi),
    .pop_uart(pop_uart)*/
    /*.D_pop_mbc(D_pop_mbc),
    .D_pop_spi(D_pop_spi),
    .D_pop_uart(D_pop_uart),*/
    /*.D_push_mbc(D_push_mbc),
    .D_push_spi(D_push_spi),
    .D_push_uart(D_push_uart)*/
  );

 
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual bus_if)::set(uvm_root::get(),"*","vif",intf);
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