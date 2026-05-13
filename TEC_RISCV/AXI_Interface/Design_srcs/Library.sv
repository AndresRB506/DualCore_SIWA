`timescale 1ns / 1ps

//////////////////////////////////////////////////////////
// Definición de un FF tipo D con reset síncrono       //
////////////////////////////////////////////////////////

module ffD #(DataW=1)(
    input clk,
    input reset,
    input En,
    input [DataW-1:0]D,
    output logic [DataW-1:0]Q
    );
    
    always_ff @ (posedge clk)
    if (reset) begin
      Q <= 0;
    end  
    else if (En) begin
      Q <= D;
    end
endmodule

////////////////////////////////////////////////////////////////////
// Definición de un Mux con entradas y selección parametrizable  //
//////////////////////////////////////////////////////////////////

module Mux #(DataW=1,Inputs=2)(
    input [$clog2(Inputs)-1:0]selec,
    input [Inputs-1:0][DataW-1:0]Data_in,
    output logic [DataW-1:0]Data_out
    );
    always_comb
    begin
        Data_out=Data_in[selec];
    end

endmodule


////////////////////////////////////////////////////////////////////
// Definición de un Demux con entradas y selección parametrizable
// con salida de Push
//////////////////////////////////////////////////////////////////
module DemPush #(DataW=1,Outputs=2)(
    input [$clog2(Outputs+1)-1:0]selec,
    output logic [Outputs-1:0][DataW-2:0]Data_out,
    output logic [Outputs-1:0]Push,
    input [DataW-1:0]Data_in
    );
    genvar i;
    generate
    for (i=0;i<Outputs;i=i+1)begin :Dem_logic
        always_comb
        begin
            if (selec==i+1'b1)begin
                Data_out[i]=Data_in[DataW-1:1];
                Push[i]=Data_in[0];
            end
            else begin
                Data_out[i]={(DataW-1){1'bz}};
                Push[i]=1'b0;
            end
        end
    end
    endgenerate
endmodule
////////////////////////////////////////////
// Definición del decodificador de push  //
//////////////////////////////////////////


module Deco_Push#(AW=32,Masters=2,Slaves=2)(
    input [Masters-1:0][AW-1:0]A,
    input [Masters-1:0]V,
    output logic [Masters-1:0][$clog2(Slaves+1)-1:0]Sel,
    output logic [Masters-1:0]Rst,
    output logic [Masters-1:0]Push,
    output logic [Masters-1:0][AW-1:0] Addr
    );
    logic [Masters-1:0][$clog2(Slaves+1)-1:0]Slave_id;   
    logic [Masters-1:0][$clog2(Slaves+1)-1:0]S_id;
    
    
    genvar i;
    genvar j;
    generate
    for(i=0;i<Masters;i=i+1)begin
        Mem_map #(AW,Slaves)Map(.Addr(A[i]),.Slave_id(Slave_id[i]),.AddrO(Addr[i]));
        always_comb S_id[i]=Slave_id[i];
    end
    for(i=0;i<Masters;i=i+1)begin :Decoder_logic   
        if (i==0)begin
            always_comb begin
                if (S_id[i]!=0 && V[i])begin
                    Sel[i]=S_id[i];
                    Push[i]=1;
                    Rst[i]=1;   
                end
                else begin
                    Sel[i]=0;
                    Push[i]=0;
                    if (V[i]) Rst[i]=1;      
                    else Rst[i]=0;     
                end
            end
        end
        else begin
            logic [i-1:0]Eq_Flags;
            logic En_Flag;
            for (j=0;j<i;j++)begin
                always_comb begin
                    if (S_id[i]==S_id[j]&&V[j]) Eq_Flags[j]=1'b1;
                    else Eq_Flags[j]=1'b0;
                end
            end
            assign En_Flag= ~| Eq_Flags;
            always_comb begin
                if (S_id[i]!=0 && V[i] && En_Flag)begin
                    Sel[i]=S_id[i];
                    Push[i]=1;
                    Rst[i]=1;   
                end
                else begin
                    Sel[i]=0;
                    Push[i]=0;
                    if (V[i] && En_Flag)Rst[i]=1;
                    else Rst[i]=0;                    
                end
            end
        end
    end    
    endgenerate

endmodule

////////////////////////////////////////////
// Definición del banco de registros     //
//////////////////////////////////////////

module B_Reg#(DW=1,Registers=2)(
    input clk,reset,
    input [DW-1:0]D_in,
    input W_en,
    input [$clog2(Registers)-1:0]Waddr,
    input [$clog2(Registers)-1:0]Raddr,
    input R_en,
    output logic [DW-1:0]D_out
    );
    
    logic [DW-1:0] Bank [Registers-1:0]; 
    
    always_ff @(posedge clk,posedge reset)begin
        if (reset) Bank<='{default:0};
        else begin
            if (W_en) Bank[Waddr]<=D_in;
            if (R_en) Bank[Raddr]<=0;
        end    
    end
    
    always_comb D_out=Bank[Raddr];
    
    
endmodule


////////////////////////////////////////////
// Definición de la FSM FIFO             //
//////////////////////////////////////////

module FSM_FIFO#(Registers=2)(
    input clk,reset,
    input Push,
    input R_end,
    input S_Ready,
    output logic [$clog2(Registers)-1:0] Waddr,
    output logic [$clog2(Registers)-1:0] Raddr,
    output R_en,
    output logic S_Valid
    );
    enum logic [1:0] {
    Espera = 2'b00,
    Data = 2'b01,
    Read = 2'b10
    } State;
    
    always_ff @(posedge clk,posedge reset)
        if (reset) begin
            State<=Espera;
            Waddr<=0;
            Raddr<=0;
            S_Valid<=0;
        end
        else begin
            case(State)
            Espera:begin
                if (Push)begin
                    if (Waddr==Registers-1'b1)Waddr<=0;
                    else Waddr<=Waddr+1'b1;
                    if (S_Ready)begin
                        S_Valid<=1;
                        State<=Read;
                    end
                    else begin
                        S_Valid<=1;
                        State<=Data;
                    end
                end
                else State<=Espera;
            end
            Data:begin
                case({Push,S_Ready})
                    2'b00:begin
                        State<=Data;
                    end
                    2'b01:begin
                        State<=Read;
                        S_Valid<=0;
                    end
                    2'b10:begin
                        State<=Data;
                        if (Waddr==Registers-1'b1)Waddr<=0;
                        else Waddr<=Waddr+1'b1;
                    end
                    2'b11:begin
                        State<=Read;
                        if (Waddr==Registers-1'b1)Waddr<=0;
                        else Waddr<=Waddr+1'b1;
                        S_Valid<=0;
                    end
                endcase
            end
            Read:begin
                S_Valid<=0;
                case({Push,R_end})
                    2'b00:begin
                        State<=Read;    
                    end
                    2'b01:begin
                        if (Waddr==Raddr+1)State<=Espera;
                        else if (Waddr==0 && Raddr+1'b1==Registers)State<=Espera;
                        else begin
                        	S_Valid<=1;
                        	State<=Data;
                        	end
                        if (Raddr==Registers-1'b1)Raddr<=0;
                        else Raddr<=Raddr+1'b1;
                    end
                    2'b10:begin
                        if (Waddr==Registers-1'b1)Waddr<=0;
                        else Waddr<=Waddr+1'b1;
                        State<=Read;
                    end
                    2'b11:begin
                        State<=Data;
                        S_Valid<=1;
                        Raddr<=Raddr+1'b1;
                        if (Raddr==Registers-1'b1)Raddr<=0;
                        else Raddr<=Raddr+1'b1;
                        if (Waddr==Registers-1'b1)Waddr<=0;
                        else Waddr<=Waddr+1'b1;
                    end
                    default: State<=Read;        
                endcase
            end
            default: State<=Espera;
            endcase      
        end 
        
        assign R_en = State[1] ? R_end : 1'b0;
endmodule

////////////////////////////////////////////
// Definición del deco de error          //
//////////////////////////////////////////

module Deco_error#(Masters=2,Slaves=2)(
    input [Masters-1:0]V,
    input [Masters-1:0][$clog2(Slaves+1)-1:0]S,
    input [Masters-1:0] R,
    output [Masters-1:0]SE
    );
    genvar i;
    generate
    for (i=0;i<Masters;i=i+1)begin
        assign SE[i] = (V[i]==1 && S[i]==0 && R[i]==1) ? 1'b1 : 1'b0;
    end 
    endgenerate
endmodule 
