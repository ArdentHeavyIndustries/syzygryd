// AVR-DMX
// by Mike Estee

#ifndef _DMX_H_
#define _DMX_H_

// timer defs
#define SIG_DMX_TIMER	SIG_OUTPUT_COMPARE1A
#define DMX_TIE			OCIE1A
#define DMX_TCNT		TCNT1
#define DMX_TCCRA		TCCR1A
#define DMX_TCCRB		TCCR1B
#define DMX_OCRA		OCR1A
#define DMX_CS			CS10

// usart defs
#define SIG_DMX_DATA	SIG_UART_DATA
#define SIG_DMX_TRANS	SIG_UART_TRANS
#define SIG_DMX_RECV	SIG_UART_RECV
#define DMX_UBRRH		UBRRH
#define DMX_UBRRL		UBRRL
#define DMX_UCSRA		UCSRA
#define DMX_UCSRB		UCSRB
#define DMX_UCSRC		UCSRC
#define DMX_UDR			UDR
#define DMX_PORT		PORTD
#define DMX_PIN			PIND
#define DMX_DDR			DDRD
#define DMX_TXPIN		PIN1
#define DMX_RXPIN		PIN0


#define MAX_FIXTURE		16
#define DMX_ADDR_PIN	PINC
#define DMX_ADDR_DDR	DDRC
#define DMX_ADDR_PORT   PORTC

// dmx registers
#define DMX_COUNT 256							// we don't need more than this
extern volatile unsigned char dmx_out[];		// output buffer
extern volatile unsigned char dmx_reg[];		// input registers
extern volatile unsigned char dmx_addr;			// our address

// init sequence for both modes
void dmx_init( void );	// 3 for 250kbpos @ 16Mhz

// data functions
void dmx_read_addr( void );
void dmx_clear( void );

// dmx async (interupt driven)
void dmx_start( void );
void dmx_stop( void );

// dmx synchronous
void dmx_send( void );

#endif

