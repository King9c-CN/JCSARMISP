#include <stdint.h>

//INTERRUPT DEF
#define NVIC_CTRL_ADDR (*(volatile unsigned *)0xe000e100)

#define day_isp 0x01
#define night_isp 0x02
#define day_bypass 0x03
#define night_bypass 0x04

//VGA DEF
typedef struct{
    volatile uint32_t vga_en;
}vga_type;

#define vga_BASE 0x40000000
#define vga ((vga_type *)vga_BASE)

//SDCARD DEF
typedef struct{
    volatile uint32_t sdcard_rd_en;
    volatile uint32_t sdcard_rd_addr;
	  volatile uint32_t sdcard_rd_reset;
}sdcard_type;

#define sdcard_BASE 0x40001000
#define sdcard ((sdcard_type *)sdcard_BASE)

//GPIO DEF
typedef struct{
    volatile uint32_t gpio_led;
}gpio_type;

#define gpio_BASE 0x40002000
#define gpio ((gpio_type *)gpio_BASE)

//UART DEF
typedef struct{
    volatile uint32_t uart_rx_data;
    volatile uint32_t uart_tx_busy;
    volatile uint32_t uart_tx_data;
}uart_type;

#define uart_BASE 0x40003000
#define uart ((uart_type *)uart_BASE)

//SDCARD ISP
typedef struct{
    volatile uint32_t isp_mode1;
    volatile uint32_t isp_mode2;
	  volatile uint32_t isp_bypass;
	  volatile uint32_t isp_state;
	  volatile uint32_t awb_cal;
	  volatile uint32_t awb_cal_state;
	  volatile uint32_t awb_param_set;
}isp_type;

#define isp_BASE 0x50000000
#define isp ((isp_type *)isp_BASE)


void Setvgaen(int mode);
void Set_sdcard_addr(int en,int addr);
void Set_isp_bypass(int bypass);
void Set_sdcard_reset();
void delay(int count);
void Set_gpio_led(int led);

char ReadUARTState(void);
char ReadUART(void);
void WriteUART(char data);
void UARTString(char *stri);
void UARTHandle(void);

void SetAwbParam(int i);