`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2018 18:14:27
// Design Name: 
// Module Name: barrel_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module barrel_tb(
    );
    localparam m=32;
    reg [m-1:0] A,B;
    reg [1:0] Alu_cntrl;
    wire [m-1:0] Y;
    
    Barrel_Shifter inst_BS(
    .A(A),
    .B(B),
    .Alu_cntrl(Alu_cntrl),
    .Y(Y)
      );
            
    initial begin
          A = 'd1;    //Igual A y B
          B = 'd0;
          // Initialize Inputs
          Alu_cntrl=2'b00;//////shift left
          #200
          A = 'h0a0a0a0a;    //Igual A y B
          B = 'd0;
          #200
          B = 'd1;
          #200
          B = 'd2;
          #200
          B = 'd3;
          #200
          B = 'd4;
          #200
          B = 'd8;
          #200
          B = 'd12;
          #200
          B = 'd16;
          #200
          B = 'd20;
          #200
          B = 'd24;
          #200
          B = 'd25;
          #200
          B = 'd27;
          #200             
          B = 'h0a0a0a0a;
          #200            
          Alu_cntrl=2'b01;///////////shift right
          B = 'd0;
          #200
          B = 'd1;
          #200
          B = 'd2;
          #200
          B = 'd3;
          #200
          B = 'd4;
          #200
          B = 'd8;
          #200
          B = 'd12;
          #200
          B = 'd16;
          #200
          B = 'd20;
          #200
          B = 'd24;
          #200
          B = 'd25;
          #200
          B = 'd27;
          #200    
                 
          Alu_cntrl=2'b10;
          B = 'd0;
          #200
          B = 'd1;
          #200
          B = 'd2;
          #200
          B = 'd3;
          #200
          B = 'd4;
          #200
          B = 'd8;
          #200
          B = 'd12;
          #200
          B = 'd16;
          #200
          B = 'd20;
          #200
          B = 'd24;
          #200
          B = 'd25;
          #200
          B = 'd27;
          #200    
    
    #40
    $finish;
      end
     

endmodule
