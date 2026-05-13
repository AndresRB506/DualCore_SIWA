  task selfcheck(input string inst_queue [$],
                 input string prediction [$],
                 input int executed_inst,
                 input string exe_inst_queue [$],
                 input string csr_predict [$]);
    string        file1;
    string        file2;
    string        filler;
    string        test_name;
    string        results        [$];
    string        results_csr    [$];
    string        data1          [$];
    string        data2          [$];
    string        data_csr       [$];
    logic  [32:0] status_flags   [0:31];
    int           file_s;

    //file1 = `PREDICTOR_FILE;//"Test_Files/References/lbu.o.txt";
    file2 = "results.txt";

    $display("-----------------------------------",);
    $display("Initiating Self-Checking Process...");
    $display("-----------------------------------",);
    $display("Total Number of Instructions: %d",((inst_queue.size()/4) - 1));
    //executed_inst_count(file1,executed_inst);
    $display("Total Number of Executed Instructions: %d",executed_inst);
    $display("\n---------------------------------------");    
    $display("------RTL result-----");
    $display("---------------------------------------");
    for (int inst_cont = 1; inst_cont < executed_inst; inst_cont++) begin
      //$display("\n -----Expected result (simulated)-----");
      /*load_expected_data(file1, inst_cont, status_flags, data1, status_flags);
      foreach(data1[i]) begin
        prediction.push_back(data1[i]);
      end*/
      load_RTL_data(file2, inst_cont, data2,data_csr);
      foreach(data2[i]) begin
        results.push_back(data2[i]);
      end
      foreach(data_csr[i]) begin
        results_csr.push_back(data_csr[i]);
      end
      //$display("size_p",prediction.size());
      //$display("size_r",results.size());
    end
    
    compare(prediction,results,exe_inst_queue);
    compare_csr(csr_predict,results_csr,exe_inst_queue);

    $display("---------------------------------------"); //if you reached this point, congrats!! The test has passed.
    $display("----------------TEST PASS--------------");
    $display("---------------------------------------");

    if($value$plusargs("TESTNAME=%s",test_name)) begin
        if($test$plusargs("SUMMARY")) begin
          file_s = $fopen("Summary.txt","r+");
          while(!$feof(file_s)) begin
            $fgets(filler,file_s);
          end
          filler = "";
          while (filler.len() < (30 - test_name.len())) begin //arbitrary number, it is just for aesthetics
              filler = {filler," "};
          end
          $fwrite(file_s,{" ",test_name,filler,"| PASS\n"});
          $fclose(file_s);
        end
    end

  endtask : selfcheck

  task compare(input string str_queue1 [$],
               input string str_queue2 [$],
               input string exe_inst_queue [$]); //prediction,results,instruction number
    
    string str1;
    string str2;
    string convert;
    string test_name;
    string filler;
    int count;
    int pc;
    int prev_pc;
    int pc_aux;
    int file;
    int file_s;
    int register;
    bit fail;
    logic [31:0] pc_offset;
    //$display("size",str_queue1.size());
    count = 0;
    prev_pc = 0;
    pc_aux = 0;
    fail = 0;
    pc_offset = 32'h10054;
    if($value$plusargs("TESTNAME=%s",test_name)) begin
        file = $fopen({"Results/Regfile_Comparison_",test_name,".txt"},"w");
    end
    else begin
        file = $fopen("Results/Regfile_Comparison.txt","w");
    end
    $fwrite(file,"---Prediction--RTL Result----\n");
    if ((str_queue1.size() == 0) && (str_queue2.size() == 0)) begin
      $display("Some data is missing");
      $display("Prediction Queue Size: %d",str_queue1.size());
      $display("RTL Results Queue Size: %d",str_queue2.size());
      $display("---------------------------------------",);
      $display("----------------TEST FAIL--------------");
      $display("---------------------------------------",);
      if($test$plusargs("SUMMARY")) begin
        file_s = $fopen("Summary.txt","r+");
        while(!$feof(file_s)) begin
          $fgets(filler,file_s);
        end
        filler = "";
        while (filler.len() < (30 - test_name.len())) begin //arbitrary number, it is just for aesthetics
            filler = {filler," "};
        end
        $fwrite(file_s,{" ",test_name,filler,"| FAIL\n"});
        $fclose(file_s);
      end
      $finish;
    end
    while((str_queue1.size() != 0) && (str_queue2.size() != 0)) begin
      //$display("size",str_queue1.size());
      //$display("size",str_queue2.size());
      str1 = str_queue1.pop_front();
      str2 = str_queue2.pop_front();

      //$display({"DEBUG: ",str1});
      //$display({"DEBUG: ",str2});
      if(str2 == "xxxxxxxx") begin
        convert.itoa(count);
        //$display("Uninitialized register: x", convert);
      end // if(str1 == "xxxxxxxx")
      else if(str1 != str2) begin
        //$display("DEBUG: %d",count);
        if((count % 32) == 0) begin
          $display({"Expected PC result: ",str1});
          //$display("Expected PC wihtout offset: %h",(str1.atohex() + pc_offset));
          $display({"RTL PC result: ",str2});
          fail = 1;
        end
        else begin
          convert.itoa(count%32);
          //$display("There has been a mismatch at instruction located at PC = %h (Wihtout offset: %h)",prev_pc,(prev_pc + pc_offset));
          $display("There has been a mismatch at instruction located at PC = %h",prev_pc);
          $display({"Expected x",convert," result: ",str1});
          $display({"RTL x",convert," result: ",str2});
          fail = 1;
        end
      end
      //$display("DEBUG: %d",count);
      if((count % 32) == 0) begin
        $fwrite(file,{"\nInstruction: ",exe_inst_queue[count/32],"\n"});
        prev_pc = str1.atohex();
        $fwrite(file,{"PC: ",str1,", ",str2,"\n"});
      end // if((count % 32) == 0)
      else begin
        register = count % 32;
        convert.itoa(register);
        $fwrite(file,{"x",convert,": ",str1,", ",str2,"\n"});
      end
      if (fail == 1) begin
        $display("---------------------------------------",);
        $display("----------------TEST FAIL--------------");
        $display("---------------------------------------",);
        if($test$plusargs("SUMMARY")) begin
          file_s = $fopen("Summary.txt","r+");
          while(!$feof(file_s)) begin
            $fgets(filler,file_s);
          end
          filler = "";
          while (filler.len() < (30 - test_name.len())) begin //arbitrary number, it is just for aesthetics
              filler = {filler," "};
          end
          $fwrite(file_s,{" ",test_name,filler,"| FAIL\n"});
          $fclose(file_s);
        end
        $finish;
      end // if (fail == 1)
      count++;
    end
    /*if (fail == 0) begin
      $display("---------------------------------------",);
      $display("----------------TEST PASS--------------");
      $display("---------------------------------------");
      if($test$plusargs("SUMMARY")) begin
        file_s = $fopen("Summary.txt","r+");
        while(!$feof(file_s)) begin
          $fgets(filler,file_s);
        end
        filler = "";
        while (filler.len() < (30 - test_name.len())) begin //arbitrary number, it is just for aesthetics
            filler = {filler," "};
        end
        $fwrite(file_s,{" ",test_name,filler,"| PASS\n"});
        $fclose(file_s);
      end
    end*/
    $fclose(file);
  
  endtask : compare

  task compare_csr(input string str_queue1 [$],
                   input string str_queue2 [$],
                   input string exe_inst_queue [$]); //prediction,results,instruction number
    
    string str1;
    string str2;
    string convert;
    string test_name;
    string filler;
    int count;
    int pc;
    int prev_pc;
    int pc_aux;
    int file;
    int file_s;
    int register;
    bit fail;
    logic [31:0] pc_offset;
    //$display("size",str_queue1.size());
    count = 0;
    prev_pc = 0;
    pc_aux = 0;
    fail = 0;
    pc_offset = 32'h10054;
    if($value$plusargs("TESTNAME=%s",test_name)) begin
        file = $fopen({"Results/CSR_Comparison_",test_name,".txt"},"w");
    end
    else begin
        file = $fopen("Results/CSR_Comparison.txt","w");
    end
    $fwrite(file,"---Prediction--RTL Result----\n");
    while((str_queue1.size() != 0) && (str_queue2.size() != 0)) begin
      //$display("size1 %d",str_queue1.size());
      //$display("size2 %d",str_queue2.size());
      str1 = str_queue1.pop_front();
      str2 = str_queue2.pop_front();
      if(str2 == "xxxxxxxx") begin
        convert.itoa(count);
      end // if(str1 == "xxxxxxxx")
      else if(str1 != str2) begin
        if((count % 13) == 0) begin
          $display({"CSR: Expected PC result: ",str1});
          $display({"CSR: RTL PC result: ",str2});
          fail = 1;
        end
        else begin
          convert.itoa((count%13)-1);
          //$display("There has been a mismatch at instruction located at PC = %h (Wihtout offset: %h)",prev_pc,(prev_pc + pc_offset));
          $display("There has been a mismatch at instruction located at PC = %h",prev_pc);
          $display({"Expected CSR",convert," result: ",str1});
          $display({"RTL CSR",convert," result: ",str2});
          fail = 1;
        end
      end
      if((count % 13) == 0) begin
        $fwrite(file,{"\nInstruction: ",exe_inst_queue[count/32],"\n"});
        prev_pc = str1.atohex();
        $fwrite(file,{"PC: ",str1,", ",str2,"\n"});
      end // if((count % 32) == 0)
      else begin
        register = (count%13)-1;
        convert.itoa(register);
        $fwrite(file,{"CSR",convert,": ",str1,", ",str2,"\n"});
      end
      if (fail == 1) begin
        $display("---------------------------------------",);
        $display("----------------TEST FAIL--------------");
        $display("---------------------------------------",);
        if($test$plusargs("SUMMARY")) begin
          file_s = $fopen("Summary.txt","r+");
          while(!$feof(file_s)) begin
            $fgets(filler,file_s);
          end
          filler = "";
          while (filler.len() < (30 - test_name.len())) begin //arbitrary number, it is just for aesthetics
              filler = {filler," "};
          end
          $fwrite(file_s,{" ",test_name,filler,"| FAIL\n"});
          $fclose(file_s);
        end
        $finish;
      end // if (fail == 1)
      count++;
    end
    $fclose(file);
  
  endtask : compare_csr

  task load_RTL_data(input string str, input int inst_num, output string data[$], output string data_csr[$]);
    int out;
    int pc;
    int prev_pc;
    int count;
    string line;
    string info;

    data.delete();
    data_csr.delete();
    count = 0;
    prev_pc = 0;
    out = $fopen(str,"r");
    //$display("DEBUG Inst_num: %d", inst_num);
    while(!$feof(out)) begin
      $fgets(line,out);
      if({line[0],line[1],line[2]} == "PC:") begin
        info = {line[4],line[5],line[6],line[7],line[8],line[9],line[10],line[11]};
        pc = info.atohex();
        //$display("pc: %d",pc);
        //$display("prev_pc: %d",prev_pc);
        //$display("count: %d",count);
        if (pc != prev_pc) begin
          count++;
          prev_pc = pc;
        end // if ()
        /*else if (pc == 0) begin
          count++;
        end*/
        if (count == (inst_num - 1)) begin //registers for current instruction found
          //$display({"PC: ",info});
          data.push_back(info);
          data_csr.push_back(info);
          $fgets(line,out);
          while ({line[0],line[1],line[2],line[3],line[4]} != "x1,ra") begin //discard lines until you find x1 line
            $fgets(line,out); //discard line
            if($feof(out)) begin
              $display("ERROR in RTL File");
              break;
            end
          end // while ({line[0],line[1],line[2],line[3],line[4]} != "x1,ra")
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x2 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x3 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x4 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x5 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x6 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x7 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x8 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x9 line
          info = {line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14]};
          data.push_back(info);
          $fgets(line,out); //x10 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x11 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x12 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x13 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x14 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x15 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x16 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x17 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x18 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x19 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x20 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x21 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x22 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x23 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x24 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x25 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x26 line
          info = {line[9],line[10],line[11],line[12],line[13],line[14],line[15],line[16]};
          data.push_back(info);
          $fgets(line,out); //x27 line
          info = {line[9],line[10],line[11],line[12],line[13],line[14],line[15],line[16]};
          data.push_back(info);
          $fgets(line,out); //x28 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x29 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x30 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //x31 line
          info = {line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15]};
          data.push_back(info);
          $fgets(line,out); //mip_mie line
          info = {line[16],line[17],line[18],line[19],line[20],line[21],line[22],line[23]};
          data_csr.push_back(info);
          $fgets(line,out); //mepc line
          info = {line[10],line[11],line[12],line[13],line[14],line[15],line[16],line[17]};
          data_csr.push_back(info);
          $fgets(line,out); //mcause1 line
          info = {line[15],line[16],line[17],line[18],line[19],line[20],line[21],line[22]};
          data_csr.push_back(info);
          $fgets(line,out); //mcause2 line
          info = {line[15],line[16],line[17],line[18],line[19],line[20],line[21],line[22]};
          data_csr.push_back(info);
          $fgets(line,out); //gpio line
          info = {line[10],line[11],line[12],line[13],line[14],line[15],line[16],line[17]};
          data_csr.push_back(info);
          $fgets(line,out); //mvtec line
          info = {line[11],line[12],line[13],line[14],line[15],line[16],line[17],line[18]};
          data_csr.push_back(info);
          $fgets(line,out); //timer_comp line
          info = {line[16],line[17],line[18],line[19],line[20],line[21],line[22],line[23]};
          data_csr.push_back(info);
          $fgets(line,out); //timer_valor line
          info = {line[17],line[18],line[19],line[20],line[21],line[22],line[23],line[24]};
          data_csr.push_back(info);
          $fgets(line,out); //full_shift line
          info = {line[16],line[17],line[18],line[19],line[20],line[21],line[22],line[23]};
          data_csr.push_back(info);
          $fgets(line,out); //IS_Val line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data_csr.push_back(info);
          $fgets(line,out); //IS_config line
          info = {line[15],line[16],line[17],line[18],line[19],line[20],line[21],line[22]};
          data_csr.push_back(info);
          $fgets(line,out); //IS_trigger line
          info = {line[16],line[17],line[18],line[19],line[20],line[21],line[22],line[23]};
          data_csr.push_back(info);
          $fclose(out);
          //$fgets(line,out); //discard line
          //$display("size_d",data.size());
          print_reg_file(data);
          print_reg_csr(data_csr);
          break;
          //disable load_data;
          //$display(data[1]);
        end //if (count == inst_num)
      end // if(line[0] == x)
    end
    $fclose(out);
  endtask : load_RTL_data

  task load_expected_data(input string str, input int inst_num, input logic [32:0] status_in[0:31], output string data_out[$], output logic [32:0] status_out[0:31]);

    int out;
    int count;
    logic [31:0] pc;
    logic [31:0] pc_offset;
    logic [31:0] instruction;
    string line;
    string info;
    string instruction_str;
    string data [$];
    pc_offset = 32'h10054;
    data.delete();
    data_out.delete();
    status_out = status_in;
    count = 0;
    out = $fopen(str,"r");
    while(!$feof(out)) begin
      $fgets(line,out);
      if({line[0],line[1]} == "00") begin
        count++;
        //$display("DEBUG: ",info);
        if(count == inst_num)begin //registers for current instruction found
          instruction_str = {line[40],line[41],line[42],line[43],line[44],line[45],line[46],line[47]};
          instruction = instruction_str.atohex();
          $display("Instruction: %h",instruction);
          info = {line[30],line[31],line[32],line[33],line[34],line[35],line[36],line[37]};
          pc = info.atohex();
          pc = pc - pc_offset;
          //$display("PC: %h",pc);
          info.hextoa(pc);
          //$display("DEBUG: ",info);
          while (info.len() <= 7) begin
            info = {"0",info};
          end // while (info.size() <= 7)
          //$display("DEBUG: ",info);
          //$display({"PC: ",info});
          data.push_back(info);
          $fgets(line,out); //x1 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          $fgets(line,out); //x2 line && x3 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x4 line && x5 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x6 line && x7 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x8 line && x9 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x10 line && x11 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x12 line && x13 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x14 line && x15 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x16 line && x17 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x18 line && x19 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x20 line && x21 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x22 line && x23 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x24 line && x25 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x26 line && x27 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x28 line && x29 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          $fgets(line,out); //x30 line && x31 line
          info = {line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]};
          data.push_back(info);
          info = {line[33],line[34],line[35],line[36],line[37],line[38],line[39],line[40]};
          data.push_back(info);
          //$fgets(line,out); //discard line
          //$display("size_d",data.size());
          $fclose(out);
          //$display("size: %d",data.size());
          instruction_analysis(instruction,pc,data,status_in,data_out,status_out);
          //$display("size: %d",data.size());
          print_reg_file(data_out);
          break;
          //disable load_data;
          //$display(data[1]);
        end
      end // if(line[0] == x)
    end
    $fclose(out);
  
  endtask : load_expected_data

  task executed_inst_count(input string str, output int count);

    string line;
    string info;
    int out;

    count = 0;
    out = $fopen(str,"r");
    $fgets(line,out);
    while ({line[0],line[1],line[2],line[3]} != "TRAP") begin
      if ({line[0],line[1]} == "00") begin
        count++;
      end // if ({line[0],line[1]} == "00")
      $fgets(line,out);
      if($feof(out)) begin
        $display("ERROR in Predictor File");
        break;
      end
    end // while ()
    $fclose(out);
  endtask : executed_inst_count

  task last_inst_search(input string str, output logic [31:0] last_inst);

    string line;
    string info;
    int out;
    logic [31:0] instruction;
    logic [31:0] instruction_old;

    instruction = 0;
    instruction_old = 0;
    out = $fopen(str,"r");
    $fgets(line,out);
    while ({line[0],line[1],line[2],line[3]} != "TRAP") begin
      if ({line[0],line[1]} == "00") begin
        instruction_old = instruction;
        info = {line[40],line[41],line[42],line[43],line[44],line[45],line[46],line[47]};
        instruction = info.atohex();
        //$display("DEBUG %h",instruction);
      end
      $fgets(line,out);
      if($feof(out)) begin
        $display("ERROR in Predictor File");
        break;
      end
    end // while ()
    $fclose(out);
    last_inst = instruction_old;
    //$display("DEBUG %h",last_inst);
  endtask : last_inst_search

  task instruction_analysis(input logic [31:0] instruction, input logic [31:0] pc, input string data_in [$], input logic [32:0] status_in[0:31], output string data_out [$], output logic [32:0] status_out[0:31]);

    //Identify which instruction we are running
    // The jal, jalr and stores are important since they change according to the memory map
    int           register;
    logic  [31:0] next_pc;
    logic  [6:0]  opcode;
    string        reg_str;
    string        content_str;

    register = 0;
    next_pc = 0;
    data_out.delete();
    data_out = data_in;
    status_out = status_in;
    //$display("size: %d",data_in.size());
    //Checks if a JAL ocurred before
    foreach(status_in[i]) begin
      //$display("reg: %d",i);
      //$display("status: %b",status_in[i]);
      if(status_in[i][32] == 1) begin
        next_pc = status_in[i][31:0];
        register = i;
        reg_file_update(register,next_pc,data_in,data_out);
      end
    end
    //JAL instruction
    opcode = {instruction[6],instruction[5],instruction[4],instruction[3],instruction[2],instruction[1],instruction[0]};
    case (opcode)
      7'b1101111 : begin
        $display("JAL Instruction identified!");
        if({instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]} != 5'b00000) begin //$zero register
          register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
          next_pc = pc + 4;
          //$display("pc: %h",pc);
          //$display("next_pc: %h",next_pc);
          status_out[register][31:0] = next_pc;
          status_out[register][32] = 1;
          reg_str.itoa(register);
          content_str.hextoa(next_pc);
          while (content_str.len() <= 7) begin
            content_str = {"0",content_str};
          end // while (content_str.size() <= 7)
          $display("This JAL instruction have made a valid update that is different from the reference model!");
          $display({"Register x",reg_str," content needs to be ",content_str});
          //$display("status: %b",status_out[register]);
          reg_file_update(register,next_pc,data_in,data_out);
        end
      end
      7'b1100111 : begin
        $display("JALR Instruction identified!");
        if({instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]} != 5'b00000) begin //$zero register
          register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
          next_pc = pc + 4;
          status_out[register][31:0] = next_pc;
          status_out[register][32] = 1;
          reg_str.itoa(register);
          content_str.hextoa(next_pc);
          while (content_str.len() <= 7) begin
            content_str = {"0",content_str};
          end // while (content_str.size() <= 7)
          $display("This JALR instruction have made a valid update that is different from the reference model!");
          $display({"Register x",reg_str," content needs to be ",content_str});
          reg_file_update(register,next_pc,data_in,data_out);
        end
      //Check if another instruction is going to overwrite the an updated register that differs from reference model
      end
      7'b0110111 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
      7'b0010111 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
      7'b0000011 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
      7'b0010011 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
      7'b0110011 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
      7'b1110111 : begin
        register = {instruction[11],instruction[10],instruction[9],instruction[8],instruction[7]};
        if(status_out[register][32] == 1) begin
          status_out[register][32] = 0;
        end
      end
    endcase // opcode

  endtask : instruction_analysis

  task reg_file_update(input int register, input logic [31:0] content, input string data_in [$], output string data_out [$]);
    //This task updates the last content saved in the reference register_file

    int data_size;
    string content_str;
    string reg_str;

    reg_str.itoa(register);
    content_str.hextoa(content);
    while (content_str.len() <= 7) begin
      content_str = {"0",content_str};
    end // while (content_str.size() <= 7)
    data_out.delete();
    data_out = data_in;
    data_size = data_out.size();
    //$display({"DEBUG: ",content_str});
    data_out[data_size - (32 - register)] = content_str;

  endtask : reg_file_update

  task print_reg_file(input string data [$]);

    int queue_size;

    queue_size = data.size();
    //$display("size: %d",queue_size);
    $display({"PC: ",data[queue_size - 32]});
    $display({"x1, ra: ",data[queue_size - 31]});
    $display({"x2, sp: ",data[queue_size - 30]});
    $display({"x3, gp: ",data[queue_size - 29]});
    $display({"x4, tp: ",data[queue_size - 28]});
    $display({"x5, t0: ",data[queue_size - 27]});
    $display({"x6, t1: ",data[queue_size - 26]});
    $display({"x7, t2: ",data[queue_size - 25]});
    $display({"x8, s0: ",data[queue_size - 24]});
    $display({"x9, s1: ",data[queue_size - 23]});
    $display({"x10, a0: ",data[queue_size - 22]});
    $display({"x11, a1: ",data[queue_size - 21]});
    $display({"x12, a2: ",data[queue_size - 20]});
    $display({"x13, a3: ",data[queue_size - 19]});
    $display({"x14, a4: ",data[queue_size - 18]});
    $display({"x15, a5: ",data[queue_size - 17]});
    $display({"x16, a6: ",data[queue_size - 16]});
    $display({"x17, a7: ",data[queue_size - 15]});
    $display({"x18, s2: ",data[queue_size - 14]});
    $display({"x19, s3: ",data[queue_size - 13]});
    $display({"x20, s4: ",data[queue_size - 12]});
    $display({"x21, s5: ",data[queue_size - 11]});
    $display({"x22, s6: ",data[queue_size - 10]});
    $display({"x23, s7: ",data[queue_size - 9]});
    $display({"x24, s8: ",data[queue_size - 8]});
    $display({"x25, s9: ",data[queue_size - 7]});
    $display({"x26, s10: ",data[queue_size - 6]});
    $display({"x27, s11: ",data[queue_size - 5]});
    $display({"x28, t3: ",data[queue_size - 4]});
    $display({"x29, t4: ",data[queue_size - 3]});
    $display({"x30, t5: ",data[queue_size - 2]});
    $display({"x31, t6: ",data[queue_size - 1]});
    $display("------------------------------------\n");
  
  endtask : print_reg_file

  task print_reg_csr(input string data [$]);

    int queue_size;

    queue_size = data.size();
    //$display("size: %d",queue_size);
    $display({"CSR,Mie/Mip/IO: ",data[queue_size - 12]});
    $display({"CSR,mepc: ",data[queue_size - 11]});
    $display({"CSR,Interrup1: ",data[queue_size - 10]});
    $display({"CSR,Interrup2: ",data[queue_size - 9]});
    $display({"CSR,GPIO: ",data[queue_size - 8]});
    $display({"CSR,mvtec: ",data[queue_size - 7]});
    $display({"CSR,timer_comp: ",data[queue_size - 6]});
    $display({"CSR,timer_valor: ",data[queue_size - 5]});
    $display({"CSR,full_shift: ",data[queue_size - 4]});
    $display({"CSR,IS_Val: ",data[queue_size - 3]});
    $display({"CSR,IS_Config: ",data[queue_size - 2]});
    $display({"CSR,IS_Trigger: ",data[queue_size - 1]});
    $display("------------------------------------\n");
  
  endtask : print_reg_csr