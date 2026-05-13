CC = riscv32-unknown-elf-gcc
CFLAGS  = -nostdlib -nostartfiles
SRCS = $(wildcard *.S)

PROGS = $(patsubst %.S,%,$(SRCS))
PROGS2 = $(patsubst %.S,%.o,$(SRCS))

all: $(PROGS)

%: %.S
	$(CC) $(CFLAGS) -o $@.o $<
clean:
	rm -f $(PROGS2)
