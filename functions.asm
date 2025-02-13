%define quant_blocks [ebp+8]
%define program_size [ebp+12]
%define last_aloc [ebp-6]

section .data
newline db 0ah

nao_cabe db 0ah,0dh,'O programa dado nao cabe nos blocos de memoria passados.',0ah,0dh,0ah,0dh
nao_cabe_size equ $-nao_cabe

cabe db 0ah,0dh,'O programa foi alocado da seguinte forma nos blocos de memoria passados:',0ah,0dh,0ah,0dh
cabe_size equ $-cabe

msg_bloco db 'Bloco '
msg_bloco_size equ $-msg_bloco

msg_inicio db 'Endereco inicial: '
msg_inicio_size equ $-msg_inicio

msg_utilizado db 'Ultimo endereco alocado: '
msg_utilizado_size equ $-msg_utilizado

msg_fim db 'Endereco final: '
msg_fim_size equ $-msg_fim

msg_nao_usou db 'Bloco não foi utilizado.',0ah,0dh
msg_nao_usou_size equ $-msg_nao_usou

section .bss
buffer resb 12

section .text
global f1

f1:             enter 6, 0

                push ecx
                push ebx
        
                mov eax, DWORD program_size             ; eax = tamanho do programa
                mov ecx, DWORD quant_blocks             ; ecx = quantidade de blocos
                mov ebx, 5                              ; ebx = indice na pilha pro tamanho do primeiro bloco
                mov BYTE [ebp-1], 1                     ; flag pra dizer se coube
                mov BYTE [ebp-2], 1                     ; flag pra dizer se coube em um bloco só

cabe_inteiro:
                cmp eax, DWORD [ebp+ebx*4]              ; programa <= bloco
                jle encerra_f1                          ; ? encerra_f1 : continua loop

                add ebx, 2
                loop cabe_inteiro

                ; se chegou aqui, o programa não coube em um bloco só
                mov ebx, 5                              ; restaura as 
                mov ecx, DWORD quant_blocks             ; configurações iniciais
                mov BYTE [ebp-2], 0                     ; atualiza a flag de caber num bloco só

repete: 
                cmp eax, DWORD [ebp+ebx*4]              ; programa <= bloco
                jle encerra_f1                          ; ? encerra_f1 : continua loop
                sub eax, DWORD [ebp+ebx*4]              ; programa -= bloco

                add ebx, 2
                loop repete

                ; se chegou aqui, o programa não coube nos blocos
                mov BYTE [ebp-1], 0
                sub ebx, 2                              ; ajusta o índice pro último

encerra_f1:
                dec ebx                                 ; ebx-- (ebx agora é o endereço do bloco)
                mov DWORD last_aloc, ebx                ; last_aloc = ebx
                mov ebx, 4

                cmp BYTE [ebp-2], 1
                je so_usou_1_bloco

                ; eax = restante de espaço do programa a ser alocado
                ; ebx = 4 (endereço inicial do 1° bloco)
                ; last_aloc = indice na pilha pro endereço do ultimo bloco que aloca espaço [FIXO]
                ; ecx -> não importa

args_blocos:
                cmp ebx, DWORD last_aloc            
                je ultimo_bloco                         ; enquanto ebx < last_aloc:
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                inc ebx                                 ; ebx++
                add ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial + tamanho
                dec ecx                                 ; ecx--
                push ecx                                ; push endereço final usado
                push ecx                                ; push ultimo endereço do bloco
                inc ebx                                 ; ebx++
                jmp args_blocos

ultimo_bloco:
                ; último bloco utilizado
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                add ecx, eax                            ; ecx += eax (add o tamanho do resto do programa)
                dec ecx                                 ; ecx--
                push ecx                                ; push endereço final USADO
                inc ebx                                 ; ebx++
                sub ecx, eax                            ; ecx -= eax
                add ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial - 1 + tamanho
                push ecx                                ; push ultimo endereço do bloco

                mov eax, DWORD quant_blocks             ; eax = q
                dec eax                                 ; eax = q-1
                add eax, eax                            ; eax = (q-1)*2
                add eax, 5                              ; eax = 5 + (q-1)*2

restantes:
                inc ebx
                cmp ebx, eax                            ; ebx >= ultimo bloco
                jge chama_f2                            ; ? chama_f2 : continua
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                push -1                                 ; indica que não usou
                inc ebx                                 ; ebx++
                add ecx, DWORD [ebp+ebx*4]              ; ecx += tamanho do bloco
                dec ecx                                 ; ecx--
                push ecx                                ; push ultimo endereço do bloco
                jmp restantes

so_usou_1_bloco:
                ; eax = tamanho do programa
                ; ebx = 4 (indice na pilha pro endereço inicial do primeiro bloco)
                ; last_aloc = indice na pilha pro endereço inicial do bloco usado
                cmp ebx, DWORD last_aloc                ; ebx == last_aloc
                je ultimo_bloco                         ; ? pula pro ultimo bloco : continua
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                push -1                                 ; indica que não usou
                inc ebx                                 ; ebx++
                add ecx, DWORD [ebp+ebx*4]              ; ecx += tamanho do bloco
                dec ecx                                 ; ecx--
                push ecx                                ; push ultimo endereço do bloco
                inc ebx                                 ; ebx++ (endereço do próximo bloco)
                jmp so_usou_1_bloco                

chama_f2:
                mov ecx, DWORD quant_blocks
                push ecx                                ; push quantidade de blocos
                movzx ecx, BYTE [ebp-1]
                push ecx                                ; push flag de dizer se coube

                call f2
                
                add esp, 8
                mov ecx, DWORD quant_blocks             ; ecx = q
                add ecx, ecx                            ; ecx = 2q
                add ecx, ecx                            ; ecx = 4q
                mov edx, ecx                            ; edx = 4q
                add ecx, ecx                            ; ecx = 8q
                add ecx, edx                            ; ecx = 12q
                add esp, ecx                            ; add esp 12 * quant_blocks
                
                pop ebx
                pop ecx
                leave
                ret





f2:
                enter 0,0
                push ebx
                push ecx
                push edx

                cmp DWORD [ebp+8], 0
                je nao_coube

                ; se chega aqui, é porque coube
                push cabe
                push cabe_size
                call print_str                          ; printa que cabe o programa
                add esp, 8
                mov ecx, DWORD [ebp+12]                 ; ecx = quant_blocks
                mov edx, 6                              ; edx = indice na pilha

results:
                push msg_bloco
                push msg_bloco_size
                call print_str                          ; printa "Bloco "
                add esp, 8

                push ecx
                call print_num                          ; printa o numero do bloco
                add esp, 4

                push msg_inicio
                push msg_inicio_size
                call print_str                          ; printa "Endereco inicial: "
                add esp, 8

                push DWORD [ebp+4*edx]
                call print_num                          ; printa endereço de inicio do bloco
                add esp, 4

                push msg_utilizado
                push msg_utilizado_size
                call print_str                          ; printa "Ultimo endereco utilizado: "
                add esp, 8

                dec edx                                 ; edx--
                mov ebx, DWORD [ebp+4*edx]              ; ebx = último endereço utilizado
                cmp ebx, -1                             ; se ebx = -1, bloco não foi utilizado                     
                je nao_usou
                push ebx
                call print_num                          ; printa endereço de uso do bloco
                add esp, 4
                jmp usou
nao_usou:
                push msg_nao_usou
                push msg_nao_usou_size
                call print_str                          ; printa que bloco não foi usado
                add esp, 8

usou:
                push msg_fim
                push msg_fim_size
                call print_str                          ; printa "Endereco final: "
                add esp, 8                

                dec edx                                 ; edx--
                push DWORD [ebp+4*edx]
                call print_num                          ; printa endereço final do bloco
                add esp, 4

                push newline
                push 1
                call print_str
                add esp, 8

                add edx, 5
                dec ecx
                cmp ecx, 0
                jne results                              ; troquei o 'loop' pq passou o limite do short jump

fim_f2:
                pop edx
                pop ecx
                pop ebx
                leave
                ret

nao_coube:      
                pusha
                push nao_cabe
                push nao_cabe_size
                call print_str
                add esp, 8
                popa
                jmp fim_f2
                




;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Função auxiliar para ;;;
;;;   printar um número  ;;;
;;;       na tela        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_num:
                enter 0,0
                push eax       
                push ebx                                
                push ecx                                
                push edx    

                mov edi, buffer
                mov ecx, 12
                mov al, 0
                rep stosb                               ; limpa o buffer (12 bytes)
                     

                mov ecx, buffer + 10                    ; aponta ecx para o final do buffer
                mov byte [ecx], 0
                mov ebx, 10                             ; decimal
                mov eax, DWORD [ebp+8]                  ; pega argumento (numero pra printar)

convert_loop:
                dec ecx
                mov edx, 0
                div ebx                                 ; dl = eax % 10; eax /= 10
                add dl, 0x30                            ; converte o resto pra ASCII
                mov BYTE [ecx], dl                      ; move o ASCII pro buffer
                cmp eax, 0
                jnz convert_loop                        ; enquanto tiver digito, volta

                mov eax, 4
                mov ebx, 1
                mov ecx, buffer
                mov edx, 10
                int 80h                                 ; printa o numero

                mov eax, 4
                mov ebx, 1
                mov ecx, newline
                mov edx, 1
                int 80h                                 ; printa '\n'

                pop edx
                pop ecx
                pop ebx
                pop eax
                leave
                ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Função auxiliar para ;;;
;;;  printar uma string  ;;;
;;;       na tela        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_str:
                enter 0,0

                push eax
                push ebx
                push ecx
                push edx

                mov eax, 4
                mov ebx, 1
                mov ecx, DWORD [ebp+12]
                movzx edx, BYTE [ebp+8]
                int 80h

                pop edx
                pop ecx
                pop ebx
                pop eax

                leave
                ret