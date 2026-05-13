//////////////////////////////////////////
//	Driver								//
//	Modulo UVM encargado de manejar 	//
//	las señales que van al DUT			//
//	Programador: Javier Espinoza Rivera	//
// 	Supervisor: Roberto Molina 			//
//////////////////////////////////////////

class Driver extends uvm_driver #(drv_item); // Driver dedicado a recibir drv_item

	`uvm_component_utils(Driver); 	// Registro en Fabrica
	virtual wrapper_if v_if;		// Instancia de la interfaz
	int start_delay = 0;			// Valor de delay de inicio (Tiempo de RESET)
   	int sim_time_execution = 0;		// Tiempo de ejecucion
   	bit dropped;

	function new(string name = "Driver",uvm_component parent = null);
    	super.new(name,parent);
  	endfunction


  	function void build_phase(uvm_phase phase);
    	if(!uvm_config_db#(virtual wrapper_if)::get(this, "", "v_if", v_if)) begin
      		`uvm_error("","uvm_config_db::get failed")
    	end
  	endfunction


   	virtual task run_phase(uvm_phase phase);
   		super.run_phase(phase);
   		phase.raise_objection(this);	// Se levanta objecion para no avanzar de fase
   		if_known_initial_state();		// Iniciar intefaz en valor conocido (Seguro)
   		this.v_if.reset = 1'b1;			// Inicializar con RESET 
   		forever begin
   			drv_item drv_item_i;		// Instancia de "drv_item"
	   		sim_time_execution = 0;

	   		seq_item_port.get_next_item(drv_item_i);  	// Espera hasta drv_item disponible
	   		if(drv_item_i.stop==1) begin 				// Caso de indicacion para detener la simulacion
	   			`uvm_info("DRV",$sformatf("Se recibe Item para Detener %0d", $time()),UVM_HIGH)
	   			phase.drop_objection(this); 	// Dar paso a la siguiente fase
	   		end
	   		
	   		if(drv_item_i.start == 1) begin 	// Indicacion de iniciar ejecucion
	   			`uvm_info("DRV",$sformatf("Se recibe Item para reiniciar %0d", $time()),UVM_HIGH)
	   			apply_reset(drv_item_i.delay);		// Llamado a tarea de RESET, delay de reset como argumento

	   		end
	   		else begin
	   			`uvm_warning("DRV",$sformatf("Se recibe Item sin reiniciar %0d", $time()))
	   		end
	   		while (sim_time_execution < drv_item_i.sim_time) begin 	// Evaluacion de tiempo de simulacion
	   			sim_time_execution++;		// Se suma 1 a la cuenta en cada paso de simulacion
	   			#1;
	   		end
	   		seq_item_port.item_done();
	   		
   		end
   		
   		//
	endtask : run_phase

	task apply_reset(int delay);	// Tarea aplicar RESET
		int start_delay = 0;		
		while (start_delay < delay) begin 	// Evaluacion de cumplimiento de tiempo de reset
			this.v_if.reset = 1'b1;
	   		start_delay+= 1;		// Se suma 1 a la cuenta en cada paso de simulacion
	   		#1;
   		end
   		`uvm_info("DRV",$sformatf("Simulation Delay Finisheed at %0d", $time()),UVM_HIGH)
   		this.v_if.reset = 1'b0;
	endtask : apply_reset

	task if_known_initial_state();
		this.v_if.gpio = 0;
		this.v_if.full_range_level_shifter = 0;
		this.v_if.IS_Val = 0;
		this.v_if.IS_Config = 0;
		this.v_if.IS_Trigger = 0;
		this.v_if.maip = 0;
		this.v_if.Reg_GPIO_en = 0;
		this.v_if.Reg_GPIO_int = 0;
		this.v_if.Reg_GPIO_out = 0;
		this.v_if.TX_UART = 1;			// UART se colocan en uno para no activar el protocolo
		this.v_if.RX_UART = 1;
	endtask : if_known_initial_state

endclass