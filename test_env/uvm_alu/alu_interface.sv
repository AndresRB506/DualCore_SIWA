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
//////////////////////////////////////////////////////    
    Control_compa : coverpoint ALU_CTRL { 
      bins  equ  =  {0};
      bins  le =    {1};
      bins  leu  =  {2};
      bins  gre =   {3};
      bins  greu  = {4};
      bins  no_comp = default;
    }
    Control_nocompa : coverpoint ALU_CTRL { 
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

    Control_aritm : coverpoint ALU_CTRL {
      bins  add =   {5};
      bins  addu  = {6};
      bins  subu =  {7}; 
      bins  no_comp = default;
    }
    Control_noaritm : coverpoint ALU_CTRL { 
      bins  equ  =  {0};
      bins  le =    {1};
      bins  leu  =  {2};
      bins  gre =   {3};
      bins  greu  = {4};
      bins  sl  =   {8};
      bins  sr =    {9};
      bins  sra  =  {10};
      bins  Or =    {11};
      bins  Xor  =  {12};
      bins  And =   {13};
    }
////////////////////////////////////////////////////    
    Result_cero : coverpoint result {
      bins  cero = {32'h00000000};
    }
    
    
    //CXZ: cross Control, Zer0;
    //CXC: cross Control, Carr1;
    //CXN: cross Control, Neg;
    //CXO: cross Control, Over;
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// CRUZADOS PARA RESULTADO /////////////////////////////////////////////////////////
    CCXRcero: cross Control_compa, Result_cero; // resultado permanece en cero con funciones comparativas. 

/*    CCXRuno: cross Control_compa, Resultado{  // resultado nunca es diferente de cero con funciones comparativas, 
      ignore_bins no_cero = binsof (Resultado) intersect {0}; //por lo tanto prcentaje de cobertura deberia ser cero 
    }*/
//////////////////////////////////// CRUZADOS PARA ZERO /////////////////////////////////////////////////////////
    CCXZ: cross Control_compa, Zer0; // no dice mucho 

    CnCXZcero: cross Control_nocompa, Zer0{  // zero siempre debe permanecer en cero con estas funciones
      ignore_bins no_uno = binsof (Zer0) intersect {1};
    }

  /*  CnCXZuno: cross Control_nocompa, Zer0{  // Zero nunca es 1 con funciones no comparativas,
      ignore_bins no_cero = binsof (Zer0) intersect {0}; //por lo tanto porcentaje de cobertura deberia ser cero  
    }*/
    //////////////////////////////////// CRUZADOS PARA CARRY /////////////////////////////////////////////////////////
    CAXC: cross Control_aritm, Carr1;  // no dice mucho

    CnAXCcero: cross Control_noaritm, Carr1{  // overflow siempre debe permanecer en cero con estas funciones
      ignore_bins no_uno = binsof (Carr1) intersect {1};
    }   
    
    /*CnAXCuno: cross Control_noaritm, Carr1{  // Carry nunca es 1 con funciones no aritmeticas,
      ignore_bins no_cero = binsof (Carr1) intersect {0}; //por lo tanto porcentaje de cobertura deberia ser cero  
    }*/

    //////////////////////////////////// CRUZADOS PARA Overflow /////////////////////////////////////////////////////////
    CAXO: cross Control_aritm, Over;  // no dice mucho

    CnAXOcero: cross Control_noaritm, Over{  // Overflow siempre debe permanecer en cero con estas funciones
      ignore_bins no_uno = binsof (Over) intersect {1};
    }    
    
  /*  CnAXOuno: cross Control_noaritm, Over{  // Overflow nunca es 1 con funciones no aritmeticas,
      ignore_bins no_cero = binsof (Over) intersect {0}; //por lo tanto porcentaje de cobertura deberia ser cero  
    }*/
        
      endgroup: ALU
      
      ALU alu=new();
      
     
      endinterface