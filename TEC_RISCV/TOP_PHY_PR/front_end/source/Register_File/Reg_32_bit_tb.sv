//`timescale 1ns/1ns
module RF_tb;
	reg [4:0] rd, rs1, rs2; 
	reg [3:0] csr_addr;
	reg [29:0] pc;
	reg [31:0] reg_w_data;
	reg [95:0] csr_trap;
	reg w_enable, r_enable, clk, csr_rd_en, csr_wr_en, reset, load;
	reg enable_pc, mip_IO, mip_time;
	wire mie_IO, mie_time;
	wire [4:0] csr_io;
	wire [31:0] R1, R2, limits1, limits2, limits3, limits4, limits5, limits6;

	int x_write, acumulador, acumuladorCSR;
	int escrituras[32];
	int lecturasR1[32];
	int lecturasR2[32];
	int escriturasCSR[32];
	int lecturasCSR[32];

	// Device Under Test
	Banco_registros_latches DUT (
		/* Entradas */
		.csr_ad(csr_addr),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.write_en(w_enable),
		.read_en(r_enable),
		.csr_read_en(csr_rd_en),
		.csr_write_en(csr_wr_en),
		.reg_write_data(reg_w_data),
		.clk(clk),
		.rst(reset),
		.load(load),
		.csr_trap(csr_trap),
		.pc(pc),
		.enable_pc(enable_pc),
		.mip_IO(mip_IO),
		.mip_time(mip_time),
		/* Salidas */
		.mie_IO(mie_IO),
		.mie_time(mie_time),
		.limits1(limits1),
		.limits2(limits2),
		.limits3(limits3),
		.limits4(limits4),
		.limits5(limits5),
		.limits6(limits6),
		.csr_io(csr_io),
		.R1(R1),
		.R2(R2)
		);

	// 20 MHz Clock
	always begin
		#25 clk = ~clk;
	end

	initial begin
		// Para monitorear R1 y R2
		// $monitor("R1: %b, R2: %b.",R1, R2);
		// Inicializa las variables
		clk = 1;
		rs1 = 5'd0;
		rs2 = 5'd0;
		rd  = 5'd0;
		reg_w_data = 32'h00000000;
		w_enable   = 0;
		r_enable   = 0;
		
		// Inicializa variables CSR
		csr_addr  = 5'd0;
		csr_rd_en = 0;
		csr_wr_en = 0;

		// Inicializa el reset
		reset = 0;
		// Reset
		#10 reset = 1;
		#10 reset = 0;
		#30;

		// Load PC
		pc = 31'h01024569;
		enable_pc = 1;
		#50 enable_pc = 0;

		// Load CSR Trap
		csr_trap = 96'd23423454;
		load = 1;
		#50 load = 0;

		// MIP - MIE
		mip_time  = 0;
		mip_IO	  = 0;


		#50; // 50 ns delay

		// Escribe todos los registros de propósito general
		for (int i = 0; i < 32; i++) begin
			x_write = $urandom_range(1,10000);
			escrituras[i] = x_write;
			registerWrite(i, x_write);
			#50;
		end

		// MIP - MIE
		mip_time  = 1;
		mip_IO	  = 1;

		// Escribe todos los CSR
		for (int i = 0; i < 16; i++) begin
			if(i==3) begin
				mip_time=$urandom_range(0,1);
				mip_IO=$urandom_range(0,1);
				#50;
			end // if(i==3)
			else if(i==4) begin
				pc = $urandom_range(1,10000);
				enable_pc= 1;
				#50 enable_pc= 0;
			end // else if(i==4)
			else if(i==5 || i==6 || i==7) begin
				csr_trap=$urandom_range(1,10000);
				load = 1;
				#50 load = 0;
			end // else if(i==5, i==6, i==7)
			
			else begin
				x_write = $urandom_range(1,10000);
				escriturasCSR[i] = x_write;
				csrWrite(i, x_write);
			end // else
		end
		
		#50; // 50 ns delay

		// Lee de todos los registros en R1 y R2
		for (int i = 0; i < 32; i++) begin
			registerRead(i, 31-i, lecturasR1[i], lecturasR2[i]);
			#50;
		end

		acumulador = 0;
		for (int i = 0; i < 32; i++) begin
			if( (lecturasR1[i]==escrituras[i]) && (lecturasR2[31-i]==escrituras[i]) ) begin
				acumulador = acumulador + 1;
			end
		end

		// Si se tienen 31 comparaciones exitosas el RF funciona bien. Se hacen 32
		// comparaciones pero la primera debe fallar, pues se compara el valor leído
		// del registro x0/zero
		if(acumulador == 31) begin
			$display("+---------------------------------------------+");
			$display("Test de registros de propósito general exitoso.");
		end

		#50; // 50 ns delay

		// Lee de todos los registros CSR
		for (int i = 0; i < 15; i++) begin
			csrRead(i, 31-i, i, lecturasCSR[i]);
			#50;
		end

		acumuladorCSR = 0;
		for (int i = 0; i < 16; i++) begin
			if(lecturasCSR[i] == escriturasCSR[i]) begin
				acumuladorCSR = acumuladorCSR + 1;
			end
		end

		$display("acumulador: %0d", acumuladorCSR);
		if(acumuladorCSR == 10) begin
			$display("+---------------------------------------------+");
			$display("Test de registros CSR exitoso.");
			$display("+---------------------------------------------+");
		end

		#5 $finish;
	end

	// Task para leer de ambas direcciones (rs1 y rs2)
	task registerRead (input bit [4:0] rs_1, rs_2, output int outR1, outR2);
		r_enable = 1;
		rs1 = rs_1;
		rs2 = rs_2;
		// Si se toma el valor sin esperar más, se captura el valor previo
		// de R1 (Z), por eso hay que esperar 5 mas.
		#45 outR1 = R1;
		outR2 = R2;
		#5 r_enable = 0;
	endtask

	// Task para comprobar la lectura desde diferentes entradas
	task csrRead (input bit [4:0] rs_1, rs_2, csr_address, output int outCSR);
		csr_rd_en = 1;
		rs1 = rs_1;
		rs2 = rs_2;
		csr_addr =  csr_address;
		#45 outCSR = R2;
		#5 csr_rd_en = 0;
	endtask

	// Task para escribir en un registro de proposito general
	task registerWrite (input bit [4:0] reg_dir, input bit [31:0] write_value);
		w_enable = 1;
		rd = reg_dir;
		reg_w_data = write_value;
		#50 w_enable = 0;
		reg_w_data = 32'h00000000;
		rd = 5'd0;
		//#25; // 25 ns delay;
		// Con los dos delay la operacion de escritura toma un ciclo completo del clk (50 ns)
	endtask

	// Task para escribir en los CSR
	task csrWrite (input bit [4:0] csr_dir, input bit [31:0] write_value);
		csr_wr_en = 1;
		csr_addr = csr_dir;
		reg_w_data = write_value;
		#50 csr_wr_en = 0;
		reg_w_data = 32'h00000000;
		csr_addr = 5'd0;
		//#25; // 25 ns delay;
		// Con los dos delay la operacion de escritura toma un ciclo completo del clk (50 ns)
	endtask

endmodule