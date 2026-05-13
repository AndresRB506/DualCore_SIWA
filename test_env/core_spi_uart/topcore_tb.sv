`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU.sv"
`include "../../TEC_RISCV/SPI/spi.v"
//`timescale 1ns/10ps

module Test_Top_spi_uart;

//global signals

  logic clk;
  logic reset;

//core-spi-spi interface

  logic push_spi;
  logic pop_spi;
  logic [64:0] D_push_spi;
  
//other interfaces

  logic push_uart;
  logic push_anlg;
  logic pop_uart;
  logic pop_anlg;
  logic [64:0] D_push_uart;
  logic [64:0] D_push_anlg;
  logic [7:0] gpio;

  int estado=0;
  int contador=0;
  parameter inst_1  = {65'h0_1e00_0000_5555_5555};//dest=0,source=1,code=7,address=0,dato=0
  parameter inst_2  = {65'h0_1e00_0004_aaaa_aaaa};//dest=0,source=1,code=7,address=4,dato=1
  parameter inst_3  = {65'h0_1e00_0008_5555_5555};//dest=0,source=1,code=7,address=8,dato=2
  parameter inst_4  = {65'h0_1e00_000c_aaaa_aaaa};//dest=0,source=1,code=7,address=12,dato=3
  parameter inst_5  = {65'h0_1e00_0010_5555_5555};//dest=0,source=1,code=7,address=16,dato=4
  parameter inst_6  = {65'h0_1e00_0014_aaaa_aaaa};//dest=0,source=1,code=7,address=20,dato=5
  parameter inst_7  = {65'h0_1e00_0018_5555_5555};//dest=0,source=1,code=7,address=24,dato=6
  parameter inst_8  = {65'h0_1e00_001c_aaaa_aaaa};//dest=0,source=1,code=7,address=28,dato=7
  parameter inst_9  = {65'h0_1e00_0020_5555_5555};//dest=0,source=1,code=7,address=32,dato=8
  parameter inst_10 = {65'h0_1e00_0024_aaaa_aaaa};//dest=0,source=1,code=7,address=36,dato=9
  parameter fn_boot = {65'h0_1600_0000_0000_0000};//dest=0,source=1,code=3,address=0,dato=0
  
  top_CPU_riscv core (
    .clk(clk),
    .reset(reset),
    .push_spi(push_spi),
    .push_uart(push_uart),
    .push_anlg(push_anlg),
    .pop_spi(pop_spi),
    .pop_uart(pop_uart),
    .pop_anlg(pop_anlg),
    .D_push_spi(D_push_spi),
    .D_push_uart(D_push_uart),
    .D_push_anlg(D_push_anlg),
    .D_pop_spi(D_pop_spi),
    .D_pop_uart(D_pop_uart),
    .D_pop_anlg(D_pop_anlg),
    .pndng_spi(pndng_spi),
    .pndng_uart(pndng_uart),
    .gpio(gpio),
    .pndng_anlg(pndgn_anlg)
  );

  spi spi (
    .clk
  );

  input             CLK;      //Señal de reloj
input           reset;
input           MISO;     //MISO
input     [15:0]      data_config;  //Señal de configuración de SPI
input           config_enable;  //Bandera de configuración SPI
input   [DATA_IN-1:0] data_send;    //dato de envio
input             send_data;
output  reg [DATA_OUT-1:0]  data_read;    //dato de recepcion
output  reg         MOSI;     //MOSI
output  reg         CS;       //Chip Select
output  reg         SCK;
output  reg         end_send;



parameter num_instructions = 50;
logic [2:0] dest 		       = 0;
logic [1:0] source         = 1;
logic [64:0] packed_inst   = 0;
logic [2:0]  code 	 	     = 7;
logic [24:0] address 	     = 0;
logic [31:0] data 	 	     = 32'h55555555;
logic [31:0] inst_queue [0:num_instructions];


initial begin
  $dumpfile("../../../sim_files/core_sim_files/Test_Top.vcd");
  $dumpvars(0,Test_Top);
  clk=0;
  reset=1;
  push_spi=0;
  push_uart=0;
  push_anlg=0;
  pop_spi=0;
  pop_uart=0;
  pop_anlg=0;
  D_push_spi=0;
  D_push_uart=0;
  D_push_anlg=0;
  gpio =0;
  $readmemh("test_program.txt",inst_queue);
end

  always #1 clk=~clk;   
  always @(posedge clk)begin
    prueba();
  end

  task prueba();
    
    if ($time<2)begin
      reset <=1;
      push_spi <=0;
      push_uart <=0;
      push_anlg <=0;
      pop_spi <=0;
      pop_uart <=0;
      pop_anlg <=0;
      D_push_spi <=0;
      D_push_uart <=0;
      D_push_anlg <=0;
      gpio<=0;
    end else begin
      reset <=0;
      D_push_spi[64:60]  <= {5'b00001};
      D_push_uart[64:60] <= {5'b00010};
      D_push_anlg[64:60] <= {5'b00011};
      push_spi <=0;
      push_uart <=0;
      push_anlg <=0;
      pop_spi <=0;
      pop_uart <=0;
      pop_anlg <=0;
      gpio <=0;
      case(estado)
        0: begin // espera que llegue un mensaje al SPI
          if (pndng_spi) begin
            estado=1;
            inst_packing();
            $display("tiempo %g recibido dato %h",$time,D_pop_spi);
            contador++;
          end
          push_spi=0;
          pop_spi=0;
        end
        1: begin // saca el dato del fifo del SPI
          D_push_spi = (contador<num_instructions)?packed_inst:fn_boot;
          estado=2;
          pop_spi=1;
        end
        2: begin // manda mensaje hacia el MBC
          D_push_spi = (contador<num_instructions)?packed_inst:fn_boot;
          estado=0;
          pop_spi=0;
          push_spi=1;
          $display("tiempo %g  enviado dato %h",$time,D_push_spi);
        end
      endcase
   
    end
    if($time >2000) begin
      $finish;
    end
  endtask

  task inst_packing();
  	//this task is for packing the instruction in the bus packet format

	address = contador * 4;

	packed_inst [64:62] = dest;
	packed_inst [61:60] = source;
	packed_inst [59:57] = code;
	packed_inst [56:32] = address;
	packed_inst [31:0]  = inst_queue [contador];

  endtask : inst_packing

endmodule  
