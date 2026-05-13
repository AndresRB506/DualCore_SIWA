.section .text
.globl _start
.equ valor, 0x00000008
.section .text
.globl _start

_start:
      add ra,x0,x0
      add sp,x0,x0
      add gp,x0,x0
      add tp,x0,x0
      add t0,x0,x0
      add t1,x0,x0
      add t2,x0,x0
      add s0,x0,x0
      add s1,x0,x0
      add a0,x0,x0
      add a1,x0,x0
      add a2,x0,x0
      add a3,x0,x0
      add a4,x0,x0
      add a5,x0,x0
      add a6,x0,x0
      add a7,x0,x0
      add s2,x0,x0
      add s3,x0,x0
      add s4,x0,x0
      add s5,x0,x0
      add s6,x0,x0
      add s7,x0,x0
      add s8,x0,x0
      add s9,x0,x0
      add s10,x0,x0
      add s11,x0,x0
      add t3,x0,x0
      add t4,x0,x0
      add t5,x0,x0
      add t6,x0,x0
      beq ra, sp, case1
      j Fail

case7:
        li s6,7
        add ra,x0,x0
        add sp,x0,x0
        bne ra, sp, Fail
        addi ra,x0,-1
        blt ra, sp, case8
        j Fail

Write_t1:
        j Fail
Write_t2:
        j Fail
case2:
        li s1,2
        addi ra,x0,1
        bge ra, sp, case3
        j Fail
Write_s1:
        j Fail
case5:
        li s4,5
        addi ra,x0,1
        bgeu ra, sp, case6
        j Fail
Write_a1:
        j Fail
Write_a2:
        j Fail
Write_a3:
        j Fail
case3:
        li s2,3
        bge sp, ra, Fail
        addi ra,x0,-3
        bge sp, ra, case4
        j Fail
Write_a5:
        j Fail
Write_a6:
        j Fail
case9:
        li s8,9
        bltu sp,ra, Fail
        add ra,x0,x0
        add sp,x0,x0
        bltu sp,ra, Fail
        blt sp,ra, Fail
        j succes

Write_s2:
        j Fail
Write_s3:
        j Fail
Write_s4:
        j Fail
Write_s5:
        j Fail
Write_s6:
        j Fail
Write_s7:
        j Fail
case1:
        li s0,1
        bge ra, sp, case2
        j Fail
case8:
        li s7,8
        blt sp, ra, Fail
        add ra,x0,x0
        add sp,x0,x0
        addi sp,x0,1
        bltu ra,sp,case9
        j Fail
case6:
        li s5,6
        bgeu  sp, ra, Fail
        bne ra, sp, case7
        j Fail
case4:
        li s3,4
        add ra,x0,x0
        add sp,x0,x0
        bgeu ra, sp, case5
        j Fail
Write_t3:
        j Fail
Write_t4:
        j Fail
Write_t5:
        j Fail
Write_t6:
        j Fail

succes:
      lui t5, 1

Fail:
      lui t6,1
