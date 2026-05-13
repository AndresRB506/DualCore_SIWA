`timescale 1ns / 1ps


module CSA4#(n=4)(
    input [n-1:0] a,b,
    input cin,
    output  [n-1:0] s,
    output cout
    );
    
    wire [n-1:0] p;  //propagate
    assign p= a ^ b;
    wire [n-1:0] g;  //generate
    assign g= a & b;  
    wire [n-1:0] c;  //carry =g|p&c
    assign c= {g | p & c[n-1:0],cin};
    assign s = p ^ c[n-1:0];  //suma
    wire bp;
    assign bp =  &p;
    assign cout = bp ? cin:c[n-1];  //mux
endmodule
