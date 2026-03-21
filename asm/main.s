#include <avr/io.h>


.set Null, 0
.set Time, 16
.set TimeInd, 17
.set TimeDin, 18
.set Flags, 19
.set Sound, 20
.set Loud, 21
.set tmp, 22
.set tmp1, 23
.set tmp2, 24

/* define X/Y/Z register aliases used in the original AVRASM */
.set Xl, 26
.set Xh, 27
.set Yl, 28
.set Yh, 29
.set Zl, 30
.set Zh, 31


.section .bss
.global Out0
.lcomm Out0,8


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
;TIM0_OVF_ISR:
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
	; out SPL, tmp
    sts SPL, tmp

	ldi tmp, 0xff
	sts TIFR, tmp
	ldi tmp, 6
	sts TCNT0, tmp
	ldi tmp, 2
	sts TCCR0B, tmp
	ldi tmp, 0x02
	sts TIMSK, tmp

	ldi tmp, 0xff
	sts DDRB, tmp
	ldi tmp, 0b11000011
	sts DDRD, tmp
	ldi tmp, 0b00111101
	sts PORTD, tmp
	ldi tmp, 0b00111100
	sts PORTD, tmp
	ldi tmp, 0b00000001
	mov Flags, tmp

	sei

Begin:	ldi tmp1, 0
	ldi Xl, lo8(Out0)
	ldi Xh, hi8(Out0)
	ldi tmp, 7
	add Xl, tmp
	adc Xh, tmp1
	ldi tmp, 0

Repeat:	ldi Yl, lo8(Out0)
	ldi Yh, hi8(Out0)
	add Yl, tmp
	adc Yh, tmp1
	rcall Coder
	st Y, Null
	inc tmp
	cpi tmp, 7
	brne Repeat

Loop:
    lds tmp, PIND
	andi tmp, 0b00111100
	lsl tmp
	com tmp
	st X, tmp
	rcall Wait
	rjmp Loop

	rjmp Begin


Wait:	push tmp
	ldi tmp, 0
BA:	dec tmp
	brne BA
	pop tmp
	ret


Coder:	clr Null
	ldi Zl, lo8(Table)
	ldi Zh, hi8(Table)
	add Zl, tmp
	adc Zh, Null
	lpm
	ret


Table:	.byte 0b01111110, 0b00110000, 0b01101101, 0b01111001
	.byte 0b00110011, 0b01011011, 0b01011111, 0b01110000
	.byte 0b01111111, 0b01111011


TIM0_OVF_ISR:	push tmp
	lds tmp, SREG
	push tmp
	push Zl
	push Zh

	ldi tmp, 0x02
	sts TIFR, tmp
	ldi tmp, 6
	sts TCNT0, tmp
	lds tmp, PIND
	andi tmp, 0b00111100
	andi Flags, 0b11000011
	add Flags, tmp

	inc Time
	cpi Time, 1
	brne CA
	mov tmp, Flags
	andi tmp, 0b00000001
	breq CA
	; cbi PORTD, 1
    lds tmp, PORTD
    cbi tmp, 1
    sts PORTD, tmp

CA:	cpi Time, 2
	brne Din

	clr Time
	; sbi PORTD, 1
    lds tmp, PORTD
    sbi tmp, 1
    sts PORTD, tmp
	mov tmp, Flags
	andi tmp, 0b00000001
	breq CB

	inc TimeInd
	cpi TimeInd, 8
	brne CB
	clr TimeInd
CB:	clr tmp
	ldi Zl, lo8(Out0)
	ldi Zh, hi8(Out0)
	add Zl, TimeInd
	adc Zh, tmp
	ld tmp, Z
	sts PORTB, tmp

Din:	mov tmp, Flags
	andi tmp, 0b01000000
	brne CC
	; cbi PORTD, 6
    lds tmp, PORTD
    cbi tmp, 6
    sts PORTD, tmp
	clr TimeDin
	rjmp End

CC:	inc TimeDin
	mov tmp, Flags
	andi tmp, 0b10000000
	brne CD

	cp TimeDin, Sound
	brne End
	; sbi PORTD, 6
    lds tmp, PORTD
    sbi tmp, 6
    sts PORTD, tmp
	rjmp CF

CD:	cp TimeDin, Loud
	brne CE
	; cbi PORTD, 6
    lds tmp, PORTD
    cbi tmp, 6
    sts PORTD, tmp
CE:	cp TimeDin, Sound
	brne End
	; cbi PORTD, 6
    lds tmp, PORTD
    cbi tmp, 6
    sts PORTD, tmp

CF:	mov tmp, Flags
	com tmp
	andi tmp, 0b10000000
	andi Flags, 0b01111111
	or Flags, tmp

End:	pop Zh
	pop Zl
	pop tmp
	sts SREG, tmp
	pop tmp

	reti
