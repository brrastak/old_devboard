.include "avr/io.h"

.def	Null = r0
.def	Time = r16
.def	TimeInd = r17
.def	TimeDin = r18
.def	Flags = r19
.def	Sound = r20
.def	Loud = r21
.def	Temp = r22
.def	Temp1 = r23
.def	Temp2 = r24



.dseg

Out0:	.byte 8


.cseg

.org 0

	rjmp RESET ; Reset Handler
	rjmp INT0 ; External Interrupt0 Handler
	rjmp INT1 ; External Interrupt1 Handler
	rjmp TIM1_CAPT ; Timer1 Capture Handler
	rjmp TIM1_COMPA ; Timer1 CompareA Handler
	rjmp TIM1_OVF ; Timer1 Overflow Handler
	rjmp TIM0_OVF ; Timer0 Overflow Handler
	rjmp USART0_RXC ; USART0 RX Complete Handler
	rjmp USART0_DRE ; USART0,UDR Empty Handler
	rjmp USART0_TXC ; USART0 TX Complete Handler
	rjmp ANA_COMP ; Analog Comparator Handler
	rjmp PCINT ; Pin Change Interrupt
	rjmp TIMER1_COMPB ; Timer1 Compare B Handler
	rjmp TIMER0_COMPA ; Timer0 Compare A Handler
	rjmp TIMER0_COMPB ; Timer0 Compare B Handler
	rjmp USI_START ; USI Start Handler
	rjmp USI_OVERFLOW ; USI Overflow Handler
	rjmp EE_READY ; EEPROM Ready Handler
	rjmp WDT_OVERFLOW ; Watchdog Overflow Handler

;INT0:
;INT1:
TIM1_CAPT:
TIM1_COMPA:
TIM1_OVF:
;TIM0_OVF:
USART0_RXC:
USART0_DRE:
USART0_TXC:
ANA_COMP:
PCINT:
TIMER1_COMPB:
TIMER0_COMPA:
TIMER0_COMPB:
USI_START:
USI_OVERFLOW:
EE_READY:
WDT_OVERFLOW:

RESET:	cli
	ldi Temp, Low(RamEnd)
	out spl, Temp

	ldi Temp, 0xff
	out TIFR, Temp
	ldi Temp, 6
	out tcnt0, Temp
	ldi Temp, 2
	out tccr0b, Temp
	ldi Temp, 0x02
	out timsk, Temp

	ldi Temp, 0xff
	out ddrb, Temp
	ldi Temp, 0b11000011
	out ddrd, Temp
	ldi Temp, 0b00111101
	out portd, Temp
	ldi Temp, 0b00111100
	out portd, Temp
	ldi Temp, 0b00000001
	mov Flags, Temp

	sei

Begin:	ldi Temp1, 0
	ldi Xl, Low(Out0)
	ldi Xh, High(Out0)
	ldi Temp, 7
	add Xl, Temp
	adc Xh, Temp1
	ldi Temp, 0

Repeat:	ldi Yl, low(Out0)
	ldi Yh, High(Out0)
	add Yl, Temp
	adc Yh, Temp1
	rcall Coder
	st Y, Null
	inc Temp
	cpi Temp, 7
	brne Repeat

Loop:	in Temp, PIND
	andi Temp, 0b00111100
	lsl Temp
	com Temp
	st X, Temp
	rcall Wait
	rjmp Loop

	rjmp Begin


Wait:	push Temp
	ldi Temp, 0
BA:	dec Temp
	brne BA
	pop Temp
	ret


Coder:	clr Null
	ldi Zl, Low(Table*2)
	ldi Zh, High(Table*2)
	add Zl, Temp
	adc Zh, Null
	lpm
	ret


Table:	.db 0b01111110, 0b00110000, 0b01101101, 0b01111001
	.db 0b00110011, 0b01011011, 0b01011111, 0b01110000
	.db 0b01111111, 0b01111011


TIM0_OVF:	push Temp
	in Temp, SREG
	push Temp
	push Zl
	push Zh

	ldi Temp, 0x02
	out TIFR, Temp
	ldi Temp, 6
	out TCNT0, Temp

	in Temp, PIND
	andi Temp, 0b00111100
	andi Flags, 0b11000011
	add Flags, Temp

	inc Time
	cpi Time, 1
	brne CA
	mov Temp, Flags
	andi Temp, 0b00000001
	breq CA
	cbi PORTD, 1

CA:	cpi Time, 2
	brne Din

	clr Time
	sbi PORTD, 1
	mov Temp, Flags
	andi Temp, 0b00000001
	breq CB

	inc TimeInd
	cpi TimeInd, 8
	brne CB
	clr TimeInd
CB:	clr Temp
	ldi Zl, Low(Out0)
	ldi Zh, High(Out0)
	add Zl, TimeInd
	adc Zh, Temp
	ld Temp, Z
	out PORTB, Temp

Din:	mov Temp, Flags
	andi Temp, 0b01000000
	brne CC
	cbi PORTD, 6
	clr TimeDin
	rjmp End

CC:	inc TimeDin
	mov Temp, Flags
	andi Temp, 0b10000000
	brne CD

	cp TimeDin, Sound
	brne End
	sbi PORTD, 6
	rjmp CF

CD:	cp TimeDin, Loud
	brne CE
	cbi PORTD, 6
CE:	cp TimeDin, Sound
	brne End
	cbi PORTD, 6

CF:	mov Temp, Flags
	com Temp
	andi Temp, 0b10000000
	andi Flags, 0b01111111
	or Flags, Temp

End:	pop Zh
	pop Zl
	pop Temp
	out SREG, Temp
	pop Temp

	reti					