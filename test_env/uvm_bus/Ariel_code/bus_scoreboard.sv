class bus_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  bus_seq_item pkt_qu[$];
  bit [1:0]Num; 
  

  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  `uvm_component_utils(bus_scoreboard)
  uvm_analysis_imp#(bus_seq_item, bus_scoreboard) item_collected_export;
  

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(bus_seq_item pkt);
    
    //pkt.print();
    pkt_qu.push_back(pkt);
    //$display("Scoreboard Data MBC: %h",pkt.D_push_mbc);
    //$display("Scoreboard Data SPI: %h",pkt.D_push_spi);
    //$display("Scoreboard Data UART: %h",pkt.D_push_uart);
    $display("Scoreboard pndng_mbc:", pkt.pndng_mbc);
    $display("Scoreboard pndng_spi:", pkt.pndng_spi);
    $display("Scoreboard pndng_uart:", pkt.pndng_uart);
    $display("dato posicion 01=", pkt.D_push_mbc);
    $display("numero entrada=",pkt.D_push_mbc);
  endfunction : write
  
  virtual task run_phase(uvm_phase phase);
    bus_seq_item bus_pkt; 
    
    forever begin
      wait(pkt_qu.size() >0);
      bus_pkt = pkt_qu.pop_front();
      $display("dato mbc= %b", bus_pkt.D_push_mbc); 
      Num=bus_pkt.D_push_mbc[64:63];
      $display("numero gay= %b",Num);
      
     
      
      if (bus_pkt.pndng_mbc==1 && bus_pkt.push_mbc==1)begin
        bus_pkt.D_pop_mbc = bus_pkt.D_push_mbc;
        $display("scoreboard Data salida: %h", bus_pkt.D_pop_mbc);
      end
      
      if (bus_pkt.pndng_spi==1 && bus_pkt.push_spi==1)begin
        bus_pkt.D_pop_spi = bus_pkt.D_push_spi;
      end
      
      if (bus_pkt.pndng_uart==1 && bus_pkt.push_uart==1)begin
        bus_pkt.D_pop_uart = bus_pkt.D_push_uart;
      end
      
      
      if (bus_pkt.push_mbc==1) begin 
        if (bus_pkt.pndng_mbc==1) begin 
          if(Num== 2'b01)begin 
            if(bus_pkt.push_spi==1 && bus_pkt.pndng_spi==1)begin 
              bus_pkt.D_pop_spi=bus_pkt.D_push_mbc;
            end
          end
        end
      end
      
      if (bus_pkt.push_mbc==1) begin 
        if (bus_pkt.pndng_mbc==1) begin 
          if(Num== 2'b10)begin 
            if(bus_pkt.push_uart==1 && bus_pkt.pndng_uart==1)begin 
              bus_pkt.D_pop_uart=bus_pkt.D_push_mbc;
            end
          end
        end
      end
      
      if (bus_pkt.push_spi==1) begin 
        if (bus_pkt.pndng_spi==1) begin 
          if(Num== 2'b00)begin 
            if(bus_pkt.push_mbc==1 && bus_pkt.pndng_mbc==1)begin 
              bus_pkt.D_pop_mbc=bus_pkt.D_push_spi;
            end
          end
        end
      end
      
      if (bus_pkt.push_spi==1) begin 
        if (bus_pkt.pndng_spi==1) begin 
          if(Num== 2'b10)begin 
            if(bus_pkt.push_uart==1 && bus_pkt.pndng_uart==1)begin 
              bus_pkt.D_pop_uart=bus_pkt.D_push_spi;
            end
          end
        end
      end
      
      if (bus_pkt.push_uart==1) begin 
        if (bus_pkt.pndng_uart==1) begin 
          if(Num== 2'b00)begin 
            if(bus_pkt.push_mbc==1 && bus_pkt.pndng_mbc==1)begin 
              bus_pkt.D_pop_mbc=bus_pkt.D_push_uart;
            end
          end
        end
      end
      if (bus_pkt.push_uart==1) begin 
        if (bus_pkt.pndng_uart==1) begin 
          if(Num== 2'b01)begin 
            if(bus_pkt.push_spi==1 && bus_pkt.pndng_spi==1)begin 
              bus_pkt.D_pop_spi=bus_pkt.D_push_uart;
            end
          end
        end
      end
             
      
      
      
      
    end
    
   endtask 
      
endclass 
        
      