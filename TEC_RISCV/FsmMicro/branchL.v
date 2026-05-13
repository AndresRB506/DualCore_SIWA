`timescale 1ns / 1ps

module branchL #(parameter i=3)(
    input [(i-1):0] inputs,
    input [2:0] BrachI,
    output reg MuxC 
    );
    
    always@*
    begin
        case (BrachI)                               //se evaluan los posibles casos de branch según las entradas 0 y 1 para controlar el mux
            3'b000:MuxC=1'b0;                      //NOP
            3'b001: if (inputs[0]==1'b1)MuxC=1'b1; //B0  
                    else MuxC=1'b0;
            3'b010: if (inputs[1]==1'b1)MuxC=1'b1; //B1
                    else MuxC=1'b0;
            3'b011: if (inputs!=0)MuxC=1'b1;       //BA
                    else MuxC=1'b0;
            3'b100: MuxC=1'b1;                     //BR
            3'b101: if (inputs[0]==1'b0)MuxC=1'b1; //BN0  
                    else MuxC=1'b0;
            3'b110: if (inputs[1]==1'b0)MuxC=1'b1; //BN1  
                    else MuxC=1'b0;
            3'b111: if (inputs[1:0]==2'b00)MuxC=1'b1; //BNA  
                    else MuxC=1'b0; 
            default: MuxC=1'b0;       
        endcase
    
    end
        
    
endmodule
