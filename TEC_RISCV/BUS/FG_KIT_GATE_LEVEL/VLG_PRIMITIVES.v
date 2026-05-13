//************************************************************************/
// Copyright        : (c) All Rights Reserved 
// Company          : X-FAB Semiconductor Foundries AG 
// Address          : Haarbergstr. 67,  D-99097 Erfurt, Germany
//
// File             : VLG_PRIMITIVES.v
// Description      : Verilog simulation file: primitives & UDP's
//
// Lib_version      : V 1.0.9, Nov 21 2011
// Last Modified by : shl
//
// #######################################################################
//
//  Copyright (c) X-FAB Semiconductor Foundries AG . All rights reserved.
//  This Design Kit data and the associated documentation are
//  confidential and proprietary to X-FAB Semiconductor Foundries AG.
//
//  DISCLAIMER
//  The information contained herein is provided by X-FAB Semiconductor
//  Foundries AG  on an "AS IS" basis without any warranty.
//
//  X-FAB Semiconductor Foundries AG disclaims any representation that
//  the information does not infringe any intellectual property rights or 
//  proprietary rights of any third parties.  There are no other warranties 
//  given by X-FAB, whether express, implied or statutory, including, 
//  without limitation, implied warranties of merchantability and fitness 
//  for a particular purpose.
//
//  In no event X-FAB Semiconductor Foundries AG will be liable or 
//  responsible for any expense, losses, damages, or action incurred or 
//  undertaken as a result of the receipt of the information.
// 
//  X-FAB Semiconductor Foundries AG  reserves the right to make changes
//  to the information at any time and without notice.
//
// #######################################################################
// ***********************************************************************
// Remark:
// 
// If an ATPG tool is used then the compiler directive 
//   `define ATPG_RUN yes
// has to be set before reading this library.
//
// ***********************************************************************
//************************************************************************/

`timescale 1ns/10ps

// --------------------------------------------------------------------
// cell primitive section --- BEGIN ---

primitive u1_fd4  (Q, D, C, RN, SN, NOTIFY);

    output Q;
    input  D, C, RN, SN, NOTIFY;
    reg    Q;

// FUNCTION : POSITIVE EDGE TRIGGERED D FLIP-FLOP WITH 
//            ASYNCHRONOUS ACTIVE LOW SET AND CLEAR.

    table

//  D    C    RN    SN   NTFY : Qt  : Qt+1
// ---- ---- ----- ----- ---- : --- : ----
// data clk  rst_n set_n ntfy : Qi  : Q_out           
// ---- ---- ----- ----- ---- : --- : ----

    *	 b    1     1	  ?   :  ?  :  -  ; // data changes, clk stable
    ?  (?0)   1     1	  ?   :  ?  :  -  ; // clocks off


    1  (0x)   1     ?	  ?   :  1  :  1  ; // possible clk of D=1, but Q=1
    0  (0x)   ?     1	  ?   :  0  :  0  ; // possible clk of D=0, but Q=0

    ?	 ?    1     0	  ?   :  ?  :  1  ; // async set
    ?	 ?    0     1	  ?   :  ?  :  0  ; // async reset
//    ?	 ?    0     0	  ?   :  ?  :  0  ; // async reset and set - only by xlicdd models possible 

    0  (01)   ?     1	  ?   :  ?  :  0  ; // clocking D=0
    1  (01)   1     ?	  ?   :  ?  :  1  ; // clocking D=1

   					    // reduced pessimism: 
    ?    ?  (?1)    1     ?   :  ?  :  -  ; // ignore the edges on rst_n
    ?    ?    1   (?1)    ?   :  ?  :  -  ; // ignore the edges on set_n

    1  (x1)   1     ?     ?   :  1  :  1  ; // potential pos_edge clk, potential set_n, but D=1 && Qi=1
    0  (x1)   ?     1     ?   :  0  :  0  ; // potential pos_edge clk, potential rst_n, but D=0 && Qi=0

    1  (1x)   1     ?     ?   :  1  :  1  ; // to_x_edge clk, but D=1 && Qi=1
    0  (1x)   ?     1     ?   :  0  :  0  ; // to_x_edge clk, but D=0 && Qi=0

`ifdef    ATPG_RUN

    ?	 *    1     0	  ?   :  ?  :  1  ; // clk while async set	      // ATPG
    ?	 *    0     1	  ?   :  ?  :  0  ; // clk while async reset	      // ATPG
    ?	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1		      // ATPG
    ?    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0		      // ATPG

`else
   					    // reduced pessimism: 
    1	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1    	      // Vlg
    0	 b    1   (0x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
    0	 b    1   (1x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
   (??)	 b    1     ?	  ?   :  1  :  1  ; //   set=X, D=egdes, but Q=1      // Vlg
    ?  (?0)   1     x	  ?   :  1  :  1  ; //   set=X, neg_edge clk, but Q=1 // Vlg

    0    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0    	      // Vlg
    1    b  (0x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
    1    b  (1x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
   (??)  b    ?     1	  ?   :  0  :  0  ; // reset=X, D=egdes, but Q=0      // Vlg
    ?  (?0)   x     1	  ?   :  0  :  0  ; // reset=X, neg_edge clk, but Q=0 // Vlg

 
`endif // ATPG_RUN

    endtable

endprimitive


primitive u1_fd5  (Q, D, C, RN, SN, NOTIFY);

    output Q;
    input  D, C, RN, SN, NOTIFY;
    reg    Q;

// FUNCTION : POSITIVE EDGE TRIGGERED D FLIP-FLOP WITH 
//            ASYNCHRONOUS ACTIVE LOW SET AND CLEAR.
//            with the correct behavioral if set and reset Low
    table

//  D    C    RN    SN   NTFY : Qt  : Qt+1
// ---- ---- ----- ----- ---- : --- : ----
// data clk  rst_n set_n ntfy : Qi  : Q_out           
// ---- ---- ----- ----- ---- : --- : ----

    *	 ?    1     1	  ?   :  ?  :  -  ; // data changes, clk stable
    ?    n    1     1	  ?   :  ?  :  -  ; // clock falling edge


    1  (0x)   1     ?	  ?   :  1  :  1  ; // possible clk of D=1, but Q=1
    0  (0x)   ?     1	  ?   :  0  :  0  ; // possible clk of D=0, but Q=0

    ?	 ?    1     0	  ?   :  ?  :  1  ; // async set
    ?	 ?    0     ?	  ?   :  ?  :  0  ; // async reset, set 0,1,x

    0  (01)   ?     1	  ?   :  ?  :  0  ; // clocking D=0
    1  (01)   1     ?	  ?   :  ?  :  1  ; // clocking D=1

   					                        // reduced pessimism: 
    ?    ?  (?1)    1     ?   :  ?  :  -  ; // ignore the edges on rst_n
    ?    ?    1   (?1)    ?   :  ?  :  -  ; // ignore the edges on set_n

    1  (x1)   1     ?     ?   :  1  :  1  ; // potential pos_edge clk, potential set_n, but D=1 && Qi=1
    0  (x1)   ?     1     ?   :  0  :  0  ; // potential pos_edge clk, potential rst_n, but D=0 && Qi=0

//    1  (1x)   1     ?     ?   :  1  :  1  ; // to_x_edge clk, but D=1 && Qi=1
//    0  (1x)   ?     1     ?   :  0  :  0  ; // to_x_edge clk, but D=0 && Qi=0

`ifdef    ATPG_RUN

    ?	 *    1     0	  ?   :  ?  :  1  ; // clk while async set	      // ATPG
    ?	 *    0     1	  ?   :  ?  :  0  ; // clk while async reset	      // ATPG
    ?	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1		      // ATPG
    ?    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0		      // ATPG

`else
   					    // reduced pessimism: 
    1	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1    	      // Vlg
    0	 b    1   (0x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
    0	 b    1   (1x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
   (??)	 b    1     ?	  ?   :  1  :  1  ; //   set=X, D=egdes, but Q=1      // Vlg
    ?  (?0)   1     x	  ?   :  1  :  1  ; //   set=X, neg_edge clk, but Q=1 // Vlg

    0    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0    	      // Vlg
    1    b  (0x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
    1    b  (1x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
   (??)  b    ?     1	  ?   :  0  :  0  ; // reset=X, D=egdes, but Q=0      // Vlg
    ?  (?0)   x     1	  ?   :  0  :  0  ; // reset=X, neg_edge clk, but Q=0 // Vlg

 
`endif // ATPG_RUN

    endtable

endprimitive


primitive u_ld1 (Q, D, G, NOTI_REG);

    output Q;
    reg    Q;
    input  D,              // data
           G,              // clock
           NOTI_REG;

// FUNCTION : DLATCH, GATED  STANDARD DRIVE / ACTIVE HIGH ( Q OUTPUT UDP )
//


   table
     //  D       G    NOTI_REG        : Qtn :   Qtn+1

         *       0      ?             :  ?  :    -   ;

         ?      (?0)    ?             :  ?  :    -   ;
         0      (1x)    ?             :  0  :    -   ;
         1      (1x)    ?             :  1  :    -   ;

         0      (0x)    ?             :  0  :    0   ;
         1      (0x)    ?             :  1  :    1   ;
         0      (x1)    ?             :  ?  :    0   ;
         1      (x1)    ?             :  ?  :    1   ;

        (?0)     1      ?             :  ?  :    0   ;
        (?1)     1      ?             :  ?  :    1   ;
         0      (01)    ?             :  ?  :    0   ;
         1      (01)    ?             :  ?  :    1   ;

        (?1)     x      ?             :  1  :    1   ;    // Reducing pessimism.
        (?0)     x      ?             :  0  :    0   ;

         ?       ?      *             :  ?  :    x   ;
 
   endtable
endprimitive

primitive u_ld4 (Q,D,G,SN,RN,NOTI_REG);
	output Q;
	input D,G,SN,RN,NOTI_REG;
	reg Q;

// function: D latch active high with reset and set

table
//         D       G      SN    RN   NOTI_REG       : Qtn :   Qtn+1

         *       0      1     1     ?             :  ?  :    -   ;
         ?       ?      1     0     ?             :  ?  :    0   ; // asynchro clear
         ?       ?      0     1     ?             :  ?  :    1   ; // asynchro set

         ?      (?0)    1     1     ?             :  ?  :    -   ;
         0      (1x)    1     1     ?             :  0  :    -   ;
         1      (1x)    1     1     ?             :  1  :    -   ;

         0      (0x)    1     1     ?             :  0  :    0   ;
         1      (0x)    1     1     ?             :  1  :    1   ;
         0      (x1)    1     1     ?             :  ?  :    0   ;
         1      (x1)    1     1     ?             :  ?  :    1   ;

        (?0)     1      1     x     ?             :  ?  :    0   ;
        (?0)     1      1     1     ?             :  ?  :    0   ;
        (?1)     1      1     1     ?             :  ?  :    1   ;
         0      (01)    1     1     ?             :  ?  :    0   ;
         1      (01)    1     1     ?             :  ?  :    1   ;
         1      (01)    x     1     ?             :  ?  :    1   ;

         0      (01)    x     1     ?             :  ?  :    0   ;
         0       ?      x     1     ?             :  0  :    0   ;   // Reducing pessimism.
         1       ?      1     x     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       0     (?1)   1     ?             :  ?  :    -   ;   // ignore edge on clear
         0       1     (?1)   1     ?             :  ?  :    0   ;   // pessimism .
         1       1     (?1)   1     ?             :  ?  :    1   ;
         ?       0      1     (?1)  ?             :  ?  :    -   ;   // ignore edge on set
         0       1      1     (?1)  ?             :  ?  :    0   ;   // pessimism .
         1       1      1     (?1)  ?             :  ?  :    1   ;
 
        (?1)     x      1     1     ?             :  1  :    1   ;   // Reducing pessimism.
        (?0)     x      1     1     ?             :  0  :    0   ;   // Reducing pessimism.
 
         ?       0      1     x     ?             :  0  :    0   ;   // Reducing pessimism.
         ?       0      x     1     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       ?      ?     ?     *             :  ?  :    x   ;
           
endtable
endprimitive

primitive u_ld5 (Q,D,G,SN,RN,NOTI_REG);
	
    output Q;
	input D,G,SN,RN,NOTI_REG;
	reg Q;
	
//          function: D latch active high with reset and set
//          with the correct behavioral if set and reset Low

table
//         D       G      SN    RN   NOTI_REG       : Qtn :   Qtn+1

         *       0      1     1     ?             :  ?  :    -   ;
         ?       ?      1     0     ?             :  ?  :    0   ; // asynchro clear
         ?       ?      0     1     ?             :  ?  :    1   ; // asynchro set
         ?       ?      0     0     ?             :  ?  :    0   ; // set and clear

         ?      (?0)    1     1     ?             :  ?  :    -   ;
         0      (1x)    1     1     ?             :  0  :    -   ;
         1      (1x)    1     1     ?             :  1  :    -   ;

         0      (0x)    1     1     ?             :  0  :    0   ;
         1      (0x)    1     1     ?             :  1  :    1   ;
         0      (x1)    1     1     ?             :  ?  :    0   ;
         1      (x1)    1     1     ?             :  ?  :    1   ;

        (?0)     1      1     x     ?             :  ?  :    0   ;
        (?0)     1      1     1     ?             :  ?  :    0   ;
        (?1)     1      1     1     ?             :  ?  :    1   ;
         0      (01)    1     1     ?             :  ?  :    0   ;
         1      (01)    1     1     ?             :  ?  :    1   ;
         1      (01)    x     1     ?             :  ?  :    1   ;

         0      (01)    x     1     ?             :  ?  :    0   ;
         0       ?      x     1     ?             :  0  :    0   ;   // Reducing pessimism.
         1       ?      1     x     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       0     (?1)   1     ?             :  ?  :    -   ;   // ignore edge on clear
         0       1     (?1)   1     ?             :  ?  :    0   ;   // pessimism .
         1       1     (?1)   1     ?             :  ?  :    1   ;
         ?       0      1     (?1)  ?             :  ?  :    -   ;   // ignore edge on set
         0       1      1     (?1)  ?             :  ?  :    0   ;   // pessimism .
         1       1      1     (?1)  ?             :  ?  :    1   ;
 
        (?1)     x      1     1     ?             :  1  :    1   ;   // Reducing pessimism.
        (?0)     x      1     1     ?             :  0  :    0   ;   // Reducing pessimism.
 
         ?       0      1     x     ?             :  0  :    0   ;   // Reducing pessimism.
         ?       0      x     1     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       ?      ?     ?     *             :  ?  :    x   ;
           
endtable
endprimitive

primitive u_ld6 (Q,D,G,SN,RN,NOTI_REG);
	
    output Q;
	input D,G,SN,RN,NOTI_REG;
	reg Q;
	
//          function: D latch active high with reset and set
//          with the correct behavioral if set and reset Low

table
//         D       G      SN    RN   NOTI_REG       : Qtn :   Qtn+1

         *       0      1     1     ?             :  ?  :    -   ;
         ?       ?      1     0     ?             :  ?  :    0   ; // asynchro clear
         ?       ?      0     1     ?             :  ?  :    1   ; // asynchro set
         ?       ?      0     0     ?             :  ?  :    1   ; // set and clear

         ?      (?0)    1     1     ?             :  ?  :    -   ;
         0      (1x)    1     1     ?             :  0  :    -   ;
         1      (1x)    1     1     ?             :  1  :    -   ;

         0      (0x)    1     1     ?             :  0  :    0   ;
         1      (0x)    1     1     ?             :  1  :    1   ;
         0      (x1)    1     1     ?             :  ?  :    0   ;
         1      (x1)    1     1     ?             :  ?  :    1   ;

        (?0)     1      1     x     ?             :  ?  :    0   ;
        (?0)     1      1     1     ?             :  ?  :    0   ;
        (?1)     1      1     1     ?             :  ?  :    1   ;
         0      (01)    1     1     ?             :  ?  :    0   ;
         1      (01)    1     1     ?             :  ?  :    1   ;
         1      (01)    x     1     ?             :  ?  :    1   ;

         0      (01)    x     1     ?             :  ?  :    0   ;
         0       ?      x     1     ?             :  0  :    0   ;   // Reducing pessimism.
         1       ?      1     x     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       0     (?1)   1     ?             :  ?  :    -   ;   // ignore edge on clear
         0       1     (?1)   1     ?             :  ?  :    0   ;   // pessimism .
         1       1     (?1)   1     ?             :  ?  :    1   ;
         ?       0      1     (?1)  ?             :  ?  :    -   ;   // ignore edge on set
         0       1      1     (?1)  ?             :  ?  :    0   ;   // pessimism .
         1       1      1     (?1)  ?             :  ?  :    1   ;
 
        (?1)     x      1     1     ?             :  1  :    1   ;   // Reducing pessimism.
        (?0)     x      1     1     ?             :  0  :    0   ;   // Reducing pessimism.
 
         ?       0      1     x     ?             :  0  :    0   ;   // Reducing pessimism.
         ?       0      x     1     ?             :  1  :    1   ;   // Reducing pessimism.

         ?       ?      ?     ?     *             :  ?  :    x   ;
           
endtable
endprimitive

primitive u_mx2 (Y,D0,D1,S);
          output Y;
          input D0,D1,S;
 
table
     //  D0    D1   S   :  Y ;
          0     ?   0   :  0 ;
          1     ?   0   :  1 ;
          ?     0   1   :  0 ;
          ?     1   1   :  1 ;
          0     0   x   :  0 ;
          1     1   x   :  1 ;
endtable
endprimitive

primitive check   (z, a, b);
    output z;
    input a, b ;

// FUNCTION :  Comparison cell

    table
    //  a   b       :   z
        1   0       :   1 ;
        0   1       :   1 ;
        x   0       :   1 ;
        x   1       :   1 ;
        0   x       :   1 ;
        1   x       :   1 ;
        0   0       :   0 ;
        1   1       :   0 ;

    endtable
endprimitive

primitive prejk   (z, a, b, c);
    output z;
    input a, b, c ;

// FUNCTION :  Pre Driver Of JK FF

    table
    //  a   b   c   :   z
        0   1   ?   :   0 ;
        1   0   ?   :   1 ;
        x   0   0   :   1 ;
        x   1   0   :   0 ;
        0   x   1   :   0 ;
        1   x   1   :   1 ;
        1   1   1   :   1 ;
        1   1   0   :   0 ;
        0   0   0   :   1 ;
        0   0   1   :   0 ;

    endtable
endprimitive

primitive checkjk   (z, a, b);
    output z;
    input a, b ;

// FUNCTION :  Comparison cell

    table
    //  a   b       :   z
        1   ?       :   1 ;
        x   1       :   1 ;
        x   0       :   0 ;
        0   ?       :   0 ;

    endtable
endprimitive

primitive checkrs   (z, a, b);
    output z;
    input a, b ;

// FUNCTION :  Comparison cell

    table
    //  a    b      :   z
        1    1      :   1 ;
        x    1      :   1 ;
        1    x      :   1 ;
        0    1      :   0 ;
        0    x      :   0 ;
        1    0      :   0 ;
        x    0      :   0 ;
        0    0      :   0 ;

    endtable
endprimitive

primitive check_buf   (z, a, b);
    output z;
    input a, b ;

// FUNCTION :  Comparison cell

    table
    //  a    b      :   z
        1    1      :   1 ;
        x    1      :   x ;
	    0    1      :   0 ;
        1    x      :   x ;
        x    x      :   x ;
	    0    x      :   x ;

    endtable
endprimitive

primitive check_vdd   (z, a);
    output z;
    input a;

// FUNCTION :  Comparison cell

    table
    // a      :   z
       1      :   1 ;

    endtable
endprimitive

primitive check_gnd   (z, a);
    output z;
    input a;

// FUNCTION :  Comparison cell

    table
    // a      :   z
       0      :   1 ;

    endtable
endprimitive


primitive diff_lshifter   (z, a, an);
    output z;
    input a, an;
    reg z;

// FUNCTION :  differrential level shifter

    table
    // a   an :  zt-1 :  z
       0    1 :   ?   :  0 ;
       1    0 :   ?   :  1 ;
       1    1 :   ?   :  1 ;
       0    0 :   0   :  0 ;
       0    0 :   1   :  1 ;

    endtable
endprimitive



// cell primitive section --- END ---
// --------------------------------------------------------------------






