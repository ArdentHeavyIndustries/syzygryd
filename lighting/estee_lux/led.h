// LED
// by Mike Estee

#ifndef _LED_H_
#define _LED_H_

#include "lux.h"
#include "dmx.h"

#define LED_PORT PORTD
#define LED_DDR DDRD
#define RED PIN5
#define GRN PIN7
#define BLU PIN4
#define WHT PIN6
#define LED_MASK ((1<<RED) | (1<<GRN) | (1<<BLU) | (1<<WHT))

#define SIG_LED_TIMER   SIG_OUTPUT_COMPARE0
#define LED_TCCR		TCCR0
#define LED_TCNT		TCNT0
#define LED_OCR			OCR0
#define LED_OCIE		OCIE0

extern short led_red, led_grn, led_blu, led_wht;

// DMX_MODE modes
enum {
	MODE_ANIM_MASK = 0xF0,		// number of animation fixtures
	MODE_RGB = 0x01,
	MODE_BURST_PWM = 0x02,		// use burst instead of full pwm
};

enum {
	DMX_STROBE,		// strobing speed
	DMX_SPEED,		// hue cycling speed
	DMX_HUE_HI,		// high byte of hue
	DMX_HUE_LO,		// low byte of hue
	DMX_SAT,		// saturation
	DMX_VAL,		// value
	DMX_LFO,		// 0x01==sync on break
	DMX_MODE,		// 0=HSV, 1=RGB, 2=BURST, 0xn0=animation fixture count
	DMX_RSIZE,		// number of registers
	
	// dual purpose registers
	DMX_RED			=DMX_HUE_HI,
	DMX_GRN			=DMX_HUE_LO,
	DMX_BLU			=DMX_SAT,
	
	// controller registers
	DMX_WATCHDOG	=DMX_STROBE,
	DMX_SPIN		=DMX_SPEED,
	DMX_HUE_B		=DMX_HUE_HI,
	DMX_HUE_A		=DMX_HUE_LO,
	
	// address counting register
	DMX_ADDR=DMX_COUNT-1
};

void led_init(void);
void led_start(void);
void led_stop(void);

#endif
