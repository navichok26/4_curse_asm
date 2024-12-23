#include <stdio.h>
#include <stdlib.h>

int main() {
    int n;
    printf("Input n: ");
    scanf("%d", &n);

    // Выделение памяти под матрицу
    int** matrix = malloc(n * sizeof(int*));
    for (int i = 0; i < n; i++) {
        matrix[i] = malloc(n * sizeof(int));
    }

    // Считывание матрицы
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("Matrix[%d][%d]: ", i, j);
            scanf("%d", &matrix[i][j]);
        }
    }

    // Расчёт суммы в заштрихованной области
    int center = n / 2;
    long long sum = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (abs(i - center) + abs(j - center) <= center) {
                sum += matrix[i][j];
            }
        }
    }

    // Вывод результата
    printf("Sum = %lld\n", sum);

    // Освобождение памяти
    for (int i = 0; i < n; i++) {
        free(matrix[i]);
    }
    free(matrix);

    return 0;
}