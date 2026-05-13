`timescale 1ns / 1ps

module csk_bloque #(n=4)(        
        input [n-1:0] a,b,
        input cin,
        output [n-1:0] s,
        output wire cout
        );
        
        wire [n-1:0] p= a ^ b;  //propagate
        wire [n-1:0] g= a & b;  //generate
        wire [n:0] c= {g | p & c[n-1:0],cin};  //carry =g|p&c
        assign s = p ^ c[n-1:0];  //suma
        wire bp =  &p;
        wire skip_1= bp & cin;
        assign cout= skip_1 | c[n];
endmodule
