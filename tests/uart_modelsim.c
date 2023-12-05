#include <string.h>
#include <stdint.h>

typedef struct {
    volatile uint32_t SR;
    volatile uint32_t DR;
    volatile uint32_t BRR;
} UART_TypeDef;

#define UART_BASE   0x40013800U
#define UART1       ((UART_TypeDef *)UART_BASE)

const char *str = "Modelsim\r\n";

void delay(int time) {
    for (int num = time; num > 0; num--);
}

int main() {
    int len = strlen(str);
    /* At test we let the divider be 5 */
    UART1->BRR = 5;
    /* Baud rate 115200 */
//    UART1->BRR = 217;
    while (1) {
        for (int i = 0; i < len; i++) {
            UART1->DR = str[i];
            while (!(UART1->SR & 0x40));
        }
        delay(3);
    }
    return len;
}