ASFLAGS = -l $(basename $@).lst -f elf32
LDFLAGS = --oformat=binary -melf_i386 -Ttext=0x10000 -defsym _start=kmain
CFLAGS  = -Wall -Werror -std=c89 -O0 -m32 -mtune=pentium -I./include \
          -nostdinc -nostdlib -fno-builtin \
          -Xassembler -al=$(basename $@).lst

AS = nasm
LD = /usr/local/bin/x86_64-elf-ld

CC = /usr/local/bin/x86_64-elf-gcc

OBJS = kernel.o irq.o keyboard.o terminal.o library.o shell.o

all:	boot.flp

kernel.bin:	$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

boot:	boot.asm
	$(AS) -l $(basename $@).lst -o $@ $<

boot.flp:	boot kernel.bin
	dd if=/dev/zero of=boot.flp bs=512 count=2880
	dd if=boot of=boot.flp bs=512 conv=notrunc
	dd if=kernel.bin of=boot.flp bs=512 seek=1 conv=notrunc

clean:
	rm -f kernel.bin $(OBJS) boot boot.flp
	rm -f *.lst

%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<
