

module coremark_mem_model (Q,D,A,CLK,CEn,WEn,SL,RDY);

	input CLK;
	input WEn;
	input CEn;
	input [18:0] A;
	input [31:0] D;
	input SL;

	output logic RDY;
	output logic [31:0] Q;

	logic [31:0] mem [0:262143];

	initial begin
		$readmemh("Test_Files/Assembly_Code/coremark_program.txt",mem);
	end

	assign Q = (!CEn) ? mem[A] : {32{1'bz}};
	assign RDY = 0;

	always @(posedge CLK) begin
		if(!WEn) begin
			mem[A] = D;
		end
	end

endmodule