#include <stdio.h>


int main() {
    extern int soma(int, int);
    int resultado = soma(5, 3);
    printf("Resultado: %d\n", resultado);
    return 0;
}
