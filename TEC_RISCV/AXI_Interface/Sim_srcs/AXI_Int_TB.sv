//
`timescale 1ns / 1ps

//`define 
//`define DW 32
//`define Masters 2
//`define Slaves 2

module AXI_Int_TB();
    
    localparam AW=32;
    localparam DW=32;
    localparam Masters=2;
    localparam Slaves=2;
    localparam trans=2;
    int retardo=(150+300*trans);

    Ports #(AW,DW,Masters)M_Ports();
    Ports #(AW,DW,Slaves)S_Ports();
    logic ACLK;
    logic ARESETn;
    
////////
//DUT//
//////
    AXI_Int #(32,32,2,2) AXI_BUS(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .M_Ports(M_Ports),
    .S_Ports(S_Ports)
    );
        
    initial begin
        $vcdpluson;
        $dumpfile("AXI_Int.vcd");
        $dumpvars(0,AXI_BUS);
        //Estado inicial de las señales
        ACLK=0;
        ARESETn=0;
        M_Ports.ARADDR=0;
        M_Ports.ARPROT=0;
        M_Ports.ARVALID=0;
        S_Ports.ARREADY=0;
        M_Ports.AWADDR=0;
        M_Ports.AWPROT=0;
        M_Ports.AWVALID=0;
        S_Ports.AWREADY=0;
        M_Ports.WDATA=0;
        M_Ports.WSTRB=0;
        M_Ports.WVALID=0;
        S_Ports.WREADY=0;     
        S_Ports.RDATA=0;
        S_Ports.RRESP=0;
        S_Ports.RVALID=0;
        M_Ports.RREADY=0;
        S_Ports.BRESP=0;
        S_Ports.BVALID=0;
        M_Ports.BREADY=0;
    #26
        ARESETn=1;  

    #retardo 
        $finish;
        $vcdplusclose;
    end


    genvar i;
    genvar j;
    generate
    	for (j = 0; j < trans; j++) begin
    		for (i = 0; i < Masters; i++) begin
    			int delay = 76+(300*j);
    		    initial begin
    		    	#delay
    		    	fork
		            Lectura(
		                .maestro(i),
		                .esclavo(i)
		            );
		            Escritura(
		                .maestro(i),
		                .esclavo(i)
		            );
    		    	join
    		    end
    		end    		
    	end
    endgenerate

    always #25 ACLK=~ACLK;

///////////////////////
//Proceso de lectura//
/////////////////////
    task automatic Lectura (
        input int maestro,
        input int esclavo
        ); 
        if (esclavo==0)M_Ports.ARADDR[maestro]=$urandom_range(1073741824,1073745919); // direcciones del esclavo cero
        else if (esclavo==1)M_Ports.ARADDR[maestro]=$urandom_range(1073745920,1073811455); // direcciones del esclavo uno
        M_Ports.ARPROT[maestro]=$random();
        S_Ports.RDATA[esclavo]=$random();
        S_Ports.RRESP[esclavo]=$random();
        #50
        M_Ports.ARVALID[maestro]=1'b1;
        M_Ports.RREADY[maestro]=1'b1;
        #50
        M_Ports.ARVALID[maestro]=1'b0;
        #50
        S_Ports.ARREADY[esclavo]=1'b1;
        #50
        S_Ports.ARREADY[esclavo]=1'b0;
        S_Ports.RVALID[esclavo]=1'b1;
        #50
        S_Ports.RVALID[esclavo]=1'b0;
        M_Ports.RREADY[maestro]=1'b0;
        #50 
        M_Ports.ARADDR[maestro]=32'b0;
        M_Ports.ARPROT[maestro]=3'b0;
        S_Ports.RDATA[esclavo]=32'b0;
        S_Ports.RRESP[esclavo]=2'b0;
    endtask : Lectura

/////////////////////////
//Proceso de escritura//
///////////////////////
    task automatic Escritura (
        input int maestro,
        input int esclavo
        );
        if (esclavo==0)M_Ports.AWADDR[maestro]=$urandom_range(1073741824,1073745919); // direcciones del esclavo cero
        else if (esclavo==1)M_Ports.AWADDR[maestro]=$urandom_range(1073745920,1073811455); // direcciones del esclavo uno
        M_Ports.AWPROT[maestro]=$random();
        M_Ports.WDATA[maestro]=$random();
        M_Ports.WSTRB[maestro]=$random();
        S_Ports.BRESP[esclavo]=$random();
        #50
        M_Ports.AWVALID[maestro]=1'b1;
        M_Ports.WVALID[maestro]=1'b1;
        M_Ports.BREADY[maestro]=1'b1;
        #50
        M_Ports.AWVALID[maestro]=1'b0;
        M_Ports.WVALID[maestro]=1'b0;
        #50
        S_Ports.AWREADY[esclavo]=1'b1;
        S_Ports.WREADY[esclavo]=1'b1;
        #50
        S_Ports.AWREADY[esclavo]=1'b0;
        S_Ports.WREADY[esclavo]=1'b0;
        S_Ports.BVALID[esclavo]=1'b1;
        #50
        S_Ports.BVALID[esclavo]=1'b0;
        M_Ports.BREADY[maestro]=1'b0;
        #50
        M_Ports.AWADDR[maestro]=32'b0;
        M_Ports.AWPROT[maestro]=3'b0;
        M_Ports.WDATA[maestro]=32'b0;
        M_Ports.WSTRB[maestro]=4'b0;
        S_Ports.BRESP[esclavo]=2'b0;
    endtask : Escritura

endmodule