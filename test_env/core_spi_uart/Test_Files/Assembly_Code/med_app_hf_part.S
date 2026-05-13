#Description:
#This is a measurment program to acquire power consumption when the core is emulating the high power part of a med app. We want the core to work at 20MHz. The main idea is, that the program will be doing mixed arithmetic/logic instructions, jump instructions, memory instructions and I/O instructions at high frequency, to emulate the behavior of a med app when it is calculating stuff, taking decisions, driving a defibrillator and storing data into memory. The program will be looped exceuting these instructions for measurment purposes. The idea is that the microcontroller executes this process once and then return to sleep.
#-------------------------------------------------------------------------------
#Bank Register Description:
#$zero = 0 constant
#$ra = return address
#$sp = stack pointer
#$gp = global pointer
#$tp = thread pointer
#$t0 = temporary register
#$t1 = ^
#$t2 = ^
#$s0 = "register where the CSR code is stored. Used to determine if an interruption was triggered by the timer or the analog input"
#$s1 = "counter to limit the time in high speed mode (emulates the behavior when the microcontroller have to take decisions)"
#$a0 = "unused"
#$a1 = "unused"
#$a2 = "unused"
#$a3 = "unused"
#$a4 = "unused"
#$a5 = "unused"
#$a6 = "unused"
#$a7 = "unused"
#$s2 = "s1 counter limit"
#$s3 = "unused"
#$s4 = "unused"
#$s5 = "unused"
#$s6 = "unused"
#$s7 = "unused"
#$s8 = "unused"
#$s9 = "unused"
#$s10 = "unused"
#$s11 = "unused"
#$t3 = temporary register
#$t4 = temporary register
#$t5 = temporary register
#$t6 = temporary register
#-------------------------------------------------------------------------------
#Constants for the program
#-------------------------------------------------------------------------------
.section .text
.globl _start
.equ timer_chkpnt, 500 #54614	 #this is the timer checkpoint when it should change to active mode
.equ high_spd_loop_cnt, 20 #300  #this is the timer checkpoint when it should change to active mode

#-------------------------------------------------------------------------------
#Program
#-------------------------------------------------------------------------------
_start:
	jal x0,_main
#-------------------------------------------------------------------------------
#Interrupt handler: for this program, this is a dummy interrupt handler, it will never enter into this routine
#-------------------------------------------------------------------------------
_int_handler:
	csrrs t0,2,x0      #read the mcauseA CSR and check if timer code happened (3'b011) or if analog interrupt code happened (3'b100)
	andi s0,t0,7       #mask the code bits (mcause bits 0, 1 and 2) and discard the rest

_return:
	j _status_chk	           #return to the main program
#-------------------------------------------------------------------------------
#Main program: First, configre CSRs. Then, execute the described logic
#-------------------------------------------------------------------------------
_main:
#-------------------------------------------------------------------------------
#Initialize register bank to known values
#-------------------------------------------------------------------------------
	add x1,x0,x0
	add x2,x0,x0
	add x3,x0,x0
	add x4,x0,x0
	add x5,x0,x0
	add x6,x0,x0
	add x7,x0,x0
	add x8,x0,x0
	add x9,x0,x0
	add x10,x0,x0
	add x11,x0,x0
	add x12,x0,x0
	add x13,x0,x0
	add x14,x0,x0
	add x15,x0,x0
	add x16,x0,x0
	add x17,x0,x0
	add x18,x0,x0
	add x19,x0,x0
	add x20,x0,x0
	add x21,x0,x0
	add x22,x0,x0
	add x23,x0,x0
	add x24,x0,x0
	add x25,x0,x0
	add x26,x0,x0
	add x27,x0,x0
	add x28,x0,x0
	add x29,x0,x0
	add x30,x0,x0
	add x31,x0,x0
#-------------------------------------------------------------------------------
#CSR configuration: activate timer, enable analog interruption, set interrupt address
#-------------------------------------------------------------------------------
#t0 register holds the MIE/MIP CSR configuration value
#-------------------------------------------------------------------------------
	li t0,0x00000010			#bus disabled and maie enabled, the rest is clear by default
#-------------------------------------------------------------------------------
#t1 register holds the MEPC CSR interrupt adress
#-------------------------------------------------------------------------------
	li t1,4
	#li t1,52
#-------------------------------------------------------------------------------
#t2 register holds the GPIO CSR output
#-------------------------------------------------------------------------------
	li t2,0x00000000
#-------------------------------------------------------------------------------
#t3 register holds the MVTEC CSR that contains the address in case of a bad instruction
#-------------------------------------------------------------------------------
	li t3,4
#-------------------------------------------------------------------------------
#t4 register holds the Timer comparator number ()
#-------------------------------------------------------------------------------
	li t4,timer_chkpnt
#-------------------------------------------------------------------------------
#Write the CSR registers
#-------------------------------------------------------------------------------
	csrrw x0,0,t0 #MIE/MIP CSR
	csrrw x0,1,t1 #MEPC CSR
	csrrw x0,4,t2 #GPIO CSR
	csrrw x0,5,t3 #MVTEC CSR
	csrrw x0,6,t4 #MVTEC CSR
	j _loop

#-------------------------------------------------------------------------------
#Status check routine, to identify the interruption source
#-------------------------------------------------------------------------------
_status_chk:
	li t0, 3 					#this is the 011 code to identify the timer interruption
	li t1, 4 					#this is the 100 code to identify the analog interruption
	beq s0, t0, _high_spd

#-------------------------------------------------------------------------------
#Emergency routine, the timer reached its checkpoint, tha means that the heart pulse didn't happen
#Set microcontroller to high speed mode.
#(This is a dummy routine, instructions here doesn't have any meaning, it is just a sample to measure power consumption)
#-------------------------------------------------------------------------------
_high_spd:
	li t0, 1 			#this is the position of GPIO0, used to adjust the frequency of the microcontroller
	csrrs x0,4,t0		#GPIO0 = 1 means that the micrcontroller will work at 20MHz
	li s1, high_spd_loop_cnt

_high_proc_rtn:
	li s2, 3
	li s3, 5
	addi s2, s2, 6
	add s2, s3, s2
	andi s3, s3, 4
	li s4,1024
	sw s2,0(s4)
	lw s5,0(s4)
	sw s3,4(s4)
	addi s6, s6, 1
	andi s6, s6, 1
	li t0, 2
	beq s6, x0, _gpio_set
	csrrc x0, 4, t0
	j _gpio_clr

_gpio_set:
	csrrs x0, 4, t0

_gpio_clr:
	beq s1, x0, _low_spd
	addi s1, s1, -1
	j _high_proc_rtn
#-------------------------------------------------------------------------------
#Low speed mode
#-------------------------------------------------------------------------------
_low_spd:
	li t0, 1 			#this is the position of GPIO0, used to adjust the frequency of the microcontroller
	csrrc x0,4,t0		#GPIO0 = 0 means that the micrcontroller will work at 32.768kHz
#-------------------------------------------------------------------------------
#Loop waiting for interruptions
#-------------------------------------------------------------------------------
_loop:
	j _loop 		#just wait for an interruption