#include <stdio.h>
#include <stdlib.h>

typedef enum { INT, FLOAT, CHAR } TypeTag;

typedef struct {
    TypeTag type;
    union {
        int i;
        float f;
        char c;
    } value;
} Element;

int main() {
    int n, i;
    Element *elements;
    unsigned char *int_vec, *float_vec, *char_vec;

    printf("Enter number of elements: ");
    scanf("%d", &n);

    elements = (Element*)malloc(n * sizeof(Element));
    int_vec = (unsigned char*)calloc(n, sizeof(unsigned char));
    float_vec = (unsigned char*)calloc(n, sizeof(unsigned char));
    char_vec = (unsigned char*)calloc(n, sizeof(unsigned char));

    // Ввод элементов
    for (i = 0; i < n; i++) {
        int type;
        printf("Element %d: enter type (0 - int, 1 - float, 2 - char): ", i);
        scanf("%d", &type);
        elements[i].type = (TypeTag)type;

        switch (type) {
            case 0:
                printf("Enter integer: ");
                scanf("%d", &elements[i].value.i);
                break;
            case 1:
                printf("Enter float: ");
                scanf("%f", &elements[i].value.f);
                break;
            case 2:
                printf("Enter char: ");
                scanf(" %c", &elements[i].value.c);
                break;
            default:
                printf("Invalid type\n");
                return 1;
        }
    }

    // Ассемблерная вставка
    asm volatile (
        "mov %[n], %%r8\n"               // Загружаем n в r8
        "test %%r8, %%r8\n"              // Если n == 0, выход
        "jz end_asm_loop%=\n"
        "xor %%r9, %%r9\n"               // Индекс i = 0

        "start_asm_loop%=:\n"
        "cmp %%r9, %%r8\n"               // Сравниваем i и n
        "jle end_asm_loop%=\n"

        // Вычисляем адрес элемента
        "mov %[elements], %%r10\n"
        "mov %%r9, %%r11\n"
        "imul $8, %%r11\n"              // i * sizeof(Element)
        "add %%r11, %%r10\n"            // elements + i

        // Получаем тип элемента
        "movl (%%r10), %%r11d\n"

        // Проверяем тип и устанавливаем вектор
        "cmp $0, %%r11d\n"
        "je set_int_label%=\n"
        "cmp $1, %%r11d\n"
        "je set_float_label%=\n"
        "cmp $2, %%r11d\n"
        "je set_char_label%=\n"
        "jmp next_iter_label%=\n"

        "set_int_label%=:\n"
        "movb $1, (%[int_vec], %%r9)\n"
        "jmp next_iter_label%=\n"

        "set_float_label%=:\n"
        "movb $1, (%[float_vec], %%r9)\n"
        "jmp next_iter_label%=\n"

        "set_char_label%=:\n"
        "movb $1, (%[char_vec], %%r9)\n"
        "jmp next_iter_label%=\n"

        "next_iter_label%=:\n"
        "inc %%r9\n"
        "jmp start_asm_loop%=\n"

        "end_asm_loop%=:\n"
        :
        : [elements] "r" (elements), [n] "r" (n),
          [int_vec] "r" (int_vec), [float_vec] "r" (float_vec),
          [char_vec] "r" (char_vec)
        : "r8", "r9", "r10", "r11", "memory", "cc"
    );

    // Вывод результатов
    printf("Int vector:    ");
    for (i = 0; i < n; i++) {
        printf("%d ", int_vec[i]);
    }
    printf("\nFloat vector:  ");
    for (i = 0; i < n; i++) {
        printf("%d ", float_vec[i]);
    }
    printf("\nChar vector:   ");
    for (i = 0; i < n; i++) {
        printf("%d ", char_vec[i]);
    }
    printf("\n");

    free(elements);
    free(int_vec);
    free(float_vec);
    free(char_vec);

    return 0;
}