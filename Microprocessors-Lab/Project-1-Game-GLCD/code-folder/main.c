/*Program to display simple text on Graphics LCD*/

#include <intrins.h>
#include "at89c5131.h"
#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#define dport P2
#define LED P0

void numpad_Int();
void find_col();
void moveleft();
void moveright();
void delay_ms(int);

sbit rs=P0^0;       // Register select. used to select between command and data
sbit rw=P0^1;      // Read write select. used to select if data is read or written to LCD controller
sbit en=P0^2;       // enable pin. used to create a data transfer initiation on high to low transition.
sbit cs1=P3^0;     // chip select 1. selects controller 1
sbit cs2=P3^1;		// chip select 2, selects controller 2
sbit rst=P3^2;
sbit left = P1^3;
sbit right = P1^4;
sbit r3 = P0^3;
sbit c0 = P0^4;
sbit c1 = P0^5;
sbit c2 = P0^6;
sbit c3 = P0^7;

unsigned char c,p,temp,j,k,l,y,z, page_number1, fcollision,game_over=0;
unsigned char var=1;
int final_pos, block_cleared=0, numpad_key=4;
/*
void numpad_Int(void) interrupt 0 {
	delay_ms(20);
	find_col();
	IE0_=0;
}
*/
void find_col(){
	ACC = P0;
	ACC &= 0xF0;
	if(ACC != 0xF0){
		delay_ms(10);
		ACC = P0;
		ACC &= 0xF0;
		if(ACC != 0xF0){
			if(c0 == 0){ 
				numpad_key=0;
			}
			else if(c1 == 0){ 
				numpad_key=1;
			}
			else if(c2 == 0){ 
				numpad_key=2;
			}
			else if(c3 == 0){
				numpad_key=3;
			}
			else{
				numpad_key=4;
			}
		}
	}
}

void delay(unsigned int value){
	unsigned int temp=0;
	while(temp<value){
		temp++;
	}
}

void delay_ms(int delay){
	int d=0;
	while(delay>0){
		for(d=0;d<382;d++);
		delay--;
	}
}

void ctrloff(){
	rs=0;
	rw=0;
	en=0;
	cs1=0;
	cs2=0;
}

//Display on function			 
void displayon(){  // step 1 
	ctrloff();
	dport=0x3f;  // on display
	cs1=1;cs2=1; // enable bot halves
	rw=0;rs=0;   //instruction mode , write operation
	en=1;        // LCD enable
	delay(1); 
	en=0;
}

void setpage(unsigned char x){ // step 2
	ctrloff();
	dport= 0xb8|x;	   //0xb8 represents Page 0 // 1011xxx
	cs1=1;
	cs2=1;
	rs=0;               //instruction mode , write operation
	rw=0;
	en=1;
	delay(1); 
	en=0;
}

void setcolumn(unsigned char y){ //step 3 - setting of column address
	if(y<64){
		ctrloff();
		c=y;
		dport=0x40|(y&63);	  //0x40 represents Column 0 //01xxxxxx
		cs1=1;cs2=0;          //page 1 on
		rs=0;
		rw=0;
		en=1;
		delay(1); 
		en=0;		
	}
	else{ 
		c=y;
		dport=0x40|((y-64)&63);	  //0x40 represents Column 0
		cs2=1;cs1=0;    // page 2 on
		rs=0;
		rw=0;
		en=1;
		delay(1); 
		en=0;
	}
}

void set_loc(unsigned char x,unsigned char y){
	setpage(x);
	setcolumn(y);
	p=x;
}

// This function is always called after setcoloumn function is called. c stores the value of coloumn to which data has to be written
void lcddata(unsigned char *value,unsigned int limit) // writing the data in perticular column
{
	unsigned int i;
	for(i=0;i<limit;i++){
		if(c<64){
			dport=value[i];
			cs1=1;cs2=0;
			rs=1;
			rw=0;
			en=1;
			delay(1); 
			en=0;
			c++;
		}
		else{
			setcolumn(c); 
			dport=value[i];
			cs2=1;cs1=0;
			rs=1;
			rw=0;
			en=1;
			delay(1); 
			en=0;
			c++;
		}
	if(c>127)
	return;
	}
}

// It must be note down that the LCD doesnt have a single command to clear the entire screen.
// Hence the screen is clearedd by writing '0' data to the screen
// This function cleares the entire screen
void clrlcd(unsigned char col){
    unsigned char i,j;
    for (i=0;i < 8;i++){
			setpage(i);
			setcolumn(col);
			for(j = col; j < 128; j++)
							lcddata(&z,1);
    }
}

// This function is used to read from the LCD. This function is useful if the data 
// has to be written to a pixel group in which some of pixels are already ON which shouldnt be modified.
// Hence the pixels are read XOR'ed and written back.
// A pixel group refers to a set of 8 pixels that are written simultaneously.
char read_pixel(void)
{
	  char temp=0;
	  P2=0xFF;             // Make P2 input port to read data
		rw=1;
		rs=1;
	
		en=1;
		_nop_();
	  _nop_();
	  _nop_();
	  _nop_();
	  _nop_();
	  _nop_();
	  en=0;
	  _nop_();
	  _nop_();
	  _nop_();        // By trail and error, it was found that the data in only read when en pin is made high to low 2 times
	  _nop_();
	  _nop_();
	  _nop_();
	  en=1;
	  _nop_();
	  _nop_();
	  _nop_();
	  _nop_();
	  _nop_();
	  _nop_();	  
	  temp=P2;
		en=0;
	  P2&=~0xFF;             // make P2 output port
	  return(temp);
}

// This function writes to a single pixel without modifing the other pixels in the same group
void write_pixel(unsigned char x,unsigned char y,char pixel_data)
{
	  char temp=0;
	  x=x-1;
				set_loc(x/8,y);
	      cs1=(y<64);
	      cs2=~cs1;
				temp=read_pixel();
				temp&=~(1<<(x%8));
				pixel_data=(pixel_data&0x01)<<(x%8);
	  temp = temp+pixel_data;
    set_loc(x/8,y);
		lcddata(&temp,1);  
}

void draw_boundary(void)
{
	  char byte=0xFF,index=0;
	  for(index=0;index<8;index++)
	  {
      set_loc(index,01);
		  lcddata(&byte,1);
		}
		for(index=0;index<8;index++)
	  {
		  set_loc(index,126);
		  lcddata(&byte,1);
		}
}

void draw_shooter(unsigned char page_no, char byte){
	unsigned char i;
	for(i=0; i<2; i++){
		set_loc(page_no%8, i);
		lcddata(&byte, 1);
	}
	if(byte!=0x00){
		byte=0x3C;
	}
	for(i=2; i<4; i++){
		set_loc(page_no%8, i);
		lcddata(&byte, 1);
	}
}

void moveright(void){
		draw_shooter(final_pos, 0x00);
		final_pos = (final_pos+1);
		if(final_pos == 8){
			final_pos = 7;
		}
		draw_shooter(final_pos, 0xFF);
		//delay_ms(50);
}

void moveleft(void){
		draw_shooter(final_pos, 0x00);
		final_pos = (final_pos-1);
		if(final_pos == -1){
			final_pos = 0;
		}
		draw_shooter(final_pos, 0xFF);
		//delay_ms(50);
}

void drawblock(unsigned char x,unsigned char y, char byte){
	unsigned char k;
	for(k=0;k<8;k++){	
		set_loc(x,y*8+k);
		lcddata(&byte,1);
	}
}

void draw_bullet(unsigned char page_number, unsigned char col, char byte){
	// the bullet \size is 4x4
	unsigned char k;
	for(k=0; k<3 ;k++){
		set_loc(page_number, col*4+k);
		lcddata(&byte, 1);
	}
}

void startdumping(unsigned char page_number){
		unsigned char j,k;
		int col, upper_collision=0, lower_collision=0;

		upper_collision=0;
		for(col=15; col>8; col--){
			find_col();
			if(upper_collision!=1){
				drawblock(page_number, col, 0xFF);
			}
			if(var != 1 && lower_collision != 1){
				drawblock(page_number1, col-8, 0xFF);  // new added
			}
			delay_ms(300);
			if(numpad_key == 0){
				moveleft();
			}
			else if(numpad_key == 1){
				moveright();
			}
			else if(numpad_key == 2){           // shoot key pressed
				for(j=1; j<=31; j++){
					draw_bullet(final_pos, j, 0x3C);
					if(j*4+4 == col*8 && page_number==final_pos && upper_collision != 1){
						upper_collision=1;
						fcollision=1;
						drawblock(page_number, col, 0x00);
						break;
					}
					if(var != 1 && lower_collision != 1){
						if(j*4+4 == (col-8)*8 && page_number1==final_pos){
							lower_collision=1;
							drawblock(page_number1, col-8, 0x00);
							break;
						}
					}
				}
				delay_ms(100);
				for(k=1; k<=j; k++){
					draw_bullet(final_pos, k, 0x00);
				}
			}
			numpad_key = 4;
			if(upper_collision == 1 && lower_collision == 1){
				break;
			}
			drawblock(page_number, col, 0x00);
			drawblock(page_number1, col-8, 0x00);
			if((col-8) == 1){
				game_over++;
			}
		}
		page_number1 = page_number;
		if(fcollision==1){
			var=1;
			fcollision=0;
		}
		else if(fcollision==0){
			var=0;
		}
}

void draw_grid_lines(void){
	char byte=0x11,index=0;
	for(index=1;index<10;index++){
	    set_loc(0,10*index);
		lcddata(&byte,1);
	    set_loc(1,10*index);
		lcddata(&byte,1);
	    set_loc(2,10*index);
		lcddata(&byte,1);
	    set_loc(3,10*index);
		lcddata(&byte,1);
	    set_loc(4,10*index);
		lcddata(&byte,1);
	    set_loc(5,10*index);
		lcddata(&byte,1);
	    set_loc(6,10*index);
		lcddata(&byte,1);
	    set_loc(7,10*index);
		lcddata(&byte,1);
	}			
}

void main(){ 
	unsigned char page_number;
	r3 = 0;
	c0 = 1;
	c1 = 1;
	c2 = 1;
	c3 = 1;
	rst=1;
	temp=0x88;
	clrlcd(0);
	displayon();
	//LED&=~0x80;
	P1|=0x0F;
	P3|=0x38;
	page_number=3;
	draw_shooter(page_number, 0xFF);
	final_pos=page_number;
	while(1){
		page_number=rand()%8;
		startdumping(page_number);
		if(game_over==5){
			break;
		}
	}
	clrlcd(0);
	while(1);
}