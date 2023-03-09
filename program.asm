[ORG 0x8000]

start:
    ; Set up the stack pointer
    mov ax, 0x0002
    mov ds, ax

    ; print welcome message
    mov si, msg     ; load pointer to msg

ch_loop:
    lodsb           ; load char from string into al
    or al, al       ; zero means end of string
    jz done         ; go to end of loop om zero
    mov ah, 0x0E    ; color in hi byte of word
    int 0x10        ; use bios for print
    jmp ch_loop     ; go to next char
done:

halt:
    ; Infinite loop
    cli             ; disable interrupts
    hlt             ; stop processor
    jmp $

msg db 'Start Program', 13, 10, 0
