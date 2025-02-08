%define quant_blocks [ebp+8]
%define program_size [ebp+12]

section .data
used_blocks db 0


section .text
global f1

f1:             enter 0, 0

                push ecx
                push ebx
        
                mov eax, DWORD program_size             ; eax = tamanho do programa
                mov ecx, DWORD quant_blocks             ; ecx = quantidade de blocos
                mov ebx, 5                              ; ebx = indice na pilha
                ;mov ecx, 1

repete: 
                cmp eax, DWORD [ebp+ebx*4]              ; programa <= bloco
                jle encerra_f1                          ; ? encerra_f1 : continua loop
                sub eax, DWORD [ebp+ebx*4]              ; programa -= bloco

                add ebx, 2
                loop repete

encerra_f1:
                
                pop ebx
                pop ecx

                leave
                ret