`timescale 1ns/10ps
`include "../../TEC_RISCV/TOP/topcore_tecriscv.sv"
`include "Status.sv"
`include "IS25WP032D.v"
`include "coverage_classes.sv"
`include "instruction_class.sv"
//`include "core_coverage_collection.sv"
`include "Reference_Model.sv"
`include "Selfcheck.sv"

//`define DEBUG

module dhrystone_tb;

	/*This test is done in two steps:
		1) The first step reads a .lst file which has the listing information of a program compiled using Freedom Studio from SciFive.
		   This program filters the information of this .lst file and extracts the disassembled code for RISCV.
		   Then, a new .txt file is generated with only the program code, ready to be loaded in our core model.

		 2) The second step consists in loading the program from step 1, and letting it run in our RISCV core model. We introduce CPI
		 	values, previously measured, in this model so that we can estimate the parameters needed. In this case, we are running a
		 	Dhrystone test.
	*/

	//Step 1: Extracting the disassembled code

	int out;
	string str;

	out = $fopen("dhrystone.lst","r+");
	while(!$feof(out)) begin
        $fgets(instruction_str,file);
     	inst_queue.push_back(instruction_str);
     	instruction = instruction_str.atohex();
     	mem[count]  = instruction;
     	count++;
    end
    $fclose(out);

	//Step 2: Running the Dhrystone test



endmodule // dhrystone_tb