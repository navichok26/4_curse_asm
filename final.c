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

    // Ассемблерная вставка с синтаксисом AT&T
    asm volatile (
        "movl %%ecx, %[n]\n"               // Загружаем n в ecx
        "test %%ecx, %%ecx\n"             // Если n == 0, выход
        "jz end_asm_loop\n"
        "xor %%ebx, %%ebx\n"              // Индекс i = 0

        "start_asm_loop:\n"
        "cmp %%ebx, %%ecx\n"              // Сравниваем i и n
        "jle end_asm_loop\n"

        // Вычисляем адрес элемента
        "mov %[elements], %%eax\n"
        "mov %%ebx, %%edx\n"
        "imul $8, %%edx\n"               // i * sizeof(Element)
        "add %%edx, %%eax\n"             // elements + i

        // Получаем тип элемента
        "mov (%%eax), %%edx\n"            // elements[i].type

        // Проверяем тип и устанавливаем вектор
        "cmp $0, %%edx\n"
        "je set_int_label\n"
        "cmp $1, %%edx\n"
        "je set_float_label\n"
        "cmp $2, %%edx\n"
        "je set_char_label\n"
        "jmp next_iter\n"

        "set_int_label:\n"
        "mov %[int_vec], %%eax\n"
        "movb $1, (%%eax,%%ebx)\n"
        "jmp next_iter\n"

        "set_float_label:\n"
        "mov %[float_vec], %%eax\n"
        "movb $1, (%%eax,%%ebx)\n"
        "jmp next_iter\n"

        "set_char_label:\n"
        "mov %[char_vec], %%eax\n"
        "movb $1, (%%eax,%%ebx)\n"
        "jmp next_iter\n"

        "next_iter:\n"
        "incl %%ebx\n"
        "jmp start_asm_loop\n"

        "end_asm_loop:\n"
        :
        : [elements] "r" (elements), [n] "r" (n),
          [int_vec] "r" (int_vec), [float_vec] "r" (float_vec),
          [char_vec] "r" (char_vec)
        : "eax", "ebx", "ecx", "edx", "memory", "cc"
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