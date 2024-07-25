#include "code_def.h"
#include <string.h>

void Setvgaen(int en)
{
	vga -> vga_en = en;
}

void Set_sdcard_addr(int en,int addr)
{
	sdcard -> sdcard_rd_addr = addr;
	sdcard -> sdcard_rd_en = en;

}

void Set_sdcard_reset()
{
		   sdcard -> sdcard_rd_reset = 1;    
}


void Set_isp_bypass(int bypass)
{
	if(bypass)
	   isp -> isp_bypass = 0b00100000010001000000011110010000;
	else 	isp -> isp_mode1 = 0b00010000010001000000011110010000;

}

void Set_gpio_led(int led)
{ 
	gpio ->gpio_led=led;
}

char ReadUARTState()
{
    char state;
	state = uart -> uart_tx_busy;
    return(state);
}

char ReadUART()
{
    char data;
	data = uart -> uart_rx_data;
    return(data);
}

void WriteUART(char data)
{
    while(ReadUARTState());
	uart -> uart_tx_data = data;
}

void UARTString(char *stri)
{
	int i;
	for(i=0;i<strlen(stri);i++)
	{
		WriteUART(stri[i]);
	}
}

void SetAwbParam(int i)
{
	if(i == 1){
	isp->awb_param_set = 0b10101000011000001000110000000001;
	}
	else{
	isp->awb_param_set =  0b11101011010101001000100000000001;
	}
}