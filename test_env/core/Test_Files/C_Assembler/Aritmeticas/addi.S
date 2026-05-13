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
#---------------Carga 1000 en ra----------------
#-------------resultado ra=1000----------------
        addi ra,x0,1000
#----------Carga 1000+-1000 en sp -----------------------
#---------------resultado sp=0------------------------------
        addi sp,ra,-1000
#-----------Suma normal-------------------------------------
#---------------gp=2000------------------------------------
        addi gp,ra,1000
#------------Carga diferentes datos
#--------------s0=8,s1=-1
        addi s0,x0,8
        addi s1,x0,-1
