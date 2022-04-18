; TODO:
; 	- test when booting with only one partition and when there is no MBR available

%include "lib/defines.asm"

%macro get_bpb_byte 1
	xor eax, eax
	mov byte al, [((BOOT1_ADDR) + (%1))]
%endmacro

%macro get_bpb_word 1
	xor eax, eax
	mov word ax, [((BOOT1_ADDR) + (%1))]
%endmacro

%macro get_bpb_dword 1
	mov dword al, [((BOOT1_ADDR) + (%1))]
%endmacro


[org BOOT1_ADDR]
[bits 16]

boot_start:
	jmp short boot_resume
	nop

	times 86 db 0

boot_resume:
	cli	
	xor ax, ax								; zero out all registers
	mov ds, ax
	mov es, ax
	mov ss, ax								; setup the stack	
	mov ax, STACK_ADDR
   	mov sp, ax
	cld										; clear direction flag

	mov [booted_drive_index], dl

	call check_drive_ext					; check if the drive extension is available
	jc drive_ext_not_present_error			; if not show error message and exit
	
	get_bpb_word(BPB_RESERVED_SECTORS)		; setup the DAP data
	sub ax, 2
	mov word [dap_sectors], ax
	mov word [dap_buf_off], BOOT2_ADDR
	
	cmp si, 0								; check if booted from MBR
	jne init_from_mbr

	mov dword [dap_lba], 2
	jmp init_done

init_from_mbr:
	add si, PENTRY_LBA_OFFSET
	mov ax, [si]							; ax contains the start LBA of the bootable partition
	add ax, 2
	mov dword [dap_lba], eax				; set the lba to load

init_done:
	call read_sectors
	jc read_err
	jmp 0x0:BOOT2_ADDR


drive_ext_not_present_error:
	mov si, drive_ext_msg
	call print_line
	call wait_shutdown

read_err:
	mov si, read_err_msg
	call print_line
	call wait_shutdown

msg: 				db "Hello :D", 0
drive_ext_msg: 		db "Extended read is not supported!", 0
read_err_msg:		db "Failed to read!", 0


%include "lib/print.asm"
%include "lib/common.asm"
%include "lib/disk.asm"


times 510 - ($-$$) db 0
