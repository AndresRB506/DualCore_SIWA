`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2018 09:20:18 PM
// Design Name: 
// Module Name: uart_sb Scoreboard
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


class uart_sb;
   mailbox tx = new();
   mailbox rx = new();

  task txAdd(input [63:0] data);
  begin
    tx.put(data);
    $write("%dns : txAdd     : Dato agregado %x\n",$time, data);
  end
  endtask

  task rxAdd(input [63:0] data);
  begin
    rx.put(data);
    $write("%dns : rxAdd     : Dato agregado %x\n",$time, data);
  end
  endtask

  task txCompare(input [63:0] data);
  begin
    bit [63:0] org_data;
    tx.get(org_data);
    if (data != org_data) begin
      $write("%dns : txCompare : Error : Expera el dato %x, Recive %x\n",
       $time, org_data, data); 
    end else begin
      $write("%dns : txCompare : Match : Expera el dato %x, Recive %x\n",
       $time, org_data, data); 
    end
  end
  endtask

  task rxCompare(bit [63:0] data);
  begin
    bit [63:0] org_data;
    rx.get(org_data); //Recive rxAdd
    if (data != org_data) begin
      $write("%dns : rxCompare : Error : Expera el dato %x, Recive %x\n",
        $time, org_data, data); 
    end else begin
      $write("%dns : rxCompare : Match : Expecta el dato %x, Recive %x\n",
       $time, org_data, data); 
    end
  end
  endtask
endclass
