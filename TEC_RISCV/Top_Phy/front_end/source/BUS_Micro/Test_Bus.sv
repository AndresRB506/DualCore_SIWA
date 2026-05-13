`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 65 
`define BROADCAST {3{1'b1}}
`define DRVRS 4
`define MAX_MSGS 1024
`include "Bus_Micro.sv"

module Sim_bs_systm;
 //inputs
  logic clk;
  logic reset;
  logic push_mbc;
  logic push_spi;
  logic push_uart;
  logic push_anlg;
  logic pop_mbc;
  logic pop_spi;
  logic pop_uart;
  logic pop_anlg;
  logic [64:0] D_push_mbc;
  logic [64:0] D_push_spi;
  logic [64:0] D_push_uart;
  logic [64:0] D_push_anlg;
 //outputs
  wire  [64:0] D_pop_mbc;
  wire  [64:0] D_pop_spi;
  wire  [64:0] D_pop_uart;
  wire  [64:0] D_pop_anlg;
  wire  pndng_mbc;
  wire  pndng_spi;
  wire  pndng_uart;
  wire  pndng_anlg;

 tec_riscv_bus  uut(
  .clk(clk),
  .reset(reset),
  .pndng_mbc(pndng_mbc),
  .pndng_spi(pndng_spi),
  .pndng_uart(pndng_uart),
  .pndng_anlg(pndng_anlg),
  .push_mbc(push_mbc),
  .push_spi(push_spi),
  .push_uart(push_uart),
  .push_anlg(push_anlg),
  .pop_mbc(pop_mbc),
  .pop_spi(pop_spi),
  .pop_uart(pop_uart),
  .pop_anlg(pop_anlg),
  .D_pop_mbc(D_pop_mbc),
  .D_pop_spi(D_pop_spi),
  .D_pop_uart(D_pop_uart),
  .D_pop_anlg(D_pop_anlg),
  .D_push_mbc(D_push_mbc),
  .D_push_spi(D_push_spi),
  .D_push_uart(D_push_uart),
  .D_push_anlg(D_push_anlg)
);

 //varibles used for testing
  reg [2:0] target;
  reg [1:0] source;
  int mensages_enviados = 0;
  reg [1:0]pushed_mbc=0;

initial begin
  clk=0;
  reset=1;
  target = 0;
  source =0;
  push_mbc=0;
  push_spi=0;
  push_uart=0;
  push_anlg=0;
  pop_mbc=0;
  pop_spi=0;
  pop_uart=0;
  pop_anlg=0;
  D_push_mbc=0;
  D_push_spi=0;
  D_push_uart=0;
  D_push_anlg=0;
end

  always #1 clk=~clk;   
  always @(posedge clk)begin
    prueba();
  end
  
  task prueba ();
    if($time > 3) begin
      reset = 0;
      source = 0;
      pop_mbc =0;
      pop_spi=0;
      pop_anlg=0;
      pop_uart=0;
        D_push_mbc = {target,source,{60{1'b0}}};
        if(pushed_mbc[0]) begin 
          if(pushed_mbc[1])begin
            push_mbc=0;
          end else begin
            push_mbc=1;
            pushed_mbc[1] = 1;
          end
        end else begin
            target++;
            pushed_mbc[0] = 1;
        end
     
       if (Sim_bs_systm.uut.pop_mbc_int) begin
         $display("tiempo %g: mensaje enviado en la terminal MBC %h",$time,D_push_mbc);
         pushed_mbc=0;
         mensages_enviados++;
       end
       if (Sim_bs_systm.uut.pop_spi_int) begin
         $display("tiempo %g: mensaje enviado en la terminal SPI %h",$time,D_push_spi);
       end
       if (Sim_bs_systm.uut.pop_uart_int) begin
         $display("tiempo %g: mensaje enviado en la terminal UART %h",$time,D_push_uart);
       end
       if (Sim_bs_systm.uut.pop_anlg_int) begin
         $display("tiempo %g: mensaje enviado en la terminal MBC %h",$time,D_push_anlg);
       end
      if(pndng_mbc)begin 
         $display("tiempo %g: mensaje recibido en la terminal MBC %h",$time,D_pop_mbc);
         pop_mbc=1;
      end
      if(pndng_spi)begin 
         $display("tiempo %g: mensaje recibido en la terminal SPI %h",$time,D_pop_spi);
         pop_spi=1;
      end
      if(pndng_uart)begin 
         $display("tiempo %g: mensaje recibido en la terminal UART %h",$time,D_pop_uart);
         pop_uart=1;
      end
      if(pndng_anlg)begin 
         $display("tiempo %g: mensaje recibido en la terminal ANLG %h",$time,D_pop_anlg);
         pop_anlg=1;
      end
      if (mensages_enviados > 3) begin
        $finish;
      end 
    end
  endtask

endmodule
