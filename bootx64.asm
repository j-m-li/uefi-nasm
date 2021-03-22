#                      22 march MMXXI PUBLIC DOMAIN
#           The author disclaims copyright to this source code.
 
bits 64
org  0x200000
section .header

dos:
    	dd 0x00005a4d       
    	times 14 dd 0
    	dd 0x00000080
    	times 16 dd 0

pecoff:
        dd `PE\0\0`     ; sig
    	dw 0x8664       ;  IMAGE_FILE_MACHINE_AMD64
    	dw 3            ; NumberOfSections
    	dd 0x5cba52f6   ; TimeDateStamp
	dd 0		; PointerToSymbolTable
	dd 0		; NumberOfSymbols
    	dw osize        ; SizeOfOptionalHeader
    	dw 0x202e       ; Characteristics

oheader:
    	dd 0x0000020b   ; oheader + 0000 linker sig
    	dd codesize     ; code size
    	dd datasize     ; data size
    	dd 0            ; uninitialized data size
    	dd 4096         ; * entry
    	dd 4096         ; * code base
    	dq 0x200000     ; * image base
    	dd 4096         ; section alignment
    	dd 4096         ; file alignment
    	dq 0            ; os maj, min, image maj, min
    	dq 0            ; subsys maj, min, reserved
    	dd 0x4000       ; image size
    	dd 4096         ; headers size
    	dd 0            ; checksum
    	dd 0x0040000A   ; dll characteristics & subsystem
    	dq 0x10000      ; stack reserve size
    	dq 0x10000      ; stack commit size
    	dq 0x10000      ; heap reserve size
    	dq 0            ; heap reserve commit
    	dd 0            ; loader flags
    	dd 0x10         ; rva count

dirs:
    	times 5 dq 0    ; unused
    	dd 0x004000     ; virtual address .reloc
    	dd 0      	; size .reloc
        times 10 dq 0   ; unused
oend:
osize equ oend - oheader

sects:
.1:
    	dq  `.text`     ; Name
    	dd  codesize    ; virtual size
    	dd  4096        ; virtual address   
    	dd  codesize    ; SizeOfRawData
    	dd  4096        ; PointerToRawData
    	dd  0           ; * relocations, 
	dd  0		; * line numbers
    	dw  0           ; # relocations, 
	dw  0		; # line numbers
    	dd  0x60000020      ; characteristics

.2:
        dq  `.data`
        dd  datasize     
        dd  4096 + codesize ;
        dd  datasize
        dd  4096 + codesize ;
        dd  0
        dd  0
        dw  0
        dw  0
        dd  0xC0000040     


.3:
    	dq  `.reloc`
    	dd  0   
    	dd  0 
    	dd  0
    	dd  0 
    	dd  0
    	dd  0
    	dw  0
    	dw  0
    	dd  0x02000040

	times 4096 - ($-$$) db 0 ;align the text section on a 4096 byte boundary

section .text follows=.header

	sub rsp, 48

	mov rcx, [rdx+64] 	; EFI_SYSTEM_TABLE_CONOUT  
	lea rdx, [rel hello]
	call [rcx+8]		; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING  
	
	add rsp, 48
	ret

    	times 8192-($-$$) db 0 

codesize equ $ - $$

section .data follows=.text

_EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90 
	db 0xdc, 0x23, 0x38, 0x4a
        db 0x96, 0xfb, 0x7a, 0xde
	db 0xd0, 0x80, 0x51, 0x6a

hello  	db __utf16__ "Hello World.", 0

    	times 4096-($-$$) db 0

datasize equ $ - $$


section .reloc follows=.data

