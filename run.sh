nasm -f elf32 functions.asm -o functions.o

gcc -m32 -no-pie main.c functions.o -o carregador