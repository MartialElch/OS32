; kernel.asm
[BITS 32]

%define TYPE_IRQ 0x8e

extern genericInterruptHandler, keyboardHandler, printString, registerInterrupt, \
       setIdt, shell

global kmain

    call kmain

kmain:
    mov esi, msg_welcome
    call printString

    mov eax, 0x21
    mov ebx, keyboardHandler
    mov ecx, TYPE_IRQ
    call registerInterrupt

    mov eax, 0x06                      ; don't know why, but we need to handle
    mov ebx, genericInterruptHandler   ; this one
    mov ecx, TYPE_IRQ
    call registerInterrupt

    call setIdt

    call shell

hang:
    hlt
    jmp hang

    call halt

;-------------------------------------------------------------------------------
halt:
    ; stop processor
    cli                ; disable interrupts
    hlt                ; stop processor

;-------------------------------------------------------------------------------
msg_welcome  db 'starting kernel ...', 13, 10, 0

;-------------------------------------------------------------------------------
