nasm -f elf32 functions.asm -o functions.o

gcc -m32 main.c functions.o -o carregador