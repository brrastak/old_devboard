
; Enforce register addresses to be suitable for in/out instructions instead of lds/sts
#define __SFR_OFFSET 0x00
#include <avr/io.h>


; Output for the lpm instruction
; and function values
.set r0, 0
; First function argument
.set arg0, 24
; Index for the current digit being displayed (0-7); 7 corresponds to the non-digital indicator
.set digit_index, 17
; Inverts value every time timer 0 overflows
; is used to enerate a clock to increment the counter of dinamic indication
.set counter_clock_phase, 16

; Global flags
.set flags, 19
; Flags definitions:
#define BUTTON0_MASK 0b00000100
#define BUTTON1_MASK 0b00001000
#define BUTTON2_MASK 0b00010000
#define BUTTON3_MASK 0b00100000

.set ticksDin, 18

.set Sound, 20
.set Loud, 21

; Temporary registers for calculations; not preserved across function calls
.set tmp, 22
.set tmp1, 23


; Define X/Y/Z register aliases used in the original AVRASM for indirect addressing and lpm instruction
.set Xl, 26
.set Xh, 27
.set Yl, 28
.set Yh, 29
.set Zl, 30
.set Zh, 31


; Pin number of PORTD for a counter reset input
#define RESET_COUNTER 0
; Pin number of PORTD for a counter increment input
#define INC_COUNTER 1


.section .bss
; Global array to hold the values to be displayed on the 7-segment displays;
; 8 bytes for 8 digits (including the non-digital indicator)
.global values_to_display
.lcomm values_to_display, 8


.section .text

	rjmp RESET ; Reset Handler
	rjmp INT0_ISR ; External Interrupt0 Handler
	rjmp INT1_ISR ; External Interrupt1 Handler
	rjmp TIM1_CAPT_ISR ; ticksr1 Capture Handler
	rjmp TIM1_COMPA_ISR ; ticksr1 CompareA Handler
	rjmp TIM1_OVF_ISR ; ticksr1 Overflow Handler
	rjmp TIM0_OVF_ISR ; ticksr0 Overflow Handler
	rjmp USART0_RXC_ISR ; USART0 RX Complete Handler
	rjmp USART0_DRE_ISR ; USART0,UDR Empty Handler
	rjmp USART0_TXC_ISR ; USART0 TX Complete Handler
	rjmp ANA_COMP_ISR ; Analog Comparator Handler
	rjmp PCINT_ISR ; Pin Change Interrupt
	rjmp ticksR1_COMPB_ISR ; ticksr1 Compare B Handler
	rjmp ticksR0_COMPA_ISR ; ticksr0 Compare A Handler
	rjmp ticksR0_COMPB_ISR ; ticksr0 Compare B Handler
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
ticksR1_COMPB_ISR:
ticksR0_COMPA_ISR:
ticksR0_COMPB_ISR:
USI_START_ISR:
USI_OVERFLOW_ISR:
EE_READY_ISR:
WDT_OVERFLOW_ISR:

RESET:
    cli
	ldi tmp, lo8(RAMEND)
	out SPL, tmp

	ldi tmp, 0xff
	out TIFR, tmp
	ldi tmp, 6
	out TCNT0, tmp
	ldi tmp, 2
	out TCCR0B, tmp
	ldi tmp, 0x02
	out TIMSK, tmp

	ldi tmp, 0xff
	out DDRB, tmp
	ldi tmp, 0b11000011
	out DDRD, tmp
	ldi tmp, 0b00111101
	out PORTD, tmp
	ldi tmp, 0b00111100
	out PORTD, tmp
	ldi tmp, 0b00000001
	mov flags, tmp

    ; Initial values
    clr counter_clock_phase

	sei

Begin:	ldi tmp1, 0
	ldi Xl, lo8(values_to_display)
	ldi Xh, hi8(values_to_display)
	ldi tmp, 7
	add Xl, tmp
	adc Xh, tmp1
	ldi tmp, 0

Repeat:	ldi Yl, lo8(values_to_display)
	ldi Yh, hi8(values_to_display)
	add Yl, tmp
	adc Yh, tmp1
    mov arg0, tmp
	rcall encode
	st Y, r0
	inc tmp
	cpi tmp, 7
	brne Repeat

Loop:
    in tmp, PIND
	andi tmp, 0b00111100
	lsl tmp
	com tmp
	st X, tmp
    ldi arg0, 0xff
	rcall delay
	rjmp Loop

	rjmp Begin


; Wait:	push tmp
; 	ldi tmp, 0
; BA:	dec tmp
; 	brne BA
; 	pop tmp
; 	ret

; Delay for arg0 cycles
delay:
delay_loop:
    dec arg0
	brne delay_loop
	ret
; end delay


; Convert a decimal digit (0-9) in r0 to the corresponding 7-segment display encoding
; argument: arg0 = digit (0-9)
; returns: r0 = 7-segment encoding
encode:
    clr r0
	ldi Zl, lo8(digits_table)
	ldi Zh, hi8(digits_table)
	add Zl, arg0
	adc Zh, r0
	lpm
	ret


; Table to convert a decimal digit to the corresponding 7-segment display encoding
digits_table:
    .byte 0b01111110, 0b00110000, 0b01101101, 0b01111001
	.byte 0b00110011, 0b01011011, 0b01011111, 0b01110000
	.byte 0b01111111, 0b01111011


TIM0_OVF_ISR:
    push tmp
	in tmp, SREG
	push tmp
	push Zl
	push Zh

    ; Clear timer overflow flag and reset timer
	ldi tmp, 0x02
	out TIFR, tmp
	ldi tmp, 6
	out TCNT0, tmp

    ; Set flags based on button states; bits 2-5 of PORTD correspond to the 4 buttons
	in tmp, PIND
	andi tmp, 0b00111100
	andi flags, 0b11000011
	add flags, tmp

    ; Generate a clock to increment the counter of dinamic indication
	com counter_clock_phase
    ; if counter_clock_phase == true
    tst counter_clock_phase
    brne else_if_counter_clock_phase
    cbi PORTD, INC_COUNTER

    ; Increment digit_index and 
    inc digit_index
    cpi digit_index, 8
    brne end_if_reset_digit_index
    clr digit_index
end_if_reset_digit_index:
    ; Set the corresponding digit value
    clr tmp
	ldi Zl, lo8(values_to_display)
	ldi Zh, hi8(values_to_display)
	add Zl, digit_index
	adc Zh, tmp
	ld tmp, Z
	out PORTB, tmp

    rjmp end_if_counter_clock_phase
else_if_counter_clock_phase:
    sbi PORTD, INC_COUNTER


end_if_counter_clock_phase:

	; andi counter_clock_phase, 0b00000001
	; brne CA
	; mov tmp, flags
	; andi tmp, 0b00000001
	; breq CA


; CA:	cpi ticks, 2
; 	brne Din

; 	clr ticks
; 	sbi PORTD, INC_COUNTER
; 	mov tmp, flags
; 	andi tmp, 0b00000001
; 	breq CB

; 	inc digit_index
; 	cpi digit_index, 8
; 	brne CB
; 	clr digit_index
; CB:
;     clr tmp
; 	ldi Zl, lo8(values_to_display)
; 	ldi Zh, hi8(values_to_display)
; 	add Zl, digit_index
; 	adc Zh, tmp
; 	ld tmp, Z
; 	out PORTB, tmp

Din:	mov tmp, flags
	andi tmp, 0b01000000
	brne CC
	cbi PORTD, 6
	clr ticksDin
	rjmp End

CC:	inc ticksDin
	mov tmp, flags
	andi tmp, 0b10000000
	brne CD

	cp ticksDin, Sound
	brne End
	sbi PORTD, 6
	rjmp CF

CD:	cp ticksDin, Loud
	brne CE
	cbi PORTD, 6
CE:	cp ticksDin, Sound
	brne End
	cbi PORTD, 6

CF:	mov tmp, flags
	com tmp
	andi tmp, 0b10000000
	andi flags, 0b01111111
	or flags, tmp

End:	pop Zh
	pop Zl
	pop tmp
	out SREG, tmp
	pop tmp

	reti
