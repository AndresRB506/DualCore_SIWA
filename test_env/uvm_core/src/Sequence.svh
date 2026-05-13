
class gen_sequence_item extends uvm_sequence #(drv_item);
    `uvm_object_utils(gen_sequence_item);

    function new (string name = "gen_sequence_item");
        super.new(name);
    endfunction

    function void build_phase(uvm_phase phase);

    endfunction : build_phase

    virtual task body();
        uvm_component test;
        string testname;
        test = uvm_root::get().find("uvm_test_top");   
        testname = test.get_type_name();
        $display("TEST NAME: %s",testname);
        for (int i = 0; i <= 1 ; i++) begin  
            if (i == 1) begin 
                drv_item drv_item_i = drv_item::type_id::create("drv_item_i");
                start_item(drv_item_i);
                drv_item_i.delay = 0;
                drv_item_i.sim_time = 0;
                drv_item_i.start = 0;
                drv_item_i.stop = 1;
                `uvm_info("SEQ",$sformatf("New item %0s", drv_item_i.item_str_content()),UVM_LOW)
                finish_item(drv_item_i);
                
            end

            else begin
                drv_item drv_item_i = drv_item::type_id::create("drv_item_i");
                start_item(drv_item_i);
                drv_item_i.delay = 500000;
                drv_item_i.sim_time = 300000;
                drv_item_i.start = 1;
                drv_item_i.stop = 0;
                `uvm_info("SEQ",$sformatf("New item %0s", drv_item_i.item_str_content()),UVM_LOW)
                finish_item(drv_item_i);

            end
            

        end
    endtask : body

endclass : gen_sequence_item
