.text
.align 2
.globl _start 

_start:
  and x5,x5,x0
  and x6,x5,x0
  and x7,x5,x0
  and x8,x5,x0
  li x1, 0x00000001
  li x2, 0x00000002
  li x3, 0x00000003
  li x4, 0x00000004
  sw x5, 1024(x0)
  sb x1, 1024(x0)
  sb x2, 1025(x0)
  sb x3, 1026(x0)
  sb x4, 1027(x0)
  lb x5, 1024(x0)
  lb x6, 1025(x0)
  lb x7, 1026(x0)
  lb x8, 1027(x0)
  lw x9, 1024(x0)
  li x10, 0xaaaaaaaa
  li x11, 0x55555555 
  sh x10, 1028(x0)
  sh x11, 1030(x0)
  lh x12, 1028(x0)
  lh x13, 1030(x0)
  lw x14, 1028(x0)
