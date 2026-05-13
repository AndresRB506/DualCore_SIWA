`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Bus_core
// Module Name: error_handler
// Project Name: Controlador de memoria y bus
// Description: Módulo encargado de manejar las señales para un solo recurso, solicitado por dos módulos.
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module error_handler#(parameter dat_size = 3)(
    input reset, clean, sys_clk,
    input Rqs_bs, Rqs_cr,
    input [dat_size-1:0] Data_cr, Data_bs,
    output reg Go_cr, Go_bs,
    output reg Sgnl,
    output reg [dat_size-1:0] Data
    );
    
    logic enable;
    logic [dat_size-1:0] Data_int;
    logic Sgnl_int;
    logic go_cr_p, go_bs_p;

    assign enable = Rqs_bs | Rqs_cr;

    always @(negedge sys_clk, posedge reset) begin
        if (reset) begin
            Data <= {dat_size{1'b0}};
            Sgnl <= Sgnl_int;
            Go_cr <= 1'b0;
            Go_bs <= 1'b0;
        end else begin
            if (clean) begin
                Go_cr <= go_cr_p;
                Go_bs <= go_bs_p;
            end else begin
                Go_cr <= 1'b0;
                Go_bs <= 1'b0;
            end
            if (enable) Data <= Data_int;
            Sgnl <= Sgnl_int;
        end 
    end

    always @(*)  begin
        if (reset) begin
            {go_cr_p,go_bs_p} = 2'd0;
            Data_int = {dat_size{1'b0}};
            Sgnl_int = 1'b0;
        end else begin
            case ({Rqs_bs,Rqs_cr}) 
                2'b00: begin
                    {go_cr_p,go_bs_p} = 2'd0;
                    if(clean) Sgnl_int = 1'b1;
                    else Sgnl_int = 1'b0;
                end
                2'b01: begin
                    go_cr_p = 1'b1;
                    go_bs_p = 1'b0;
                    Data_int = Data_cr;
                    Sgnl_int = clean;
                end
                2'b10, 2'b11: begin
                    go_cr_p = 1'b0;
                    go_bs_p = 1'b1;
                    Data_int = Data_bs;
                    Sgnl_int = clean;
                end 
                default: begin
                    {go_cr_p,go_bs_p} = 2'd0;
                    Data_int = {dat_size{1'b0}};
                    Sgnl_int = 1'b0;
                end
            endcase
        end
    end
    
endmodule
