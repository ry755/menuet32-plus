IMAGE := m32-plus.img
ASM := fasm
ME := $(shell id -run)

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
	build/EYES \
	build/HTTPC \
	build/HTTPS \
	build/ICON \
	build/ICONMNGR \
	build/JPEGVIEW \
	build/LAUNCHER \
	build/MEMUSE \
	build/MHC \
	build/MPANEL \
	build/MDM \
	build/PAINT \
	build/RCLOCK \
	build/RDFDEL \
	build/SB \
	build/SETUP \
	build/STACKCFG \
	build/STACKINF \
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
	$(ASM) $< $@

$(IMAGE): build/BOOTLDR.BIN build/KERNEL.MNT $(APPS) $(STATIC)
	rm -f $(IMAGE)
	sudo mkdosfs -C $(IMAGE) 1440
	sudo chown $(ME):$(ME) $(IMAGE)
	dd status=noxfer conv=notrunc if=build/BOOTLDR.BIN of=$(IMAGE)
	mcopy -v -i $(IMAGE) $^ ::

build/KERNEL.MNT: kernel/KERNEL.ASM $(wildcard kernel/*.INC)
	mkdir -p build/
	$(ASM) kernel/KERNEL.ASM build/KERNEL.MNT

build/%: applications/%.ASM
	mkdir -p build/
	$(ASM) $< $@

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
