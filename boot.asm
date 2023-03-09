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

ALIGN 4
start_pm:
    ; Set up the data segment
    mov ax, 0x10
    mov ds, ax
    mov es, ax

    ; Load the program from floppy
    mov ax, 0x0201   ; Read one sector from floppy
    mov ebx, program_buffer  ; Destination buffer address
    mov dl, 0x00     ; Drive number: floppy A
    mov dh, 0x00     ; Head number: 0
    mov cx, 0x0002   ; Sector number: 2
    mov ah, 0x02     ; BIOS disk function
    int 0x13         ; Call the BIOS to read the sector

    ; Jump to the program's entry point
    jmp program_entry

; Buffer to store the program code
program_buffer:
    TIMES 65536 db 0

; Program entry point in protected mode
program_entry:
    ; Set up the stack and data segments
    mov ax, 0x18     ; Data segment selector
    mov ds, ax
    mov ss, ax
    mov esp, 0x40000 ; Set the stack pointer to the top of the buffer

    ; Call the program's main function
    call dword [program_main]

    ; Halt the CPU
    cli
    hlt

; Address of the program's main function
program_main:
    dd 0x00008000  ; Assume the program starts at address 0x0000:0x8000