`timescale 1ns / 1ps

module FsmMicro #(parameter s=32, parameter i=3, parameter o=3)(
    input clk,reset,
    input [(i-1):0] inputs,
    input [(s-1):0] instr,
    output [(s-1):0] dir,
    output [(o-1):0] outputs
    );
        reg [(s-1):0]nuPC;
        wire [(o-1):0]outw;
        wire MuxC;
        wire [(s-1):0]bruPC;
        reg [(s-1):0]uPC;
        reg [(o-1):0]out;
        
        //instancias
        
        branchL #(i) branchLInst(
            .inputs(inputs),
            .BrachI(instr[(o+s+2):(o+s)]),
            .MuxC(MuxC) 
            );
        
        branchTL #(i,s) branchTLInst(
            .inputs(inputs),      
            .BranchI(instr[(o+s+6):(o+s+3)]),            
            .BranchT(instr[(o+s-1):(o)]),            
            .bruPC(bruPC)             
            );
    
        always @(posedge clk, posedge reset)
        begin
        if (reset)
            begin
            uPC<=0;
            out<=0;
            end
        else
            begin
            out<=outw;
            uPC<=nuPC;
                       
            end
        end

        always @*
        begin 
            //Mux para branch
            case(MuxC)
                1'b0: nuPC = uPC+1;            
                1'b1: nuPC = bruPC;
            endcase    
        end
        assign outw=instr[(o-1):0];
        assign outputs=out;
        assign dir=uPC;
    
endmodule
