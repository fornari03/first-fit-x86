# first-fit-x86
Repositório para um simulador de gerenciador de memória first-fit em Assembly x86

## Como rodar

Primeiro deve-se instalar a biblioteca `gcc-multilib`:
```shell
    sudo apt install gcc-multilib
```

Depois, basta apenas estar no diretório root do projeto e digitar os seguintes comandos:
```shell
    nasm -f elf32 functions.asm -o functions.o

    gcc -m32 main.c functions.o -o carregador

    ./carregador args
```

Ou, se preferir, usar o script shell para compilar e ligar:
```shell
    chmod +x run.sh     # dar permissão ao script
```

```shell
    ./run.sh

    ./carregador args
```