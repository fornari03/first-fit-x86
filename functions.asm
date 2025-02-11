%define quant_blocks [ebp+8]
%define program_size [ebp+12]
%define last_aloc [ebp-5]

section .data

section .text
global f1

f1:             enter 5, 0
                push ecx
                push ebx
        
                mov eax, DWORD program_size             ; eax = tamanho do programa
                mov ecx, DWORD quant_blocks             ; ecx = quantidade de blocos
                mov ebx, 5                              ; ebx = indice na pilha
                mov BYTE [ebp-1], 1                     ; flag pra dizer se coube

repete: 
                cmp eax, DWORD [ebp+ebx*4]              ; programa <= bloco
                jle encerra_f1                          ; ? encerra_f1 : continua loop
                sub eax, DWORD [ebp+ebx*4]              ; programa -= bloco

                add ebx, 2
                loop repete

                ; se chegou aqui, o programa não coube nos blocos
                mov BYTE [ebp-1], 0

encerra_f1:
                dec ebx
                mov DWORD last_aloc, ebx
                mov ebx, 5
                ; eax = restante de espaço do programa a ser alocado
                ; ebx = 5 (endereço inicial do 1° bloco)
                ; last_aloc = indice na pilha pro endereço do ultimo bloco que aloca espaço [FIXO]
                ; ecx -> não importa
                movzx ecx, BYTE [ebp-1]
                push ecx                                ; push flag de dizer se coube
                mov ecx, DWORD quant_blocks
                push ecx                                ; push quantidade de blocos

                ; enquanto ebx < last_aloc:
                ;     mov ecx, DWORD [ebp+ebx*4]
                ;     push ecx                          ; push endereço inicial
                ;     inc ebx
                ;     add ecx, DWORD [ebp+ebx*4]
                ;     dec ecx 1
                ;     push ecx                          ; push endereço final usado
                ;     push ecx                          ; push ultimo endereço do bloco

                ; quando ebx == last_aloc
                ;     mov ecx, DWORD [ebp+ebx*4]
                ;     push ecx                          ; push endereço inicial
                ;     inc ebx
                ;     add ecx, eax
                ;     dec ecx
                ;     push ecx                          ; push endereço final usado
                ;     sub ecx, eax
                ;     add ecx, DWORD [ebp+ebx*4]
                ;     push ecx                          ; push ultimo endereço do bloco

                ; enquanto ebx <|<= quant_blocks*2
                ;     mov ecx, DWORD [ebp+ebx*4]
                ;     push ecx                          ; push endereço inicial
                ;     push -1                           ; indica que não usou
                ;     add ecx, DWORD [ebp+ebx*4]
                ;     dec ecx 1
                ;     push ecx                          ; push ultimo endereço do bloco


                ; call f2
                ; mov ecx, DWORD quant_blocks           ; ecx = q
                ; add ecx, ecx                          ; ecx = 2q
                ; add ecx, ecx                          ; ecx = 4q
                ; mov edx, ecx                          ; edx = 4q
                ; add ecx, ecx                          ; ecx = 8q
                ; add ecx, edx                          ; ecx = 12q
                ; add esp, ecx                          ; add esp 12 * quant_blocks

                add esp, 8
                
                pop ebx
                pop ecx
                leave
                ret