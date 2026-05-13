`timescale 1ns / 1ns
`define DAT_SZ 3
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Handler
// Module Name: tb_handler
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Dependencies: handler
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_handler( );
    reg rst,cln, clk;
    reg rqs_bs, rqs_cr;
    reg [`DAT_SZ-1:0] data_cr, data_bs;
    reg sgnl_cr, sgnl_bs;

    wire go_cr, go_bs;
    wire sgnl;
    wire [`DAT_SZ-1:0] data;

    error_handler#(.dat_size(`DAT_SZ)) manejador(
    .reset(rst), .clean(cln), .sys_clk(clk),
    .Rqs_bs(rqs_bs), .Rqs_cr(rqs_cr),
    .Data_cr(data_cr), .Data_bs(data_bs),
    .Sgnl_cr(sgnl_cr), .Sgnl_bs(sgnl_bs),
    .Go_cr(go_cr), .Go_bs(go_bs),
    .Sgnl(sgnl),
    .Data(data)
    );

    initial begin
        {rst, rqs_bs, rqs_cr,sgnl_cr, sgnl_bs} = 'd0;
        clk = 1'b0;
        {data_cr, data_bs} = 'd0;
        cln = 1'b1;
        #15 rst = ~rst;
        #50 rst = ~rst;
        repeat(15) begin
            data_cr = $random($random());
            data_bs = $random({$random()});
            {sgnl_cr,sgnl_bs} = $random({$random()});
            {rqs_bs,rqs_cr} = {$random($random())};
            #15 ;
            sgnl_cr = ~sgnl_cr;
            sgnl_bs = ~sgnl_bs;
            #60 ;
            data_cr = $random($random());
            data_bs = $random({$random()});
            {sgnl_cr,sgnl_bs} = $random({$random()});
            #100 ;
        end
        #100 $finish;
    end

    always begin
    #25 clk = ~clk;
    end

endmodule
