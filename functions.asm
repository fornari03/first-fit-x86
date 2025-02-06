section .text
    global f1

f1:
    enter 0, 0
    mov eax, [ebp+8]    ; numero de endereços + tamanhos dos blocos
    add eax, [ebp+12]
    add eax, [ebp+16]
    leave
    ret
