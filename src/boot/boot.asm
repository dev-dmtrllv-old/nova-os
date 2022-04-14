%include "lib/defines.asm"

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

	call wait_shutdown

msg: db "Hello :D", 0

%include "lib/print.asm"
%include "lib/common.asm"

times 510 - ($-$$) db 0
