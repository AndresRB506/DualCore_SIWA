//////////////////////////////////////////////////////////
// Definition of a D Latch  without  reset  //
/////////////////////////////////////////////////////////
module dltch_n_r (
 input data,
  input clk,
  output reg q);

  always @ (clk or data)    
    if (clk) begin
      q <= data;
    end

endmodule

module mem_latch #(parameter bits= 32, parameter entradas = 10)(
  input [$clog2(entradas-1)-1:0] direcciones,
  input [bits-1:0]datos_in,
  input write,
  output [bits-1:0]datos_out
  ); 
  
  wire [bits-1:0]datos_out_entrada[entradas]; 
  wire [bits-1:0]datos_in_entrada[entradas]; 
  wire clk_entrada[entradas];
  wire [entradas-1:0] select_entrada;
    
  genvar b,d;
  generate
    for(d = 0; d < entradas; d=d+1) begin:_depth_
      for(b = 0; b < bits; b=b+1) begin:_bit_
        dltch_n_r Ram_latch(.data(datos_in[b]),.clk(clk_entrada[d]),.q(datos_out_entrada[d][b]));
      end
      assign select_entrada[d] = (direcciones == d)?1:0;
      assign clk_entrada[d] = select_entrada[d]&write;
      assign datos_out = (select_entrada[d])?datos_out_entrada[d]:{bits{1'bz}};
    end
  endgenerate

endmodule
