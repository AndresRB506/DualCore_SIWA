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
#------------------------------------------------------------------------
#---------------resta 1000 - -1000 en s0 debería quedar 2000-------------
#------------------------------------------------------------------------
        li ra,1000
        li sp,-1000
        sub s0,ra,sp
#------------------------------------------------------------------------
#---------------resta -1000 - 1000  en s1 debería quedar -2000------------
#------------------------------------------------------------------------
        sub s1,sp,ra
#---------------------------------------------------------------------
#--------------resta 1000-1000 en s2 deberia quedar 0---------------
        li sp,1000
        sub s2, ra, sp
#------------------restas normales-------------------------
#-----------------------s3=300,s4=-900-------------------------
        li ra,400
        li sp,100
        sub s3, ra, sp
        li sp,900
        sub s4,x0,sp
