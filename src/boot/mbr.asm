; This MBR code will be placed at the MBR sector of the disk
; It will scan the partition table for bootable partitions,
; loads the bootable partition at 0x7C00 and starts executing it

%include "lib/defines.asm"

[org MBR_ADDR]
[bits 16]

boot_start:
	cli
	xor ax, ax								; zero out all registers
	mov ds, ax
	mov es, ax
	mov ss, ax								; setup the stack	
	mov ax, STACK_ADDR
   	mov sp, ax
	cld										; clear direction flag
	mov cx, 0x100							; copy 256 words (512 bytes)
	mov si, BOOT1_ADDR						; from
	mov di, MBR_ADDR						; to
	rep movsw

	jmp 0:relocated_start

relocated_start:
	mov [booted_drive_index], dl			; store the booted drive number

	call check_drive_ext					; check if the drive extension is available
	jc drive_ext_not_present_error			; if not show error message and exit

	mov cx, 0								; counter to store number of loops
	mov si, MBR_ADDR + PTABLE_OFFSET		; the partition table offset (calculated from the relocated MBR sector)

find_partition_loop:
	cmp cx, 4								; loop max 4 times (for all the partition entries)
	je find_partition_loop_error			; no bootable partition found
	mov ax, [si]							; get the first byte from the partition entry
	test ax, PENTRY_BOOT_FLAG				; check if the partition is bootable
	jnz partition_found						; partition is found!
	add si, PENTRY_SIZE						; get next partition
	inc cx
	jmp find_partition_loop

partition_found: 							; bx contains partition table entry address
	push si									; store the entry pointer
	add si, PENTRY_LBA_OFFSET
	mov ax, [si]							; ax contains the start LBA of the bootable partition
	mov [dap_lba], ax						; set the lba to load
	mov word [dap_buf_off], BOOT1_ADDR		; set the buffer address to load to
	mov word [dap_sectors], 1				; only load 1 sector (the boot sector of the partition)
	call read_sectors
	xor edx, edx							; set the edx booted drive number 
	mov dl, [booted_drive_index]
	pop si									; restore the entry pointer for the bootloader

	jmp 0:BOOT1_ADDR						; and jump to the bootloader
	hlt

drive_ext_not_present_error:
	mov si, drive_ext_msg
	call print_line
	jmp shutdown_from_err

find_partition_loop_error:
	mov si, drive_ext_msg
	call print_line

shutdown_from_err:
	call wait_shutdown

%include "lib/print.asm"
%include "lib/disk.asm"
%include "lib/common.asm"

drive_ext_msg: db "Extended read is not supported!", 0

times 446 - ($-$$) db 0						; prevents overwriting the MBR partition table
