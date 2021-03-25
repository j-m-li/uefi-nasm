;                      22 march MMXXI PUBLIC DOMAIN
;           The author disclaims copyright to this source code.

; https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN#section-flags
; https://github.com/charlesap/nasm-uefi/blob/master/yo.asm

 
bits 64
org  0x200000
section .header

dos:
    	dd 0x00005a4d       
    	times 14 dd 0
    	dd 0x00000080
    	times 16 dd 0

pecoff:
        dd `PE\0\0`     ; Signature
    	dw 0x8664       ; Machine IMAGE_FILE_MACHINE_AMD64
    	dw 3            ; NumberOfSections
    	dd 0x5cba52f6   ; TimeDateStamp
	dd 0		; PointerToSymbolTable
	dd 0		; NumberOfSymbols
    	dw osize        ; SizeOfOptionalHeader
    	dw 0x202e       ; Characteristics

oheader:
    	dw 0x020b   	; PE32+
	db 0		; MajorLinkerVersion
	db 0		; MinorLinkerVersion
    	dd codesize     ; SizeOfCode  
  	dd datasize     ; SizeOfInitilizedData
    	dd 0            ; SizeOfUninitializedDta
    	dd 4096         ; AddressOfEntryPoint
    	dd 4096         ; BaseOfCode

    	dq 0x200000     ; ImageBase
    	dd 4096         ; SectionAlignment
    	dd 4096         ; FileAlignment
	dw 0		; MajorOperatingSystemVersion
	dw 0		; MinorOperatingSystemVersion
	dw 0		; MajorImageVersion
	dw 0		; MinorImageVersion	
	dw 0		; MajorSubsystemVersion
	dw 0		; MinorSubsystemVersion
	dd 0		; Win32VersionValue

    	dd 4096 + datasize + codesize      ; SizeOfImage
    	dd 4096         ; SizeOfHeaders
    	dd 0            ; Checksum
	dw 0x000A	; Subsystem
	dw 0x0040	; DllCharateristics

    	dq 0x10000      ; SizeOfStackReserve
    	dq 0x10000      ; SizeOfStackCommit
    	dq 0x10000      ; SizeOfHeapReserve
    	dq 0            ; SizeOfHeapCommit
    	dd 0            ; LOaderFlags
    	dd 0x10         ; NumberOfRvaAndSizes

dirs:
    	times 5 dq 0    ; unused

			; BaseRelocationTable
    	dd 0x004000     ; VirtualAddress
    	dd 0      	; Size

        times 10 dq 0   ; unused
oend:
osize equ oend - oheader

sects:
.1:
    	dq  `.text`     ; Name
    	dd  codesize    ; VirtualSize
    	dd  4096        ; VirtualAddress   
    	dd  codesize    ; SizeOfRawData
    	dd  4096        ; PointerToRawData
    	dd  0           ; PointerToRelocations 
	dd  0		; PointerToLineNumbers
    	dw  0           ; NumberOfRelocations
	dw  0		; NumberOfLineNumbers
    	dd  0x60000020  ; Characteristics IMAGE_SCN_CNT_CODE
			; IMAGE_SCN_MEM_EXECUTE IMAGE_SCN_MEM_READ

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
        dd  0xC0000040    ; IMAGE_SCN_MEM_READ IMAGE_SCN_MEM_WRITE  
			  ; IMAGE_SCN_CNT_INITIALIZED_DATA


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
    	dd  0x02000040 	; IMAGE_SCN_CNT_INITIALIZED_DATA IMAGE_SCN_MEM_DISCARDABLE

	times 4096 - ($-$$) db 0 ;align the text section on a 4096 byte boundary

section .text follows=.header

	sub rsp, 48

	mov rcx, [rdx+64] 	; EFI_SYSTEM_TABLE_CONOUT  
	lea rdx, [rel hello]
	call [rcx+8]		; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING  
	
	add rsp, 48
	ret

    	times ($-$$) % 8192 db 0 

codesize equ $ - $$

section .data follows=.text

_EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90 
	db 0xdc, 0x23, 0x38, 0x4a
        db 0x96, 0xfb, 0x7a, 0xde
	db 0xd0, 0x80, 0x51, 0x6a

hello  	db __utf16__ "Hello World.", 0

    	times ($-$$) % 4096 db 0

datasize equ $ - $$


section .reloc follows=.data

