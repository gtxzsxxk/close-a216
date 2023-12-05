#include <stdint.h>

typedef struct {
    volatile uint32_t SR;
    volatile uint32_t DR;
    volatile uint32_t BRR;
} UART_TypeDef;

#define UART_BASE   0x0000000040013800U
#define UART1       ((UART_TypeDef *)UART_BASE)

typedef struct {
    volatile uint32_t DATA;
} PINOUT_TypeDef;

#define PINOUT_BASE   0x0000000040014800U
#define PINOUT       ((PINOUT_TypeDef *)PINOUT_BASE)

const char *str = "Cross-compiled by riscv32-buildroot-linux-gnu-\r\n"
                "GCC :\t" __VERSION__ "\r\n"
                "File:\t" __FILE__ "\r\n"
                "Date:\t" __DATE__ "\r\n"
                "Time:\t"  __TIME__ "\r\n"
                "Feel:\t" "Boundless Oceans, Vast Skies, Hold On To My Dream\r\n\r\n";

int my_strlen(const char *src) {
    int temp = 0;
    const char *tmp = str;
    while (*tmp) {
        temp++;
        tmp++;
    }
    return temp;
}

void delay(int time) {
    for (int num = time; num > 0; num--);
}

int main() {
    int len = my_strlen(str);
    /* At test we let the divider be 5 */
//    UART1->BRR = 5;
    /* Baud rate 115200 */
    UART1->BRR = 109;
    int flag = 0;
    while (1) {
        for (int i = 0; i < len; i++) {
            UART1->DR = str[i];
            while (!(UART1->SR & 0x40));
            delay(2500);
        }
        delay(2500000);
        if (flag) {
            flag = 0;
        } else {
            flag = 1;
        }
        PINOUT->DATA = flag;
    }
    return 0;
}