#include<intrins.h>
#include "at89c5131.h"
#include "stdio.h"

void numpad_Int();
void find_col();

int numpad_key;
sbit r0 = P0^3;
sbit c0 = P0^4;
sbit c1 = P0^5;
sbit c2 = P0^6;
sbit c3 = P0^7;

void numpad_Int(void) interrupt 0
{
	
	find_col();
}

void find_col(){
	ACC = P0;
	ACC &= 0xF0;
	if(ACC != 0xF0){
		if(c0 == 0){ 
			P1 = 0x10;
		}
		else if(c1 == 0){ 
			P1 = 0x20;
		}
		else if(c2 == 0){ 
			P1 = 0x40;
		}
		else if(c3 == 0){
			P1 = 0x80;
		}
	}
	else;
}

void main(){
	P1 = 0x00;
	r0 = 0;
	c0 = 1;
	c1 = 1;
	c2 = 1;
	c3 = 1;
	IEN0 = 0x81;
	while(1);
}

