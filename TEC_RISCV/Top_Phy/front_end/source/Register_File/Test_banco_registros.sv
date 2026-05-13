`timescale 1ps / 1ps
`default_nettype none
`define TESTING
`include "Banco_de_registros_latches.v"
//`include "Biblioteca.sv"


module test_Banco_registros;

    // Inputs
    logic [2:0] csr_id=0;
    logic [4:0] rs1=0;
    logic [4:0] rs2=0;
    logic [4:0] rd=0;
    logic csr_en=0;
    logic [31:0] reg_write_data=0;
    logic write=0;
    logic clk=0;
    logic rst=0;
    logic [29:0] pc=0;
    logic mip_IO=0;
    logic mip_time=0;
    logic [31:0] timer=0;


    // Outputs
    wire mie_time;
    wire mie_IO;
    wire [31:0] comparation;
    wire [31:0] R1;
    wire [31:0] R2;

    //Inout pad
    wire [7:0] GPIO_pad;

    //control
    logic enable=0;
    logic [7:0] GPIO_port=0;
    assign GPIO_pad = enable ? GPIO_port : {8'bzzzzzzzz};

     //integer
     integer i;

  // Instantiate the Unit Under Test (UUT)
    Banco_registros_latches uut (
    .csr_id(csr_id),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .csr_en(csr_en),
    .reg_write_data(reg_write_data),
    .write(write),
    .R1(R1),
    .R2(R2),
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .mip_IO(mip_IO),
    .mip_time(mip_time),
    .mie_time(mie_time),
    .mie_IO(mie_IO),
    .comparation(comparation),
    .timer(timer),
    .GPIO_pad(GPIO_pad)
    );

initial begin
    csr_id={3'b000};
    rs1={5'b00000};
    rs2={5'b00000};
    rd={5'b00000};
    csr_en=0;
    reg_write_data=0;
    write=0;
    rst=1;
    pc=0;
    mip_IO=0;
    mip_time=0;
    timer=0;
    enable=0;
    GPIO_port=0;
#20;

end

always #10 clk=~clk;
always@(posedge clk)begin
  prueba();
end

 int ciclo =0;
 int direccion =1;

  task prueba();

  case(ciclo)

    0:begin
      rst=0;
      ciclo = 1;
    end
    //Escritura de registros
    1:begin
      write=1;
      if(direccion<32) begin
        rd=direccion;
        reg_write_data=direccion;
        direccion=direccion+1;
        //$display("at time: %g csr read address: %g R2: %h R1: %h",$time,direccion,R2,R1);
      end
      else begin
        ciclo=2;
        reg_write_data=0;
        direccion=0;
        rd=0;
        write=0;
      end
    end
    2:begin //lectura de registros
      if(direccion<32) begin
        rs1=direccion;
        rs2=direccion;
        direccion=direccion+1;
        //$display("at time: %g csr write address: %g R2: %h R1: %h",$time,direccion,R2,R1);
      end
      else begin
        ciclo=3;
        direccion=0;
        rs1=0;
        rs2=0;
      end // else
    end
//Escritura registro 0 CSR
    3:begin
      csr_en=1;
      csr_id=0;
      write=1;
      reg_write_data=1;
      mip_time=1;
      mip_IO=0;
      ciclo=4;
    end // 3:
//Lectura Registro 0
    4:begin
      csr_en=1;
      csr_id=0;
      write=0;
      $display("at time: %g csr 0: %h  ",$time,R2);
      reg_write_data=0;
      mip_time=0;
      mip_IO=0;
      ciclo=5;
    end // 4:
//Escritura Registro mepc 1
    5:begin
      csr_en=1;
      csr_id=1;
      write=1;
      pc=1000;
      ciclo=6;
    end
//Lectura Registro mepc 1
    6:begin
      csr_en=1;
      csr_id=1;
      write=0;
$display("at time: %g csr mepc: %h del que se espera un valor de fa0 ",$time,R2);//El numero escrito aqui se multiplica por 4
      pc=0;
      ciclo=7;
    end
//Escritura Registro Interrup1 2
    7:begin
      csr_en=1;
      csr_id=2;
      write=1;
      reg_write_data=2000;
      ciclo=8;
    end
//Lectura Registro Registro Interrup1 2
    8:begin
      csr_en=1;
      csr_id=2;
      write=0;
      reg_write_data=0;
      $display("at time: %g csr Interrup1: %h del que se espera un valor de 7d0 ",$time,R2);
      ciclo=9;
    end
//Escritura Registro Interrup2 3
    9:begin
      csr_en=1;
      csr_id=3;
      write=1;
      reg_write_data=2500;
      ciclo=10;
    end
//Lectura Registro Registro Interrup2 3
    10:begin
      csr_en=1;
      csr_id=3;
      write=0;
      reg_write_data=0;
      $display("at time: %g csr Interrup2: %h del que se espera un valor de 9c4 ",$time,R2);
      ciclo=11;
    end
/*GPIO pad*/
  /*Se ponen los registro de control en 0*/
    11:begin
      csr_en=1;
      csr_id=4;
      write=1;
      reg_write_data=0;
      ciclo=12;
    end
    /*Se escribe en los primeros 8 bits*/

    12:begin
      csr_en=1;
      csr_id=4;
      write=1;
      reg_write_data=8;
      ciclo=13;
    end
//Lectura del 8
    13:begin
      csr_en=1;
      csr_id=4;
      write=0;
      reg_write_data=0;
      $display("at time: %g csr GPIO_pad: %h del que se espera un valor de 0008 ",$time,R2);
      ciclo=14;
    end
/*Escritura control para pad*/

    14:begin
      csr_en=1;
      csr_id=4;
      write=1;
      reg_write_data=65280;
      ciclo=15;
    end

    15:begin
      csr_en=1;
      csr_id=4;
      write=1;
      reg_write_data=65280;
      enable=1;
      GPIO_port=4;
      ciclo=16;
    end
/*Lectura */
    16:begin
      csr_en=1;
      csr_id=4;
      write=0;
      enable=0;
      $display("at time: %g csr GPIO_pad: %h del que se espera un valor de ff04 ",$time,R2);
      reg_write_data=0;
      ciclo=17;
      end
//Escritura Registro mvtec
    17:begin
      csr_en=1;
      csr_id=5;
      write=1;
      reg_write_data=100;
      ciclo=18;
      end
//Lectura Registro mvtec
    18:begin
      csr_en=1;
      csr_id=5;
      write=0;
    $display("at time: %g csr mvtec: %h del que se espera un valor de 64 ",$time,R2);
      reg_write_data=0;
      ciclo=19;
      end
//Escritura Registro Comparacion
    19:begin
      csr_en=1;
      csr_id=6;
      write=1;
      reg_write_data=700;
      ciclo=20;
      end
      //Lectura Registro Compracion
    20:begin
      csr_en=1;
      csr_id=6;
      write=0;
      $display("at time: %g csr compracion: %h del que se espera un valor de 2bc ",$time,R2);
      reg_write_data=0;
      ciclo=21;
      end
//Escritura Registro timer
      21:begin
        csr_en=1;
        csr_id=7;
        write=1;
        timer=888;
        ciclo=22;
      end
//Lectura Registro timer
      20:begin
        csr_en=1;
        csr_id=7;
        write=0;
        $display("at time: %g csr timer: %h del que se espera un valor de 378 ",$time,R2);
        timer=0;
        ciclo=21;
        end


    8: begin
      $display("at time %g Test_finshed",$time);
      $finish;
    end
    default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
    end
  endcase
  endtask

endmodule
