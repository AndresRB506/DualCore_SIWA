//-------------------------------------------------------------------------
//						alu_sequence's - www.verificationguide.com
//-------------------------------------------------------------------------
int i=1000;
//=========================================================================
// alu_sequence - random stimulus 
//=========================================================================
class alu_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(alu_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "alu_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(alu_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
// Agregado para cerciorarse de que ocurra un igual
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0000;
    req.Data_A = 32'h00003900;
    req.Data_B = 32'h00003900;
    send_request(req);
    wait_for_item_done(); 
    
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// zero_sequence - "EQU" type
//=========================================================================
class equ_sequence extends uvm_sequence#(alu_seq_item);
  int j=0;
  `uvm_object_utils(equ_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "equ_sequence");
    super.new(name);
  endfunction
  
  virtual task body();    
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    if (j==0) begin
    req.Data_B = req.Data_A;
    j = 1; 
    end
    else j=0; 
    req.ALU_CTRL=4'b0000;
    send_request(req);
    wait_for_item_done();      
   end
    //`uvm_do_with(req,{req.ALU_CTRL==4'b0000;})
  endtask
endclass   //=========================================================================
//=========================================================================
// zero_sequence - "LESS" type
//=========================================================================
class le_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(le_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "le_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0001;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// zero_sequence - "LESS UN" type
//=========================================================================
class leu_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(leu_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "leu_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0010;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// zero_sequence - "GREATER" type
//=========================================================================
class gre_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(gre_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "gre_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0011;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// zero_sequence - "GREATER UN" type
//=========================================================================
class greu_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(greu_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "greu_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0100;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// OP_sequence - "ADD" type
//=========================================================================
class add_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(add_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "add_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0101;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// OP_sequence - "ADD UN" type
//=========================================================================
class addu_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(addu_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "addu_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0110;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// OP_sequence - "SUB UN" type
//=========================================================================
class subu_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(subu_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "subu_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b0111;
    send_request(req);
    wait_for_item_done();       
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// SHIFT_sequence - "LEFT" type
//=========================================================================
class left_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(left_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "left_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1000;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// SHIFT_sequence - "RIGHT" type
//=========================================================================
class ri_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(ri_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ri_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1001;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// SHIFT_sequence - "RIGHT ARITMETIC" type
//=========================================================================
class ria_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(ria_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ria_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1010;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// LOGIC_sequence - "OR" type
//=========================================================================
class or_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(or_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "or_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1011;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// LOGIC_sequence - "XOR" type
//=========================================================================
class xor_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(xor_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "xor_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1100;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================
//=========================================================================
// LOGIC_sequence - "AND" type
//=========================================================================
class and_sequence extends uvm_sequence#(alu_seq_item);
  
  `uvm_object_utils(and_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "and_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(i) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    req.ALU_CTRL=4'b1101;
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================


// Result_sequence PRUEBA SEMI-ESPECIFICA PARA RESULTADO
//=========================================================================
class result_sequence extends uvm_sequence#(alu_seq_item);
  int anterior= 23170;
  int j = 185000;
  int h = 0;

  `uvm_object_utils(result_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "result_sequence");
    super.new(name);
  endfunction
  virtual task body();
    repeat(j) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    if (h==1) begin
      req.Data_A = anterior;
      req.Data_B = 46340;
      anterior = anterior + req.Data_B;
      req.ALU_CTRL=4'b0101;
      h = 0;
    end
    else begin
      req.Data_B = anterior;
      h = 1;      
    end
    send_request(req);
    wait_for_item_done();        
   end
  endtask
endclass
//=========================================================================

// Carry_sequence PRUEBA SEMI-ESPECIFICA PARA Carry
//=========================================================================
class carry_sequence extends uvm_sequence#(alu_seq_item);
  int j= 1000;

  `uvm_object_utils(carry_sequence)
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "carry_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(j) begin
    req = alu_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
      req.Data_A = $urandom_range(4294967295,2147483648);
      req.Data_B = $urandom_range(4294967295,2147483648);  //
    req.ALU_CTRL=4'b0101;
    //value = value10;
    send_request(req);
    wait_for_item_done();       
   end
  endtask
 
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint no_iguales { req.Data_A != req.Data_B; };
 
endclass
//=========================================================================
// Cin_sequence
//=========================================================================
class cin_sequence extends uvm_sequence#(alu_seq_item);
  int anterior= 0;
  int j= 0;

  `uvm_object_utils(cin_sequence)
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "cin_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    for (int r=0; r<3; r++) begin
      j = 0;
      repeat(4) begin
      req = alu_seq_item::type_id::create("req");
      wait_for_grant();
      req.randomize();
      req.Cin = 1;
      if (j==0) begin
        req.Data_A = 0;
        req.Data_B = 0;
      end
      else if (j<3) begin
        req.Data_B = anterior;
        if (anterior == 1) req.Data_A = 0;
        else req.Data_A = 1;
      end
      else begin
        req.Data_A = 1;
        req.Data_B = 1;
      end
      case (r)
        0: req.ALU_CTRL = 4'b0101;
        1: req.ALU_CTRL = 4'b0110;
        2: req.ALU_CTRL = 4'b0111;
      endcase
      anterior = req.Data_A;
      j++;
      send_request(req);
      wait_for_item_done();       
      end
    end
  endtask
endclass
//=========================================================================
//=========================================================================
class overflow_sequence extends uvm_sequence#(alu_seq_item);
//  int anterior= 23170;
  int j = 0;

  `uvm_object_utils(overflow_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "overflow_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    for (int r=0; r<3; r++) begin
      repeat(4) begin
      req = alu_seq_item::type_id::create("req");
      wait_for_grant();
      req.randomize();
      if (j==0) begin
        if (r==0 | r==1) begin
          req.Data_A = $urandom_range(4294967295,3221225472);
          req.Data_B = $urandom_range(2147483647,1073741825);  //
        end
        else begin
          req.Data_A = $urandom_range(4294967295,2147483648);
          req.Data_B = 2147483648;        
        end  
        j=1;
      end
      else begin
        if (r==0 | r==1) begin
          req.Data_B = 2147483648;
          req.Data_A = $urandom_range(2147483647,1073741825);  //
        end
        else begin
         req.Data_A = 1073741824;
         req.Data_B = $urandom_range(2147483647,1073741825); 
        end  
        j=0;      
      end
      case (r)
        0: req.ALU_CTRL=4'b0101;
        1: req.ALU_CTRL=4'b0110;
        2: req.ALU_CTRL=4'b0111;
      endcase
      send_request(req);
      wait_for_item_done();        
      end
    end
  endtask
endclass
//=========================================================================
//=========================================================================
// mayor_sequence - llamado a todas las secuencias.
//=========================================================================
class mayor_sequence extends uvm_sequence#(alu_seq_item);
  
  //--------------------------------------- 
  //Declaring sequences
  //---------------------------------------
  equ_sequence equ_seq;
  le_sequence  le_seq;
  leu_sequence leu_seq;
  gre_sequence gre_seq;
  greu_sequence greu_seq;
  add_sequence add_seq;
  addu_sequence addu_seq;
  subu_sequence subu_seq;  
  left_sequence left_seq;
  ri_sequence  ri_seq;
  ria_sequence ria_seq;
  or_sequence or_seq;
  xor_sequence xor_seq;
  and_sequence and_seq;
  result_sequence result_seq;
  carry_sequence carry_seq;   
  cin_sequence cin_seq;
  overflow_sequence overflow_seq;  
//  alu_sequence alu_seq;  
  
  `uvm_object_utils(mayor_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mayor_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do(equ_seq)
    `uvm_do(le_seq)
    `uvm_do(leu_seq)
    `uvm_do(gre_seq)
    `uvm_do(greu_seq)
    `uvm_do(add_seq)
    `uvm_do(addu_seq)
    `uvm_do(subu_seq)
    `uvm_do(left_seq)
    `uvm_do(ri_seq)
    `uvm_do(ria_seq)
    `uvm_do(or_seq)
    `uvm_do(xor_seq)
    `uvm_do(and_seq)
    `uvm_do(result_seq)
    `uvm_do(carry_seq)
    `uvm_do(cin_seq)
    `uvm_do(overflow_seq)
  endtask
endclass
//=========================================================================
//=========================================================================