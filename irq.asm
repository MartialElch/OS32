global genericInterruptHandler, registerInterrupt, setIdt

struc idt_entry
    .m_baseLow      resw 1
    .m_selector     resw 1              ; code segment selector
    .m_reserved     resb 1              ; zero
    .m_flags        resb 1              ; type and attributes
    .m_baseHi       resw 1
endstruc

struc idt_ptr
    .m_size         resw 1
    .m_base         resd 1
endstruc

;-------------------------------------------------------------------------------
; handle some IRQ
genericInterruptHandler:
    iret

;-------------------------------------------------------------------------------
; completely hang the computer
exceptionHandler:
    cli
    hlt

;-------------------------------------------------------------------------------
; register interrupt handler
; eax : IRQ number
; ebx : IRQ handler address
; ecx : IRQ type
registerInterrupt:
    pusha
    mov edx, 8
    mul dx
    add eax, idt
    mov word [eax+idt_entry.m_baseLow], bx
    shr ebx, 16
    mov word [eax+idt_entry.m_baseHi], bx
    mov byte [eax+idt_entry.m_flags], cl
    mov byte [eax+idt_entry.m_reserved], 0
    mov word [eax+idt_entry.m_selector], 0x08
    popa

registerInterruptReturn:
    ret

;-------------------------------------------------------------------------------
setIdt:
    cli                                            ; disable interrupts
    mov word [idtr+idt_ptr.m_size], idt_size - 1   ; set idt size
    mov dword [idtr+idt_ptr.m_base], idt           ; set idt base pointer
    lidt [idtr]                                    ; store idt structure
    sti

    ret

;-------------------------------------------------------------------------------
align 8
idt:
%rep 256
    istruc idt_entry
        at idt_entry.m_baseLow,  dw 0x0000
        at idt_entry.m_selector, dw 0x0008   
        at idt_entry.m_reserved, db 0x00
        at idt_entry.m_flags,    db 0x8e
        at idt_entry.m_baseHi,   dw 0x0000
    iend
%endrep
idt_end:

idt_size equ idt_end - idt

idtr:
    istruc idt_ptr
        at idt_ptr.m_size, dw 0
        at idt_ptr.m_base, dd 0
    iend

;-------------------------------------------------------------------------------
