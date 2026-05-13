//`define DEBUG
module control (
  input clk,
  input reset,
  input [6:0] codif_inst_deco,
  input mem_rdy_mem_cntrlr,
  input error_drs_mem_cntrlr,
  input Zero_alu,
  input int_A,
  input int_T,
  input int_E,
  output logic r_1_w_0_mbc,
  output logic b_mbc,
  output logic h_mbc,
  output logic enable_mbc,
  output logic pop_intrpt,
  output logic ld_id_instrl_deco,
  output logic ld_addrs,
  output logic ld_pc,
  output logic s_addrs,
  output logic [1:0]s_pc1,
  output logic [1:0] s_pc2,
  output logic [2:0] s_alu,
  output logic [3:0] s_reg_w,
  output logic [2:0] s_csr,
  output logic write_reg_fl,
  output logic csr_write,
  output logic [3:0] cntrl_alu,
  output logic sign_ext,
  output logic inv_r1,
  output logic rst_tmr 
  );

  logic [1:0]s_cond;
  logic [1:0]cond;
  reg [7:0]cur_state;
  logic [7:0]nxt_state;
  logic r_1_w_0_mbc_pre;
  logic b_mbc_pre;
  logic h_mbc_pre;
  logic enable_mbc_pre;
  logic pop_intrpt_pre;
  logic ld_id_instrl_deco_pre;
  logic ld_addrs_pre;
  logic s_addrs_pre;
  logic ld_pc_pre;
  logic [2:0]s_csr_pre;
  logic [1:0]s_pc1_pre;
  logic [3:0]s_reg_w_pre;
  logic [2:0]s_alu_pre;
  logic [1:0] s_pc2_pre;
  logic sign_ext_pre;
  logic rst_tmr_pre;
  logic write_reg_fl_pre;
  logic csr_en_reg_fl_pre;
  logic [3:0]cntrl_alu_pre; 
  logic inv_r1_pre;
  logic csr_write_pre;
  logic enbl_ntrpt_pre;
  logic [1:0] ntrpt_dco;
  logic enbl_ntrpt;
  logic Actv_ntrpt;

  parameter boot = 0;
  parameter fetchwait= 1;
  parameter fetch= 2; 
  parameter fetch1 = 3;
  parameter fetch2 = 4;
  parameter fetch3 = 5;
  parameter dco = 6;
  parameter inst_det =7;
  parameter LUI =8;
  parameter AUIPC =9;
  parameter AUIPC1 = 10;
  parameter AUIPC2 = 11;
  parameter JAL =12;
  parameter JAL1=13;
  parameter JAL2=14;
//  parameter JAL3=15;
  parameter BEQ =16;
  parameter BEQ1 =17;
  parameter BEQ2 =18;
  parameter BNE =19;
  parameter BNE1 =20;
  parameter BNE2 =21;
  parameter BLT =22;
  parameter BLT1 =23;
  parameter BLT2 =24;
  parameter BGE =25;
  parameter BGE1 =26;
  parameter BGE2 =27;
  parameter BLTU=28;
  parameter BLTU1=29;
  parameter BLTU2=30;
  parameter BGEU=31;
  parameter BGEU1=32;
  parameter BGEU2=33;
  parameter SB =34;
  parameter SB1 =35;
  parameter SB2 =36;
  parameter SB3 =37;
  parameter SB4 =38;
  parameter SH =39;
  parameter SH1 =40;  
  parameter SH2 =41;
  parameter SH3 =42;
  parameter SH4 =43;
  parameter SW =44;
  parameter SW1 =45;
  parameter SW2 =46;
  parameter SW3 =47;
  parameter SW4 =48;
  parameter JALR =49;
  parameter JALR1 =50;
  parameter JALR2 =51;
//  parameter JALR3 =52;
  parameter LB =53;
  parameter LB1 =54;
  parameter LB2 =55;
  parameter LB3 =56;
  parameter LB4 =57;
  parameter LB5 =58;
  parameter LH =59;
  parameter LH1 =60;
  parameter LH2 =61;
  parameter LH3 =62;
  parameter LH4 =63;
  parameter LH5 =64;
  parameter LW =65;
  parameter LW1 =66;
  parameter LW2 =67;
  parameter LW3 =68;
  parameter LW4 =69;
  parameter LW5 =70;
  parameter LBU =71;
  parameter LBU1 =72;
  parameter LBU2 =73;
  parameter LBU3 =74;
  parameter LBU4 =75;
  parameter LBU5 =76;
  parameter LHU =77;
  parameter LHU1 =78;
  parameter LHU2 =79;
  parameter LHU3 =80;
  parameter LHU4 =81;
  parameter LHU5 =82;
  parameter ADDI =83;
  parameter ADDI1 =84;
  parameter SLTI =85;
  parameter SLTI1 =86;
  parameter SLTI2 =87;
  parameter SLTIU =88;
  parameter SLTIU1 =89;
  parameter SLTIU2 =90;
  parameter XORI =91;
  parameter XORI1 =92;
  parameter XORI2 =93;
  parameter ORI =94;
  parameter ORI1 =95;
  parameter ORI2 =96;
  parameter ANDI =97;
  parameter ANDI1 =98;
  parameter ANDI2 =99;
  parameter SLLI =100;
  parameter SLLI1 =101;
  parameter SLLI2 =102;
  parameter SRLI =103;
  parameter SRLI1 =104;
  parameter SRLI2 =105;
  parameter SRAI =106;
  parameter SRAI1 =107;
  parameter SRAI2 =108;
  parameter ADD =109;
  parameter ADD1= 110;
  parameter ADD2= 111;
  parameter SUB =112;
  parameter SUB1= 113;
  parameter SUB2= 114;
  parameter SLL =115;
  parameter SLL1 =116;
  parameter SLL2 =117;
  parameter SLT =118;
  parameter SLT1 =119;
  parameter SLT2 =120;
  parameter SLTU=121;
  parameter SLTU1=122;
  parameter SLTU2=123;
  parameter XOR =124;
  parameter XOR1 =125;
  parameter XOR2 =126;
  parameter SRL =127;
  parameter SRL1 =128;
  parameter SRL2 =129;
  parameter SRA =130;
  parameter SRA1 =131;
  parameter SRA2 =132;
  parameter OR  =133;
  parameter OR1  =134;
  parameter OR2  =135;
  parameter AND  =136;
  parameter AND1  =137;
  parameter AND2  =138;
  parameter ECALL  =139;
  parameter EBREAK =140;
  parameter MRET =141;
//  parameter MRET1 =142;
  parameter CSRRW =143;
  parameter CSRRW1 =144;
  parameter CSRRW2 =145;
  parameter CSRRW3 =146;
  parameter CSRRW4 =147;
  parameter CSRRS =148;
  parameter CSRRS1 =149;
  parameter CSRRS2 =150;
  parameter CSRRS3 =151;
  parameter CSRRS4 =152;
  parameter CSRRC= 153;
  parameter CSRRC1= 154;
  parameter CSRRC2= 155;
  parameter CSRRC3= 156;
  parameter CSRRC4= 157;
  parameter CSRRWI =158;
  parameter CSRRWI1 =159;
  parameter CSRRWI2 =160;
  parameter CSRRWI3 =161;
  parameter CSRRSI =162;
  parameter CSRRSI1 =163;
  parameter CSRRSI2 =164;
  parameter CSRRSI3 =165;
  parameter CSRRSI4 =166;
  parameter CSRRCI =167;
  parameter CSRRCI1 =168;
  parameter CSRRCI2 =169;
  parameter CSRRCI3 =170;
  parameter CSRRCI4 =171;
  parameter ERROR_INST = 172;
  parameter ERROR_INST1 = 173;
  parameter incr_PC  =174;
//  parameter incr_PC1  =175;
  parameter INT_TIMER = 176;
  parameter INT_TIMER1 = 177;
  parameter INT_ANALOG = 178;
  parameter INT_ANALOG1 = 179;
  parameter INT_SPI_UART =180;
  parameter INT_SPI_UART1 =181;
  parameter INT_SPI_UART2 =182;
  parameter INT_SPI_UART3 =183;
  parameter INT_SPI_UART4 =184;
  parameter ERROR_ADRS = 185;
  parameter ERROR_ADRS1 = 186;
  parameter ERROR_ADRS2 = 187;
  parameter ERROR_ADRS3 = 188;
  parameter W_MEPC_PC = 189; 
  parameter W_MEPC_PC1= 190;
  parameter W_PC_MTVEC= 191;
 // parameter W_PC_MTVEC1 = 191;
  parameter CHECK_INT = 192;
  parameter CHECK_INT1 = 193;
  parameter WFI  =194;

always@(*)begin

  case(s_cond) //synopsys infer_mux
    0: begin
     cond <= 0;
    end
    1: begin
     cond <= {error_drs_mem_cntrlr,mem_rdy_mem_cntrlr};
    end
    2: begin
     cond <= ntrpt_dco;
    end
    3: begin
     cond <= {1'b0,Zero_alu};
    end
  endcase

  case (cur_state)
    default: begin
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
      nxt_state<=ERROR_INST;
    end
    boot: begin // Espera a que termine el proceso de boot con la señal mem_ready
      nxt_state <= (cond==1)?fetch:boot;
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    incr_PC: begin
      nxt_state <= CHECK_INT;
      ld_pc_pre <=1;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
//    incr_PC1: begin
//      nxt_state <= CHECK_INT;
//      ld_pc_pre<= 1;
//      
//      r_1_w_0_mbc_pre<=1;
//      b_mbc_pre<=0;
//      h_mbc_pre<=0;
//      enable_mbc_pre<=0;
//      pop_intrpt_pre<=0;
//      ld_id_instrl_deco_pre<=0;
//      ld_addrs_pre<=0;
//      s_addrs_pre<=1;
//      s_csr_pre<=0;
//      s_pc1_pre<=0;
//      s_reg_w_pre<=1;
//      s_alu_pre<=1;
//      s_pc2_pre<=0;
//      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
//      write_reg_fl_pre<=0;
//      csr_write_pre<=0;inv_r1_pre<=0;
//      cntrl_alu_pre<=6; 
//      s_cond<=1;
//    end
    
    CHECK_INT: begin
      s_cond<=2;
      nxt_state<=CHECK_INT1;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
    end
    CHECK_INT1: begin
      s_cond<=2;
      case(cond)
        0: nxt_state <= fetch;
        1: nxt_state <= INT_ANALOG;
        2: nxt_state <= INT_TIMER;
        3: nxt_state <= INT_SPI_UART;
      endcase 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
    end
  

    fetch: begin // inicia el proceso de fetch cargando la dirección de la siguiente instrucción
      ld_addrs_pre<=1;
      nxt_state <= fetch1;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    fetch1: begin // inicia el proceso de lectura
      enable_mbc_pre <= 1;
      nxt_state <= fetchwait;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    fetchwait: begin
      nxt_state <= fetch2;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    fetch2: begin // espera  a que el proceso de lectura termine
      nxt_state <= (cond==1)?fetch3:fetch2;
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    fetch3: begin //Carga la instrucción en el decodificador y carga la siguiente dirección en el PC
      ld_id_instrl_deco_pre<=1;
      ld_pc_pre <=0;
      nxt_state <=dco;
       `ifdef DEBUG
         status_gpr();
         $display("tiempo: %g --> finaliza el fetch",$time);
       `endif
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
    end
    dco: begin // Calculate the next state based on the output of the instructions deco
      s_cond<=1;
        case(codif_inst_deco)
          0:   nxt_state <= AUIPC;
          2:   nxt_state <= BEQ;
          3:   nxt_state <= SB;
          4:   nxt_state <= LB;
          6:   nxt_state <= JALR;
          7:   nxt_state <= ADD;
          8:   nxt_state <= LUI;
          9:   nxt_state <= CSRRW;
          10:  nxt_state <= BNE;
          11:  nxt_state <= SH;
          12:  nxt_state <= LH;
          13:  nxt_state <= SLLI;
          15:  nxt_state <= SLL;
          17:  nxt_state <= CSRRS;
          19:  nxt_state <= SW;
          20:  nxt_state <= LW;
          23:  nxt_state <= SLT;
          25:  nxt_state <= CSRRC;
          31:  nxt_state <= SLTU;
          33:  nxt_state <= ECALL;
          34:  nxt_state <= BLT;
          36:  nxt_state <= LBU;
          39:  nxt_state <= XOR;
          40:  nxt_state <= CSRRWI;
          41:  nxt_state <= EBREAK;
          42:  nxt_state <= BGE;
          44:  nxt_state <= LHU;
          45:  nxt_state <= SRLI;
          47:  nxt_state <= SRL;
          48:  nxt_state <= CSRRSI;
          50:  nxt_state <= BLTU;
          55:  nxt_state <= OR;
          56:  nxt_state <= CSRRCI;
          57:  nxt_state <= MRET;
          58:  nxt_state <= BGEU;
          63:  nxt_state <= AND;
          64:  nxt_state <= JAL;
          68:  nxt_state <= ADDI;
          71:  nxt_state <= SUB;
          84:  nxt_state <= SLTI;
          92:  nxt_state <= SLTIU;
          97:  nxt_state <= WFI;
          100: nxt_state <= XORI;
          111: nxt_state <= SRA;
          109: nxt_state <= SRAI;
          116: nxt_state <= ORI;
          124: nxt_state <= ANDI;
          127: nxt_state <= ERROR_INST;
          default: nxt_state <= ERROR_INST;
        endcase
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
     LUI: begin // carga el Registro con el inmediato que viene de la instruccion
       write_reg_fl_pre<=1;
       nxt_state <= incr_PC;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LUI",$time);
         status_deco();
       `endif
    
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     AUIPC: begin
       s_reg_w_pre<=2;
       s_alu_pre<=2;
       nxt_state <=AUIPC1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de AUIPC",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     AUIPC1: begin
       s_reg_w_pre <= 2;
       s_alu_pre<=2;
       write_reg_fl_pre<=1;
       nxt_state <=AUIPC2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     AUIPC2: begin
       s_reg_w_pre<=2;
       s_alu_pre<=2;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     JAL: begin
       s_reg_w_pre <= 2;
       cntrl_alu_pre<= 6;
       s_alu_pre<=1;
       s_pc2_pre<=0;
       nxt_state <= JAL1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de JAL", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end 
     JAL1: begin
       s_reg_w_pre <= 2;
       cntrl_alu_pre<=6;
       s_alu_pre<=1;
       s_pc2_pre<=0;
       write_reg_fl_pre<=1;
       s_pc1_pre<=1;
       nxt_state <= JAL2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     JAL2: begin
       s_reg_w_pre <=2;
       cntrl_alu_pre<=5;
//       ld_pc_pre <= 0;
       ld_pc_pre <= 1;
       s_alu_pre<=2;
       s_pc1_pre<=0;
       s_pc2_pre<=0;
       write_reg_fl_pre<=0;
//       nxt_state <= JAL3; 
       nxt_state <= CHECK_INT;
       
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
//     JAL3: begin
//       s_reg_w_pre <=2;
//       cntrl_alu_pre<=5;
//       ld_pc_pre <= 1;
//       s_alu_pre<=2;
//       s_pc1_pre<=0;
//       s_pc2_pre<=0;
//       write_reg_fl_pre<=0;
//       nxt_state <= fetch; 
//       
//      r_1_w_0_mbc_pre<=1;
//      b_mbc_pre<=0;
//      h_mbc_pre<=0;
//      enable_mbc_pre<=0;
//      pop_intrpt_pre<=0;
//      ld_id_instrl_deco_pre<=0;
//      ld_addrs_pre<=0;
//      s_addrs_pre<=1;
//      s_csr_pre<=0;
//      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
//      csr_write_pre<=0;inv_r1_pre<=0;
//      s_cond<=1;
//     end
     ADD: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       nxt_state <=ADD1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de ADD", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     ADD1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       nxt_state <=ADD2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     ADD2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
     end
     AND: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=13; 
       nxt_state <=AND1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de AND", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     AND1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=13; 
       nxt_state <=AND2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     AND2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=13; 
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     OR: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=11; 
       nxt_state <=OR1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de OR", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     OR1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=11; 
       nxt_state <=OR2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     OR2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=11; 
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     XOR: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=12; 
       nxt_state <=XOR1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de XOR", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     XOR1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=12; 
       nxt_state <=XOR2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     XOR2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=12; 
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SUB: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=7;
       nxt_state <=SUB1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SUB", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SUB1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=7;
       nxt_state <= SUB2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SUB2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=7;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SLL: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=8;
       nxt_state <=SLL1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLL", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SLL1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=8;
       nxt_state <= SLL2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SLL2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=8;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRL: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=9;
       nxt_state <=SRL1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SRL", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRL1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=9;
       nxt_state <= SRL2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRL2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=9;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRA: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=10;
       nxt_state <=SRA1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SRA", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRA1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=10;
       nxt_state <= SRA2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRA2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=0;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=10;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
    JALR: begin
      s_alu_pre<=1;
      nxt_state<=JALR1;
      s_reg_w_pre<=2;
      s_pc2_pre<=0;
      cntrl_alu_pre<=6; 
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de JALR",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end 
    JALR1: begin
      s_alu_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=JALR2;
      write_reg_fl_pre<=1;
      s_pc2_pre<=0;
      cntrl_alu_pre<=6; 

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end 
    JALR2: begin
      s_alu_pre<=2;
      s_reg_w_pre<=2;
//      nxt_state<=JALR3;
      nxt_state<=CHECK_INT;
      write_reg_fl_pre<=0;
      cntrl_alu_pre<=5; 
      s_pc1_pre<=0;
      s_pc2_pre<=1;
      ld_pc_pre <=1;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
//      ld_pc_pre<= 0;
      s_csr_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end 
//    JALR3: begin
//      s_alu_pre<=2;
//      nxt_state<=fetch;
//      write_reg_fl_pre<=0;
//      cntrl_alu_pre<=5; 
//      s_pc2_pre<=1;
//      ld_pc_pre<= 1;
//      s_reg_w_pre<=2;
//
//      r_1_w_0_mbc_pre<=1;
//      b_mbc_pre<=0;
//      h_mbc_pre<=0;
//      enable_mbc_pre<=0;
//      pop_intrpt_pre<=0;
//      ld_id_instrl_deco_pre<=0;
//      ld_addrs_pre<=0;
//      s_addrs_pre<=1;
//      s_csr_pre<=0;
//      s_pc1_pre<=0;
//      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
//      csr_write_pre<=0;inv_r1_pre<=0;
//      s_cond<=1;
//    end 
    ADDI: begin
      s_alu_pre<=2;
      s_pc2_pre<=1;
      cntrl_alu_pre<=5;
      s_reg_w_pre<=2;
      nxt_state<=ADDI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de ADDI",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ADDI1: begin
      s_alu_pre<=2;
      s_pc2_pre<=1;
      cntrl_alu_pre<=5;
      nxt_state<=incr_PC;
      s_reg_w_pre<=2;
      write_reg_fl_pre<=1;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ANDI: begin
      cntrl_alu_pre<=13;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=ANDI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de ANDI",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ANDI1: begin
      cntrl_alu_pre<=13;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      nxt_state<=ANDI2;
      write_reg_fl_pre<=1;
      s_reg_w_pre<=2;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ANDI2: begin
      cntrl_alu_pre<=13;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=incr_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ORI: begin
      cntrl_alu_pre<=11;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=ORI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de ORI",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ORI1: begin
      cntrl_alu_pre<=11;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      nxt_state<=OR2;
      write_reg_fl_pre<=1;
      s_reg_w_pre<=2;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    ORI2: begin
      cntrl_alu_pre<=11;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=incr_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    XORI: begin
      cntrl_alu_pre<=12;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=XORI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de XORI",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    XORI1: begin
      cntrl_alu_pre<=12;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      nxt_state<=XORI2;
      write_reg_fl_pre<=1;
      s_reg_w_pre<=2;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    XORI2: begin
      cntrl_alu_pre<=12;
      s_alu_pre<=2;
      s_pc2_pre<=1;
      s_reg_w_pre<=2;
      nxt_state<=incr_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLT: begin
      s_pc2_pre<=1;
      s_alu_pre<=0;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      nxt_state<=SLT1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLT", $time);
         status_deco();
       `endif
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLT1: begin
      s_pc2_pre<=1;
      s_alu_pre<=0;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=SLT2;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLT2: begin
      s_pc2_pre<=1;
      s_alu_pre<=0;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      nxt_state<=incr_PC;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTU: begin
      s_pc2_pre<=1;
      s_alu_pre<=0;
      cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      nxt_state<=SLTU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLTU", $time);
         status_deco();
       `endif
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTU1: begin
      s_pc2_pre<=1;
      s_alu_pre<=0;
      cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=SLTU2;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTU2: begin
    s_pc2_pre<=1;
    s_alu_pre<=0;
    cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      nxt_state<=incr_PC;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTI: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      nxt_state<=SLTI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLTI", $time);
         status_deco();
       `endif
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTI1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=SLTI2;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTI2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=1; 
      s_reg_w_pre<=0;
      nxt_state<=incr_PC;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTIU: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      nxt_state<=SLTIU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLTIU", $time);
         status_deco();
       `endif
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTIU1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=SLTIU2;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SLTIU2: begin
    s_pc2_pre<=1;
    s_alu_pre<=2;
    cntrl_alu_pre<=2; 
      s_reg_w_pre<=0;
      nxt_state<=incr_PC;
      
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
     SLLI: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=8;
       nxt_state <=SLLI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SLLI", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SLLI1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=8;
       nxt_state <= SLLI2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SLLI2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=8;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRLI: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=9;
       nxt_state <=SRLI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SRLI", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRLI1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=9;
       nxt_state <= SRLI2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRLI2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=9;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRAI: begin // suma
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=10;
       nxt_state <=SRAI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SRAI", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRAI1: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       write_reg_fl_pre<=1;
       cntrl_alu_pre<=10;
       nxt_state <= SRAI2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
     SRAI2: begin // carga el resultado en el registro correspondiente
       s_pc2_pre<=1;
       s_alu_pre<=2;
       s_reg_w_pre<=2;
       cntrl_alu_pre<=10;
       nxt_state <=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
     end
    BEQ: begin
      cntrl_alu_pre<=0; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BEQ1;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BEQ1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==1)?BEQ2:incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BEQ2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;
       `ifdef DEBUG
         $display("tiempo: %g --> finaliza  ejecución de BEQ", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BNE: begin
      cntrl_alu_pre<=0; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BNE1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de BNE", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BNE1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==0)?BNE2:incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BNE2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLT: begin
      cntrl_alu_pre<=1; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BLT1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de BLT", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLT1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==1)?BLT2:incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLT2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGE: begin
      cntrl_alu_pre<=3; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BGE1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de BGE", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGE1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==1)?BGE2:BEQ;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGE2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLTU: begin
      cntrl_alu_pre<=2; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BLTU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de BLTU", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLTU1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==1)?BLTU2:incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BLTU2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGEU: begin
      cntrl_alu_pre<=4; 
      s_alu_pre<=0;
      s_cond<=3;
      s_pc2_pre<=1;
      nxt_state<=BGEU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de BGEU", $time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGEU1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      nxt_state <= (cond==1)?BGEU2:BEQ;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    BGEU2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_cond<=3;
      s_pc2_pre<=0;
      ld_pc_pre<= 1;
      nxt_state <= CHECK_INT;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    SB: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      b_mbc_pre<=1;
      r_1_w_0_mbc_pre<=0;
      s_pc2_pre<=1;
      nxt_state<=SB1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SB",$time);
         status_deco();
       `endif
     
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SB1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      b_mbc_pre<=1;
      ld_addrs_pre<=1;
      s_pc2_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<=SB2;
     
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SB2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      b_mbc_pre<=1;
      s_pc2_pre<=1;
      enable_mbc_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<=SB3;
     
      h_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SB3: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      b_mbc_pre<=1;
      enable_mbc_pre<=0;
      s_pc2_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<= SB4;
     
      h_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SB4: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      b_mbc_pre<=1;
      enable_mbc_pre<=0;
      s_pc2_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<= (cond==1)?incr_PC:SB4;
     
      h_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SH: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=1;
      s_pc2_pre<=1;
      nxt_state<=SH1;
      r_1_w_0_mbc_pre<=0;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SH",$time);
         status_deco();
       `endif
     
      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SH1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=1;
      ld_addrs_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<=SH2;
     
      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SH2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=1;
      enable_mbc_pre<=1;
      r_1_w_0_mbc_pre<=0;
      nxt_state<=SH3;
     
      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SH3: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=1;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=0;
      nxt_state<= SH4;
     
      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SH4: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=1;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=0;
      case(cond)
        0: nxt_state <= SH4;
        1: nxt_state <= incr_PC;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase
      s_cond<=1;
     
      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
    end
    SW: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=0;
      nxt_state<=SW1;
      r_1_w_0_mbc_pre<=0;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de SW",$time);
         status_deco();
       `endif
     
      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SW1: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=0;
      ld_addrs_pre<=1;
      nxt_state<=SW2;
      r_1_w_0_mbc_pre<=0;
 
      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SW2: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=SW3;
      r_1_w_0_mbc_pre<=0;

      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SW3: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=0;
      nxt_state<= SW4;
     
      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    SW4: begin
      cntrl_alu_pre<=5; 
      s_alu_pre<=2;
      s_addrs_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=0;
      case(cond)
        0: nxt_state <= SW4;
        1: nxt_state <= incr_PC;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase
     
      b_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_reg_w_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      nxt_state<=LB1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LB",$time);
         status_deco();
       `endif

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=1;
      nxt_state<=LB2;

      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=LB3;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB3: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      nxt_state<=LB4;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB4: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      case(cond)
        0: nxt_state <= LB4;
        1: nxt_state <= LB5;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LB5: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=incr_PC;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      nxt_state<=LH1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LH",$time);
         status_deco();
       `endif

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=1;
      nxt_state<=LH2;

      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=LH3;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH3: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      nxt_state<=LH4;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH4: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      case(cond)
        0: nxt_state <= LH4;
        1: nxt_state <= LH5;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LH5: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=incr_PC;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      nxt_state<=LW1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LW",$time);
         status_deco();
       `endif

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=1;
      nxt_state<=LW2;

      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=LW3;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW3: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      nxt_state<=LW4;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW4: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      case(cond)
        0: nxt_state <= LW4;
        1: nxt_state <= LW5;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LW5: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=1;
      b_mbc_pre<=0;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=incr_PC;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      nxt_state<=LBU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LBU",$time);
         status_deco();
       `endif

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=1;
      nxt_state<=LBU2;

      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=LBU3;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU3: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      nxt_state<=LBU4;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU4: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      case(cond)
        0: nxt_state <= LBU4;
        1: nxt_state <= LBU5;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LBU5: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      b_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=incr_PC;

      h_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      nxt_state<=LHU1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de LHU",$time);
         status_deco();
       `endif

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU1: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=1;
      nxt_state<=LHU2;

      b_mbc_pre<=0;
      enable_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU2: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=LHU3;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU3: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      nxt_state<=LHU4;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU4: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      case(cond)
        0: nxt_state <= LHU4;
        1: nxt_state <= LHU5;
        2: nxt_state <= ERROR_ADRS;
        3: nxt_state <= ERROR_ADRS;
      endcase

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      write_reg_fl_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end
    LHU5: begin
      s_pc2_pre<=1;
      s_alu_pre<=2;
      cntrl_alu_pre<=5; 
      sign_ext_pre<=0;
      h_mbc_pre<=1;
      s_addrs_pre<=0;
      s_reg_w_pre<=6;
      ld_addrs_pre<=0;
      enable_mbc_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=incr_PC;

      b_mbc_pre<=0;
      r_1_w_0_mbc_pre<=1;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
    end

    CSRRW: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRW1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRW",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRW1: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=CSRRW2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRW2: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRW3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRW3: begin
      s_reg_w_pre<=3;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRW4;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRW4: begin
      s_reg_w_pre<=3;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRWI: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRWI1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRWI",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRWI1: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      write_reg_fl_pre<=1;
      nxt_state<=CSRRWI2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRWI2: begin
      s_reg_w_pre<=1;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRWI3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRWI3: begin
      s_reg_w_pre<=1;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6; 
      s_cond<=1;
   end 
    CSRRS: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRS1;
      cntrl_alu_pre<=11; 
      s_alu_pre<=4;
      s_pc2_pre<=1;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRS",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRS1: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=1;
      s_pc2_pre<=1;
      cntrl_alu_pre<=11; 
      s_alu_pre<=4;
      nxt_state<=CSRRS2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRS2: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=CSRRS3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRS3: begin
      s_reg_w_pre<=2;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=CSRRS4;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRS4: begin
      s_reg_w_pre<=2;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRSI: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      nxt_state<=CSRRSI1;
      cntrl_alu_pre<=11; 
      s_alu_pre<=4;
      s_pc2_pre<=2;
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRSI",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRSI1: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=1;
      s_pc2_pre<=2;
      cntrl_alu_pre<=11; 
      s_alu_pre<=4;
      nxt_state<=CSRRSI2;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRSI2: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=CSRRSI3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRSI3: begin
      s_reg_w_pre<=2;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=CSRRSI4;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRSI4: begin
      s_reg_w_pre<=2;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      s_alu_pre<=4;
      cntrl_alu_pre<=11; 
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      inv_r1_pre<=0;
      s_cond<=1;
   end 
    CSRRC: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      nxt_state<=CSRRC1;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRC",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;
      s_cond<=1;
   end 
    CSRRC1: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=1;
      nxt_state<=CSRRC2;
      cntrl_alu_pre<=13; 
      inv_r1_pre<=1;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;
      s_cond<=1;
   end 
    CSRRC2: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      cntrl_alu_pre<=13; 
      write_reg_fl_pre<=0;
      inv_r1_pre<=1;
      nxt_state<=CSRRC3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    CSRRC3: begin
      s_reg_w_pre<=2;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      s_alu_pre<=4;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
      nxt_state<=CSRRC4;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    CSRRC4: begin
      s_reg_w_pre<=2;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      s_pc2_pre<=1;
      s_alu_pre<=4;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    CSRRCI: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      nxt_state<=CSRRCI1;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
       `ifdef DEBUG
         $display("tiempo: %g --> inicia ejecución de CSRRC",$time);
         status_deco();
       `endif

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;
      s_cond<=1;
   end 
    CSRRCI1: begin
      s_reg_w_pre<=7;
      write_reg_fl_pre<=1;
      nxt_state<=CSRRCI2;
      cntrl_alu_pre<=13; 
      inv_r1_pre<=1;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=2;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; sign_ext_pre<=0;
      csr_write_pre<=0;
      s_cond<=1;
   end 
    CSRRCI2: begin
      s_reg_w_pre<=7;
      csr_write_pre<=0;
      cntrl_alu_pre<=13; 
      write_reg_fl_pre<=0;
      inv_r1_pre<=1;
      nxt_state<=CSRRCI3;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=2;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    CSRRCI3: begin
      s_reg_w_pre<=2;
      csr_write_pre<=0;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      s_alu_pre<=4;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
      nxt_state<=CSRRCI4;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    CSRRCI4: begin
      s_reg_w_pre<=2;
      csr_write_pre<=1;
      write_reg_fl_pre<=0;
      s_pc2_pre<=2;
      s_alu_pre<=4;
      inv_r1_pre<=1;
      cntrl_alu_pre<=13; 
      nxt_state<=incr_PC;

      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_csr_pre<=0;
      s_pc1_pre<=0;
      rst_tmr_pre<=0; enbl_ntrpt_pre <= 0; 
      sign_ext_pre<=0;
      s_cond<=1;
   end 
    ERROR_INST: begin // escribe el Mcause_A con el vector_ist_error
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=13;
      csr_write_pre<=0;
      nxt_state<=ERROR_INST1;
       `ifdef DEBUG
         $display("tiempo: %g --> Se detecta un error de instrucción",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
    ERROR_INST1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=13;
      csr_write_pre<=1;
      nxt_state<=W_MEPC_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
INT_TIMER: begin // escribe el Mcause_A con el vector_timer  reseta el timer
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=12;
      csr_write_pre<=0;
      rst_tmr_pre<=1; 
      nxt_state<=INT_TIMER1;
       `ifdef DEBUG
         $display("tiempo: %g --> Se detecta una interrupción de timer",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
    INT_TIMER1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      rst_tmr_pre<=0; 
      s_reg_w_pre<=12;
      csr_write_pre<=1;
      nxt_state<=W_MEPC_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
    INT_ANALOG: begin // escribe el Mcause_A con el vector_anlg
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=11;
      csr_write_pre<=0;
      nxt_state<=INT_ANALOG1;
       `ifdef DEBUG
         $display("tiempo: %g --> Se detecta una interrupcion del bloque analógico",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_ANALOG1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=11;
      csr_write_pre<=1;
      nxt_state<=W_MEPC_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_SPI_UART: begin // escribe el Mcause_A con el vector_ext_int_A
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=4;
      csr_write_pre<=0;
      nxt_state<=INT_SPI_UART1;
       `ifdef DEBUG
         $display("tiempo: %g --> Se detecta una interrupcion del SPI o UART",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_SPI_UART1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=4;
      csr_write_pre<=1;
      nxt_state<=INT_SPI_UART2;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_SPI_UART2: begin // escribe el Mcause_B con el vector_ext_int_B y hace pop de la comunicación del bus
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=2;
      s_reg_w_pre<=5;
      csr_write_pre<=0;
      pop_intrpt_pre<=0;
      nxt_state<=INT_SPI_UART3;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_SPI_UART3: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=2;
      s_reg_w_pre<=5;
      csr_write_pre<=1;
      pop_intrpt_pre<=0;
      nxt_state<=INT_SPI_UART4;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    INT_SPI_UART4: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=2;
      s_reg_w_pre<=5;
      csr_write_pre<=0;
      pop_intrpt_pre<=1;
      nxt_state<=W_MEPC_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
    ERROR_ADRS: begin // escribe el Mcause_A con el vector_bad_addrs_A y resetea el MBC
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=9;
      csr_write_pre<=0;
      enable_mbc_pre<=1;
      nxt_state<=ERROR_ADRS1;
       `ifdef DEBUG
         $display("tiempo: %g --> Se detecta una excepción de address",$time);
         status_deco();
       `endif
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    ERROR_ADRS1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=1;
      s_reg_w_pre<=9;
      csr_write_pre<=1;
      nxt_state<=ERROR_ADRS2;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      enbl_ntrpt_pre <= 0; 
      s_cond<=1;
    end
    ERROR_ADRS2: begin // escribe el Mcause_B con el vector_bad_addrs_B
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=2;
      s_reg_w_pre<=10;
      csr_write_pre<=0;
      nxt_state<=ERROR_ADRS3;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    ERROR_ADRS3: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=2;
      s_reg_w_pre<=10;
      csr_write_pre<=1;
      nxt_state<=W_MEPC_PC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    W_MEPC_PC: begin  // escribe el mepc con el valor actual del PC y desabilita las interrupciones para el manejadir de interrupciones.
      enbl_ntrpt_pre <= 1; 
      s_csr_pre<=3;
      s_reg_w_pre<=8;
      nxt_state<=W_MEPC_PC1;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      csr_write_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    W_MEPC_PC1: begin
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=3;
      s_reg_w_pre<=8;
      csr_write_pre<=1;
      nxt_state<=W_PC_MTVEC;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
      ld_pc_pre<= 0;
      s_pc1_pre<=0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
    W_PC_MTVEC: begin // Escribe el PC con el valor de MTvec
      enbl_ntrpt_pre <= 0; 
      s_csr_pre<=4;
      s_pc1_pre<=2;
      s_reg_w_pre<=13;
      csr_write_pre<=0;
//      nxt_state<=W_PC_MTVEC1;
      nxt_state <= fetch;
      ld_pc_pre<=1;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
//      ld_pc_pre<= 0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
//      W_PC_MTVEC1: begin // Escribe el PC con el valor de MTvec
//      enbl_ntrpt_pre <= 0; 
//      s_csr_pre<=4;
//      s_pc1_pre<=2;
//      s_reg_w_pre<=13;
//      csr_write_pre<=0;
//      ld_pc_pre<= 1;
//      nxt_state<=fetch;
// 
//      r_1_w_0_mbc_pre<=1;
//      b_mbc_pre<=0;
//      h_mbc_pre<=0;
//      enable_mbc_pre<=0;
//      pop_intrpt_pre<=0;
//      ld_id_instrl_deco_pre<=0;
//      ld_addrs_pre<=0;
//      s_addrs_pre<=1;
//      s_alu_pre<=1;
//      s_pc2_pre<=0;
//      rst_tmr_pre<=0; 
//      sign_ext_pre<=0;
//      write_reg_fl_pre<=0;
//      inv_r1_pre<=0;
//      cntrl_alu_pre<=6;
//      enbl_ntrpt_pre <= 0; 
//      s_cond<=1;
//    end
    MRET: begin // Escribe el PC con el valor de MePC y habilita las interrupciones
      enbl_ntrpt_pre <= 1; 
      s_csr_pre<=3;
      s_pc1_pre<=2;
      s_reg_w_pre<=13;
      csr_write_pre<=0;
//      nxt_state<=MRET1;
      nxt_state<=CHECK_INT;
      ld_pc_pre <=1;
 
      r_1_w_0_mbc_pre<=1;
      b_mbc_pre<=0;
      h_mbc_pre<=0;
      enable_mbc_pre<=0;
      pop_intrpt_pre<=0;
      ld_id_instrl_deco_pre<=0;
      ld_addrs_pre<=0;
      s_addrs_pre<=1;
     // ld_pc_pre<= 0;
      s_alu_pre<=1;
      s_pc2_pre<=0;
      rst_tmr_pre<=0; 
      sign_ext_pre<=0;
      write_reg_fl_pre<=0;
      inv_r1_pre<=0;
      cntrl_alu_pre<=6;
      s_cond<=1;
    end
//      MRET1: begin // Escribe el PC con el valor de MTvec
//      enbl_ntrpt_pre <= 0; 
//      s_csr_pre<=3;
//      s_pc1_pre<=2;
//      s_reg_w_pre<=13;
//      csr_write_pre<=0;
//      ld_pc_pre<= 1;
//      nxt_state<=fetch;
// 
//      r_1_w_0_mbc_pre<=1;
//      b_mbc_pre<=0;
//      h_mbc_pre<=0;
//      enable_mbc_pre<=0;
//      pop_intrpt_pre<=0;
//      ld_id_instrl_deco_pre<=0;
//      ld_addrs_pre<=0;
//      s_addrs_pre<=1;
//      s_alu_pre<=1;
//      s_pc2_pre<=0;
//      rst_tmr_pre<=0; 
//      sign_ext_pre<=0;
//      write_reg_fl_pre<=0;
//      inv_r1_pre<=0;
//      cntrl_alu_pre<=6;
//      enbl_ntrpt_pre <= 0; 
//      s_cond<=1;
//    end
  endcase
end  

always_comb begin
  if(~Actv_ntrpt) begin
    if(int_A) begin
      ntrpt_dco <= 1;
    end else begin
       if(int_T) begin
          ntrpt_dco <=2;
       end else begin
          if(int_E) begin
            ntrpt_dco <= 3;
          end else begin
             ntrpt_dco <=0;
          end
       end
    end
  end else begin
    ntrpt_dco <=0;
  end
end  

always_ff@(posedge enbl_ntrpt or posedge reset) begin
  if(reset)begin
   Actv_ntrpt <= 0;
  end else begin
   Actv_ntrpt <= ~Actv_ntrpt; 
  end
end

dff_async_rst st0 (.data(nxt_state[0]),.clk(clk),.reset(reset),.q(cur_state[0]));
dff_async_rst st1 (.data(nxt_state[1]),.clk(clk),.reset(reset),.q(cur_state[1]));
dff_async_rst st2 (.data(nxt_state[2]),.clk(clk),.reset(reset),.q(cur_state[2]));
dff_async_rst st3 (.data(nxt_state[3]),.clk(clk),.reset(reset),.q(cur_state[3]));
dff_async_rst st4 (.data(nxt_state[4]),.clk(clk),.reset(reset),.q(cur_state[4]));
dff_async_rst st5 (.data(nxt_state[5]),.clk(clk),.reset(reset),.q(cur_state[5]));
dff_async_rst st6 (.data(nxt_state[6]),.clk(clk),.reset(reset),.q(cur_state[6]));
dff_async_rst st7 (.data(nxt_state[7]),.clk(clk),.reset(reset),.q(cur_state[7]));

always@(posedge clk or posedge reset) begin
  if(reset) begin
    r_1_w_0_mbc <=0;
    b_mbc <=0;
    h_mbc <=0;
    enable_mbc <=0;
    pop_intrpt <=0;
    ld_id_instrl_deco <=0;
    ld_addrs <=0;
    s_addrs <=0;
    ld_pc <=0;
    s_csr <=0;
    s_pc1 <=0;
    s_reg_w <=0;
    s_alu <=0;
    s_pc2 <=0;
    rst_tmr <=0;
    write_reg_fl <=0;
    csr_write <=0;
    cntrl_alu <=0;
    sign_ext <=0;
    inv_r1 <=0;
  end else begin
    r_1_w_0_mbc <= r_1_w_0_mbc_pre;
    b_mbc <= b_mbc_pre;
    h_mbc <= h_mbc_pre;
    enable_mbc <= enable_mbc_pre;
    pop_intrpt <= pop_intrpt_pre;
    ld_id_instrl_deco <= ld_id_instrl_deco_pre;
    ld_addrs <= ld_addrs_pre;
    s_addrs <= s_addrs_pre;
    ld_pc <= ld_pc_pre;
    s_csr <= s_csr_pre;
    s_pc1 <= s_pc1_pre;
    s_reg_w <= s_reg_w_pre;
    s_alu <= s_alu_pre;
    s_pc2 <= s_pc2_pre;
    rst_tmr <= rst_tmr_pre;
    write_reg_fl <= write_reg_fl_pre;
    cntrl_alu <= cntrl_alu_pre; 
    sign_ext <= sign_ext_pre;
    inv_r1 <= inv_r1_pre;
    csr_write <= csr_write_pre;
    enbl_ntrpt <= enbl_ntrpt_pre;
  end
  
end

endmodule


