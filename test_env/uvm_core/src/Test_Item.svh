//////////////////////////////////////////////
//	Sequence Item							//
//	UVM Sequence Item, hereda de UVM   		//
//	object, establece valores para el Driver//
//	Programador: Javier Espinoza Rivera		//
// 	Supervisor: Roberto Molina 				//
//////////////////////////////////////////////

class drv_item extends uvm_sequence_item;
	//`uvm_object_utils(drv_item)
	int delay;
	int sim_time;
	bit start;
	bit stop;

	`uvm_object_utils_begin(drv_item)
		`uvm_field_int (delay, UVM_DEFAULT)
		`uvm_field_int (sim_time, UVM_DEFAULT)
		`uvm_field_int (start, UVM_DEFAULT)
		`uvm_field_int (stop, UVM_DEFAULT)
	`uvm_object_utils_end


	function new(string name = "drv_item");
		super.new(name);
	endfunction

	function void build_phase(uvm_phase phase);

	endfunction

	virtual function string item_str_content ();
        return $sformatf("Delay=%0d, SimulationTime=%0d", delay, sim_time);
    endfunction

endclass 



class mon_sb extends uvm_object; // Clase de datos del monitor al scoreboard

  int reset;                      // Indicador si el caso es de reset
  int event_time;                 // Valor de tiempo de simulacion donde sucede el evento
  bit [32] reg_values [32];         // Arreglo de bits para representar los registros generales
  bit [32] interrupt1;
  `uvm_object_utils_begin(mon_sb) // Declaracion en la fabrica
    `uvm_field_int (reset, UVM_DEFAULT)
    `uvm_field_int (event_time, UVM_DEFAULT)
  `uvm_object_utils_end

  ///////////Constructor///////////////
  function new(string name= "mon_sb");
      super.new(name);
  endfunction
endclass : mon_sb

class inst_fetch_item extends uvm_object;
	`uvm_object_utils(inst_fetch_item)
	bit [6:0] opcode;
	bit [4:0] rd;
	bit [4:0] rs1;
	bit [4:0] rs2;
	bit [2:0] func3;
	bit [6:0] func7;
	function new(string name = "inst_fetch_item");
		super.new(name);
	endfunction
endclass: inst_fetch_item