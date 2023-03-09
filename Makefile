AS = nasm

.SUFFIXES:
.SUFFIXES: .asm

all:	boot.flp

boot.flp:	boot program
	dd if=/dev/zero of=boot.flp bs=512 count=2880
	dd if=boot of=boot.flp bs=512 conv=notrunc
	dd if=program of=boot.flp bs=512 conv=notrunc seek=1

clean:
	rm -f boot program *.lst boot.flp

.asm:
	$(AS) -l $@.lst $<