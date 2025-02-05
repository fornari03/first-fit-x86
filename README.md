# first-fit-x86
Repositório para um simulador de gerenciador de memória first-fit em Assembly x86

## Como rodar

```shell
    sudo apt install gcc-multilib

    nasm -f elf32 functions.asm -o functions.o

    gcc -m32 main.c functions.o -o carregador

    ./carregador
```