.section .text
.globl _start
.equ valor, 0x00000008


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
        jal ra, Write_t0
        jal ra, Write_t1
        jal ra, Write_t2
        jal ra, Write_s0
        jal ra, Write_s1
        jal ra, Write_a0
        jal ra, Write_a1
        jal ra, Write_a2
        jal ra, Write_a3
        jal ra, Write_a4
        jal ra, Write_a5
        jal ra, Write_a6
        jal ra, Write_a7
        jal ra, Write_s2
        jal ra, Write_s3
        jal ra, Write_s4
        jal ra, Write_s5
        jal ra, Write_s6
        jal ra, Write_s7
        jal ra, Write_s8
        jal ra, Write_s9
        jal ra, Write_s10
        jal ra, Write_s11
        jal ra, Write_t3
        jal ra, Write_t4
        jal ra, Write_t5
        jal ra, Write_t6
        j finish


Write_t0:
        li t0,valor
        ret
Write_t1:
        li t1,valor
        ret
Write_t2:
        li t2,valor
        ret
Write_s0:
        li s0,valor
        ret
Write_s1:
        li s1,valor
        ret
Write_a0:
        li a0,valor
        ret
Write_a1:
        li a1,valor
        ret
Write_a2:
        li a2,valor
        ret
Write_a3:
        li a3,valor
        ret
Write_a4:
        li a4,valor
        ret
Write_a5:
        li a5,valor
        ret
Write_a6:
        li a6,valor
        ret
Write_a7:
        li a7,valor
        ret
Write_s2:
        li s2,valor
        ret
Write_s3:
        li s3,valor
        ret
Write_s4:
        li s4,valor
        ret
Write_s5:
        li s5,valor
        ret
Write_s6:
        li s6,valor
        ret
Write_s7:
        li s7,valor
        ret
Write_s8:
        li s8,valor
        ret
Write_s9:
        li s9,valor
        ret
Write_s10:
        li s10,valor
        ret
Write_s11:
        li s11,valor
        ret
Write_t3:
        li t3,valor
        ret
Write_t4:
        li t4,valor
        ret
Write_t5:
        li t5,valor
        ret
Write_t6:
        li t6,valor
        ret
finish:
