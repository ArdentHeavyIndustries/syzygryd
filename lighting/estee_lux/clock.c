// Clock
// by Mike Estee

#include <avr/io.h>
#include <avr/signal.h>
#include <avr/interrupt.h>
#include <avr/delay.h>
#include "utils.h"
#include "clock.h"

// 1000 per second
volatile clock_t _clock;

SIGNAL (SIG_CLOCK_TIMER)
{
	// short and sweet
	_clock ++;

//  scope test
#if 1
	bell(1);
	bell(0);
#endif
}

void clock_init(void)
{
	// disable interupts
	unsigned char sreg = SREG;
	cli();
	
	// init timer 2
	_clock = 0;
	
	CLOCK_TCNT = 0;
	CLOCK_OCR = 124;	// 1ms
	CLOCK_TCCR = (1<<WGM21) | (5<<CS20); // CTC mode, xtal/128
	
	TIMSK |= (1<<CLOCK_TIE);
	
	// restore interups
	SREG = sreg;
}

clock_t clock( void )
{
	clock_t val;
	
	// no interupts between access
	unsigned char sreg = SREG;
	cli();
	val = _clock;
	SREG = sreg;
	
	return val;
}


clock_t clock_delta( void )
{
	static clock_t oldTime;
	clock_t newTime = clock();
	clock_t delta = newTime - oldTime;
	oldTime = newTime;
	return delta;
}

// sync delay
void clock_delay( clock_t delay )
{
	while( delay > 0 )
		delay -= clock_delta();
}



