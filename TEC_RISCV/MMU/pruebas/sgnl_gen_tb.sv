`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2018 11:15:35 AM
// Design Name: 
// Module Name: sgnl_gen_tb
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


module sgnl_gen_tb( );
    
    reg reloj, rst;
    reg rw_mem, mem_en;
    reg rdy_from_mem;
    
    wire c_en;
    wire w_en, sl, clk_mem, rdy_device;

    mem_sgnl_gen generador(
        .sys_clk(reloj), .reset(rst),
        .RW_Mem(rw_mem), .Mem_en(mem_en),
        .RDY(rdy_from_mem),
        .CEn(c_en), 
        .WEn(w_en), .SL(sl), .CLK(clk_mem), .rdy_to_dv(rdy_device));
        
    initial begin
        reloj = 1'b0;
        rst = 1'b0;
        rdy_from_mem = 1'b0;
        mem_en = 1'b0;
        rw_mem = 1'b0;
        #55 rst = ~rst;
        #55 rst = ~rst;
        mem_en = 1'b1;
        #250 rw_mem = 1'b1;
        #250 rdy_from_mem = 1'b1;
        #250 rdy_from_mem = 1'b0;
    end
    always
    #25 reloj = ~reloj;

endmodule
