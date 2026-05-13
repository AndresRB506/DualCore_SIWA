//-------------------------------------------------------------------------
//						alu_interface - www.verificationguide.com
//-------------------------------------------------------------------------

interface alu_if();
  int covA;
  int covB;
  int covC;
  int covR;
   bit clk;
  always #1 clk = ~clk; 
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic [31:0] Data_A;
  logic [31:0] Data_B;
  logic [3:0] ALU_CTRL;
  logic Cin;
  logic [31:0] result;
  logic Zero;
  logic Overflow;
  logic Carry;
  logic Negative;
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output Data_A;
    output Data_B;
    output ALU_CTRL;
    output Cin;
    input result; 
    input Zero;
    input Overflow;
    input Carry;
    input Negative;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input Data_A;
    input Data_B;
    input ALU_CTRL;
    input Cin;
    input result; 
    input Zero;
    input Overflow;
    input Carry;
    input Negative;
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb, input clk);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
    modport MONITOR (clocking monitor_cb, input clk);
      //=================================================
  // Coverage Group in interface
  //=================================================
  
  covergroup ALU @(negedge clk);
    Dato_1 : coverpoint Data_A {
      bins Pos[46340]    = {[32'h00000000:32'h7FFFFFFF]};
      bins Neg[46340]    = {[32'h80000000:32'hFFFFFFFF]};
    }
    Dato_2 : coverpoint Data_B {
      bins Pos[46340]    = {[32'h00000000:32'h7FFFFFFF]};
      bins Neg[46340]    = {[32'h80000000:32'hFFFFFFFF]};
     
    }
    Resultado : coverpoint result {
      bins Pos[46340]    = {[32'h00000000:32'h7FFFFFFF]};
      bins Neg[46340]    = {[32'h80000000:32'hFFFFFFFF]};
          }
    Control : coverpoint ALU_CTRL {
      bins  equ  =  {0};
      bins  le =    {1};
      bins  leu  =  {2};
      bins  gre =   {3};
      bins  greu  = {4};
      bins  add =   {5};
      bins  addu  = {6};
      bins  subu =  {7};
      bins  sl  =   {8};
      bins  sr =    {9};
      bins  sra  =  {10};
      bins  Or =    {11};
      bins  Xor  =  {12};
      bins  And =   {13};
    }
    Zer0: coverpoint Zero{
      bins tr = {1};
      bins cr = {0};
    } 
    Carr1: coverpoint Carry{
      bins tr = {1};
      bins cr = {0};
    }
    Neg: coverpoint Negative{
      bins tr = {1};
      bins cr = {0};
    }
    Over: coverpoint Overflow{
      bins tr = {1};
      bins cr = {0};
    }
    CXZ: cross Control, Zer0;
    CXC: cross Control, Carr1;
    CXN: cross Control, Neg;
    CXO: cross Control, Over;
        

      endgroup: ALU
      
      ALU alu=new();
      
     
      endinterface
