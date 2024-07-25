#include <stdint.h>
#include "code_def.h"


void KEY0(void)
{
Set_gpio_led(0b00000000000000000000000000000001);
	Set_isp_process();
	SetAwbParam(0);
  Set_sdcard_addr(0,16416);
	Set_sdcard_reset();
 Set_sdcard_addr(1,16416);
	WriteUART(1);


}

void KEY1(void)
{	
Set_gpio_led(0b00000000000000000000000000000010);	
	SetAwbParam(1);
	Set_isp_process();
	Set_sdcard_addr(0,1497456);
	Set_sdcard_reset();
	Set_isp_bypass(0);
  Set_sdcard_addr(1,1497456);
	WriteUART(2);

}

void KEY2(void)
{

Set_gpio_led(0b00000000000000000000000000000100);
  Set_sdcard_addr(0,16416);
	Set_sdcard_reset();
	Set_isp_bypass;
  Set_sdcard_addr(1,16416);
	WriteUART(3);

}

void KEY3(void)
{	
Set_gpio_led(8);
		Set_sdcard_addr(0,1497456);
	Set_sdcard_reset();
	Set_isp_grey();
  Set_sdcard_addr(1,1497456);
	WriteUART(4);

}

void UARTHandle()
{
	int data;
	data = ReadUART();
	switch(data){
		case day_isp:
			Set_gpio_led(0b00000000000000000000000000000001);
			Set_sdcard_addr(0,16416);
			Set_sdcard_reset();
			Set_isp_bypass(0);
			Set_sdcard_addr(1,16416);
			WriteUART(1);
			break;
		
		case night_isp:
			Set_gpio_led(0b00000000000000000000000000000010);	
			Set_sdcard_addr(0,1497456);
			Set_sdcard_reset();
			Set_isp_bypass(0);
			Set_sdcard_addr(1,1497456);
			WriteUART(2);
			break;
		
		case day_bypass:
			Set_gpio_led(0b00000000000000000000000000000100);
			Set_sdcard_addr(0,16416);
			Set_sdcard_reset();
			Set_isp_bypass(1);
			Set_sdcard_addr(1,16416);
			WriteUART(3);
			break;

		case night_bypass:
			Set_gpio_led(8);
			Set_sdcard_addr(0,1497456);
			Set_sdcard_reset();
			Set_isp_bypass(1);
			Set_sdcard_addr(1,1497456);
			WriteUART(4);
			break;
	}
		
	//UARTString("Cortex-M0 : ");
	//WriteUART(data);
	//WriteUART('\n');
}