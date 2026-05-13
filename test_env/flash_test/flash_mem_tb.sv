`include "IS25WP032D.vp"
//`timescale 1ns/10ps

module flash_mem_tb;

  logic SCLK;
  logic CS;
  logic SI;
  logic SO;
  logic WP;
  logic SIO3;

  IS25WP032D flash_mem(
    .SCLK (SCLK),    // Serial Clock Input
    .CS   (CS),      // Chip select (Low active)
    .SI   (SI),      // Serial Input/Output SIO0
    .SO   (SO),      // Serial Input/Output SIO1
    .WP   (WP),      // Hardware write protection or Serial Input/Output SIO2
    .SIO3 (SIO3),    // Hold/HWRST or Serial Input/Output SIO3
  );

initial begin
  $dumpfile("../../../sim_files/core_sim_files/flash_mem_tb.vcd");
  $dumpvars(0,flash_mem_tb);
  //$readmemh("test_program.txt",inst_queue);
end

  always #1 clk=~clk;
  always @(posedge clk)begin
    
  end

endmodule
