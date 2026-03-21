#include <avr/io.h> 


.set r0, 0
.set tmp, 16


.section .text

	rjmp RESET ; Reset Handler
	rjmp INT0_ISR ; External Interrupt0 Handler
	rjmp INT1_ISR ; External Interrupt1 Handler
	rjmp TIM1_CAPT_ISR ; Timer1 Capture Handler
	rjmp TIM1_COMPA_ISR ; Timer1 CompareA Handler
	rjmp TIM1_OVF_ISR ; Timer1 Overflow Handler
	rjmp TIM0_OVF_ISR ; Timer0 Overflow Handler
	rjmp USART0_RXC_ISR ; USART0 RX Complete Handler
	rjmp USART0_DRE_ISR ; USART0,UDR Empty Handler
	rjmp USART0_TXC_ISR ; USART0 TX Complete Handler
	rjmp ANA_COMP_ISR ; Analog Comparator Handler
	rjmp PCINT_ISR ; Pin Change Interrupt
	rjmp TIMER1_COMPB_ISR ; Timer1 Compare B Handler
	rjmp TIMER0_COMPA_ISR ; Timer0 Compare A Handler
	rjmp TIMER0_COMPB_ISR ; Timer0 Compare B Handler
	rjmp USI_START_ISR ; USI Start Handler
	rjmp USI_OVERFLOW_ISR ; USI Overflow Handler
	rjmp EE_READY_ISR ; EEPROM Ready Handler
	rjmp WDT_OVERFLOW_ISR ; Watchdog Overflow Handler

INT0_ISR:
INT1_ISR:
TIM1_CAPT_ISR:
TIM1_COMPA_ISR:
TIM1_OVF_ISR:
TIM0_OVF_ISR:
USART0_RXC_ISR:
USART0_DRE_ISR:
USART0_TXC_ISR:
ANA_COMP_ISR:
PCINT_ISR:
TIMER1_COMPB_ISR:
TIMER0_COMPA_ISR:
TIMER0_COMPB_ISR:
USI_START_ISR:
USI_OVERFLOW_ISR:
EE_READY_ISR:
WDT_OVERFLOW_ISR:

RESET:
    cli
	ldi tmp, lo8(RAMEND)
    sts SPL, tmp

    ldi tmp, 0xff
	sts DDRB, tmp
	ldi tmp, 0b11000011
	sts DDRD, tmp
	ldi tmp, 0b00111101
	sts PORTD, tmp
	ldi tmp, 0b00111100
	sts PORTD, tmp

; loop:
    ldi tmp, 0xff
    sts PORTB, tmp

    ; rcall delay

    ; ldi tmp, 0x00
    ; sts PORTB, tmp

    ; rcall delay
    ; rjmp loop

loop:
    ldi tmp, PORTD2
    sts PORTD, tmp

    rcall delay

    ldi tmp, 0
    sts PORTD, tmp

    rcall delay
    rjmp loop

; loop:
    rcall delay

    lds tmp, PIND
    andi tmp, PIND2
    breq low

    ; set high
    lds tmp, PORTD
    sbi tmp, PORTD1
    sts PORTD, tmp

    rjmp loop

low:
    ; set low
    lds tmp, PORTD
    cbi tmp, PORTD1
    sts PORTD, tmp

    rjmp loop


    ; delay for 10 cycles
delay:
    push tmp
	ldi tmp, 10

delay_loop:
    dec tmp
	brne delay_loop

	pop tmp
	ret
    ; end delay
