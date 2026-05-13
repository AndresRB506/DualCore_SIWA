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
      add a2 ,x0,x0
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
      beq ra, sp, case1-4
      j Fail-4

case7:
        li s6,valor
        add ra,x0,x0
        add sp,x0,x0
        bne ra, sp, Fail-4
        addi ra,x0,-1
        blt ra, sp, case8-4
        j Fail

Write_t1:
        j Fail
Write_t2:
        j Fail
case2:
        li s1,valor
        addi ra,x0,1
        bge ra, sp, case3-4
        j Fail-4
Write_s1:
        j Fail-4
case5:
        li s4,valor
        addi ra,x0,1
        bgeu ra, sp, case6-4
        j Fail-4
Write_a1:
        j Fail-4
Write_a2:
        j Fail-4
Write_a3:
        j Fail-4
case3:
        li s2,valor
        bge sp, ra, Fail-4
        addi ra,x0,-3
        bge sp, ra, case4-4
        j Fail-4
Write_a5:
        j Fail-4
Write_a6:
        j Fail-4
case9:
        li s8,valor
        bltu sp,ra, Fail-4
        add ra,x0,x0
        add sp,x0,x0
        bltu sp,ra, Fail-4
        blt sp,ra, Fail-4
        j succes-4

Write_s2:
        j Fail-4
Write_s3:
        j Fail-4
Write_s4:
        j Fail-4
Write_s5:
        j Fail-4
Write_s6:
        j Fail-4
Write_s7:
        j Fail-4
case1:
        li s0,valor
        bge ra, sp, case2-4
        j Fail-4
case8:
        li s7,valor
        blt sp, ra, Fail-4
        add ra,x0,x0
        add sp,x0,x0
        addi sp,x0,1
        bltu ra,sp,case9-4
        j Fail-4
case6:
        li s5,valor
        bgeu  sp, ra, Fail-4
        bne ra, sp, case7-4
        j Fail
case4:
        li s2,valor
        add ra,x0,x0
        add sp,x0,x0
        bgeu ra, sp, case5-4
        j Fail-4
Write_t3:
        j Fail-4
Write_t4:
        j Fail-4
Write_t5:
        j Fail-4
Write_t6:
        j Fail-4

succes:
      lui t5, 1

Fail:
      lui t6,1
