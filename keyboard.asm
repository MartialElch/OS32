global keyboardHandler

global keyboardBuffer, keyboardBufferPos

extern printHex16, printHex32

;-------------------------------------------------------------------------------
keyboardHandler:
    pushad

    mov ax, 0x18
    mov gs, ax

    in  al, 0x60                ; get key data
    mov bl, al
    xor ecx, ecx
    mov cl, al

    in  al, 0x61                ; keyboard control
    mov ah, al
    or  al, 0x80                ; disable bit 7
    out 0x61, al                ; send it back
    xchg ah, al                 ; get original
    out 0x61, al                ; send that back

    mov al, 0x20                ; end of interrupt
    out 0x20, al

    and bl, 0x80                ; ignore key released
    jnz keyboardHandlerReturn   ; don't repeat

    add ecx, keyboardMap
    mov ah, 0x0A
    mov al, byte [ecx]

    mov ebx, 0
    mov bl, byte [keyboardBufferPos] 
    mov ah, bl
    add ebx, keyboardBuffer
    mov [ebx], al

    inc byte [keyboardBufferPos]

keyboardHandlerReturn:
    popad
    iret

;-------------------------------------------------------------------------------
keyboardMap db '--1234567890----qwertzuiop--', 0xa, '-asdfghjkl-----yxcvbnm'

align 4
keyboardBufferPos db 0x00
keyboardBufferWritePos db 0x00
keyboardBufferReadPos db 0x00
align 4
keyboardBuffer times 256 db 0x00
 
;-------------------------------------------------------------------------------
