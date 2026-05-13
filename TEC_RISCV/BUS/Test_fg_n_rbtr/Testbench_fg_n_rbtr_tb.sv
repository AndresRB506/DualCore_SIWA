`timescale 1ns / 1ns
`default_nettype none
`define PCKG_SZ 32 
`define BROADCAST {8{1'b1}}
`define DRVRS 4
`define BITS 1

module Sim_bs_systm;
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
//                VARIABLE DEFINITION
//#########################################################
  reg [7:0] target [`DRVRS-1:0];
  int i = 0;
  int k = 0;
  int etapa = 0;
  int mensajes_enviados_turno = 0;
  int mensajes_recibidos [`BITS][`DRVRS];
  int mnsgs_rcbds = 0;

//#########################################################
//                   INITIAL
//#########################################################

initial begin
$dumpfile("vcd_file.vcd");
$dumpvars(0,Sim_bs_systm);
//$vcdplusfile ("Ronny.vpd");
//$vcdpluson;
  clk=0;
  reset =1;
  for(i=0;i<`DRVRS;i=i+1)
  begin
    target[i] = i;
  end
end

  always #1 clk=~clk;   
  always @(posedge clk)begin
    prueba();
  end


//#########################################################
//                   TASK DEFINITION
//#########################################################
  
  task prueba ();
    reset = 0;
    for(k=0;k <`BITS;k=k+1)begin
      for(i=0;i<`DRVRS;i=i+1)begin
        pndng[k][i] = (i==etapa)?{1'b1}:{1'b0};
//        $display("at time %g driver %g pnding= %h",$time,i,pndng[k][i]);
        case(mensajes_enviados_turno)
          0: D_pop[k][i]= (i != `DRVRS-1)?{target[i+1],{`PCKG_SZ-8{1'b0}}}:{target[0],{`PCKG_SZ-8{1'b0}}};
          1: D_pop[k][i]= (i != `DRVRS-1)?{target[i+1],{`PCKG_SZ-8{1'b1}}}:{target[0],{`PCKG_SZ-8{1'b1}}};
          2: D_pop[k][i]= (i != `DRVRS-1)?{target[i+1],{(`PCKG_SZ-8)/2{2'b01}}}:{target[0],{(`PCKG_SZ-8)/2{2'b01}}};
          3: D_pop[k][i]= (i != `DRVRS-1)?{target[i+1],{(`PCKG_SZ-8)/2{2'b10}}}:{target[0],{(`PCKG_SZ-8)/2{2'b10}}};
          default:D_pop[k][i]= (i != `DRVRS-1)?{target[i+1],{`PCKG_SZ-8{1'b0}}}:{target[0],{`PCKG_SZ-8{1'b0}}};
        endcase
      end
    end

    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)
        begin
          if( push[k][i] == 1 )begin
            $display("At time %t: in terminal %g bus %g message saved. target: %g, message: %h ",$time,i,k, D_push[k][i][`PCKG_SZ-1:`PCKG_SZ-8],D_push[k][i][`PCKG_SZ-9:0]);
            mensajes_recibidos[k][i] =mensajes_recibidos[k][i]+1;
          end
        end
    end

    for(k=0;k<`BITS;k=k+1)begin
        for(i=0;i<`DRVRS;i=i+1)
        begin
          if( pop[k][i] == 1 )begin
            $display("At time %t: in terminal %g bus %g message pop. target: %g,message: %h",$time,i,k, D_pop[k][i][`PCKG_SZ-1:`PCKG_SZ-8],D_pop[k][i][`PCKG_SZ-9:0]);
            etapa =(mensajes_enviados_turno >= 3)?etapa+1:etapa;
	    mensajes_enviados_turno=(mensajes_enviados_turno >= 3)?0:mensajes_enviados_turno+1;
          end        
        end
    end
 
  if($time >= 2000)begin
    $display("Test_finalizado: Timeup");
    $finish;
  end

  if(etapa >= `DRVRS) begin
    etapa = etapa+1;
    mnsgs_rcbds = 0;
    for(k=0;k <`BITS;k=k+1)begin
      for(i=0;i<`DRVRS;i=i+1)begin
        mnsgs_rcbds=( mensajes_recibidos[k][i] == 4)?mnsgs_rcbds+1:mnsgs_rcbds;
      end
    end
    if(mnsgs_rcbds == `BITS*`DRVRS)begin
      $display("Test_finalizado: etapas concluidas mensajes recibidos %g",mnsgs_rcbds*4);
      $finish;
    end
  end

  endtask

endmodule
