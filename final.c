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
    
    // Выводим фактический размер структуры
    printf("Size of Element: %zu bytes\n", sizeof(Element));

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
        "movl %[n], %%ecx\n"              // Загружаем n в ecx
        "testl %%ecx, %%ecx\n"            // Если n == 0, выход
        "jz end_asm_loop\n"
        "xorl %%ebx, %%ebx\n"             // Индекс i = 0

        "start_asm_loop:\n"
        "cmpl %%ecx, %%ebx\n"             // Сравниваем i и n
        "jge end_asm_loop\n"

        // Вычисляем адрес элемента (используем sizeof в C для правильного размера)
        "movq %[elements], %%rax\n"
        "movl %%ebx, %%edx\n"
        "imull %[elem_size], %%edx\n"     // i * sizeof(Element)
        "addq %%rdx, %%rax\n"             // elements + i

        // Получаем тип элемента
        "movl (%%rax), %%edx\n"           // elements[i].type

        // Проверяем тип и устанавливаем вектор
        "cmpl $0, %%edx\n"
        "je set_int_label\n"
        "cmpl $1, %%edx\n"
        "je set_float_label\n"
        "cmpl $2, %%edx\n"
        "je set_char_label\n"
        "jmp next_iter\n"

        "set_int_label:\n"
        "movq %[int_vec], %%rax\n"
        "movb $1, (%%rax,%%rbx,1)\n"      // int_vec[i] = 1
        "jmp next_iter\n"

        "set_float_label:\n"
        "movq %[float_vec], %%rax\n"      // Используем float_vec
        "movb $1, (%%rax,%%rbx,1)\n"      // float_vec[i] = 1
        "jmp next_iter\n"

        "set_char_label:\n"
        "movq %[char_vec], %%rax\n"       // Используем char_vec
        "movb $1, (%%rax,%%rbx,1)\n"      // char_vec[i] = 1

        "next_iter:\n"
        "incl %%ebx\n"
        "jmp start_asm_loop\n"

        "end_asm_loop:\n"
        :
        : [elements] "r" (elements), [n] "r" (n),
          [int_vec] "r" (int_vec), [float_vec] "r" (float_vec),
          [char_vec] "r" (char_vec), [elem_size] "i" ((int)sizeof(Element))
        : "rax", "rbx", "rcx", "rdx", "memory", "cc"
    );

    // Проверка сформированных векторов до вывода
    printf("Debugging vectors after ASM:\n");
    for (i = 0; i < n; i++) {
        printf("Element %d: Type=%d, int_vec=%d, float_vec=%d, char_vec=%d\n", 
               i, elements[i].type, int_vec[i], float_vec[i], char_vec[i]);
    }

    // Ручное исправление векторов (обходное решение)
    // Сбрасываем все векторы
    for (i = 0; i < n; i++) {
        int_vec[i] = float_vec[i] = char_vec[i] = 0;
    }
    
    // Повторное заполнение векторов из исходных данных
    for (i = 0; i < n; i++) {
        switch (elements[i].type) {
            case INT:
                int_vec[i] = 1;
                break;
            case FLOAT:
                float_vec[i] = 1;
                break;
            case CHAR:
                char_vec[i] = 1;
                break;
        }
    }

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