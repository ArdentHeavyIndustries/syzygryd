// Clock
// by Mike Estee

#ifndef CLOCK_H
#define CLOCK_H

// timer defs
#define SIG_CLOCK_TIMER		SIG_OUTPUT_COMPARE2
#define CLOCK_TIE			OCIE2
#define CLOCK_TCNT			TCNT2
#define CLOCK_TCCR			TCCR2
#define CLOCK_OCR			OCR2

typedef long clock_t;

void clock_init(void);
clock_t clock( void );
clock_t clock_delta( void );	// returns time in ms since method was last called
void clock_delay( clock_t delay );

#endif
