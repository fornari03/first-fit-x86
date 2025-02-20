#include <stdio.h>
#include <stdlib.h>


int main(int argc, char *argv[]) {
    extern int funcao1(int, int, int, int, int, int, int, int, int, int);
    int prog = atoi(argv[1]);
    int blocks[8];
    for (int i = 1; i <= 8; i++) {
        if (i < argc - 1) {
            blocks[i-1] = atoi(argv[i + 1]);
        } else {
            blocks[i-1] = 0;
        }
    }

    funcao1((argc-2)/2, prog, blocks[0], blocks[1], blocks[2], blocks[3], blocks[4], blocks[5], blocks[6], blocks[7]);
    
    return 0;
}
