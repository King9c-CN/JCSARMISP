#include "code_def.h"
#include <string.h>
#include <stdint.h>


int main()
{ 
	//interrupt initial
	NVIC_CTRL_ADDR = 0x1f;

	//WATERLIGHT
	Setvgaen(1);

	while(1){	
	}
}
