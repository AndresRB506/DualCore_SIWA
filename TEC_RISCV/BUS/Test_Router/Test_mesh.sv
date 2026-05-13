`timescale 1ns / 1ns
`default_nettype none
//`define DEBUG
`define PCKG_SZ 40 
`define BROADCAST {8{1'b1}}
`define ROWS 4
`define COLUMS 4
`define NUM_NTRFS 2*(`ROWS + `COLUMS) 
`define NUM_MSGS 2*(2*`ROWS + 2*`COLUMS-1)
`define FIFO_DEPTH 4
`define TIME_LIMIT 200000
`define FIFOS
`include "../../FIFO_Latches/fifo.sv"
`include "../../BUS/Library.sv"
`define LIB
`include "../Router_library.sv"

module router;
//#########################################################
//        DEFINITION OF  TEST VARS AND CLASSES
//#########################################################

 //inputs of the UUT: these are the variables to control in the test
  reg clk;
  reg reset;
  reg [`PCKG_SZ-1:0] data_out_i_in[(2*`ROWS+2*`COLUMS)];
  reg pndng_i_in[(2*`ROWS+2*`COLUMS)];
  reg pop[(2*`ROWS+2*`COLUMS)];
 //outputs of the UUT: these are the variables to read in the test
  wire popin[(2*`ROWS+2*`COLUMS)];
  wire pndng[(2*`ROWS+2*`COLUMS)];
  wire [`PCKG_SZ-1:0] data_out[(2*`ROWS+2*`COLUMS)];
 // miscelaneus variables.
  bit [7:0] src;
  bit [3:0] trgt_r;
  bit [3:0] trgt_c;
  bit mode;
  bit [`PCKG_SZ-34:0] pyld[3:0];
  bit [7:0] id;

  always_comb begin
    pyld[0] = {(`PCKG_SZ-34){1'b0}};
    pyld[1] = {(`PCKG_SZ-34)/2{2'b01}};
    pyld[2] = {(`PCKG_SZ-34)/2{2'b10}};
    pyld[3] = {(`PCKG_SZ-34){1'b1}};
  end

// This structure contain all the important fields for a message
  typedef struct {
    bit [7:0] nxt_jmp;
    bit [3:0] trgt_c;
    bit [3:0] trgt_r;
    bit [7:0] src;
    bit [7:0] id;
    bit mode;
    bit [`PCKG_SZ-34:0] pyld; 
    bit cmplt;
    int tm_snd;
    int tm_rcvd;
    int rcvd_in_ntrfs;
  } mnsj;
  mnsj recibido;
  mnsj enviado;

//#########################################################
//                   UUT DEFINITION
//#########################################################

  mesh_gnrtr #(.ROWS(`ROWS),.COLUMS(`COLUMS),.pckg_sz(`PCKG_SZ),.fifo_depth(`FIFO_DEPTH),.bdcst(`BROADCAST)) uut(
 .clk(clk),
 .reset(reset),
 .pndng(pndng),
 .data_out(data_out),
 .popin(popin),
 .pop(pop),
 .data_out_i_in(data_out_i_in),
 .pndng_i_in(pndng_i_in)
  );


//*******************************************
// input queues 
//*******************************************
// This class contain all the mesages to be send in the test, for each interface.

  class queues #(parameter int num_msgs = 4, parameter int drvrs = 4);
    protected int index[drvrs];
    protected mnsj data[drvrs][num_msgs];
 
    
    // This function is intende to load messages to the queue
    function bit push(mnsj mensaje);
      if(index[mensaje.src] < (num_msgs)) begin
        data[mensaje.src][index[mensaje.src]] = mensaje;
        index[mensaje.src]=index[mensaje.src]+1;
        $display("Messaje pushed to the queues:  from src %g, to trgt_r %g trgt_c %g , with mode %g id %g and pyld %h,  at time %g",mensaje.src,mensaje.trgt_r,mensaje.trgt_c,mensaje.mode,mensaje.id,mensaje.pyld,$time);
        return 1;
      end else begin
        $display("Error there is no space left in the queue for terminal src %g  at time  %g", mensaje.src,$time);
        $finish;
        return 0;
      end
    endfunction
    
    // This function removes a message from one of the queues.
    function bit pop( int drvr);
      if(index[drvr]>0)begin
        index[drvr] =index[drvr] -1;
        return 1;
      end else begin
        $display("Error there is nothing to pop from the queue in terminal %g at time  %g",drvr, $time);
        $finish;
        return 0;
      end
    endfunction
   // This function return the current message in a queue
    function mnsj current(int drvr);
      if(index[drvr] != 0)begin
        return data[drvr][index[drvr]-1];
      end else begin
        $display("ERROR: The queue for terminal %g  is empty, nothing to return at time %g",drvr,$time);
        $finish;
      end
    endfunction
    // This fucntion checks if there are mesages pending in a queue
    function bit get_pndng(int drvr);
      if(index[drvr] != 0)begin
        return  1;
      end else begin
        return 0;
      end
    endfunction
    //This function check if all the queues are empty   
    function bit empty();
      for(int i=0; i< drvrs; i=i+1) begin
        if(index[i] != 0) begin
          return 1;
        end
      end
        return 0;
    endfunction

  endclass
  queues #(.num_msgs(`NUM_MSGS),.drvrs(2*`ROWS+2*`COLUMS)) input_queues= new;


  //*******************************************
  // scoreboard for received and send messages 
  //*******************************************
  class scoreboard_mensajes #(parameter int drvrs = 4,parameter int num_msgs = 4);
    protected mnsj enviados[drvrs*num_msgs];
    protected int index = 0;
    protected int completed = 0;
    protected bit test_status = 0;
    protected  bit status;
    protected  bit [7:0]Source_ID;
    protected  bit [3:0]Msg_trgt_r;
    protected  bit [3:0]Msg_trgt_c;
    protected  bit [`PCKG_SZ-9:0] Msg_pyld;
    protected  int rcvd_in_trmnl;
    protected  int time_send;
    protected  int time_rcvd;
    protected  int Dly_in_clk_cycls;

    // This function add messages to the scoreboard to start the tracking.
    // If the message is pushed twice it assumes that the message is been received. 
    function bit push(mnsj mensaje, int rcvd_in_ntrfs);
      if(index <= (drvrs*num_msgs)) begin // if there is space in the scoreboard 
        for(int i = 0;i < index;i=i+1) begin
          if((enviados[i].src == mensaje.src)&(enviados[i].mode == mensaje.mode)&(enviados[i].id==mensaje.id)&(enviados[i].pyld==mensaje.pyld)) begin // if the message match a previous entry
            enviados[i].cmplt = 1;
            enviados[i].tm_rcvd = $time;
            enviados[i].rcvd_in_ntrfs = rcvd_in_ntrfs;
            $display("TRANSACTION COMPLETED: from src %g, to trgt_r: %g trgt_c: %g, with id %g, mode %g and pyld %h, received in terminal %g, at  at time %g",mensaje.src,mensaje.trgt_r,mensaje.trgt_c,mensaje.id,mensaje.mode,mensaje.pyld,rcvd_in_ntrfs,$time);
            return 1;
          end
        end // if the messaje is new
          enviados[index] = mensaje;
          enviados[index].tm_snd = $time;
          enviados[index].cmplt = 0;
          enviados[index].tm_rcvd = 0;
          index = index+1;
          $display("Message Pushed to the scoreboard: index: %g from src %g, to trgt_r: %g trgt_c: %g, with id %g. mode %g and pyld %h, received in terminal %g, at  at time %g",index,mensaje.src,mensaje.trgt_r,mensaje.trgt_c,mensaje.id,mensaje.mode,mensaje.pyld,rcvd_in_ntrfs,$time);
          return 1;
      end else begin // if there is no space left in the scoreboard
        $display("ERROR: There is no space left in the Scoreboard");
        $display("Message from src %g, to trgt_r: %g trgt_c: %g, with id %g mode %g and pyld %h, received in terminal %g, at  at time cannot be stored",mensaje.src,mensaje.trgt_r,mensaje.trgt_c,mensaje.id,mensaje.mode,mensaje.pyld,rcvd_in_ntrfs,$time);
        $finish;
        test_status = 0;
        return 0;
      end
    endfunction
    
    //this function creates a csv print of the information in the scoreboard
    function int report();
      $display("BEGIN_REPORT");
      $display("status,Source_ID,Msg_trgt_r,Msg_trgt_c,,Msg_pyld,rcvd_in_trmnl,time_send,time_rcvd,Dly_in_clk_cycls");
      test_status = 1;
      for(int i = 0;i < index;i=i+1) begin
        status = enviados[i].cmplt;
        Source_ID=enviados[i].src;
        Msg_trgt_r=enviados[i].trgt_r;
        Msg_trgt_c=enviados[i].trgt_c;
        Msg_pyld =enviados[i].pyld;
        rcvd_in_trmnl= enviados[i].rcvd_in_ntrfs;
        time_send = enviados[i].tm_snd;
        time_rcvd = enviados[i].tm_rcvd;
        Dly_in_clk_cycls =time_rcvd-time_send;
        $display("%g,%g,%g,%g,%h,%g,%g,%g,%g",status,Source_ID,Msg_trgt_r,Msg_trgt_c,Msg_pyld,rcvd_in_trmnl,time_send,time_rcvd,Dly_in_clk_cycls);
        if(status == 0) begin
          test_status = 0;
        end
      end
      $display("END_REPORT");
      if(status == 1) begin
        $display("TEST FINISHED SUCCESFULLY");
        return 1;
      end else begin
        $display("TEST FAILED");
        return 1;
      end
    endfunction
    
    // This function check if  all the messages send are already received and if all the intended messages are already send
    function bit all_snd_nd_received();
      if(index == drvrs*num_msgs)begin
        for(int i = 0;i < index;i=i+1) begin
          if (enviados[i].cmplt==0) begin
            return 0;
          end
        end
        return 1;
      end
      return 0;
    endfunction
  endclass
 
  scoreboard_mensajes #(.drvrs((2*`ROWS + 2*`COLUMS)),.num_msgs(`NUM_MSGS)) mensajes_enviados = new;

///////////////////////////////////
// Here the Test Begins!!!!!
///////////////////////////////////

initial begin
  clk=0;
  reset = 1;
  for(int i = 0; i <`NUM_NTRFS; i = i+1) begin
    pndng_i_in[i] = 1'b0;
    data_out_i_in[i] = {`PCKG_SZ{1'b0}};
    pop[i] = 1'b0;
  end
end

always #1 clk=~clk;   
always@(posedge clk)begin
  prueba();
end

task prueba ();
  //////////////////////////////////////////////////
  //  Initialize the queues of messages at time 1 //
  //////////////////////////////////////////////////
  if($time==1) begin
//    for(src = 0; src < (2* `ROWS+ 2*`COLUMS); src = src+1) begin
//      if(src == (2* `ROWS+ 2*`COLUMS - 1) begin
//        trgt_r = 0; 
//        trgt_c = 0;
//      end else begin
//        trgt = src+1;
//      end 
//      for(int i=0;i<`NUM_MSGS;i=i+1) begin  
        enviado.trgt_r =5;
        enviado.trgt_c =4;
        enviado.mode = 0;
        enviado.pyld =pyld[2]; // here the payload will alternate
        enviado.src =1;
        enviado.id = 1;
        enviado.cmplt = 0;
        enviado.tm_snd = 0;
        enviado.tm_rcvd = 0;
        enviado.rcvd_in_ntrfs = 255;
        input_queues.push(enviado);

        enviado.trgt_r =4;
        enviado.trgt_c =5;
        enviado.mode = 1;
        enviado.pyld =pyld[0]; // here the payload will alternate
        enviado.src =4;
        enviado.id = 1;
        enviado.cmplt = 0;
        enviado.tm_snd = 0;
        enviado.tm_rcvd = 0;
        enviado.rcvd_in_ntrfs = 255;
        input_queues.push(enviado);
//      end
//    end
  end else begin 
    /////////////////////////////////////////////////////////////////////////////
    // here the protocol to comunicate with the bus interfaces is implemented  //
    /////////////////////////////////////////////////////////////////////////////
    reset =0;
    for(int i = 0; i <`NUM_NTRFS; i = i+1) begin
    //////////////////////////////////////
    //check for data  pendning to send  //
    //////////////////////////////////////
      if (popin[i] == 1) begin
       $display("Send through terminal %g",i);
       enviado = input_queues.current(i);
       mensajes_enviados.push(enviado,255);
       input_queues.pop(i);
      end
      if (input_queues.get_pndng(i) != 0) begin
         enviado = input_queues.current(i);
         data_out_i_in[i] = {{8{1'b0}},enviado.trgt_r,enviado.trgt_c,enviado.mode,enviado.src,enviado.id,enviado.pyld};
         pndng_i_in[i] = 1'b1;
      end else begin
         pndng_i_in[i] = 1'b0;
         data_out_i_in[i] ={`PCKG_SZ{1'b0}};
      end       
    ////////////////////////////////////////
    //check for data  pendning to receive //
    ////////////////////////////////////////
      if((pndng[i]==1)&&(pop[i]==0)) begin
        $display("Received in terminal %g",i);
        pop[i]=1;
        recibido.trgt_r = data_out[i][`PCKG_SZ-9:`PCKG_SZ-12];
        recibido.trgt_c = data_out[i][`PCKG_SZ-13:`PCKG_SZ-16];
        recibido.mode = data_out[i][`PCKG_SZ-17];
        recibido.src = data_out[i][`PCKG_SZ-18:`PCKG_SZ-25];
        recibido.id = data_out[i][`PCKG_SZ-26:`PCKG_SZ-33];
        recibido.pyld = data_out[i][`PCKG_SZ-34:0];
        mensajes_enviados.push(recibido,i);
      end else begin
        pop[i] = 0;
      end
    end
  /////////////////////////////////////////////////////////////////////////////////
  // Check if all the messages are send and received in order to finish the test //
  /////////////////////////////////////////////////////////////////////////////////
    if(mensajes_enviados.all_snd_nd_received()) begin
      mensajes_enviados.report();
      $finish;
    end
  //////////////
  // Timeout  //
  //////////////
    if($time >= `TIME_LIMIT) begin
      $display("ERROR: Test Timeout");
      mensajes_enviados.report();
      $finish;
    end
  end
endtask
  
endmodule
