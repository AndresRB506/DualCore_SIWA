`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 16 
`define NUM_SLCT_LNS 3
`define BROADCAST {8{1'b1}}
`define DRVRS 4
`define FIFOS
`include "../../FIFO_Latches/fifo.sv"
`include "../../BUS/Library.sv"
`define LIB
`include "../Router_library.sv"

module router;
 //inputs
  reg clk;
  reg [`NUM_SLCT_LNS-1:0]select;
  reg  [`PCKG_SZ-1:0]input_signal[(2**`NUM_SLCT_LNS)-1:0];
 //outputs
  reg  [`PCKG_SZ-1:0]out;
  int contador = 0;

  int i = 0;


  param_mux #(.num_slct_lns(`NUM_SLCT_LNS),.pck_sz(`PCKG_SZ)) dut(
  .select(select),
  .input_signal(input_signal),
  .out(out)
);

initial begin
  clk=0;
  select ={`NUM_SLCT_LNS{1'b0}};
  contador=0;
end

always #1 clk=~clk;   
always@(posedge clk)begin
  prueba();
end

task prueba ();
  contador = (contador< (2**`NUM_SLCT_LNS))?contador+1:0;
  if($time < 20) begin
    for(int k=0;k < (2**`NUM_SLCT_LNS);k=k+1) begin
      input_signal[k] = 2*k;
      $display("input signal %g: %g",k,input_signal[k]);
    end
    $display("select: %g salida del mux: %g tiempo %g",out, select, $time);
    select = contador;
  end else begin
    $finish;
  end
endtask
endmodule
