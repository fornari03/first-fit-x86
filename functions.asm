%define quant_blocks DWORD [ebp+8]
%define program_size DWORD [ebp+12]
%define last_aloc DWORD [ebp-6]

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

msg_enderecos_prog_1 db 'O BLOCO ALOCOU DO ENDEREÇO '
msg_enderecos_prog_1_size equ $-msg_enderecos_prog_1

msg_enderecos_prog_2 db ' AO '
msg_enderecos_prog_2_size equ $-msg_enderecos_prog_2

msg_enderecos_prog_3 db ' DO PROGRAMA.',0ah,0dh
msg_enderecos_prog_3_size equ $-msg_enderecos_prog_3



section .bss
buffer resb 12



section .text
global funcao1





;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Função para efetuar  ;;;
;;;  os cálculos para a  ;;;
;;; alocação nos blocos  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Recebe os parâmetros ;;;
;;; pela pilha a partir  ;;;
;;;      da main.c       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
funcao1:        enter 6, 0

                push edx
                push ecx
                push ebx
        
                mov eax, program_size                   ; eax = tamanho do programa
                mov ecx, quant_blocks                   ; ecx = quantidade de blocos
                mov ebx, 5                              ; ebx = indice na pilha pro tamanho do primeiro bloco
                mov BYTE [ebp-1], 1                     ; flag pra dizer se coube
                mov BYTE [ebp-2], 1                     ; flag pra dizer se coube em um bloco só
                mov edx, 0                              ; edx = endereco inicial do programa

cabe_inteiro:
                cmp eax, DWORD [ebp+ebx*4]              ; programa <= bloco
                jle encerra_f1                          ; ? encerra_f1 : continua loop

                add ebx, 2
                loop cabe_inteiro

                ; se chegou aqui, o programa não coube em um bloco só
                mov ebx, 5                              ; restaura as 
                mov ecx, quant_blocks                   ; configurações iniciais
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
                mov last_aloc, ebx                      ; last_aloc = ebx
                mov ebx, 4

                cmp BYTE [ebp-2], 1
                je so_usou_1_bloco

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; A PARTIR DAQUI, os argumentos para a funcao2 serão empilhados ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ; eax = restante de espaço do programa a ser alocado
                ; ebx = 4 (endereço inicial do 1° bloco)
                ; last_aloc = indice na pilha pro endereço do ultimo bloco que aloca espaço [FIXO]
                ; ecx -> não importa

args_blocos:
                cmp ebx, last_aloc            
                je ultimo_bloco                         ; enquanto ebx < last_aloc:
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                inc ebx                                 ; ebx++
                add ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial + tamanho
                dec ecx                                 ; ecx--
                push ecx                                ; push endereço final usado
                push ecx                                ; push ultimo endereço do bloco
                push edx                                ; push endereço inicial do programa no bloco
                add edx, DWORD [ebp+ebx*4]              ; soma o tamanho do bloco ao endereço do programa
                dec edx                                 ; edx--
                push edx                                ; push endereço final do programa no bloco
                inc edx                                 ; edx++
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
                push edx                                ; push endereço inicial do programa no bloco
                add edx, eax                            ; edx += eax (add o tamanho do resto do programa)
                dec edx                                 ; edx--
                push edx                                ; push endereço final do programa no bloco
                inc edx

                mov eax, quant_blocks                   ; eax = q
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
                push -1                                 ; indica que não alocou programa nesse bloco
                push -1                                 ; indica que não alocou programa nesse bloco
                jmp restantes

so_usou_1_bloco:
                ; eax = tamanho do programa
                ; ebx = 4 (indice na pilha pro endereço inicial do primeiro bloco)
                ; last_aloc = indice na pilha pro endereço inicial do bloco usado
                cmp ebx, last_aloc                      ; ebx == last_aloc
                je ultimo_bloco                         ; ? pula pro ultimo bloco : continua
                mov ecx, DWORD [ebp+ebx*4]              ; ecx = endereço inicial
                push ecx                                ; push endereço inicial
                push -1                                 ; indica que não usou
                inc ebx                                 ; ebx++
                add ecx, DWORD [ebp+ebx*4]              ; ecx += tamanho do bloco
                dec ecx                                 ; ecx--
                push ecx                                ; push ultimo endereço do bloco
                push -1                                 ; indica que não alocou programa nesse bloco
                push -1                                 ; indica que não alocou programa nesse bloco
                inc ebx                                 ; ebx++ (endereço do próximo bloco)
                jmp so_usou_1_bloco                

chama_f2:
                mov ecx, quant_blocks
                push ecx                                ; push quantidade de blocos
                movzx ecx, BYTE [ebp-1]
                push ecx                                ; push flag de dizer se coube

                call funcao2

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; aqui iremos desempilhar todos os bytes que empilhamos para chamar funcao2 ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;              
                
                add esp, 8
                mov ecx, quant_blocks                   ; ecx = q
                add ecx, ecx                            ; ecx = 2q
                mov edx, ecx                            ; edx = 2q
                add ecx, ecx                            ; ecx = 4q
                add ecx, ecx                            ; ecx = 8q
                add ecx, edx                            ; ecx = 10q
                add ecx, ecx                            ; ecx = 20q
                add esp, ecx                            ; add esp 20 * quant_blocks (20: 4(inteiros) * 5(numero de inteiros))
                
                pop ebx
                pop ecx
                pop edx
                leave
                ret










;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Função para printar  ;;;
;;; na tela as alocações ;;;
;;;  feitas nos blocos   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Recebe os parâmetros ;;;
;;; pela pilha a partir  ;;;
;;;      da funcao1      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
funcao2:
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
                mov eax, DWORD [ebp+12]                 ; eax = quant_blocks
                mov cl, 5                               ; cl = 5 (quantidade de infos por bloco)
                mul cl                                  ; ax = quant_blocks * 5
                movzx edx, ax                           ; edx = ax
                add edx, 3                              ; edx += 3 (edx é o indice na pilha pro endereço inicial do primeiro bloco)
                mov ecx, 1                              ; ecx é o número do bloco começando do 1

results:
                push msg_bloco
                push msg_bloco_size
                call print_str                          ; printa "Bloco "
                add esp, 8

                push ecx
                call print_num                          ; printa o numero do bloco
                add esp, 4
                push newline
                push 1
                call print_str                          ; printa '\n
                add esp, 8

                push msg_inicio
                push msg_inicio_size
                call print_str                          ; printa "Endereco inicial: "
                add esp, 8

                push DWORD [ebp+4*edx]
                call print_num                          ; printa endereço de inicio do bloco
                add esp, 4
                push newline
                push 1
                call print_str                          ; printa '\n
                add esp, 8

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
                push newline
                push 1
                call print_str                          ; printa '\n
                add esp, 8
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
                call print_str                          ; printa '\n'
                add esp, 8

                dec edx                                 ; edx--
                mov ebx, DWORD [ebp+4*edx]              ; ebx = endereço inicial do programa no bloco
                dec edx                                 ; edx-- (pra caso não tenha usado o bloco)
                cmp ebx, -1                             ; se ebx = -1, bloco não foi utilizado 
                je nova_linha                           ; não printa nada sobre os endereços do programa
                inc edx                                 ; edx++ (pra restaurar o valor de antes do cmp)

                ; caso o bloco tenha sido utilizado
                push msg_enderecos_prog_1
                push msg_enderecos_prog_1_size
                call print_str                          ; printa "O BLOCO ALOCOU DO ENDEREÇO "
                add esp, 8

                push ebx
                call print_num
                add esp, 4

                push msg_enderecos_prog_2
                push msg_enderecos_prog_2_size          ; printa " AO "
                call print_str
                add esp, 8

                dec edx                                 ; edx-- (pega agora o endereço final do programa no bloco)
                push DWORD [ebp+4*edx]
                call print_num
                add esp, 4

                push msg_enderecos_prog_3
                push msg_enderecos_prog_3_size
                call print_str                          ; printa " DO PROGRAMA."
                add esp, 8


nova_linha:
                push newline
                push 1
                call print_str                          ; printa '\n'
                add esp, 8

                dec edx                                 ; edx-- (vai pro endereço inicial do próximo bloco)
                inc ecx                                 ; incrementa o número do bloco
                cmp ecx, DWORD [ebp+12]                 ; se já foram todos os blocos, termina
                jle results                             ; troquei o 'loop' pq passou o limite do short jump

fim_f2:
                pop edx
                pop ecx
                pop ebx
                leave
                ret

nao_coube:      
                push nao_cabe
                push nao_cabe_size
                call print_str
                add esp, 8
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
                push edi   

                mov edi, buffer
                mov ecx, 12
                mov al, 0
                rep stosb                               ; limpa o buffer (12 bytes)
                     

                mov ecx, buffer + 10                    ; aponta ecx para o final do buffer
                mov byte [ecx], 0
                mov ebx, 10                             ; vai dividir por 10 pra pegar os dígitos
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

                pop edi
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