# the compiler: gcc for C program, define as g++ for C++
CC = riscv32-unknown-elf-gcc

  # compiler flags:
  #  -g    adds debugging information to the executable file
  #  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -nostdlib -nostartfiles

  # the build target executable:
TARGET = Escritura_Registros_Add
TARGET2 = Escritura_Registros_AUIPC
TARGET3 = Escritura_Registros_LUI
TARGET4 = jump
TARGET5 = branches
TARGET6 = Store_load_byte
TARGET7 = add
TARGET8 = addi
TARGET9 = and
TARGET10 = or
TARGET11 = xor
TARGET12 = sub
TARGET13 = sltu
TARGET14 = slt
TARGET15 = andi
TARGET16 = ori
TARGET17 = xori
TARGET18 = slti
TARGET19 = sltiu
TARGET20 = sh_lh
TARGET21 = sw_lw
TARGET22 = srl
TARGET23 = sra
TARGET24 = sll
TARGET25 = srli
TARGET26 = srai
TARGET27 = slli
TARGET28 = lhu
TARGET29 = lbu

all: $(TARGET) $(TARGET2) $(TARGET3) $(TARGET4) $(TARGET5) $(TARGET6) $(TARGET7) $(TARGET8) $(TARGET9) $(TARGET10) $(TARGET11) $(TARGET12) $(TARGET13) $(TARGET14) $(TARGET15) $(TARGET16) $(TARGET17) $(TARGET18) $(TARGET19) $(TARGET20) $(TARGET21) $(TARGET22) $(TARGET23) $(TARGET24) $(TARGET25) $(TARGET26) $(TARGET27) $(TARGET28) $(TARGET29)


$(TARGET): $(TARGET).S
		$(CC) $(CFLAGS) -o $(TARGET).o $(TARGET).S

$(TARGET2): $(TARGET2).S
	$(CC) $(CFLAGS) -o $(TARGET2).o $(TARGET2).S

$(TARGET3): $(TARGET3).S
	$(CC) $(CFLAGS) -o $(TARGET3).o $(TARGET3).S

$(TARGET4): $(TARGET4).S
	$(CC) $(CFLAGS) -o $(TARGET4).o $(TARGET4).S

$(TARGET5): $(TARGET5).S
	$(CC) $(CFLAGS) -o $(TARGET5).o $(TARGET5).S

$(TARGET6): $(TARGET6).S
		$(CC) $(CFLAGS) -o $(TARGET6).o $(TARGET6).S

$(TARGET7): $(TARGET7).S
	$(CC) $(CFLAGS) -o $(TARGET5).o $(TARGET5).S
		$(CC) $(CFLAGS) -o $(TARGET7).o $(TARGET7).S

$(TARGET8): $(TARGET8).S
		$(CC) $(CFLAGS) -o $(TARGET8).o $(TARGET8).S

$(TARGET9): $(TARGET9).S
		$(CC) $(CFLAGS) -o $(TARGET9).o $(TARGET9).S

$(TARGET10): $(TARGET10).S
		$(CC) $(CFLAGS) -o $(TARGET10).o $(TARGET10).S

$(TARGET11): $(TARGET11).S
		$(CC) $(CFLAGS) -o $(TARGET11).o $(TARGET11).S

$(TARGET12): $(TARGET12).S
		$(CC) $(CFLAGS) -o $(TARGET12).o $(TARGET12).S

$(TARGET13): $(TARGET13).S
		$(CC) $(CFLAGS) -o $(TARGET13).o $(TARGET13).S

$(TARGET14): $(TARGET14).S
		$(CC) $(CFLAGS) -o $(TARGET14).o $(TARGET14).S

$(TARGET15): $(TARGET15).S
		$(CC) $(CFLAGS) -o $(TARGET15).o $(TARGET15).S

$(TARGET16): $(TARGET16).S
		$(CC) $(CFLAGS) -o $(TARGET16).o $(TARGET16).S

$(TARGET17): $(TARGET17).S
		$(CC) $(CFLAGS) -o $(TARGET17).o $(TARGET17).S

$(TARGET18): $(TARGET18).S
		$(CC) $(CFLAGS) -o $(TARGET18).o $(TARGET18).S

$(TARGET19): $(TARGET19).S
		$(CC) $(CFLAGS) -o $(TARGET19).o $(TARGET19).S

$(TARGET20): $(TARGET20).S
		$(CC) $(CFLAGS) -o $(TARGET20).o $(TARGET20).S

$(TARGET21): $(TARGET21).S
		$(CC) $(CFLAGS) -o $(TARGET21).o $(TARGET21).S

$(TARGET22): $(TARGET22).S
		$(CC) $(CFLAGS) -o $(TARGET22).o $(TARGET22).S

$(TARGET23): $(TARGET23).S
		$(CC) $(CFLAGS) -o $(TARGET23).o $(TARGET23).S

$(TARGET24): $(TARGET24).S
	  $(CC) $(CFLAGS) -o $(TARGET24).o $(TARGET24).S

$(TARGET25): $(TARGET25).S
	 $(CC) $(CFLAGS) -o $(TARGET25).o $(TARGET25).S

$(TARGET26): $(TARGET26).S
	 $(CC) $(CFLAGS) -o $(TARGET26).o $(TARGET26).S

$(TARGET27): $(TARGET27).S
	 $(CC) $(CFLAGS) -o $(TARGET27).o $(TARGET27).S

$(TARGET28): $(TARGET28).S
	 $(CC) $(CFLAGS) -o $(TARGET28).o $(TARGET28).S

$(TARGET29): $(TARGET29).S
	 $(CC) $(CFLAGS) -o $(TARGET29).o $(TARGET29).S



clean:
		$(RM) $(TARGET).o $(TARGET2).o $(TARGET3).o $(TARGET4).o $(TARGET5).o $(TARGET6).o $(TARGET7).o $(TARGET8).o $(TARGET9).o $(TARGET10).o $(TARGET11).o $(TARGET12).o $(TARGET13).o $(TARGET14).o $(TARGET15).o $(TARGET16).o $(TARGET17).o $(TARGET18).o $(TARGET19).o $(TARGET20).o $(TARGET21).o $(TARGET22).o $(TARGET23).o $(TARGET24).o $(TARGET25).o $(TARGET26).o $(TARGET27).o $(TARGET28).o $(TARGET29).o
