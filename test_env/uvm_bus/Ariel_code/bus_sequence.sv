class bus_sequence extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_sequence)
  
  
  function new(string name = "bus_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(bus_sequencer)
  
  virtual task body();
   repeat(2) begin
    req = bus_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass

class device_mbc extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(device_mbc)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "device_mbc");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==1;})
    `uvm_do_with(req,{req.push_mbc==1;})
    `uvm_do_with(req,{req.pndng_spi==0;})
    `uvm_do_with(req,{req.push_spi==0;})
    `uvm_do_with(req,{req.pndng_uart==0;})
    `uvm_do_with(req,{req.push_uart==0;})
  endtask
endclass

class device_spi extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(device_spi)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "device_spi");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==0;})
    `uvm_do_with(req,{req.push_mbc==0;})
    `uvm_do_with(req,{req.pndng_spi==1;})
    `uvm_do_with(req,{req.push_spi==1;})
    `uvm_do_with(req,{req.pndng_uart==0;})
    `uvm_do_with(req,{req.push_uart==0;})
  endtask
endclass

class device_uart extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(device_uart)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "device_uart");
    super.new(name);
  endfunction
  
  virtual task body();
    //$display("Sequence Data UART: %h",req.D_push_uart);
    `uvm_do_with(req,{req.pndng_mbc==0;})
    `uvm_do_with(req,{req.push_mbc==0;})
    `uvm_do_with(req,{req.pndng_spi==0;})
    `uvm_do_with(req,{req.push_spi==0;})
    `uvm_do_with(req,{req.pndng_uart==1;})
    `uvm_do_with(req,{req.push_uart==1;})
  endtask
endclass
  
class device_mbctospi extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(device_mbctospi)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
    function new(string name = "device_mbctospi");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==1;})
    `uvm_do_with(req,{req.push_mbc==1;})
    `uvm_do_with(req,{req.pndng_spi==1;})
    `uvm_do_with(req,{req.push_spi==1;})
  endtask
endclass
    
    class device_mbctouart extends uvm_sequence#(bus_seq_item);
  
      `uvm_object_utils(device_mbctouart)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
      function new(string name = "device_mbctouart");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==1;})
    `uvm_do_with(req,{req.push_mbc==1;})
    `uvm_do_with(req,{req.pndng_uart==1;})
    `uvm_do_with(req,{req.push_uart==1;})
  endtask
      endclass
      
class device_spitombc extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(device_spitombc)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
        function new(string name = "device_spitombc");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==1;})
    `uvm_do_with(req,{req.push_mbc==1;})
    `uvm_do_with(req,{req.pndng_spi==1;})
    `uvm_do_with(req,{req.push_spi==1;})

  endtask
 endclass
        
class device_spitouart extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(device_spitouart)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
       function new(string name = "device_spitouart");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_spi==1;})
    `uvm_do_with(req,{req.push_spi==1;})
    `uvm_do_with(req,{req.pndng_uart==1;})
    `uvm_do_with(req,{req.push_uart==1;})
  endtask
  endclass
          
class device_uarttombc extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(device_uarttombc)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
       function new(string name = "device_uarttombc");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_mbc==1;})
    `uvm_do_with(req,{req.push_mbc==1;})
    `uvm_do_with(req,{req.pndng_uart==1;})
    `uvm_do_with(req,{req.push_uart==1;})
  endtask
   endclass

class device_uarttospi extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(device_uarttospi)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
         function new(string name = "device_uarttospi");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.pndng_spi==1;})
    `uvm_do_with(req,{req.push_spi==1;})
    `uvm_do_with(req,{req.pndng_uart==1;})
    `uvm_do_with(req,{req.push_uart==1;})
  endtask
endclass

