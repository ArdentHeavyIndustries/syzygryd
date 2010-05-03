// LED
// by Mike Estee

#include <avr/signal.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include "dmx.h"
#include "led.h"

short led_red, led_grn, led_blu, led_wht;
void led_init( void )
{
	unsigned char sreg = SREG;
	cli();
	
	// port direction init
	LED_DDR |= LED_MASK;
	LED_PORT &= ~LED_MASK;   // all off
		
	// led timer
	LED_TCCR = (1<<WGM01) | (1<<CS00);		// CTC, clk/8 prescalar
	LED_TCNT = 0;
	LED_OCR = 0xff;
	
	SREG = sreg;
}

void led_start(void)
{
	TIMSK |= (1<<LED_OCIE);	
}

void led_stop(void)
{
	TIMSK &= ~(1<<LED_OCIE);
}

static short phase = 0;
static char channel = 0;
SIGNAL (SIG_LED_TIMER)
{	
	// advance pulse phase
	phase ++;
	if( phase > 384 )
		phase = 0;

	if( dmx_reg[DMX_MODE] & MODE_BURST_PWM )
	{
		#define BURST_PHASE(ch, clr,CLR) \
			if( channel==ch && phase < clr ) LED_PORT |= (1<<CLR); \
			else LED_PORT &= ~(1<<CLR);

		BURST_PHASE(0, led_red, RED);
		BURST_PHASE(1, led_grn, GRN);
		BURST_PHASE(2, led_blu, BLU);
		BURST_PHASE(3, led_wht, WHT);
	
		// advance the channel
		channel++;
		if( channel >= 4 )
			channel = 0;
	}
	else
	{
		#define FULL_PHASE(ch, clr,CLR) \
			if( phase < clr ) LED_PORT |= (1<<CLR); \
			else LED_PORT &= ~(1<<CLR);
	
		FULL_PHASE(0, led_red, RED);
		FULL_PHASE(1, led_grn, GRN);
		FULL_PHASE(2, led_blu, BLU);
		FULL_PHASE(3, led_wht, WHT);
	}
}
