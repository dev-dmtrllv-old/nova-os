OUT_DIR = out
INCL_DIR = include

ASM_BOOT_SRCS = $(wildcard src/boot/*.asm)
ASM_BOOT_INCL_FILES = $(wildcard src/boot/lib/*.asm)
ASM_BOOT_OBJS = $(patsubst src/%.asm,$(OUT_DIR)/%.o,$(ASM_BOOT_SRCS))

OPTIMIZATION = -O0

TARGET = i686

C_FLAGS = -ffreestanding $(OPTIMIZATION) -g -m32 -Wall -Wextra -fno-use-cxa-atexit -fno-exceptions -fno-rtti -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -fno-common -I$(INCL_DIR)
CC = $(TARGET)-elf-g++
LD = $(TARGET)-elf-ld
OBJCPY = $(TARGET)-elf-objcopy
LD_FLAGS = -nostdlib -nolibc -nostartfiles -nodefaultlibs -fno-common -ffreestanding $(OPTIMIZATION)

BOOT_OFFSET = 90
PART_OFFSET = 1048576

LOOP_DEV = /dev/loop-nova-os

QEMU = qemu-system-i386
QEMU_FLAGS = -M pc -no-reboot -m 512M -monitor stdio

DISK_IMG = out/disk.img

.PHONY: all $(DISK_IMG) build build-disk run

all: build-disk

$(ASM_BOOT_SRCS): $(ASM_BOOT_INCL_FILES)

out/boot/%.o: src/boot/%.asm $(ASM_BOOT_SRCS) $(ASM_BOOT_INCL_FILES)
	@mkdir -p $(@D)
	nasm -f bin $< -isrc/boot -o $@ $(NASM_DEFINES)

# creates a MBR disk image with a 128MB FAT32 partition
$(DISK_IMG):
	@echo "creating disk"
	@mkdir -p $(@D)
	@test -e $(LOOP_DEV) || sudo mknod -m 660 $(LOOP_DEV) b 7 8 && sudo chown root:disk $(LOOP_DEV)
	@dd if=/dev/zero of=$@ bs=512M count=1
	@parted $@ --script \
	mklabel msdos \
	mkpart primary 1MB 128MB \
	set 1 boot on
	@sudo losetup -o $(PART_OFFSET) $(LOOP_DEV) $(DISK_IMG)
	@sudo mkfs.fat -F 32 $(LOOP_DEV)
	@sudo losetup -d $(LOOP_DEV)

build: $(ASM_BOOT_OBJS)

build-disk: $(DISK_IMG) build
	@sudo losetup -o $(PART_OFFSET) $(LOOP_DEV) $(DISK_IMG)
	@dd bs=1 if=out/boot/mbr.o of=$(DISK_IMG) conv=notrunc status=progress
	@sudo dd bs=1 if=out/boot/boot.o count=3 of=$(LOOP_DEV) conv=notrunc status=progress
	@sudo dd bs=1 skip=$(BOOT_OFFSET) if=out/boot/boot.o iflag=skip_bytes of=$(LOOP_DEV) seek=$(BOOT_OFFSET) conv=notrunc status=progress
	@sudo losetup -d $(LOOP_DEV)

run: build-disk
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) 

debug: build-disk
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) -s -S -no-shutdown

clear:
	make clean
	clear

clean:
	rm -rf out
	rm -rf $(DISK_IMG)
	rm -rf *.mem
