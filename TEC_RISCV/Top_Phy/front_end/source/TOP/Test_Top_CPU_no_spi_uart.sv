`define DEBUG
`timescale 1ns/10ps
`include "TecRiscv_top_CPU.sv"
`include "Status_no_spi_uart.sv"
module Test_Top;

  logic clk;
  logic reset;
  logic push_spi;
  logic push_uart;
  logic pop_spi;
  logic pop_uart;
  logic maip;
  logic [64:0] D_push_spi;
  logic [64:0] D_push_uart;
  wire [7:0] gpio;
  wire [64:0] D_pop_spi;
  wire [64:0] D_pop_uart;
  wire pndng_spi;
  wire pndng_uart;
  wire [7:0] full_range_level_shifter;
  wire [31:0] IS_Val;
  wire [31:0] IS_Config;
  wire [3:0] IS_Trigger;
  wire [7:0] conf_GPIO_output;
  int estado=0;
  int contador=0;
  parameter fn_boot = {65'h0_1600_0000_0000_0000};//dest=0,source=1,code=3,address=0,dato=0
  string lines[$];
  string line;
  logic [31:0] pck_inst;
  logic [24:0] pck_addrs=0;

  top_CPU_riscv uut(
    .clk(clk),
    .reset(reset),
    .push_spi(push_spi),
    .push_uart(push_uart),
    .maip(maip),
    .pop_spi(pop_spi),
    .pop_uart(pop_uart),
    .D_push_spi(D_push_spi),
    .D_push_uart(D_push_uart),
    .D_pop_spi(D_pop_spi),
    .D_pop_uart(D_pop_uart),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),
    .gpio(gpio),
    .full_range_level_shifter(full_range_level_shifter),
    .IS_Val(IS_Val),
    .IS_Config(IS_Config),
    .IS_Trigger(IS_Trigger),
    .conf_GPIO_output(conf_GPIO_output));


initial begin
 int fd;
 fd = $fopen("../TOP/codigo","r");
    while (!$feof(fd)) begin
      $fgets(line,fd);
      lines.push_back(line);
      $display("leido comando = %s ",line);
    end
  $display("size lines: %h",$size(lines));
  clk <= 0;
  reset <= 1;
  push_spi <= 0;
  push_uart <= 0;
  maip  <= 0;
  pop_spi <= 0;
  pop_uart <= 0;
  D_push_spi <= 0;
  D_push_uart <= 0;
end

logic [2:0] code = 4;
logic [24:0] address = 0;
logic [31:0] data = 32'h55555555;

  always #50 clk=~clk;
  always @(posedge clk)begin
    prueba();
  end

  task prueba();
    if ($time<250)begin
      reset <=1;
      push_spi <=0;
      push_uart <=0;
      pop_spi <=0;
      pop_uart <=0;
      D_push_spi <=0;
      D_push_uart <=0;
      maip <= 0;
    end else begin
      reset <=0;
      D_push_spi[64:60]  <= {5'b00001};
      D_push_uart[64:60] <= {5'b00010};
      push_spi <=0;
      push_uart <=0;
      pop_spi <=0;
      pop_uart <=0;
      maip <=0;
      case(estado)
        0: begin // espera que llegue un mensaje al SPI
          if (pndng_spi) begin
            estado=1;
            $display("tiempo %g recibido dato %h",$time,D_pop_spi);
          end
          push_spi=0;
          pop_spi=0;
        end
        1: begin // saca el dato del fifo del SPI
             pck_inst = lines[contador].atohex();
             pck_addrs = 4*contador;
             if(contador<$size(lines)-1) begin
               D_push_spi = {{2'b00},{2'b01},{3'b111},pck_addrs,pck_inst};
             end else begin
               D_push_spi = fn_boot;
             end
          estado=2;
          pop_spi=1;
        end
        2: begin // manda mensaje hacia el MBC
          pck_inst = lines[contador].atohex();
          pck_addrs = 4*contador;
             if(contador < $size(lines)-1) begin
               D_push_spi = {{2'b00},{2'b01},{3'b111},pck_addrs,pck_inst};
             end else begin
               D_push_spi = fn_boot;
             end
          estado=0;
          pop_spi=0;
          push_spi=1;
          $display("tiempo %g  enviado dato %h",$time,D_push_spi);
          contador++;
        end
      endcase

    end
    if($time >1000000) begin
      $finish;
    end
  endtask

endmodule
