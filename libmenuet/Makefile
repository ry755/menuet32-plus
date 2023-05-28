all: libmenuet.a

libmenuet.a: src/libmenuet.asm $(wildcard src/*.asm)
	cd src && nasm -f elf -o ../$@ libmenuet.asm

clean:
	rm -f libmenuet.a
