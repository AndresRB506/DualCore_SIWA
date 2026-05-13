`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2018 09:02:51 AM
// Design Name: 
// Module Name: only_mem_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Módulo de prueba de solo la memoria
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module only_mem_tb( );
    
    reg [31:0] q_mem;
    reg [31:0] d_in;
    reg [10:0] a_in;
    reg c_en;
    reg w_en, sl, clk_mem;
    reg listo_mem;

    XSPRAMLP_2048X32_M8P memoria(.Q(q_mem), .D(d_in), .A(a_in), .CLK(clk_mem), .CEn(c_en), .WEn(w_en), .SL(sl), .RDY(listo_mem));
   /* initial begin
        clk_mem = 1'b0;
        c_en = 1'b1;
        w_en = 1'b0;
        a_in = 11'h001;
        d_in = 32'h0a0a0a0a;
        sl = 1'b0;
        #80 c_en = 1'b0;
        #55 c_en = 1'b1;
        #55 c_en = 1'b0;
        a_in = 11'h010;
        d_in = 32'h57575757;
        #50 c_en = 1'b1;
        #50 c_en = 1'b0;
        w_en = 1'b1;
        #50 c_en = 1'b1;
        a_in = 11'h001;
        #50 c_en = 1'b0;
        #50 c_en = 1'b1;
        #170 $finish;
    end*/
    initial begin
        clk_mem = 1'b0;
        c_en = 1'b1;
        w_en = 1'b1;
        a_in = 11'h000;
        d_in = 32'h00000000;
        sl = 1'b1;
        #65 sl = 1'b0;
        #5 c_en = 1'b0;
        w_en = 1'b0;
        a_in = 11'h010;
        d_in = 32'h156a4e0c;
        #10 c_en = 1'b1;
        w_en = 1'b1;
        a_in = 11'h000;
        d_in = 32'h00000000;
        #55 sl = 1'b1;
        w_en = 1'b0;
        #80 sl = 1'b0; 
        #5 c_en = 1'b0;
        w_en = 1'b1;
        a_in = 11'h010;
        #10 c_en = 1'b1;
        w_en = 1'b0;
        a_in = 11'h000;
        #55 sl = 1'b1;
        #100 $finish;
    end
    always
    #25 clk_mem = ~clk_mem;

endmodule

