`timescale 1ns / 1ps

////////////////////////////////////////////
// Definición del mapeo de memoria  //
//////////////////////////////////////////

module Mem_map #(AW=32,Slaves=2)(
    input [31:0] Addr,
    output logic [$clog2(Slaves+1)-1:0] Slave_id,
    output logic [31:0] AddrO
    );
    logic [Slaves-1:0][$clog2(Slaves+1)-1:0] S_id;
    logic [Slaves-1:0][$clog2(Slaves+1)-1:0] id_or;
    // Mapeo de periféricos
    logic [Slaves-1:0][AW-1:0]S_Base;
    logic [Slaves-1:0][AW-1:0]S_Size;
    assign S_Base[0]=32'h40000000;
    assign S_Size[0]=32'h00000FFF;
    assign S_Base[1]=32'h40001000;
    assign S_Size[1]=32'h0000FFFF;
    
    genvar i;
    generate
    for (i=0;i<Slaves;i=i+1)begin
    assign S_id[i]= (Addr>=S_Base[i] && Addr<=(S_Base[i]+S_Size[i])) ? i+1'b1 : 0;
    if (i==0)assign id_or[i]=S_id[i];
    else assign id_or[i]=id_or[i-1] | S_id[i];
    if (i==(Slaves-1))begin
        assign Slave_id=id_or[i];
        assign AddrO=Addr-S_Base[id_or[i]-1];
        end
    end
    endgenerate
endmodule
