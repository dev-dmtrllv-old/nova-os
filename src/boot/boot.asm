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

	call check_a20
	cmp eax, 0
	jne a20_enabled
	call enable_a20
	cmp eax, 0
	jne a20_failed

a20_enabled:
	mov di, bios_mem_map
	call get_mem_map
	jc get_mem_map_failed
	mov [bios_mem_map_entry_count], bp
	

	
	cli
	hlt
	jmp exit

get_mem_map_failed:
	mov si, mem_map_error_msg
	call print_line
	jmp exit

a20_failed:
	mov si, a20_error_msg
	call print_line

exit:
	call wait_shutdown

a20_error_msg:			db "Could not enable A20!", 0
mem_map_error_msg:		db "get_mem_map failed!", 0

%include "lib/common.asm"
%include "lib/print.asm"
%include "lib/disk.asm"
%include "lib/a20.asm"
%include "lib/mmap.asm"

bios_mem_map_entry_count: dw 0
bios_mem_map:
