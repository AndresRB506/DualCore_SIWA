.section .text
.globl _start
.equ rv, 1024 
_start:
    li ra,0x00001111
    li sp,rv
    li gp,0x00002222
    sh ra,0(sp)
    sh gp,4(sp)
    add ra,x0,x0
    add gp,x0,x0
    lh ra,0(sp)
    lh gp,4(sp)
