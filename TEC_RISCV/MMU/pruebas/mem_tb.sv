`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2018 09:02:51 AM
// Design Name: 
// Module Name: mem_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "../code/*" 

module mem_tb( );
    
    reg reloj, n_rst;
    reg rw_mem, mem_en;
    wire c_en;
    wire w_en, sl, clk_mem;
    wire listo_mem;
    
    reg [31:0] q_mem;
    reg [31:0] d_in;
    reg [10:0] a_in;
    reg RDY_dvc;

     mem_sgnl_gen generador(
    .sys_clk(reloj), .reset(n_rst),
    .RW_Mem(rw_mem), .Mem_en(mem_en), .RDY(listo_mem),
    .CEn(c_en), 
    .WEn(w_en), .SL(sl), .CLK(clk_mem), .rdy_to_dvc(RDY_dvc)
    );    
    XSPRAMLP_2048X32_M8P memoria(.Q(q_mem), .D(d_in), .A(a_in), .CLK(clk_mem), .CEn(c_en), .WEn(w_en), .SL(sl), .RDY(listo_mem));
    
    integer i;

    initial begin
        //Carga de datos del archivo de precarga de memoria
        #0 $readmemb("RAM_init_file.vbi", memoria.sub1.RAM_matrix);
        $display("\n%t: INFO: %m: loading RAM_init_file \n", $realtime);
        //Lógica para la lectura
        reloj = 1'b0;
        n_rst = 1'b0;
        d_in = 32'h00001000;
        a_in = 11'd0;
        rw_mem = 1'b0;
        mem_en = 1'b0;
        i=0;
        #5 n_rst = ~n_rst;
        #55 n_rst = ~n_rst; //vuelve el reset al estado original
        #300 ; //La memoria requiere 250 ns de espera al inicio, hasta que no pasen los 250 ns la memoria no va a funcionar aunque las señales sean las correctas
        $display("------------------------------------------------------------------------");
        $display("---------------------Inicio de lectura de datos-------------------------");
        $display("------------------------------------------------------------------------");
            repeat(2048) begin          //Realiza la lectura de los datos precargados
            a_in = i;
            mem_en = 1'b1;
            #70 ;
            wait(RDY_dvc==1'b1);
            mem_en = 1'b0;
            $display("Dato leído: %d | Dato en dir: %d | Dato esperado: %d",q_mem,a_in,i);
            wait(sl==1'b1);
            $display("Modo sleep activado");        //Se espera a que la memoria caiga en estado de sleep, esto con el fin de comprobar que dicho modo se activa y desactiva correctamente; además de que permita el correcto funcionamiento, en este caso de la lectura
            #50 ;
            i=i+1;
        end 
        i=0;
        rw_mem = 1'b1;
        //Realiza una escritura en todas las direcciones disponibles, el dato a escribir es el dato raíz, colocado al inicio más el valor de la dirección actual
        repeat(1024) begin              //No considera esperar a que la memoria caiga en modo sleep
            a_in = i;
            mem_en = 1'b1;
            #70 ;
            wait(RDY_dvc==1'b1);
            mem_en = 1'b0;
            i=i+1;
            #50 ;
            d_in = d_in + 1;
        end
        repeat(1024) begin               //Espera a que la memoria caiga en modo sleep para realizar la siguiente escritura
            a_in = i;
            mem_en = 1'b1;
            #70 ;
            wait(RDY_dvc==1'b1);
            mem_en = 1'b0;
            wait(sl==1'b1);
            i=i+1;
            #50 ;
            d_in = d_in + 1;
        end

        $display("Escritura terminada :)");
        rw_mem = 1'b0;
        d_in = 32'h00001000;
        i=0;
        repeat(2048) begin              //Realiza la lectura de los datos escritos anteriormente
            a_in = i;                   //En esta lectura no se espera a que el sleep se active para reactivarlo
            mem_en = 1'b1;          
            #70 ;
            wait(RDY_dvc==1'b1);
            #15 ;
            mem_en = 1'b0;
            if (q_mem !=(d_in+i)) begin
                $display("¡¡Error!!");
                break;
            end
            #50 ;
            i=i+1;
            if(i==2048) $display("Lectura terminada con éxito :)");
        end 
        #250 $finish;
    end
            
    always
    #25 reloj = ~reloj;
    
endmodule
