
module Barrel_Shifter #(parameter m=32)(A,B,Alu_cntrl,Y);
    input [m-1:0] A,B;
    input [1:0] Alu_cntrl;
    output [m-1:0] Y;
    
    reg bandera;
    reg aritmetic;
    reg [m-1:0] shifts_amount; 
    always @(*) begin
    if (Alu_cntrl==2'b00)
        begin
           shifts_amount=32'd32-{27'd0,B[4:0]};
           bandera=1'b1;
           aritmetic=1'b0;
        end
    else if (Alu_cntrl==2'b01)
        begin
          shifts_amount=B;
          bandera=1'b0;
          aritmetic=1'b0;
        end
    else if (Alu_cntrl==2'b10)
        begin
          shifts_amount=B;
          bandera=1'b0;
          aritmetic=1'b1;
        end
    else begin
         shifts_amount = 32'hXXXXXXXX;
        end
   end
////mux decode
     reg [3:0]select;
    reg [7:0]select2;
    genvar v;
    genvar w;
    generate 
    for (v=0;v<4;v=v+1)begin: blk0
    always@(*)begin
        if (shifts_amount[1:0]==v)begin
            select[v]=1;
        end
        else begin
            select[v]=0;
        end
    end
    end
    for (w=0;w<8;w=w+1)begin: blk1
    always@(*)begin
        if (shifts_amount[4:2]==w)begin
            select2[w]=1;
        end
        else begin
            select2[w]=0;
        end
    end
    end
    endgenerate

/////mux de 5 a 1///////////////////
localparam comp_paso=3;
wire [comp_paso:0][m-1:0]x;
wire [comp_paso:0][m-1:0]a;
wire [m-1:0]salida_mux5;
genvar i;

    generate
    for (i=0;i<=comp_paso;i=i+1)begin: blk2
    /////instanciación del mux de 4 a 1
    tristate_buffer inst_buffer(
    .input_x(a[i]), 
    .enable(select[i]), 
    .output_x(x[i])
    );
    if (i!=0)begin: blk10
    
        assign a[i]={A[i-1:0],A[m-1:i]};
        assign salida_mux5=x[i];

    end
    else begin: blk3
        assign a[i]= A[m-1:0];
        assign salida_mux5=x[i];
    end
    
    end
    endgenerate



////////////////////mux de 8 a 1
localparam stages=28;
wire [stages:0][m-1:0]in_x; //////  8 entradas de 32 bits
wire [stages:0][m-1:0]out_x; 
wire [m-1:0] S; 
genvar j;
    generate
    for (j=0;j<=stages;j=j+4)begin: blk4
    /////instanciación del mux de 8 a 1
    tristate_buffer inst_buffer_s(
    .input_x(in_x[j/4]), 
    .enable(select2[j/4]), 
    .output_x(out_x[j/4])
    );
    if (j!=0)begin: blk11
    
        assign in_x[j/4]={salida_mux5[j-1:0],salida_mux5[m-1:j]};
        assign S=out_x[j/4];
    end
    else begin: blk12
        assign in_x[j/4]= salida_mux5[m-1:0];
        assign S=out_x[j/4];
    end
    
    end
    endgenerate

////Máscara para lógica right--left//

    wire [m-1:0]Sal1;
    wire [m-1:0] Sal2;
    reg [m-1:0]control;
    genvar l;
    generate 
    for (l=0;l<m;l=l+1)begin: blk5
    always@(*)begin
        if (bandera)begin
            if (l<B[4:0])control[l]=1'b0;
            else control[l]=1'b1;
        end
        else begin
            if (l>=32-B[4:0])control[l]=1'b0;
            else control[l]=1'b1;
        end
    end
    assign Sal1[l]=S[l] & control[l];
    assign Sal2[l]=A[m-1] & aritmetic & ~control[l];
    assign Y[l]= Sal1[l]|Sal2[l];
    end
    endgenerate
    
endmodule
module tristate_buffer #(parameter m=32)(input_x, enable, output_x);
input [m-1:0]input_x;
input enable;
output [m-1:0] output_x;

assign output_x = enable? input_x : 'bz;

endmodule


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

module CSK_sin_mux #(m=32)(A,B,Cin,Cout,S);
    input [m-1:0] A,B;
    input Cin;
    output  [m-1:0] S;
    output Cout;
    localparam n=4;
    
    wire [(m/4)-1:0][n-1:0] a,b;
    wire [(m/4)-1:0]cin;
    wire  [(m/4)-1:0][n-1:0] s;
    wire [(m/4)-1:0]cout;
    
    
    genvar i;
    generate
    for (i=0;i<m/4;i=i+1)begin: blk6
        csk_bloque csk_bloque_inst(
        .a(a[i]),
        .b(b[i]),
        .cin(cin[i]),
        .s(s[i]),
        .cout(cout[i])
        );
        if (i!=0)begin: blk7
            assign a[i]=A[(n*(i+1))-1:(n*i)];
            assign b[i]=B[(n*(i+1))-1:(n*i)];
            assign cin[i]=cout[i-1];
        end
        else begin: blk8
            assign a[i]=A[n-1:0];
            assign b[i]=B[n-1:0];
            assign cin[i]=Cin;
        end
        if (i==((m/4)-1)) begin:blk9 
          assign Cout=cout[i];
        end
        assign S[(n*(i+1))-1:(n*i)]=s[i];
    end
    endgenerate
      
endmodule

module ALU #(bits_size=32, cntrl_size=4)(
    input [bits_size-1:0] A,
    input [bits_size-1:0] B,
    input [cntrl_size-1:0] Alu_Cntrl,
    input  Cin,
    output reg Zero, 
    output reg oVerflow,
    output reg Negative,
    output reg Carry,
    output reg [bits_size-1:0] OUT
    );
   reg [bits_size-1:0] final_suma;
   reg [bits_size-1:0] complemento_a_2;
   reg cout;
   reg [bits_size-1:0] final_shift;
   reg [1:0] shift_cod;
   
    //////instancia del carry skip adder//////
    
    CSK_sin_mux inst_CSK(
   .A(A),
   .B(complemento_a_2),
   .Cin(Cin),
   .S(final_suma),
   .Cout(cout) 
           );

    Barrel_Shifter inst_BS(
    .A(A),
    .B(B),
    .Alu_cntrl(shift_cod),
    .Y(final_shift)
      );
        
    function compare (input [bits_size-1:0] A, input [bits_size-1:0] B, input [2:0] cod);
    begin
        case (cod)
        3'b000: begin       //EQU
                compare = ($signed(A) == $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b001: begin       //LESS_THAN
                compare = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b010: begin       //LESS_THAN_UNSIGNED
                compare = (A < B) ? 1'b1 : 1'b0;
                end
        3'b011: begin       //GREATER_THAN
                compare = ($signed(A) > $signed(B)) ? 1'b1 : 1'b0;
                end
        3'b100: begin       //GREATER_THAN_UNSIGNED
                compare = (A > B) ? 1'b1 : 1'b0;
                end
        default: begin
                 compare = 1'bX;
                 end
        endcase
    end
    endfunction
        
    function [bits_size-1:0] logical (input signed [bits_size-1:0] A, input signed [bits_size-1:0] B, input [1:0] cod);
    begin
        case (cod)
        2'b00: begin        //BITWISE_XOR
                logical = $signed(A) ^ $signed(B);
               end
        2'b01: begin        //BITWISE_AND
                logical = $signed(A) & $signed(B);
               end
        2'b11: begin        //BITWISE_OR
                logical = $signed(A) | $signed(B);
               end
        default: begin
                 logical = 32'hXXXXXXXX;
                 end
        endcase
    end
    endfunction 
     
    always @* begin
        case(Alu_Cntrl)
            4'b0000: begin //EQU
                        OUT = 32'd0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);                        
                     end
            4'b0001: begin //LESS_THAN
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0010: begin //LESS_THAN_UNSIGNED
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0011: begin //GREATER_THAN
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0100: begin //GREATER_THAN_UNSIGNED
                        OUT = 32'd0;
                        Zero = compare(A,B,Alu_Cntrl[2:0]);
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b0101, 4'b0110: begin //ADD
                          complemento_a_2=B;
                          OUT = final_suma[bits_size-1:0]; 
                          Carry=cout;
                          oVerflow = ((1'b0~^A[bits_size-1]~^B[bits_size-1]) & (A[bits_size-1]^OUT[bits_size-1]));
                          Zero = 1'b0;
                     end
            4'b0111: begin //SUB_UNSIGNED
                          complemento_a_2=(-B);///para hacer la resta
                          OUT = final_suma[bits_size-1:0];
                          Carry=cout; 
                          Zero = 1'b0;
                          oVerflow = ((1'b1~^A[bits_size-1]~^B[bits_size-1]) & (A[bits_size-1]^OUT[bits_size-1]));
                     end
                     
            4'b1000: begin //SHIFT_LEFT_LOGICAL
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end
            4'b1001: begin //SHIFT_RIGTH_LOGICAL
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;
                     end   
            4'b1010: begin //SHIFT_RIGTH_ARITMETIC
                        shift_cod=Alu_Cntrl[1:0];
                        OUT = final_shift;
                        Zero = 1'b0;
                        oVerflow = 1'b0; 
                        Carry = 1'b0;                                       
                     end
            4'b1011: begin //BITWISE_OR
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0; 
                        Carry = 1'b0;      
                     end
            4'b1100: begin //BITWISE_XOR
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;                                                 
                     end
            4'b1101: begin //BITWISE_AND
                        OUT = logical(A,B,Alu_Cntrl[1:0]);
                        Zero = 1'b0;
                        oVerflow = 1'b0;
                        Carry = 1'b0;                                                         
                     end                                                          
            default: begin //default
                        OUT = 32'dX;        
                        Zero = 1'bX; 
                        oVerflow = 1'bX; 
                        Carry = 1'bX;       
                     end        
            endcase
            Negative = OUT[bits_size-1];        
    end
    
endmodule
