`define DEBUG
`timescale 1ns/10ps
`include "../../TEC_RISCV/TOP/Tec_Riscv_pads_syn_pads.v"
`include "../../TEC_RISCV/TOP/XSPRAMLP_2048X32_M8P.sv"
`include "IS25WP032D.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/IO_CELLS_F3V/v2_1/verilog/v2_1_0/IO_CELLS_F3V_UPF.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/verilog/v2_1_0/D_CELLS_HDLL.v"
`include "/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/verilog/v2_1_0/VLG_PRIMITIVES.v"
`include "coverage_classes.sv"
`include "instruction_class.sv"
`include "Status_post_synt.sv"
`include "Reference_Model.sv"
`include "Selfcheck.sv"

module Test_Top;

  logic clk;
  logic reset;
  wire  MISO;
  logic RX_UART;
  logic maip;
  wire MOSI;
  wire SCLK;
  wire SCS;
  wire TX_UART;
  wire [7:0] full_range_level_shifter;
  wire [31:0] IS_Val;
  wire [31:0] IS_Config;
  wire [3:0] IS_Trigger;
  wire [7:0] gpio;
  wire [7:0] Reg_GPIO;

 top_riscv_tec_pads uut (
  .clk_pad(clk),
  .reset_pad(reset),
  .MISO_pad(MISO),
  .RX_UART_pad(RX_UART),
  .maip_pad(maip),
  .MOSI_pad(MOSI),
  .SCLK_pad(SCLK),
  .SCS_pad(SCS),
  .TX_UART_pad(TX_UART),
  .full_range_level_shifter(full_range_level_shifter),
  .IS_Val(IS_Val),
  .IS_Config(IS_Config),
  .IS_Trigger(IS_Trigger),
  .gpio_pad(Reg_GPIO)
  );


  IS25WP032D mem(
    .SCLK(SCLK),
    .CS(SCS),
    .SI(MOSI),
    .SO(MISO),
    .WP(1'b1),
    .SIO3(1'b1));

//////////////////////////////////////////////////////////////////////
//Variables internas y parametros
//////////////////////////////////////////////////////////////////////

  int executed_inst;
  int rx_cycle_count;
  int tx_cycle_count;
  int data_count;
  int rx_byte_count;
  int tx_byte_count;
  int sent_data_count;
  int out;
  int loading_cycles;
  int exe_cycles;
  int finish_count;
  int change_counter;
  real start_loading_time;
  real stop_loading_time;
  real start_program_time;
  real stop_program_time;
  logic [7:0] uart_rx_data;
  logic even_parity;
  logic [63:0] complete_uart_rx_data;
  logic [63:0] uart_tx_data_queue [$];
  logic [63:0] data;
  logic [7:0]  tx_byte_queue [$];
  logic [7:0]  rx_byte_queue [$];
  logic loaded_data_flag;
  logic uart_busy;
  logic finish;
  logic cc_count;
  logic [31:0] past_inst;
  logic program_start;
  logic loading_start;
  string line;
  string exe_inst_queue [$];
  string prediction     [$];
  string inst_queue     [$];
  string csr_predict    [$];
  string uart_predict   [$];
  string test_name;

  //////////////////////////////////////////////////////////////////////
    //Coverage Class assignment
    //////////////////////////////////////////////////////////////////////

    core_coverage_class core_cov = new(clk);

    //////////////////////////////////////////////////////////////////////
    //Instruction Class for CPI measurement
    //////////////////////////////////////////////////////////////////////

    instruction_class inst_set [47];

//////////////////////////////////////////////////////////////////////
//Task y testbench
//////////////////////////////////////////////////////////////////////

initial begin
  out = $fopen("results.txt","w+");
  $fclose(out);
  out = $fopen("temp.txt","w+");
  $fclose(out);
  if($value$plusargs("TESTNAME=%s",test_name)) begin
    $dumpfile({"../../../sim_files/core_sim_files/post_synth_",test_name,"_test.vcd"});
    $dumpvars(0,Test_Top);
    out = $fopen({"Metrics_Reports/Post_Syn_Metrics_Report_",test_name,".txt"},"w+");
    $fwrite(out,"//////////////////////Metrics Report//////////////////////////\n");
    $fwrite(out,"\n");
    $fwrite(out,"---General Information---");
    $fclose(out);
  end
  else begin
    $dumpfile("../../../sim_files/core_sim_files/topcore_tb.vcd");
    $dumpvars(0,Test_Top);
  end
  clk <= 0;
  reset <= 1;
  RX_UART <= 1;
  maip <= 0; //ENTRADA NUEVA
  prediction.delete();
  exe_inst_queue.delete();
  inst_queue.delete();
  uart_tx_data_queue.delete();
  tx_byte_queue.delete();
  csr_predict.delete();
  uart_predict.delete();
  uart_rx_data = 0;
  rx_cycle_count = 0;
  tx_cycle_count = 0;
  data_count = 0;
  rx_byte_count = 0;
  tx_byte_count = 0;
  complete_uart_rx_data = 0;
  sent_data_count = 0;
  loaded_data_flag = 0;
  uart_busy = 0;
  finish = 0;
  cc_count = 0;
  past_inst = 0;
  loading_cycles = 0;
  exe_cycles = 0;
  program_start = 0;
  loading_start = 0;
  finish_count = 0;
  change_counter = 0;
  reference_model(inst_queue,prediction,executed_inst,exe_inst_queue,csr_predict, uart_predict);

  //////////////////////////////////////////////////////////////////////
  //CPI Report Names
  //////////////////////////////////////////////////////////////////////
  inst_set[0] = new("LUI");
  inst_set[1] = new("AUIPC");
  inst_set[2] = new("JAL");
  inst_set[3] = new("JALR");
  inst_set[4] = new("BEQ");
  inst_set[5] = new("BNE");
  inst_set[6] = new("BLT");
  inst_set[7] = new("BGE");
  inst_set[8] = new("BLTU");
  inst_set[9] = new("BGEU");
  inst_set[10] = new("LB");
  inst_set[11] = new("LH");
  inst_set[12] = new("LW");
  inst_set[13] = new("LBU");
  inst_set[14] = new("LHU");
  inst_set[15] = new("SB");
  inst_set[16] = new("SH");
  inst_set[17] = new("SW");
  inst_set[18] = new("ADDI");
  inst_set[19] = new("SLTI");
  inst_set[20] = new("SLTIU");
  inst_set[21] = new("XORI");
  inst_set[22] = new("ORI");
  inst_set[23] = new("ANDI");
  inst_set[24] = new("SLLI");
  inst_set[25] = new("SRLI");
  inst_set[26] = new("SRAI");
  inst_set[27] = new("ADD");
  inst_set[28] = new("SUB");
  inst_set[29] = new("SLL");
  inst_set[30] = new("SLT");
  inst_set[31] = new("SLTU");
  inst_set[32] = new("XOR");
  inst_set[33] = new("SRL");
  inst_set[34] = new("SRA");
  inst_set[35] = new("OR");
  inst_set[36] = new("AND");
  inst_set[37] = new("FENCE");
  inst_set[38] = new("FENCE.I");
  inst_set[39] = new("ECALL");
  inst_set[40] = new("EBREAK");
  inst_set[41] = new("CSRRW");
  inst_set[42] = new("CSRRS");
  inst_set[43] = new("CSRRC");
  inst_set[44] = new("CSRRWI");
  inst_set[45] = new("CSRRSI");
  inst_set[46] = new("CSRRCI");

end

always #25 clk=~clk;

parameter LUI =8;
parameter AUIPC =9;
parameter JAL =12;
parameter BEQ =16;
parameter BNE =19;
parameter BLT =22;
parameter BGE =25;
parameter BLTU=28;
parameter BGEU=31;
parameter SB =34;
parameter SH =39;
parameter SW =44;
parameter JALR =49;
parameter LB =53;
parameter LH =59;
parameter LW =65;
parameter LBU =71;
parameter LHU =77;
parameter ADDI =83;
parameter SLTI =85;
parameter SLTIU =88;
parameter XORI =91;
parameter ORI =94;
parameter ANDI =97;
parameter SLLI =100;
parameter SRLI =103;
parameter SRAI =106;
parameter ADD =109;
parameter SUB =112;
parameter SLL =115;
parameter SLT =118;
parameter SLTU=121;
parameter XOR =124;
parameter SRL =127;
parameter SRA =130;
parameter OR  =133;
parameter AND  =136;
parameter MRET =141;
parameter CSRRW =143;
parameter CSRRS =148;
parameter CSRRC= 153;
parameter CSRRWI =158;
parameter CSRRSI =162;
parameter CSRRCI =167;

always @(posedge clk)begin
  core_cov.ctrl_fsm_state = Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0];
  cpi_measurement(inst_set,inst_set);
  `ifdef DEBUG
    if (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == 5) begin
      status_gpr();
      $display("tiempo: %g --> finaliza el fetch",$time);
    end
    else if((Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LUI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == AUIPC) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == JAL) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BEQ) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BNE) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BLT) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BGE) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BLTU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == BGEU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SB) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SH) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SW) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == JALR) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LB) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LH) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LW) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LBU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == LHU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == ADDI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLTI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLTIU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == XORI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == ORI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == ANDI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLLI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SRLI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SRAI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == ADD) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SUB) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLL) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLT) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SLTU) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == XOR) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SRL) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == SRA) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == OR) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == AND) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == MRET) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRW) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRS) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRC) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRWI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRSI) ||
            (Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == CSRRCI)
            ) begin
                status_deco();
              end
  `endif
  prueba();
  rx_uart_monitor(TX_UART,19200);
  if(complete_uart_rx_data == 64'h8898968088888888) begin
    if (loaded_data_flag == 0) begin
      out = $fopen("uart_data.txt","r");
      while (!$feof(out)) begin
        $fgets(line,out);
        data = line.atohex();
        uart_tx_data_queue.push_back(data);
      end
      loaded_data_flag = 1;
    end
    if (loaded_data_flag == 1) begin
      if((uart_busy == 0) && (tx_byte_count == 0)) begin
        if(uart_tx_data_queue.size() > 0) begin
          tx_byte_queue.delete();
          data = uart_tx_data_queue.pop_front();
          $display("The packet to be sent through UART is: %h", data);
          $display("-----------------------------------");
          tx_byte_queue.push_back(data[7:0]);
          tx_byte_queue.push_back(data[15:8]);
          tx_byte_queue.push_back(data[23:16]);
          tx_byte_queue.push_back(data[31:24]);
          tx_byte_queue.push_back(data[39:32]);
          tx_byte_queue.push_back(data[47:40]);
          tx_byte_queue.push_back(data[55:48]);
          tx_byte_queue.push_back(data[63:56]);
        end
      end
      tx_uart_driver(19200,tx_byte_queue[tx_byte_count],RX_UART,uart_busy);
      if((uart_busy == 0) && (uart_tx_data_queue.size() == 0) && (tx_byte_count == 0)) begin
        $display("-----------------------------------");
        $display("Transmission has ended. Finishing test...");
        $display("-----------------------------------");
        complete_uart_rx_data = 0;
        finish = 1;
      end
    end
    end
end

task prueba();
if ($time<4000000)begin
    reset <=1;
    maip <= 0; //ENTRADA NUEVA
  end
  else begin
    reset <=0;
    out = $fopen("temp.txt","r+");
    while(!$feof(out)) begin
        $fgets(line,out);
    end
    $fclose(out);
    if(loading_start == 0) begin
        start_loading_time = $realtime();
        loading_start = 1;
    end
    if(program_start == 0) begin
        loading_cycles++;
    end
    else begin
        exe_cycles++;
    end
    if((Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] != 0) && (program_start == 0)) begin
        stop_loading_time = $realtime() - 100;
        start_program_time = $realtime() - 100;
        program_start = 1;
    end
    if(($time > 40000000) || /*(finish == 1)*/(line == "FINISH"))begin
        stop_program_time = $realtime() - 100;
        selfcheck(inst_queue,prediction,executed_inst,exe_inst_queue,csr_predict);
        if($value$plusargs("TESTNAME=%s",test_name)) begin
            print_metrics_report();
        end
        else begin
            $display("WARNING: Plusargs +TESTNAME=<name> is missing. Metrics reports won't be generated.");
        end
        $finish;
    end
  end
endtask : prueba

task rx_uart_monitor(input logic rx_bit, input int baud_rate); //Even parity bit is used

    int total_cycle;

    total_cycle = 20000000/baud_rate; //20MHZ / baud_rate

    if ((rx_bit == 0) && (data_count == 0)) begin // Start Bit
      if(total_cycle == rx_cycle_count) begin
        $display("Start bit found!");
        rx_cycle_count = 0;
        data_count++;
      end
      else begin
        rx_cycle_count++;
      end
    end
    else if ((data_count > 0) && (data_count < 9)) begin // 8bit Data
      if(total_cycle == rx_cycle_count) begin
        $display("Data bit found: %h",(data_count - 1));
        uart_rx_data[data_count - 1] = rx_bit;
        rx_cycle_count = 0;
        data_count++;
      end
      else begin
        rx_cycle_count++;
      end
    end
    else if(data_count == 9) begin // Even Parity bit
      if(total_cycle == rx_cycle_count) begin
        $display("Parity bit found: %b",rx_bit);
        even_parity = rx_bit;
        uart_rx_data[data_count - 1] = rx_bit;
        rx_cycle_count = 0;
        data_count++;
      end
      else begin
        rx_cycle_count++;
      end
    end
    else if((rx_bit == 1) && (data_count == 10)) begin
      if(total_cycle == rx_cycle_count) begin
        $display("Stop bit has been found!!");
        $display("-----------------------------------");
      $display("UART Transaction Succesful...");
      $display("-----------------------------------");
      $display("Data received (hex): %h",uart_rx_data);
            $display("Data received (bin): %b",uart_rx_data);
      $display("Parity bit received: %b",even_parity);
      if(even_parity == (^uart_rx_data)) begin
        $display("The parity check bit is correct");
                $display("-----------------------------------");
                rx_byte_queue.push_back(uart_rx_data);
                if(rx_byte_count < 7) begin
                    rx_byte_count++;
                end
                else begin
                    complete_uart_rx_data = {rx_byte_queue[7],rx_byte_queue[6],rx_byte_queue[5],rx_byte_queue[4],rx_byte_queue[3],rx_byte_queue[2],rx_byte_queue[1],rx_byte_queue[0]};
                    $display("The packet recieved is: %h",complete_uart_rx_data);
                    $display("-----------------------------------");
                    rx_byte_count = 0;
                end
      end
      else begin
        $display("Error in the parity bit");
      end;
        rx_cycle_count = 0;
        data_count = 0;
      end
      else begin
        rx_cycle_count++;
      end
    end

endtask : rx_uart_monitor

task tx_uart_driver(input int baud_rate, input logic [7:0] uart_tx_data, output logic tx_bit, output logic busy);

    int total_cycle;
    logic [31:0] data;

    total_cycle = 20000000/baud_rate; //20MHZ / baud_rate

    if(sent_data_count == 0) begin
        if (tx_cycle_count < total_cycle) begin //Start bit
            tx_bit = 0;
            tx_cycle_count++;
        end
        else begin
            $display("-----------------------------------");
            $display("Sending data through UART...");
            $display("Byte to be sent: %h",uart_tx_data);
            $display("-----------------------------------");
            sent_data_count++;
            tx_cycle_count = 0;
        end
        busy = 1;
    end
    else if((sent_data_count > 0) && (sent_data_count < 9)) begin
        if (tx_cycle_count < total_cycle) begin //Data bits
            tx_bit = uart_tx_data[(sent_data_count - 1)];
            tx_cycle_count++;
        end
        else begin
            sent_data_count++;
            tx_cycle_count = 0;
        end
        busy = 1;
    end
    else if(sent_data_count == 9) begin // Even Parity bit
        if(tx_cycle_count < total_cycle) begin
            tx_bit = ^uart_tx_data;
            tx_cycle_count++;
        end
        else begin
            sent_data_count++;
            tx_cycle_count = 0;
        end
        busy = 1;
    end
    else if(sent_data_count > 9) begin // Stop bit
        if(tx_cycle_count < total_cycle) begin
            tx_bit = 1;
            tx_cycle_count++;
            busy = 1;
        end
        else begin
            sent_data_count = 0;
            tx_cycle_count = 0;
            $display("-----------------------------------");
            $display("UART Transaction Succesful...");
            $display("-----------------------------------");
            busy = 0;
            if(tx_byte_count < 7) begin
                tx_byte_count++;
            end
            else begin
                tx_byte_count = 0;
            end
        end
    end

endtask : tx_uart_driver

task cpi_measurement(input instruction_class input_inst_set[47], output instruction_class output_inst_set[47]);

    int cc_counter;
    int position;

    logic [31:0] current_inst;

    instruction_class local_inst = new("");

    position = 0;
    current_inst = Test_Top.uut.top_riscv_soc.TOP.Memory_controller.d_read[31:0];
    //$display("Inst %d",position);
    //$display("Position %d",position);
    if(Test_Top.uut.top_riscv_soc.TOP.central_control.cur_state[7:0] == 4) begin
        change_counter++;
    end
    if (((past_inst != current_inst) && (current_inst[31:0] != 0)) || (change_counter == 3)) begin
        if (cc_count == 1) begin
            cc_counter++;
            find_inst_in_set(past_inst,position);
            //$display("Position %d",position);
            local_inst = input_inst_set[position];
            local_inst.increment_cpi(cc_counter);
            //$display("cpi %d",local_inst.cpi);
            //$display("repetitions %d",local_inst.repetitions);
            output_inst_set[position] = local_inst;
        end
        cc_counter = 0;
        cc_count = 1;
        change_counter = 0;
        past_inst = current_inst;
    end
    else if ((past_inst == current_inst) && (cc_count == 1)) begin
        cc_counter++;
        output_inst_set = input_inst_set;
    end
    else begin
        output_inst_set = input_inst_set;
    end

endtask : cpi_measurement

task print_metrics_report();

    string filler;
    string avg_cpi;
    string program_size;
    string inst_count;
    string exe_inst;
    string loading_time;
    //string str1;
    //string str2;
    string exe_time;
    string loading_cycles_str;
    string exe_cycles_str;

    program_size.itoa(((inst_queue.size()/4) - 1) * 4);
    inst_count.itoa((inst_queue.size()/4) - 1);
    exe_inst.itoa(executed_inst);
    loading_time = $sformatf("%f",(stop_loading_time - start_loading_time));
    exe_time = $sformatf("%f",(stop_program_time - start_program_time));
    //str1 = $sformatf("%f",(start_loading_time));
    //str2 = $sformatf("%f",(stop_loading_time));
    loading_cycles_str.itoa(loading_cycles);
    exe_cycles_str.itoa(exe_cycles);
    out = $fopen({"Metrics_Reports/Post_Syn_Metrics_Report_",test_name,".txt"},"r+");
    while(!$feof(out)) begin
        $fgets(filler,out);
    end
    $fwrite(out,"\n");
    $fwrite(out,{"Program Size: ",program_size,"B"});
    $fwrite(out,"\n");
    $fwrite(out,"Program Size (Instruction Quantity): ",inst_count);
    $fwrite(out,"\n");
    $fwrite(out,"Total Executed Instructions: ",exe_inst);
    $fwrite(out,"\n");
    $fwrite(out,{"Loading Program Time: ",loading_time,"ns"});
    $fwrite(out,"\n");
    /*$fwrite(out,{"Execution Program Time: ",str1,"ns"});
    $fwrite(out,"\n");
    $fwrite(out,{"Execution Program Time: ",str2,"ns"});
    $fwrite(out,"\n");*/
    $fwrite(out,"Loading Program Cycle Quantity: ",loading_cycles_str);
    $fwrite(out,"\n");
    $fwrite(out,{"Execution Program Time: ",exe_time,"ns"});
    $fwrite(out,"\n");
    $fwrite(out,"Execution Program Cycle Quantity: ",exe_cycles_str);
    $fwrite(out,"\n");
    $fwrite(out,"\n");
    $fwrite(out,"--- CPI Measurement Results---");
    $fwrite(out,"\n");
    $fwrite(out,"Instruction | Average CPI");
    foreach(inst_set[i]) begin
        inst_set[i].calculate_average_cpi();
        avg_cpi = $sformatf("%f",inst_set[i].average_cpi);
        filler = "";
        while (filler.len() < (8 - inst_set[i].name.len())) begin //arbitrary number, it is just for aesthetics
            filler = {filler," "};
        end
        $fwrite(out,"\n");
        $fwrite(out,{"   ",inst_set[i].name,filler," | "," ",avg_cpi});
    end

    $fclose(out);

endtask : print_metrics_report

task find_inst_in_set(input logic [31:0] local_inst, output int position);

    string inst_name;

    logic [6:0]  opcode;
    logic [2:0]  funct3;

    opcode = local_inst[6:0];
    funct3 = local_inst[14:12];

    case (opcode)
         7'b0110111 : begin //LUI
            position = 0;
         end
         7'b0010111 : begin //AUIPC
            position = 1;
         end
         7'b1101111 : begin //JAL
            position = 2;
         end
         7'b1100111 : begin //JALR
            position = 3;
         end
         7'b1100011 : begin //BEQ, BNE, BLT, BGE, BLTU, BGEU
            case (funct3)
                3'b000 : begin //BEQ
                    position = 4;
                end
                3'b001 : begin //BNE
                    position = 5;
                end
                3'b100 : begin //BLT
                    position = 6;
                end
                3'b101 : begin //BGE
                    position = 7;
                end
                3'b110 : begin //BLTU
                    position = 8;
                end
                3'b111 : begin //BGEU
                    position = 9;
                end
                default : begin
                end/* Unknown Instruction */
            endcase // funct3
         end
         7'b0000011 : begin //LB, LH, LW, LBU, LHU
            case (funct3)
                3'b000 : begin //LB
                    position = 10;
                end
                3'b001 : begin //LH
                    position = 11;
                end
                3'b010 : begin //LW
                    position = 12;
                end
                3'b100 : begin //LBU
                    position = 13;
                end
                3'b101 : begin //LHU
                    position = 14;
                end
                default : begin
                end/* Unknown Instruction */
            endcase // funct3
         end
         7'b0100011 : begin //SB, SH, SW
            case (funct3)
                3'b000 : begin //SB
                    position = 15;
                end
                3'b001 : begin //SH
                    position = 16;
                end
                3'b010 : begin //SW
                    position = 17;
                end
                default : begin
                end/* Unknown Instruction */
            endcase
         end
         7'b0010011 : begin //ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            case (funct3)
                3'b000 : begin //ADDI
                    position = 18;
                end
                3'b010 : begin //SLTI
                    position = 19;
                end
                3'b011 : begin //SLTIU
                    position = 20;
                end
                3'b100 : begin //XORI
                    position = 21;
                end
                3'b110 : begin //ORI
                    position = 22;
                end
                3'b111 : begin //ANDI
                    position = 23;
                end
                3'b001 : begin //SLLI
                    position = 24;
                end
                3'b101 : begin //SRLI, SRAI
                    if(local_inst[31:25] == 7'b0000000) begin
                        position = 25;
                    end
                    else if(local_inst[31:25] == 7'b0100000) begin
                        position = 26;
                    end
                end
                default : begin
                end/* Unknown Instruction */
            endcase
         end
         7'b0110011 : begin //ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            case (funct3)
                3'b000 : begin //ADD, SUB
                    if(local_inst[31:25] == 7'b0000000) begin
                        position = 27;
                    end
                    else if(local_inst[31:25] == 7'b0100000) begin
                        position = 28;
                    end
                end
                3'b001 : begin //SLL
                    position = 29;
                end
                3'b010 : begin //SLT
                    position = 30;
                end
                3'b011 : begin //SLTU
                    position = 31;
                end
                3'b100 : begin //XOR
                    position = 32;
                end
                3'b101 : begin //SRL, SRA
                    if(local_inst[31:25] == 7'b0000000) begin
                        position = 33;
                    end
                    else if(local_inst[31:25] == 7'b0100000) begin
                        position = 34;
                    end
                end
                3'b110 : begin //OR
                    position = 35;
                end
                3'b111 : begin //AND
                    position = 36;
                end
                default : begin
                end/* Unknown Instruction */
            endcase
         end
         7'b0001111 : begin //FENCE, FENCE.I
            case (funct3)
                3'b000 : begin //FENCE
                    position = 37;
                end
                3'b001 : begin //FENCE.I
                    position = 38;
                end
                default : begin
                end/* Unknown Instruction */
            endcase // funct3
         end
         7'b1110011 : begin //ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
            case (funct3)
                3'b000 : begin //ECALL, EBREAK
                    position = 39;
                    //position = 40; not implemented
                end
                3'b001 : begin //CSRRW
                    position = 41;
                end
                3'b010 : begin //CSRRS
                    position = 42;
                end
                3'b011 : begin //CSRRC
                    position = 43;
                end
                3'b101 : begin //CSRRWI
                    position = 44;
                end
                3'b110 : begin //CSRRSI
                    position = 45;
                end
                3'b111 : begin //CSRRCI
                    position = 46;
                end
            endcase // funct3
         end
         default : begin
         end/* Unknown Instruction */
      endcase

endtask : find_inst_in_set

endmodule
