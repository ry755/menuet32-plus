IMAGE := m32-plus.img
MOUNT := tmp-mount

APPS := \
	build/AIRC \
	build/BMPVIEW \
	build/BOARD \
	build/CACHE2FD \
	build/CACHE2HD \
	build/DESKTOP \
	build/END \
	build/ICON \
	build/ICONMNGR \
	build/JPEGVIEW \
	build/LAUNCHER \
	build/MPANEL \
	build/MDM \
	build/RD2FD \
	build/RD2HD \
	build/SETUP \
	build/SPANEL \
	build/SYSTREE \
	build/TINYPAD

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

#build/KERNEL.MNT: kernel/KERNEL.ASM $(wildcard kernel/*.INC)
#	mkdir -p $(MOUNT)
#	mkdir -p build/
#	sudo mount -o loop -t vfat $(IMAGE) $(MOUNT)
#	fasm kernel/KERNEL.ASM build/KERNEL.MNT
#	sudo cp build/KERNEL.MNT $(MOUNT)
#	sleep 0.2
#	sudo umount $(MOUNT)
#	rm -rf $(MOUNT)
#
#build/%: applications/%.ASM
#	mkdir -p $(MOUNT)
#	mkdir -p build/
#	sudo mount -o loop -t vfat $(IMAGE) $(MOUNT)
#	fasm $< $@
#	sudo cp $@ $(MOUNT)
#	sleep 0.2
#	sudo umount $(MOUNT)
#	rm -rf $(MOUNT)

clean:
	rm -rf build