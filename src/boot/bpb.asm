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

	times 71 db 0

boot_resume:
	cli
	cld										; clear direction flag
	mov [booted_drive_index], dl
	
	xor ax, ax								; zero out all registers
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax								; setup segments
	mov ss, ax								; setup the stack	
	mov ax, STACK_ADDR
   	mov sp, ax
	
	sti
	
	clc
	
	call check_drive_ext					; check if the drive extension is available
	jc drive_ext_not_present_error			; if not show error message and exit

	cli
	hlt


drive_ext_not_present_error:
	mov si, drive_ext_msg
	call print_line
	call wait_shutdown


msg: 				db "Hello :D", 0
drive_ext_msg: 		db "Extended read is not supported!", 0


%include "lib/print.asm"
%include "lib/common.asm"
%include "lib/disk.asm"


times 510 - ($-$$) db 0
