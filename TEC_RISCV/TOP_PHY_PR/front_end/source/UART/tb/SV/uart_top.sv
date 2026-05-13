`timescale 1ns / 1ps

//`include "uart_ports.sv"
module uart_top (uart_ports ports);
//incluye clases
`include "uart_txgen.sv"
`include "uart_sb.sv"

    uart_txgen txgen = new (ports);
    
    initial begin
        fork
            txgen.goTxgen();
        join_none //no espera que algun proceso fork haya terminado
            
        while (! txgen.isDone()) begin
            @ (posedge ports.uart_clk);
        end
        
        @ (posedge ports.sys_clk)
        ports.pop_R = 1;
        @ (posedge ports.sys_clk)
        ports.pop_R = 0;

        repeat (800) @ (posedge ports.uart_clk);
        @ (posedge ports.sys_clk)
        ports.pop_R = 1;
        @ (posedge ports.sys_clk)
        ports.pop_R = 0;

        repeat (800) @ (posedge ports.uart_clk);
        @ (posedge ports.sys_clk)
        ports.pop_R = 1;
        @ (posedge ports.sys_clk)
        ports.pop_R = 0;

        repeat (800) @ (posedge ports.uart_clk);
        @ (posedge ports.sys_clk)
        ports.pop_R = 1;
        @ (posedge ports.sys_clk)
        ports.pop_R = 0;

        repeat (500) @ (posedge ports.uart_clk);
        $write ("%dns: Termintating the simulation\n", $time);
         $finish();
     end
    
endmodule
