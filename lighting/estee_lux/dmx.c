// AVR-DMX
// by Mike Estee

#include <avr/io.h>
#include <avr/signal.h>
#include <avr/interrupt.h>
#include <avr/delay.h>
#include "dmx.h"
#include "led.h"	// for number of dmx registers
#include "utils.h"


#define DMX_SELF_ADDR 1

// special states for t/rx_index
enum {
	DMX_BREAK = -2,
	DMX_MAB = -1,
	DMX_START = 0
};

#define DMX_EXIT 0x01

// global DMX register table, this is what we send continuously
volatile unsigned char dmx_out[DMX_COUNT];
volatile unsigned char dmx_reg[DMX_RSIZE];
volatile unsigned char dmx_addr;

volatile unsigned char dmx_flags;
static short tx_index;
static short rx_index;

SIGNAL (SIG_DMX_TIMER)
{
#define OCR_US(us)  ((XTAL/(1000000/(us))) - 1)
	
	// check the exit flag
	if( dmx_flags & DMX_EXIT )
	{
		// disable the timer
		TIMSK &= ~(1<<DMX_TIE);
		DMX_TCCRB &= ~(1<<DMX_CS);
		
		// clear exit flag
		dmx_flags &= ~DMX_EXIT;

	} else if( tx_index == DMX_BREAK ) {	
		// Break start
		DMX_PORT &= ~(1<<DMX_TXPIN);	// TX pin
		
		// delay 88 us
		DMX_OCRA = OCR_US(1528);//(88);
		tx_index++;
		
	} else if( tx_index == DMX_MAB ) {
		
		// MAB start
		DMX_PORT |= (1<<DMX_TXPIN);
		
		// delay 8 us
		DMX_OCRA = OCR_US(139);//(8);
		tx_index++;

	} else {
		// disable the timer
		TIMSK &= ~(1<<DMX_TIE);
		
		// enable the usart and DATA interupt
		DMX_UCSRB |= (1<<TXEN) | (1<<UDRIE);
	}
}

SIGNAL (SIG_DMX_DATA)
{
	if( tx_index==DMX_START )
	{
		// send start byte
		DMX_UDR = 0;
		tx_index++;
	}
	else if( tx_index <= DMX_COUNT )
	{	
		// last DMX channel?
		if( tx_index >= DMX_COUNT )
		{
			// disable DATA interupt
			DMX_UCSRB &= ~(1<<UDRIE);
			
			// enable trans interupt for last byte
			DMX_UCSRB |= (1<<TXCIE);
		}
		
		// transmit dmx_out byte
		DMX_UDR = dmx_out[tx_index-1];
		tx_index++;
	}
}


SIGNAL (SIG_DMX_TRANS)
{	
	if( tx_index > DMX_COUNT )
	{
		// renable the timer for DMX break signal
		TIMSK |= (1<<DMX_TIE);
		DMX_OCRA = 0;			// reset timer so we retrig immediately
		
		// disable the USART and its interupts
		DMX_UCSRB &= ~((1<<TXEN) | (1<<TXCIE) | (1<<UDRIE));
		
		// reset dmx_out index for break signal
		tx_index = DMX_BREAK;
	}
}


SIGNAL (SIG_DMX_RECV)
{	
	// check flags
	char error = DMX_UCSRA & (1<<FE);// | (1<<DOR) | (1<<PE));
	
	// read out the byte
	unsigned char byte = DMX_UDR;
	
	// check for frame error
	if( error )
		rx_index = DMX_START;

	else if( rx_index == DMX_START )
	{
		// found start byte
		if( byte == 0 )
		{
			rx_index ++;
			
			// update base addr register at start of frame
			dmx_read_addr();
		}
		else
			rx_index = DMX_BREAK;
	}
	
	// keep looking for as many registers as the max number of fixtures
	else if( rx_index>0 )
	{
		short index = rx_index-1;
		
		if( index < DMX_RSIZE*MAX_FIXTURE )
		{
			// wait until our addrs come by
			short reg = index - dmx_addr;
			if( reg>=0 && reg<DMX_RSIZE )
				dmx_reg[reg] = byte;
		}
		
		// copy to TX buffer if in range
		if( index < DMX_COUNT )
			dmx_out[index] = byte;

#if DMX_SELF_ADDR
		if( index == DMX_ADDR )
		{
			dmx_addr = byte;						// our address
			dmx_out[index] = dmx_addr+DMX_RSIZE;	// the next fixtures address
		}
#endif
		
		// advance index
		rx_index ++;
	}
	
	else
		rx_index = DMX_BREAK;
}

void dmx_init( void )
{
	// disable interupts
	unsigned char sreg = SREG;
	cli();
	
	// Set baud rate, DMX is always 250kbps
	short baud = 3;
	DMX_UBRRH = (unsigned char)(baud>>8);
	DMX_UBRRL = (unsigned char)baud;
	
	// Enable transmitter and receiver
	DMX_UCSRB = (1<<TXEN) | (1<<RXEN);
	
	// Set frame format: async, 8data, 2stop bit
#ifdef __AVR_ATmega64__
	DMX_UCSRC = (1<<USBS) | (3<<UCSZ0);		// | (1<<URSEL) on single usart chips
#else
	DMX_UCSRC = (1<<USBS) | (3<<UCSZ0) | (1<<URSEL);
#endif
	
	// TX pin during DMX break
	DMX_DDR |= (1<<DMX_TXPIN);
	DMX_PORT |= (1<<DMX_TXPIN);
	
	// DMX_ADDR pins
	DMX_ADDR_DDR &= 0x0F;   // set as input
	DMX_ADDR_PORT |= 0xF0;  // enable pull-ups
	dmx_addr = 0;			// start at zero for self addressing
	dmx_read_addr();
	
	// restore interups
	SREG = sreg;
}


void dmx_read_addr( void )
{
#if DMX_SELF_ADDR
	// no-op in self addressing mode
#else
	unsigned char index = DMX_ADDR_PIN >> 4;
	index = (~index) & 0xF;
	dmx_addr = index * DMX_RSIZE;
#endif
}

void dmx_start( void )
{
	// disable interupts
	unsigned char sreg = SREG;
	cli();
	
	// Timer init
	DMX_TCNT = 0;	// clear counter
	DMX_OCRA = 0;	// and delay time
	DMX_TCCRA = 0;
#if __AVR_ATmega64__
	DMX_TCCRB = (1<<WGMB2) | (1<<DMX_CS);
#else
	DMX_TCCRB = (1<<WGM12) | (1<<DMX_CS);
#endif
	
	// enable timer interups
	TIMSK |= (1<<DMX_TIE);
	DMX_UCSRB |= (1<<RXCIE);	// RX interrupt
	
	// clear exit flags
	dmx_flags &= ~DMX_EXIT;
	tx_index = DMX_BREAK;
	rx_index = DMX_BREAK;
	
	// restore interups
	SREG = sreg;
}


void dmx_stop( void )
{
	dmx_flags = DMX_EXIT;
	
	// wait for frame to finish
	while( dmx_flags & DMX_EXIT ) {}
}


void dmx_clear( void )
{
	// init dmx_out registers
	short channel = 0;
	for( ; channel<DMX_COUNT; channel++ )
	{
		if( channel < DMX_RSIZE )
			dmx_reg[channel] = 0;
			
		dmx_out[channel] = 0;
	}
}
