// Utils
// by Mike Estee

#ifndef _UTILS_H_
#define _UTILS_H_

// toggles the bell pin for debugging
#define BELL_PORT PORTC
#define BELL_PIN PIN1
#define BELL_DDR DDRC

void bell( char on );
void debug( unsigned char chan, unsigned char cc, unsigned char val );

#define push_int() unsigned char; _sreg = SREG;
#define pop_int() SREG = _sreg;

#endif

