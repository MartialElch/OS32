; terminal.asm

%define VGA_WIDTH   80
%define VGA_HEIGHT  25
%define COLOR       0x0A 

;-------------------------------------------------------------------------------
; print 16 bit hex number on line 1
; ax :  hex number
global printHex16
printHex16:
    push bx
    push cx

    ; print nibble 0
    mov ebx, 0
    mov bx, ax
    shr bx, 12
    and bx, 0x000F
    mov ch, COLOR
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:0], cx
    ; print nibble 1
    mov ebx, 0
    mov bx, ax
    shr bx, 8
    and bx, 0x000F
    mov ch, COLOR
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:2], cx
    ; print nibble 0
    mov ebx, 2
    mov bx, ax
    shr bx, 4
    and bx, 0x000F
    mov ch, COLOR
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:4], cx
    ; print nibble 3
    mov ebx, 0
    mov bx, ax
    shr bx, 0
    and bx, 0x000F
    mov ch, COLOR
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:6], cx

printHex16Return:
    pop cx
    pop bx
    ret

;-------------------------------------------------------------------------------
; print 32 bit hex number on line 1
; eax :  hex number
global printHex32
printHex32:
    push ebx
    push ecx

    mov ch, COLOR

    ; print nibble 0
    mov ebx, eax
    shr ebx, 28
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:0], cx
    ; print nibble 1
    mov ebx, eax
    shr ebx, 24
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:2], cx
    ; print nibble 0
    mov ebx, eax
    shr ebx, 20
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:4], cx
    ; print nibble 3
    mov ebx, eax
    shr ebx, 16
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:6], cx
    ; print nibble 4
    mov ebx, eax
    shr ebx, 12
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:8], cx
    ; print nibble 5
    mov ebx, eax
    shr ebx, 8
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:10], cx
    ; print nibble 6
    mov ebx, eax
    shr ebx, 4
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:12], cx
    ; print nibble 7
    mov ebx, eax
    and ebx, 0x0000000F
    add ebx, hex_digit
    mov cl, [ebx]
    mov word [gs:14], cx

printHex32Return:
    pop ecx
    pop ebx
    ret

;-------------------------------------------------------------------------------
; print 0 terminated string at current screen position
; si : pointer to string
global printString
printString:
    mov ah, COLOR
    lodsb
    cmp al, 0
    jz printStringReturn
    call printChar
    jmp printString
printStringReturn:
    ret

;-------------------------------------------------------------------------------
; print character at current screen position
; al : character
;
; CR   = 13 sets cursor position to col 0
; CRLF = 10 sets cursor positions to col 0 on the next line
;
; TODO
; - advance line when hitting line end
; - set cursor position
global printChar
printChar:
    cmp al, 13
    je printCharCR
    cmp al, 10
    je printCharCRLF
    mov ah, COLOR
    push ax
    mov ax, VGA_WIDTH
    mul byte [pos_y]
    mov bx, 0
    mov bl, byte [pos_x]
    add bx, ax
    shl bx, 1
    pop ax
    mov word [gs:bx], ax

printCharIncrement:
    inc byte [pos_x]
    jmp printCharReturn

printCharCRLF:
    inc byte [pos_y]
    mov byte [pos_x], 0
    jmp printCharReturn

printCharCR:
    mov byte [pos_x], 0

printCharReturn:
    call setCursorPosition
    ret

;-------------------------------------------------------------------------------
setCursorPosition:
    pusha

    mov eax, 0
    mov ax, VGA_WIDTH
    mul byte [pos_y]
    mov bx, 0
    mov bl, byte [pos_x]
    add bx, ax

    ; set cursor color
    shl bx, 1
    mov ax, word [gs:bx]       ; get current contents
    mov ah, COLOR              ; set color of that location
    mov word [gs:bx], ax
    shr bx, 1

    mov dx, 0x03D4
    mov al, 0x0F
    out dx, al
    mov ax, bx
    mov dx, 0x03D5
    out dx, al

    mov dx, 0x03D4
    mov al, 0x0E
    out dx, al
    mov ax, bx
    shr ax, 8
    mov dx, 0x03D5
    out dx, al

    popa

setCursorPositionReturn:
    ret
;-------------------------------------------------------------------------------
pos_x db 0x00
pos_y db 0x05

hex_digit    db '0123456789ABCDEF'

;-------------------------------------------------------------------------------
