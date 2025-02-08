section .data


section .text
global f1

f1:     enter 0, 0
    
        mov eax, DWORD [ebp+8]

        leave
        ret