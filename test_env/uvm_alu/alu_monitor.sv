//-------------------------------------------------------------------------
//						alu_monitor - www.verificationguide.com 
//-------------------------------------------------------------------------`include "alu_coverage.sv"


class alu_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual alu_if vif;
  realtime covA, covB, covR, covC, covD;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(alu_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  alu_seq_item trans_collected;

  `uvm_component_utils(alu_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
   
  
  

  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i;
    int o;
    o=0;
    i=0;
    forever begin
      @(posedge vif.MONITOR.clk);
        i++;
        trans_collected.ALU_CTRL = vif.ALU_CTRL;
      	trans_collected.Data_A=vif.Data_A;
     	trans_collected.Data_B=vif.Data_B;
      	trans_collected.Cin=vif.Cin;
     	trans_collected.result=vif.result;
     	trans_collected.Zero=vif.Zero;
     	trans_collected.Overflow=vif.Overflow;
     	trans_collected.Carry=vif.Carry;
      	trans_collected.Negative=vif.Negative;
    	item_collected_port.write(trans_collected);
      if (i>= 5000) begin
        o++;
       $display("              ");
        $display("Intento : %0d",o);
        covA=vif.alu.Dato_1.get_coverage();
        $display("Coverage Data A : %0f",covA);
        covB=vif.alu.Dato_2.get_coverage();
        $display("Coverage Data B : %0f",covB);
        covC=vif.alu.Control.get_coverage();
        $display("Coverage ALU_CTRL : %0f",covC);
//        covD=vif.alu.CXO.get_coverage();
//        $display("Coverage Cruzado con Overflow : %0f",covD);
///////////////////////////////////////7        


/////////////////////////////////Zero///////////////////////////////////////////////
       $display("              ");
        $display("							Covertura de Bandera Zero");
////////Puntos de cobertura Existentes//////////////////////////////////////////////
//        covD=vif.alu.CXZ.get_coverage();
//        $display("Coverage Cruzado con Zero : %0f",covD);
////////Puntos de cobertura Nuevos//////////////////////////////////////////////////
        covD=vif.alu.CCXZ.get_coverage();
        $display("Coverage Cruzado Func. comparativas con bandera Zero : %0f",covD);
        covD=vif.alu.CnCXZcero.get_coverage();
        $display("Coverage Cruzado Func. NO comparativas con bandera Zero = 0 : %0f",covD);
//        covD=vif.alu.CnCXZuno.get_coverage();
//        $display("Coverage Cruzado Func. NO comparativas con bandera Zero = 1 : %0f",covD); 

/////////////////////////////////Carry///////////////////////////////////////////////
       $display("              ");
        $display("                                                 Covertura de Bandera Carry");
////////Puntos de cobertura Existentes//////////////////////////////////////////////
 //       covD=vif.alu.CXC.get_coverage();
 //       $display("Coverage Cruzado con Carry : %0f",covD);
////////Puntos de cobertura Nuevos//////////////////////////////////////////////////
        covD=vif.alu.CAXC.get_coverage();
        $display("Coverage Cruzado Func.aritmeticas con Carry : %0f",covD);
        covD=vif.alu.CnAXCcero.get_coverage();
        $display("Coverage Cruzado Func. NO aritmeticas con bandera Carry = 0 : %0f",covD);
//        covD=vif.alu.CnAXCuno.get_coverage();
//        $display("Coverage Cruzado Func. NO aritmeticas con bandera Carry = 1 : %0f",covD); 

/////////////////////////////////Overflow///////////////////////////////////////////////
       $display("              ");
        $display("                                              Covertura de Bandera Overflow");
////////Puntos de cobertura Existentes//////////////////////////////////////////////
 //       covD=vif.alu.CXC.get_coverage();
 //       $display("Coverage Cruzado con Carry : %0f",covD);
////////Puntos de cobertura Nuevos//////////////////////////////////////////////////
        covD=vif.alu.CAXO.get_coverage();
        $display("Coverage Cruzado Func.aritmeticas con Overflow: %0f",covD);
        covD=vif.alu.CnAXOcero.get_coverage();
        $display("Coverage Cruzado Func. NO aritmeticas con bandera Overflow = 0 : %0f",covD);
//        covD=vif.alu.CnAXOuno.get_coverage();
//        $display("Coverage Cruzado Func. NO aritmeticas con bandera Overflow = 1 : %0f",covD); 

/////////////////////////////////Resultado//////////////////////////////////////////
       $display("              ");
        $display("							Covertura de Resultado");
////////Puntos de cobertura Existentes//////////////////////////////////////////////
        covR=vif.alu.Resultado.get_coverage();
        $display("Coverage Result : %0f",covR);
////////Puntos de cobertura Nuevos//////////////////////////////////////////////////
        covD=vif.alu.CCXRcero.get_coverage();
        $display("Coverage Cruzado Func. comparativas con respuesta = 0 : %0f",covD);
//        covD=vif.alu.CCXRuno.get_coverage();
//        $display("Coverage Cruzado Func. comparativas con respuesta != 0 : %0f",covD);
/////////////////////////////////////////////////////////////////////////////////////

        
        
        i=0;
      end
      end
  endtask : run_phase

      
  
endclass : alu_monitor
