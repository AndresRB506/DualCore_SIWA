//////////////////////////////////////////////
//  UVM Monitor                             //
//  Monitor, hereda de UVM Monitor          //
//  Realizar lectura de señales provenientes//
//  de la interfaz y el DUT                 //
//  Programador: Javier Espinoza Rivera     //
//  Supervisor: Roberto Molina              //
//////////////////////////////////////////////

class Monitor extends uvm_monitor; 
  
  `uvm_component_utils(Monitor); // Declaracion en la fabrica
  

  uvm_analysis_port #(mon_sb) mon_analysis_port;    // Declaracion de puerto de analisis
                                                    // Metodo de comunicar al Scoreboard
  virtual wrapper_if v_if;

  ///////////// RAL Variables /////////////
  uvm_status_e  status;
  bit [7:0] fsm_ctrl_status;  // Destino del cur_state backdoor mirror
  bit [32]reg_values[31];     // Arreglo de destino Regsitros Generales

  
  ////////////////  RAL Instances  /////////////////
  csr_reg_block ral_csr;  
  reg_file_block ral_general;


  ////////////////  Constructor   //////////////////
	function new (string name = "Monitor", uvm_component parent=null);
	    super.new(name,parent);
	endfunction
  
  function void build_phase(uvm_phase phase);

    ///////////// CONFIGDB GET METHOD /////////////////
    // get interface
    if(!uvm_config_db#(virtual wrapper_if)::get(this,"","v_if",v_if))begin
      `uvm_fatal("MON","uvm_config_db::get failed wrapper_if")
    end

    // get RAL modulo CSR backdoor
    if(!uvm_config_db#(csr_reg_block)::get(null, "","ral_csr", ral_csr))begin
      `uvm_fatal("MON","uvm_config_db::get failed ral_csr")
    end
    // get RAL registros backdoor
    if(!uvm_config_db#(reg_file_block)::get(null, "","ral_general", ral_general))begin
      `uvm_fatal("MON","uvm_config_db::get failed ral_general")
    end
    ////////////////////////////////////////////////////

    mon_analysis_port=new("mon_analysis_port",this); 

    for (int r = 0; r < 31; r++) begin
      this.reg_values[r] = 0;
      `uvm_info("MON", $sformatf("REG %h", this.reg_values [r]), UVM_DEBUG)
    end   

  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
      RST_check();
      Backdoor_access();
      //concurrent_task_1...
      //concurrent_task_2...
    join

  endtask


  virtual task RST_check(); // Revision concurrente de senal de RESET
    int rst_high;           // Bandera de RESET HIGH
    forever begin

      @(posedge v_if.clk);  // Esperar el flanco positivo de CLK
        if (v_if.reset==1 && rst_high == 0) begin   // En caso de RESET y !rst_high
            mon_sb mon_sb = new;                    // Creacion de un mensaje
            rst_high = 1;                           // Levantar la bandera
            mon_sb.reset = 1;                       // Indicador de evento de reset
            mon_sb.event_time = $time();            // Almacenar tiempo del evento
            `uvm_info("MON", $sformatf("t=%0t reset=%0b",               // INFO:UVM_MEDIUM
                      mon_sb.event_time, mon_sb.reset), UVM_DEBUG)     // Datos del paquete
            mon_analysis_port.write (mon_sb);       // Escritura del mensaje en el AP
        end
        if(v_if.reset==0) rst_high = 0;     // Bajar bandera en !RESET

    end
  endtask : RST_check



  //////////////////// BACKDOOR ACCESS TASK /////////////////////
  virtual task Backdoor_access(); // Acceso a registros por medio de Backdoor
    int same_state = 0;
    bit [31:0] csr_data;
    forever begin
      @(posedge v_if.clk);
      
      ral_csr.control_sm.peek(status, fsm_ctrl_status); // Acceso a FSM de unidad de control
      //if (fsm_ctrl_status == 8'h05) begin               // Evaluar en "fetch3"
      if (tb_top.dut_wr.uut.TOP.Reg_file.write) begin       // Evaluar en RF's write signal 
        if(same_state == 0) begin
          mon_sb mon_sb = new; 
          same_state = 1;                           
          mon_sb.reset = 0;
          mon_sb.event_time = $time();
          mon_sb.reg_values[0] = tb_top.dut_wr.uut.TOP.pc;
          `uvm_info("MON",$sformatf("%0d PC RAL = %h",
                                      $time,mon_sb.reg_values[0]),UVM_HIGH)
          for(int i = 0; i < 31; i++) begin   // Iterar sobre la cantidad de registros en el banco
            for (int h = 0; h < 32; h++) begin  // Iterar sobre latches, componentes del registro 
              automatic int l = h;
              ////////// Mirror de latches ///////////
              ral_general.Reg_General_array[i].Latch_General_array[l].peek(status, reg_values [i][31-l]); // i = 0 => PC 
              ////////// Copia en "reg_values" /////////
            end
            mon_sb.reg_values[i+1] = reg_values [i];  // Escribir enformacion en paquete
            `uvm_info("MON",$sformatf("%0d General [%0d] RAL = %h",
                                      $time,i,reg_values[i]),UVM_DEBUG)  // INFO: Contenido de los registros caragdo en paquete al Sb
          end
          ral_csr.csr_reg_backdoor(ral_csr.ral_interrupt1_i, csr_data);
          mon_sb.interrupt1 = csr_data;
          ral_csr.csr_reg_backdoor(ral_csr.ral_interrupt2_i, csr_data);
          ral_csr.csr_reg_backdoor(ral_csr.gpio_i, csr_data);
          ral_csr.csr_reg_backdoor(ral_csr.timer_valor_i, csr_data);
          `uvm_info(get_full_name(),$sformatf("%0d TIMER RAL = %h",
                                      $time,csr_data),UVM_DEBUG)
          
          mon_analysis_port.write (mon_sb);  // Escritura del mensaje en el AP
        end  
      end
      else same_state = 0;
    end
  endtask : Backdoor_access
  
endclass : Monitor

