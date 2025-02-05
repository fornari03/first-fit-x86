section .text
    global soma       ; Torna a função visível para o linker

soma:
    enter 0, 0
    mov eax, [ebp+8]
    add eax, [ebp+12]
    leave
    ret
