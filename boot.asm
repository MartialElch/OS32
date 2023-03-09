BITS 16

start:
    ; Set up the stack pointer
    mov sp, 0x7c00

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor] ; Load the global descriptor table
    mov eax, cr0
    or eax, 0x01          ; Set the protected mode bit
    mov cr0, eax
    jmp CODE_SEGMENT:start_pm  ; Jump to the code segment in protected mode

; Define the global descriptor table
gdt_start:
    dd 0x00000000 ; Null segment descriptor
    ; Code segment descriptor, base=0x00000000, limit=0xffffffff, execute/read, non-system segment, 32-bit code
    dd 0xffffffff
    dd 0x00000000
    db 0x9a
    db 0xcf
    ; Data segment descriptor, base=0x00000000, limit=0xffffffff, read/write, non-system segment
    dd 0xffffffff
    dd 0x00000000
    db 0x92
    db 0xcf
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

section .text

    ; Clear the screen
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov si, welcome_message
    call print_string

    ; Enable protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000
    jmp start_pm

start_pm:
    mov si, pm_message
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E ; BIOS teletype function
    int 0x10     ; call BIOS
    jmp print_string
.done:
    ret

welcome_message:
    db 'Hello, real mode!', 0

pm_message:
    db 'Hello, protected mode!', 0

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

	times 510 - ($-$$) db 0
	dw 0xAA55