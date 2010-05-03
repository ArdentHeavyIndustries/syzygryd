// Utils
// by Mike Estee

#include <avr/io.h>
#include "utils.h"

void bell( char on )
{
	BELL_DDR |= (1<<BELL_PIN);
	
	if( on )
		BELL_PORT |= (1<<BELL_PIN);
	else
		BELL_PORT &= ~(1<<BELL_PIN);
#if 0
	if( on )
		PORTD |= (1<<PIN6);
	else
		PORTD &= ~(1<<PIN6);
#endif
}
