.section .text
.globl _start
.equ valor, 0x00000008


_start:
        jal ra, Write_t0-4
        jal ra, Write_t1-4
        jal ra, Write_t2-4
        jal ra, Write_s0-4
        jal ra, Write_s1-4
        jal ra, Write_a0-4
        jal ra, Write_a1-4
        jal ra, Write_a2-4
        jal ra, Write_a3-4
        jal ra, Write_a4-4
        jal ra, Write_a5-4
        jal ra, Write_a6-4
        jal ra, Write_a7-4
        jal ra, Write_s2-4
        jal ra, Write_s3-4
        jal ra, Write_s4-4
        jal ra, Write_s5-4
        jal ra, Write_s6-4
        jal ra, Write_s7-4
        jal ra, Write_s8-4
        jal ra, Write_s9-4
        jal ra, Write_s10-4
        jal ra, Write_s11-4
        jal ra, Write_t3-4
        jal ra, Write_t4-4
        jal ra, Write_t5-4
        jal ra, Write_t6-4
        j finish


Write_t0:
        li t0,valor
        addi ra,ra,-4
        ret
Write_t1:
        li t1,valor
        addi ra,ra,-4
        ret
Write_t2:
        li t2,valor
        addi ra,ra,-4
        ret
Write_s0:
        li s0,valor
        addi ra,ra,-4
        ret
Write_s1:
        li s1,valor
        addi ra,ra,-4
        ret
Write_a0:
        li a0,valor
        addi ra,ra,-4
        ret
Write_a1:
        li a1,valor
        addi ra,ra,-4
        ret
Write_a2:
        li a2,valor
        addi ra,ra,-4
        ret
Write_a3:
        li a3,valor
        addi ra,ra,-4
        ret
Write_a4:
        li a4,valor
        addi ra,ra,-4
        ret
Write_a5:
        li a5,valor
        addi ra,ra,-4
        ret
Write_a6:
        li a6,valor
        addi ra,ra,-4
        ret
Write_a7:
        li a7,valor
        addi ra,ra,-4
        ret
Write_s2:
        li s2,valor
        addi ra,ra,-4
        ret
Write_s3:
        li s3,valor
        addi ra,ra,-4
        ret
Write_s4:
        li s4,valor
        addi ra,ra,-4
        ret
Write_s5:
        li s5,valor
        addi ra,ra,-4
        ret
Write_s6:
        li s6,valor
        addi ra,ra,-4
        ret
Write_s7:
        li s7,valor
        addi ra,ra,-4
        ret
Write_s8:
        li s8,valor
        addi ra,ra,-4
        ret
Write_s9:
        li s9,valor
        addi ra,ra,-4
        ret
Write_s10:
        li s10,valor
        addi ra,ra,-4
        ret
Write_s11:
        li s11,valor
        addi ra,ra,-4
        ret
Write_t3:
        li t3,valor
        addi ra,ra,-4
        ret
Write_t4:
        li t4,valor
        addi ra,ra,-4
        ret
Write_t5:
        li t5,valor
        addi ra,ra,-4
        ret
Write_t6:
        li t6,valor
        addi ra,ra,-4
        ret
finish:
