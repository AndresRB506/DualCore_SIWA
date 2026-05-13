.text
.align 2
.globl _start 
.equ base, 1024
_start:
  and x5,x5,x0
  and x6,x5,x0
  and x7,x5,x0
  and x8,x5,x0
  li x15, base
  li x1, 0x00000001
  li x2, 0x00000002
  li x3, 0x00000003
  li x4, 0x00000004
  sw x5, 0(x15)
  sb x1, 0(x15)
  sb x2, 1(x15)
  sb x3, 2(x15)
  sb x4, 3(x15)
  lb x5, 0(x15)
  lb x6, 1(x15)
  lb x7, 2(x15)
  lb x8, 3(x15)
  lw x9, 0(x15)
  li x10, 0xaaaaaaaa
  li x11, 0x55555555 
  sh x10, 4(x15)
  sh x11, 6(x15)
  lh x12, 4(x15)
  lh x13, 6(x15)
  lw x14, 4(x15)
