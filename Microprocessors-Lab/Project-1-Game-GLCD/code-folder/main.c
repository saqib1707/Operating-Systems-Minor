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

unsigned char c,p,temp,j,k,l,y,fucked,z=0;
int final_pos, block_cleared=0, numpad_key=4;

void numpad_Int(void) interrupt 0 {
	delay_ms(10);
	find_col();
	IE0_=0;
}

void find_col(){
	ACC = P0;
	ACC &= 0xF0;
	if(ACC != 0xF0){
		if(c0 == 0){ 
			//P1 = 0x10;
			numpad_key=0;
		}
		else if(c1 == 0){ 
			//P1 = 0x20;
			numpad_key=1;
		}
		else if(c2 == 0){ 
			//P1 = 0x40;
			numpad_key=2;
		}
		else if(c3 == 0){
			//P1 = 0x80;
			numpad_key=3;
		}
	}
	switch(numpad_key){
		case 0:
			moveleft();
			break;
		case 1:
			moveright();
			break;
		case 2:
			//movebullet();
			break;
		case 3:
			break;
		default:
			break;
	}
}

void delay(unsigned int value){
	unsigned int temp=0;
	  while(temp<value)
		{
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
void displayon() // step 1
{ 
	ctrloff();
	dport=0x3f;  // on display
	cs1=1;cs2=1; // enable bot halves
	rw=0;rs=0;   //instruction mode , write operation
	en=1;        // LCD enable
	delay(1); 
	en=0;
}


void setpage(unsigned char x) // step 2 
{
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

void setcolumn(unsigned char y) //step 3 - setting of column address
{
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

/*void clear_shooter(unsigned char page_no, char byte){
	//char byte = 0x00, index =0;
	unsigned char i;
	for(i=0; i<2; i++){
		set_loc(page_no%8, i);
		lcddata(&byte, 1);
	}
}*/

void draw_shooter(unsigned char page_no, char byte){
	//char byte = 0xff, index = 0;
	unsigned char i;
	for(i=0; i<2; i++){
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
		delay_ms(100);
}

void moveleft(void){
		draw_shooter(final_pos, 0x00);
		final_pos = (final_pos-1);
		if(final_pos == -1){
			final_pos = 0;
		}
		draw_shooter(final_pos, 0xFF);
		delay_ms(100);
}

void drawblock(unsigned char x,unsigned char y, char byte){
	//char byte = 0xFF;
	unsigned char k;
	for(k=0;k<8;k++){	
		set_loc(x,y*8+k);
		lcddata(&byte,1);
	}
}

/*void clearblock(unsigned char x, unsigned char y){
	char byte = 0x00;
	unsigned char k;
	for(k=0;k<8;k++){	
		set_loc(x,y*8+k);
		lcddata(&byte,1);
	}
}*/

void draw_bullet(unsigned char page_number, unsigned char col, char byte){
	// the bullet \size is 4x4
	unsigned char k;
	for(k=0; k<3 ;k++){
		set_loc(page_number, col*4+k);
		lcddata(&byte, 1);
	}
}
/*
void move_bullet(unsigned char page_number, unsigned char col){
	unsigned char j;
	char byte;
	for(j=1; j<=31; j++){
		byte=0x3C;
		draw_bullet(final_pos, j, byte);
		delay_ms(10); 
		if((j*4 == col*8) && (page_number==final_pos)){ // if the bullet collides with the block then clear both
			drawblock(page_number, col, 0x00);
			block_cleared=1;
			break;
		}
		byte=0x00;
		draw_bullet(final_pos, j, byte);    // so that the user can watch the bullet going up
	}
}
*/
void startdumping(unsigned char page_number){
		unsigned char col; //col_second_block;
		unsigned char j, temp=1;
		//col_second_block=rand()%16;
		for(col=15;col>=1;col--){
			drawblock(page_number,col, 0xFF);
			delay_ms(100);
			if(numpad_key == 2){           // shoot key pressed
				//move_bullet(page_number, col);
				for(j=temp; j<=3+temp && j<=31; j++){
					//draw_bullet(final_pos, j, 0x3C);
					//delay_ms(10);
					if((j*4+4 == col*8) && (page_number==final_pos)){ // if the bullet collides with the block then clear both
						delay_ms(100);
						drawblock(page_number, col, 0x00);
						draw_bullet(final_pos, j, 0x00);
						block_cleared=1;
						break;
					}
					//draw_bullet(final_pos, j, 0x00);
				}
				draw_bullet(final_pos, j-1, 0x3C);
				delay_ms(20);
				draw_bullet(final_pos, j-1, 0x00);
				if(block_cleared==1){
					block_cleared=0;
					numpad_key=4;
					break;
				}
				temp=j;
				if(temp==32){
					numpad_key=4;
				}
			}
			//drawblock(y,j-8);
			/*if(col==9){
				if((y!=finalp)||(y!=(finalp+1))){
					fucked=1;
				}
			}*/
			drawblock(page_number, col, 0x00);
		}
		//y=page_number;
}

void draw_grid_lines(void)
{
	  char byte=0x11,index=0;
	  for(index=1;index<10;index++)
	  {
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
		IEN0 = 0x81;
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
	    //draw_boundary();
		  page_number=rand()%8;
		  startdumping(page_number);

	//			bullet(k);
		  //moveup(); 
	      
			//if(fucked==1)
			//	break;
			//while((P1&0X01)==0X01);
	  }
		//while(1);
}
 
