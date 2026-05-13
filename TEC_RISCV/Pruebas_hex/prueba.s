.section .text
.globl _start
_start:
 li x2, 0x0000000c
 li x3, 0x00000001
 add x4,x2,x3
 add x5,x4,x3
 li x6, 0x0000ffff
