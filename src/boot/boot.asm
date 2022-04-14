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
	
	xor ax, ax								; zero out all registers
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax								; setup segments
	mov ss, ax								; setup the stack	
	mov ax, STACK_ADDR
   	mov sp, ax
	
	sti

	mov si, msg
	call print_line

	get_bpb_byte BPB_OEM_LABEL

	cli
	hlt

	call wait_shutdown

msg: db "Hello :D", 0

%include "lib/print.asm"
%include "lib/common.asm"

times 510 - ($-$$) db 0
