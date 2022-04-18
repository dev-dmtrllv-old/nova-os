; TODO:
;  - enable A20
;  - get BIOS memory map
;  - load a GDT
;  - load the kernel
;  - enter Protected Mode

%include "lib/defines.asm"

[org BOOT2_ADDR]

boot:
	cli
	xor ax, ax								; zero out all registers
	mov ds, ax
	mov es, ax
	mov ss, ax								; setup the stack	
	mov ax, STACK_ADDR
   	mov sp, ax
	cld										; clear direction flag
	sti

	mov si, hello
	call print_line

	call wait_shutdown

hello:		db "Hello :D", 0

%include "lib/common.asm"
%include "lib/print.asm"
%include "lib/disk.asm"

