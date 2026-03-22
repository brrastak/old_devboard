#include <avr/io.h>
#include <avr/interrupt.h>


constexpr uint8_t INC_COUNTER_MASK = 1 << 1;

int main() {

    // Setup timer 0 for a 1ms overflow interrupt
	TIFR = 0xff;
    // Divide timer clock by 256-6 = 250
    TCNT0 = 6;
    // Set prescaler to 8
    TCCR0B = (1 << CS01);
    // Enable timer overflow interrupt
    TIMSK = (1 << TOIE0);


    // Setup I/O ports
	DDRB = 0xff;
	DDRD = 0b11000011;
    PORTD = 0b00111101;
	PORTD = 0b00111100;

    sei();

    PORTB = 0xff;

    while (true) {
        // Main loop
    }

    return 0;
}


ISR(TIMER0_OVF_vect) {
	
    static bool counter_clock_phase = false;

    if (counter_clock_phase) {
        PORTD |= INC_COUNTER_MASK;
    } else {
        PORTD &= ~INC_COUNTER_MASK;
    }
    counter_clock_phase = !counter_clock_phase;

    // PORTB ^= 0xff;
}
