IMAGE := m32-plus.img
MOUNT := tmp-mount

APPS := \
	build/AIRC \
	build/BMPVIEW \
	build/BOARD \
	build/CACHE2FD \
	build/CACHE2HD \
	build/CALC \
	build/CEXAMPLE \
	build/COPY2 \
	build/CPU \
	build/CPUSPEED \
	build/DESKTOP \
	build/END \
	build/ICON \
	build/ICONMNGR \
	build/JPEGVIEW \
	build/LAUNCHER \
	build/MEMUSE \
	build/MPANEL \
	build/MDM \
	build/PAINT \
	build/RCLOCK \
	build/RDFDEL \
	build/SB \
	build/SETUP \
	build/SYSMETER \
	build/SYSTRACE \
	build/SYSTREE \
	build/TELNET \
	build/TERMINAL \
	build/TETRIS \
	build/TINYFRAC \
	build/TINYPAD \
	build/TRANSP \
	build/TUBE \
	build/VSCREEN

STATIC := $(wildcard static/*)

all: $(IMAGE)

build/BOOTLDR.BIN: bootloader/BOOTMOSF.ASM
	mkdir -p build/
	fasm $< $@

$(IMAGE): build/BOOTLDR.BIN build/KERNEL.MNT $(APPS) $(STATIC)
	rm -f $(IMAGE)
	mkdosfs -C $(IMAGE) 1440
	dd status=noxfer conv=notrunc if=build/BOOTLDR.BIN of=$(IMAGE)
	mkdir -p $(MOUNT)
	sudo mount -o loop -t vfat $(IMAGE) $(MOUNT)
	sudo cp $^ $(MOUNT)
	sleep 0.2
	sudo umount $(MOUNT)
	rm -rf $(MOUNT)

build/KERNEL.MNT: kernel/KERNEL.ASM $(wildcard kernel/*.INC)
	mkdir -p build/
	fasm kernel/KERNEL.ASM build/KERNEL.MNT

build/%: applications/%.ASM
	mkdir -p build/
	fasm $< $@

build/%: applications/%.c libmenuet/libmenuet.a
	mkdir -p build/
	smlrcc -I libmenuet/include -Wall -flat32 -origin 0 -o $@ libmenuet/libmenuet.a $<

libmenuet/libmenuet.a:
	cd libmenuet && make

qemu: $(IMAGE)
	qemu-system-i386 -fda $(IMAGE) -hda fat:rw:build/ -boot order=a

clean:
	rm -rf build
	cd libmenuet && make clean
