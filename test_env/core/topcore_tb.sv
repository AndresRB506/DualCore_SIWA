`include "../../TEC_RISCV/TOP/TecRiscv_top_CPU.sv"
`include "Status.sv"
`include "Selfcheck.sv"
`include "Reference_Model.sv"
//`include "selfcheck.sv"
`timescale 1ns/10ps

`define DEBUG

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
  int estado;
  int contador;
  int executed_inst;

  parameter fn_boot = {65'h0_1600_0000_0000_0000};//dest=0,source=1,code=3,address=0,dato=0

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
    .IS_Trigger(IS_Trigger));

int num_instructions;
int finish_test;
logic [2:0] dest 		       = 0;
logic [1:0] source         = 1;
logic [64:0] packed_inst   = 0;
logic [2:0]  code 	 	     = 7;
logic [24:0] address 	     = 0;
logic [31:0] data 	 	     = 32'h55555555;
logic [31:0] last_inst;
//logic end_test;
string inst_queue     [$];
string exe_inst_queue [$];
string prediction     [$];
string instruction;
string line;
int file;
string file2;
int out;

initial begin
  prediction.delete();
  exe_inst_queue.delete();
  //file2 = `PREDICTOR_FILE;
  file = $fopen(`PROGRAM_FILE,"r");//("Test_Files/Assembly_Code/lbu.o.txt","r");
  while(!$feof(file)) begin
    $fgets(instruction,file);
    inst_queue.push_back(instruction);
    $display({"Introduced instruction: ",instruction});
  end
  $fclose(file);
  $display("Number of instructions: %d",(inst_queue.size() - 1));
  out = $fopen("results.txt","w");
  $fwrite(out,"Number of instructions:%h \n",(inst_queue.size() - 1));
  $fclose(out);
  num_instructions = inst_queue.size();
  $display("-----------------------------------",);
  $display("Initiating Prediction Process...");
  $display("-----------------------------------",);
  reference_model(prediction,executed_inst,exe_inst_queue);
  //executed_inst_count(file2,executed_inst);
  line.itoa((executed_inst - 1));
  //$display({"DEBUG ",line});
  file = $fopen("temp.txt","w");
  $fwrite(file,line);
  $fwrite(file,"\n");
  $fwrite(file,"0 \n");
  $fclose(file);
  //last_inst_search(file2,last_inst);
  $dumpfile("../../../sim_files/core_sim_files/Test_Top.vcd");
  $dumpvars(0,Test_Top);
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
    end else begin
      reset <=0;
      D_push_spi[64:60]  <= {5'b00001};
      D_push_uart[64:60] <= {5'b00010};
      maip <=0;
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
          D_push_spi = (contador<=num_instructions)?packed_inst:fn_boot;
          estado=2;
          pop_spi=1;
          $display("tiempo %g recibido dato %h",$time,D_pop_spi);
        end
        2: begin // manda mensaje hacia el MBC
          D_push_spi = (contador<=num_instructions)?packed_inst:fn_boot;
          estado=0;
          pop_spi=0;
          push_spi=1;
          $display("tiempo %g  enviado dato %h",$time,D_push_spi);
        end
      endcase

    end
    //$display("DEBUG: %h",Test_Top.uut.Deco.inst);
    file = $fopen("temp.txt","r");
    while(!$feof(file)) begin
      $fgets(line,file);
      if (line == "FINISH") begin
        $display("End of program reached.....Ending test...");
        finish_test = 1;
      end
    end
    $fclose(file);
    if(($time >2000000) || (finish_test == 1)) begin
      selfcheck(inst_queue,prediction,executed_inst,exe_inst_queue);
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
  	packed_inst [31:0]  = inst_queue[contador].atohex();

  endtask : inst_packing

endmodule
