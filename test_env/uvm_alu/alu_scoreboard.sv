//-------------------------------------------------------------------------
//						alu_scoreboard - www.verificationguide.com 
//-------------------------------------------------------------------------

class alu_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  alu_seq_item pkt_qu[$];
  
  //---------------------------------------
  // sc_alu 
  //---------------------------------------
  bit [31:0] sc_R ;
  bit sc_Z ;
  bit sc_O ;
  bit sc_N ;
  bit sc_C ;
  
  //---------------------------------------
  // sc_datos 
  //---------------------------------------
  int unsigned dato_1U;
  int unsigned dato_2U;
  int signed dato_1S;
  int signed dato_2S;
  int signed Complemento_2;
  longint resultado;
  int rev;
  int X,Y;
  realtime P;

  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp#(alu_seq_item, alu_scoreboard) item_collected_export;
  `uvm_component_utils(alu_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory****
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
    rev=0;
    X=0;
    Y=0;
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(alu_seq_item pkt);
    //pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    alu_seq_item alu_pkt;
    forever begin
      wait(pkt_qu.size() > 0);
      X++;
      alu_pkt=pkt_qu.pop_front;
      dato_1S=alu_pkt.Data_A;
      dato_2S=alu_pkt.Data_B;
      dato_1U=0+alu_pkt.Data_A;
      dato_2U=0+alu_pkt.Data_B;
      Complemento_2=-alu_pkt.Data_B;
      if (alu_pkt.ALU_CTRL==4'h0) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z = (dato_1S==dato_2S)? 1'b1: 1'b0;
      end
      if (alu_pkt.ALU_CTRL==4'h1) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  (dato_1S<dato_2S)?1'b1:1'b0;
      end
      else if (alu_pkt.ALU_CTRL==4'h2) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  (dato_1U<dato_2U)?1'b1:1'b0;
      end
      else if (alu_pkt.ALU_CTRL==4'h3) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  (dato_1S>dato_2S)?1'b1:1'b0 ;
      end
      else if (alu_pkt.ALU_CTRL==4'h4) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  (dato_1U>dato_2U)?1'b1:1'b0;
      end
      else if (alu_pkt.ALU_CTRL==4'h5) begin 
        resultado =  dato_1S+dato_2S;
        if (alu_pkt.Cin) resultado++;
        sc_N =  resultado[31];
        sc_C=alu_pkt.Cin;
        for (int i=0; i<=31; i++) begin
          sc_C=(dato_1S[i]&dato_2S[i])|(sc_C&(dato_1S[i]^dato_2S[i]));
        end
        sc_O = (1'b0~^dato_1S[31]~^dato_2S[31]) & (dato_1S[31]^resultado[31]);
        sc_R=resultado;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'h6) begin 
        resultado =  dato_1U+dato_2U+alu_pkt.Cin;
        sc_O =  (1'b0~^dato_1U[31]~^dato_2U[31]) & (dato_1U[31]^resultado[31]);
        sc_C=alu_pkt.Cin;
        for (int i=0; i<=31; i++) begin
          sc_C=(dato_1U[i]&dato_2U[i])|(sc_C&(dato_1U[i]^dato_2U[i]));
        end
        sc_N =  resultado[31];
        sc_R =  resultado;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'h7) begin 
        resultado =  dato_1U-dato_2U+alu_pkt.Cin;
        sc_R = resultado;
        sc_N = resultado[31];
        sc_C=alu_pkt.Cin;
        for (int i=0; i<=31; i++) begin
          sc_C=(dato_1U[i]&Complemento_2[i])|(sc_C&(dato_1U[i]^Complemento_2[i]));
        end
        sc_O = (1'b1~^dato_1U[31]~^dato_2U[31]) & (dato_1U[31]^resultado[31]);
        sc_Z = 0;
      end
      else if (alu_pkt.ALU_CTRL==4'h8) begin 
        sc_R =  alu_pkt.Data_A<<(alu_pkt.Data_B%32);
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'h9) begin 
        sc_R =  alu_pkt.Data_A>>(alu_pkt.Data_B%32);
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'ha) begin 
        sc_R =  dato_1S>>>(dato_2U%32);
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'hb) begin
        sc_R =  alu_pkt.Data_A+alu_pkt.Data_B;//alu_pkt.Data_A|alu_pkt.Data_B;
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'hc) begin 
        sc_R =  alu_pkt.Data_A^alu_pkt.Data_B;
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'hd) begin 
        sc_R =  alu_pkt.Data_A&alu_pkt.Data_B;
    	sc_O =  0;
        sc_N =  sc_R[31];
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'he) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  0;
      end
      else if (alu_pkt.ALU_CTRL==4'hf) begin 
        sc_R =  0;
    	sc_O =  0;
    	sc_N =  0;
    	sc_C =  0;
        sc_Z =  0;
      end
      if (sc_R==alu_pkt.result)   rev=rev+1;
      if (sc_N==alu_pkt.Negative) rev=rev+1;
      if (sc_C==alu_pkt.Carry)    rev=rev+1;
      if (sc_O==alu_pkt.Overflow) rev=rev+1;
      if (sc_Z==alu_pkt.Zero)     rev=rev+1;
      if (rev<5 & X>1) begin
        `uvm_error(get_type_name(),$sformatf("------MISMATCH FOUND------"))
        `uvm_info(get_type_name(),$sformatf("------ :: Send DATA       :: ------"),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato Cin: %0b",alu_pkt.Cin),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato AB: %0b",dato_1S),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato BB: %0b",dato_2S),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato AS: %0d",dato_1S),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato BS: %0d",dato_2S),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato AU: %0d",dato_1U),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Dato BU: %0d",dato_2U),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Op Code: %0h",alu_pkt.ALU_CTRL),UVM_LOW)
        `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)        
         `uvm_info(get_type_name(),$sformatf("------ :: READ DATA Match :: ------"),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Op code: %0h",alu_pkt.ALU_CTRL),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Expected Result: %0d Actual Result: %0d",sc_R,alu_pkt.result),UVM_LOW)
       `uvm_info(get_type_name(),$sformatf("Expected Zero: %0h Actual Zero: %0h",sc_Z,alu_pkt.Zero),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Expected Carry: %0h Actual Carry: %0h",sc_C,alu_pkt.Carry),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Expected Overflow: %0h Actual Overflow: %0h",sc_O,alu_pkt.Overflow),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Expected Negative: %0h Actual Negative: %0h",sc_N,alu_pkt.Negative),UVM_LOW)
          `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
      end
      else Y++;
      rev=0;
    end
    if (X==200000) begin
      P=(Y/X)*100;
      $display("El porcentaje de exito es : %0f",P);
    end
  endtask : run_phase
endclass : alu_scoreboard
