; library.asm
extern printChar, printHex16, printHex32, printString

extern keyboardBuffer, keyboardBufferPos, keyboardBufferReadPos, keyboardBufferWritePos

;-------------------------------------------------------------------------------
global getchar
getchar:
    mov eax, 0
    mov al, byte [keyboardBufferPos]
    cmp al, 0
    jz getcharReturn

    dec byte [keyboardBufferPos]
    mov eax, 0
    mov al, byte [keyboardBufferPos]
    add eax, keyboardBuffer
    mov al, byte [keyboardBuffer]

getcharReturn:
    ret

;-------------------------------------------------------------------------------
global putchar:
putchar:
    mov eax, [esp+4]       ; get char from stack
    call printChar

putcharReturn:
    ret

;-------------------------------------------------------------------------------
global puts
puts:
    mov esi, [esp+4]       ; get pointer to string from stack
    call printString

putsReturn:
    ret

;-------------------------------------------------------------------------------
