`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Melissa Fonseca Rodríguez
// 
// Design Name: Generador de señales para la memoria
// Module Name: mem_sgnl_gen
// Project Name: Controlador de memoria y bus
// Description: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define NEG_TCHK
`define DEFAULT_WORST_DELAY_OFF
module mem_sgnl_gen (
    input sys_clk, reset,
    input RW_Mem, Mem_en, RDY,
    output reg CEn, 
    output reg WEn, SL, CLK, rdy_to_dvc
    );

    reg habilitador;
    reg temp_end;
    logic provi;
    reg ending;
    reg RW_Mem_reg, Mem_en_reg;
    

    always @(posedge sys_clk, posedge reset) begin
        if (reset) begin
            {Mem_en_reg,RW_Mem_reg} <= 2'd0;
            temp_end <= 1'b0;
        end else begin
            if (RW_Mem == 1'b1 && RW_Mem_reg == 1'b0) temp_end <= 1'b0;
            else if (Mem_en_reg == 1'b0 && Mem_en == 1'b1) temp_end <= 1'b0;
            else if (ending) temp_end <= 1'b1;
            RW_Mem_reg <= RW_Mem;
            Mem_en_reg <= Mem_en;
        end
    end
       
    always @(negedge sys_clk, posedge reset) begin
        if (reset) begin
            {SL, CEn, WEn} <= 3'b110;
            habilitador <= 1'b0;
            ending <= 1'b0;
        end else begin 
            if (temp_end == 1'b0) begin
                if (habilitador == 1'b0) begin
                    ending <= 1'b0;
                    if (Mem_en) begin 
                        CEn <= 1'b0;
                        SL <= 1'b0;
                        habilitador <= 1'b1;
                    end
                    case (RW_Mem) 
                        1'b0: WEn <= 1'b1;
                        1'b1: WEn <= 1'b0;
                    endcase
                end else begin
                    CEn <= 1'b1;
                    ending <= 1'b1;
                    habilitador <= 1'b0;                 
                end
            end else begin
                SL <= 1'b1;
            end
		end
	end

    always @(*) begin
        if (reset) CLK = 1'b0;
        else begin
            if (SL == 1'b0) CLK = sys_clk;
            else CLK = 1'b0;
        end
    end
    
    always @(negedge sys_clk, posedge RDY) begin
        if(RDY) provi <= 1'b1;
        else if (CEn == 1'b1) provi <= 1'b0;
    end
    reg listo;
    always @(negedge sys_clk, posedge reset) begin
        if(reset) begin
            listo <= 1'b0;
            rdy_to_dvc <= 1'b0;
        end else if (listo) begin
            rdy_to_dvc <= 1'b0;
            listo <= 1'b0;
        end else if(provi) begin
            rdy_to_dvc <= 1'b1;
            listo <= 1'b1;
        end else begin
            rdy_to_dvc <= 1'b0;
            listo <= 1'b0;
        end
    end

endmodule
