`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 32 
`define BROADCAST {8{1'b1}}
`define DRVRS 2
`define BITS 1
`define NUM_MSGS 4

module Sim_bs_systm;

//#########################################################
//               UUT INTERFACE DEFINITION
//#########################################################
 //inputs
  reg clk;
  reg reset;
  reg pndng[`BITS-1:0][`DRVRS-1:0];
  reg [`PCKG_SZ-1:0] D_pop[`BITS-1:0][`DRVRS-1:0];
 //outputs
  wire push[`BITS-1:0][`DRVRS-1:0];
  wire pop[`BITS-1:0][`DRVRS-1:0];
  wire [`PCKG_SZ-1:0] D_push[`BITS-1:0][`DRVRS-1:0];

//#########################################################
//                   UUT DEFINITION
//#########################################################

 bs_gnrtr_n_rbtr #(`BITS,`DRVRS,`PCKG_SZ,`BROADCAST) uut(
  .clk(clk),
  .reset(reset),
  .pndng(pndng),
  .push(push),
  .pop(pop),
  .D_pop(D_pop),
  .D_push(D_push)
);

//#########################################################
//        DEFINITION OF  TEST VARS
//#########################################################
  int i = 0;
  int k = 0;
  int y = 0;
  int aux_counter = 0;
  typedef struct {
    bit [7:0] trgt;
    bit [`PCKG_SZ-9:0] pyld; 
    bit [7:0] src;
    bit [7:0] rcvd;
    bit [7:0] bt;
    bit cmplt;
    int tm_snd;
    int tm_rcvd;
  } mnsj;
  mnsj recibido;
  mnsj enviado;
  mnsj auxiliar;
  mnsj tipos_de_mensajes[`NUM_MSGS];
  
  //*******************************************
  // input queues 
  //*******************************************
  class queues #(parameter int num_msgs = 4,parameter int bits =1, parameter int drvrs = 4);
    protected bit pndng_msgs[bits][drvrs];
    protected int index[bits][drvrs];
    mnsj data [bits][drvrs][num_msgs];
    
    function bit push(mnsj mensaje);
      if(index[mensaje.bt][mensaje.src] < (num_msgs)) begin
        data[mensaje.bt][mensaje.src][index[mensaje.bt][mensaje.src]] = mensaje;
        index[mensaje.bt][mensaje.src]=index[mensaje.bt][mensaje.src]+1;
        pndng_msgs[mensaje.bt][mensaje.src] = {1'b1}; 
        return 1;
      end else begin
        $display("Error there is no space left in the queue for bus %g ID %g",mensaje.bt,mensaje.trgt);
        return 0;
      end
    endfunction
    
    function bit pop(int bt, int drvr);
      if(index[bt][drvr]>0)begin
        index[bt][drvr] =index[bt][drvr] -1;
        pndng_msgs[bt][drvr] = (index[bt][drvr] == 0)?{1'b0}:{1'b1}; 
        return 1;
      end else begin
        $display("Error there is nothing to pop from the queue in bus %g ID %g",bt,drvr);
        return 0;
      end
    endfunction

    function mnsj current(int bt, int drvr);
      if(index[bt][drvr] != 0)begin
        return data[bt][drvr][index[bt][drvr]-1];
      end else begin
        $display("ERROR: The queue for bit %g drvr %g is empty, nothing to return at time %g",bt,drvr,$time);
         return data[bt][drvr][0];
      end
    endfunction
    
    function bit get_pndng(int bt,int drvr);
      return  pndng_msgs[bt][drvr];
    endfunction
   
    function bit empty();
      foreach(pndng_msgs[i,j]) begin
        if(pndng_msgs[i][j]==1) begin
          return 0;
        end
      end
        return 1;
    endfunction
  endclass
  queues #(.num_msgs(`NUM_MSGS),.bits(`BITS),.drvrs(`DRVRS)) input_queues= new;

  //*******************************************
  // scoreboard for received and send messages 
  //*******************************************
  class vector_mensajes #(parameter int bits = 1, parameter int drvrs = 4);
    protected mnsj enviados[bits*drvrs* 4];
    protected int index = 0;
    protected int completed = 0;
    protected bit test_status[bits] = '{bits{1}};

    function bit push(mnsj mensaje);
      if(index < (bits*drvrs* 4)) begin
        enviados[index] = mensaje;
        index = index+1;
        return 1;
      end else begin
        test_status[mensaje.bt] = 0;
        return 0;
      end
    endfunction

    function bit find(mnsj mensaje);
      foreach (enviados[i]) begin
        if ((enviados[i].pyld == mensaje.pyld)&&(enviados[i].trgt == mensaje.trgt)&&(enviados[i].cmplt==0)&&(enviados[i].bt == mensaje.bt)) begin
          enviados[i].cmplt = 1;
          enviados[i].tm_rcvd =  mensaje.tm_rcvd;
          enviados[i].rcvd = mensaje.rcvd;
          completed = completed + 1;
          return 1;
        end
      end
      test_status[mensaje.bt] =0;
      return 0;
    endfunction
  
    function int report();
      $display("BEGIN_REPORT");
      $display("status,time_send,time_rcvd,bus,source_ID,receiver_ID,delay_clk_cycles,msg_payload,msg_trgt");
      foreach (enviados[i]) begin
        if(enviados[i].tm_rcvd != 0) begin
          if(enviados[i].trgt == enviados[i].rcvd) begin
            $display("%g,%g,%g,%g,%g,%g,%g,%h,%g",enviados[i].cmplt,enviados[i].tm_snd,enviados[i].tm_rcvd,enviados[i].bt,enviados[i].src,enviados[i].rcvd,(enviados[i].tm_rcvd-enviados[i].tm_snd-1)/2,enviados[i].pyld,enviados[i].trgt);
            if(enviados[i].cmplt==0) begin
              test_status[enviados[i].bt] = 0;
            end
          end else begin
            $display("0,%g,%g,%g,%g,%g,%g,%h,%g",enviados[i].tm_snd,enviados[i].tm_rcvd,enviados[i].bt,enviados[i].src,enviados[i].rcvd,(enviados[i].tm_rcvd-enviados[i].tm_snd-1)/2,enviados[i].pyld,enviados[i].trgt);
            test_status[enviados[i].bt] = 0;
          end
        end
      end
      foreach (test_status[i]) begin
        if (test_status[i]) begin
          $display("Test_Status: PASS, on bus %g",i);
        end else begin
          $display("Test_Status: FAIL, on bus %g",i);
        end
      end
      $display("Transactions successfully completed %g",completed);
      $display("END_REPORT");
      return 1;
    endfunction
    
    function bit all_received();
      int finished = 0;
      foreach (enviados[i]) begin
        if((enviados[i].cmplt == 0)&&((enviados[i].src+enviados[i].trgt) != 0))begin
          return 0;
        end
      end
        return 1;
    endfunction

  endclass
 
  vector_mensajes #(.bits(`BITS),.drvrs(`DRVRS)) mensajes_enviados = new;
//#########################################################
//                   INITIAL
//#########################################################

initial begin
$dumpfile("vcd_file.vcd");
$dumpvars(0,Sim_bs_systm.uut);
//$vcdplusfile ("Ronny.vpd");
//$vcdpluson;
  clk=0;
  reset =1;
end

  always #1 clk=~clk;   
  always @(posedge clk)begin
    prueba();
  end


//#########################################################
//                   TESTS DEFINITION
//#########################################################
  
  task prueba ();
    reset = 0;

    //************************************************************
    // at time 0 the queues get loaded with the pending messages 
    //************************************************************
    if($time == 1)begin
      aux_counter = 0;
      $display("Time = 1:");
      tipos_de_mensajes[0].pyld ={`PCKG_SZ-8{1'b0}};
      tipos_de_mensajes[1].pyld ={`PCKG_SZ-8{1'b1}};
      tipos_de_mensajes[2].pyld ={(`PCKG_SZ-8)/2{2'b01}};
      tipos_de_mensajes[3].pyld ={(`PCKG_SZ-8)/2{2'b10}};
      
      for(k=0;k <`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)begin
          for(y=0; y < 4; y=y+1)begin
            tipos_de_mensajes[y].trgt = (i==(`DRVRS-1))?0:i+1;
            tipos_de_mensajes[y].bt = k;
            tipos_de_mensajes[y].src = i;
            $display("Push Source %g target: %g payload:  %h Bit %g msg type %g",tipos_de_mensajes[y].src,tipos_de_mensajes[y].trgt,tipos_de_mensajes[y].pyld,tipos_de_mensajes[y].bt,y);
            input_queues.push(tipos_de_mensajes[y]);
            aux_counter = aux_counter +1;
          end
        end
      end
    $display("%g messages pushed to the queues",aux_counter);
    end

    //**************************************
    // Declare the connections with the UUT
    //**************************************
    for(k=0;k <`BITS;k=k+1)begin
      for(i=0;i<`DRVRS;i=i+1)begin
        if(input_queues.get_pndng(k,i))begin
          auxiliar = input_queues.current(k,i);
        end
        D_pop[k][i]={auxiliar.trgt,auxiliar.pyld};
        pndng[k][i] = input_queues.get_pndng(k,i);
      end
    end


    //************************************
    // Check on the receiving interfaces
    //************************************
    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)
        begin
          if( push[k][i] == 1 )begin
            recibido.trgt = D_push[k][i][`PCKG_SZ-1:`PCKG_SZ-8];
            recibido.bt = k;
            recibido.src = {8{1'b1}};
            recibido.pyld = D_push[k][i][`PCKG_SZ-9:0];
            recibido.tm_rcvd = $time;
            recibido.tm_snd =0;
            recibido.rcvd =i;
            if(0==mensajes_enviados.find(recibido)) begin
              $display("Error: the received message at time %g in terminal %g of bus %g sith payload %h is corrupted",$time,i,k,recibido.pyld);
            end

            $display("At time %t: in terminal %g bus %g message saved. target: %g, message: %h ",$time,i,k, D_push[k][i][`PCKG_SZ-1:`PCKG_SZ-8],D_push[k][i][`PCKG_SZ-9:0]);
          end
        end
    end

    //************************************
    // Check on the send interfaces
    //************************************
    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1) begin
          if( pop[k][i] == 1 )begin
            enviado.trgt =  D_pop[k][i][`PCKG_SZ-1:`PCKG_SZ-8];
            enviado.bt = k;
            enviado.src = i;
            enviado.pyld = D_pop[k][i][`PCKG_SZ-9:0];
            enviado.tm_snd = $time;
            enviado.cmplt = 0;
            enviado.tm_rcvd = 0;
            input_queues.pop(k,i);
            if(mensajes_enviados.push(enviado) == 0) begin 
              $display("ERROR: there are more send messages than expected");
            end
    //          auxiliar = input_queues.current(k,i);
    //          $display("%h",{auxiliar.trgt,auxiliar.pyld});
              $display("At time %t: in terminal %g bus %g message pop. target: %g,message: %h",$time,i,k,enviado.trgt,enviado.pyld);
          end        
        end
    end
 
    //************************************
    // Check on the end criteria 
    //************************************
 
  if($time >= 10000)begin
    mensajes_enviados.report();
    $display("Test_Status: FAILED, Timeup");
    $finish;
  end

  if(input_queues.empty()) begin
//    $display("Empty");
    if(mensajes_enviados.all_received())begin
      mensajes_enviados.report();
      $display("Test Finished");
      $finish;
    end
  end

  endtask

endmodule
