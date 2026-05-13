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
#---------------suma 1000 con -1000 en s0 deberia quedar 0--------------
#------------------------------------------------------------------------
        addi ra,x0,1000
        addi sp,x0,-1000
        add s0,ra,sp
#-----------------------------------------------------------
#-----------------------suma hasta 16 potencias-----------------------
#----------------------Prueba tambien usar registro entreda salida----
#----------------------Resultado en s1=16----------------------------
        addi s1,x0,2
        add s1,s1,s1
        add s1,s1,s1
        add s1,s1,s1

#------------------sumas normales-------------------------
#-----------------------s4=12000-------------------------
        addi s2,x0,400
        addi s3,x0,100
        add s4, s2, s3
        addi s5,x0,900
        add s6,x0,s5
