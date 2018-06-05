#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
#  include <avr/power.h>
#endif

#define IDLE_TIMEOUT_MS (60*1000)

#define SW0A_PIN 2
#define SW0B_PIN 3
#define SW1A_PIN 4
#define SW1B_PIN 5
#define SW2A_PIN A0
#define SW2B_PIN A1
#define SW3A_PIN A2
#define SW3B_PIN A3
#define SW4A_PIN A4
#define SW4B_PIN A5

#define NEOPIXEL_PIN 6

#define ALIGN_OUT 7
#define ALIGN_IN  9
#define SELFTEST_PIN 10

#define NUM_PIXELS 10
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_PIXELS, NEOPIXEL_PIN, NEO_RGB + NEO_KHZ800);

const uint32_t COLOR_BAD = strip.Color(0, 0, 0);
const uint32_t COLOR_WRONG = strip.Color(200, 0, 0);
const uint32_t COLOR_RIGHT = strip.Color(0, 255, 0);

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if (WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}

#define NUM_RINGS 5

const struct ring2pin {
  uint8_t a_pin;
  uint8_t b_pin;
} ring2pin[NUM_RINGS] = {
  { SW0A_PIN, SW0B_PIN },
  { SW1A_PIN, SW1B_PIN },
  { SW2A_PIN, SW2B_PIN },
  { SW3A_PIN, SW3B_PIN },
  { SW4A_PIN, SW4B_PIN },
};

#define NUM_STATES (4*15)
#define BAD 15

const struct quad_table {
  uint8_t b : 1;
  uint8_t a : 1;
  uint8_t value : 4;
} quad_table[NUM_STATES] = {
  { 1, 1, 0 }, // "aligned" position is a=1 b=1 (both switches off)
  { 0, 1, 0 },
  { 0, 0, 0 }, // 1
  { 1, 0, BAD },
  { 1, 1, BAD },
  { 0, 1, 1 },
  { 0, 0, 1 }, // 2
  { 1, 0, 1 },
  { 1, 1, 1 },
  { 0, 1, BAD },
  { 0, 0, BAD }, // 3
  { 1, 0, 2 },
  { 1, 1, 2 },
  { 0, 1, 2 },
  { 0, 0, 2 }, // 4
  { 1, 0, BAD },
  { 1, 1, BAD },
  { 0, 1, 3 },
  { 0, 0, 3 }, // 5
  { 1, 0, 3 },
  { 1, 1, 3 },
  { 0, 1, BAD },
  { 0, 0, BAD }, // 6
  { 1, 0, 4 },
  { 1, 1, 4 },
  { 0, 1, 4 },
  { 0, 0, 4 }, // 7
  { 1, 0, BAD },
  { 1, 1, BAD },
  { 0, 1, 5 },
  { 0, 0, 5 }, // 8
  { 1, 0, 5 },
  { 1, 1, 5 },
  { 0, 1, BAD },
  { 0, 0, BAD }, // 9
  { 1, 0, 6 },
  { 1, 1, 6 },
  { 0, 1, 6 },
  { 0, 0, 6 }, // 10
  { 1, 0, BAD },
  { 1, 1, BAD },
  { 0, 1, 7 },
  { 0, 0, 7 }, // 11
  { 1, 0, 7 },
  { 1, 1, 7 },
  { 0, 1, BAD },
  { 0, 0, BAD }, // 12
  { 1, 0, 8 },
  { 1, 1, 8 },
  { 0, 1, 8 },
  { 0, 0, 8 }, // 13
  { 1, 0, BAD },
  { 1, 1, BAD },
  { 0, 1, 9 },
  { 0, 0, 9 }, // 14
  { 1, 0, 9 },
  { 1, 1, 9 },
  { 0, 1, BAD },
  { 0, 0, BAD }, // 0
  { 1, 0, 0 },
};

uint8_t ring_state[NUM_RINGS] = { 0 };
bool seen_alignment = false;
bool ring_state_changed = false;
bool power_saving = false;
unsigned long last_changed_time = 0;

uint8_t incr_state(uint8_t s) {
  if (s < (NUM_STATES - 1)) {
    return s + 1;
  }
  return 0;
}

uint8_t decr_state(uint8_t s) {
  if (s > 0) {
    return s - 1;
  }
  return (NUM_STATES - 1);
}

uint8_t add_ringval(uint8_t x, uint8_t y) {
  if (x == BAD || y == BAD) {
    return BAD;
  }
  uint8_t r = x + y;
  if (r >= 10) { r -= 10; }
  return r;
}

uint8_t new_state(uint8_t ring, uint8_t old_state) {
  const struct ring2pin *r = &ring2pin[ring];
  uint8_t new_a = digitalRead(r->a_pin);
  uint8_t new_b = digitalRead(r->b_pin);
  const struct quad_table *q = &quad_table[old_state];
  if (new_a == q->a && new_b == q->b) {
    return old_state;
  }
  ring_state_changed = true;
  uint8_t state_p1 = incr_state(old_state);
  q = &quad_table[state_p1];
  if (new_a == q->a && new_b == q->b) {
    return state_p1;
  }
  uint8_t state_m1 = decr_state(old_state);
  q = &quad_table[state_p1];
  if (new_a == q->a && new_b == q->b) {
    return state_m1;
  }
  // This shouldn't really happen, but if it does assume movement forward;
  // (and we use this assumption when initializing via alignment led)
  return incr_state(state_p1);
}

uint8_t compute_result(uint8_t x, uint8_t op, uint8_t y, uint8_t eq, uint8_t z1, uint8_t z2) {
  if (x == BAD || op == BAD || y == BAD || eq == BAD || z1 == BAD || z2 == BAD) {
    return BAD;
  }
  uint16_t z = (z1 * 10) + z2;
  int16_t xy;
  // 0+−×÷+−×÷+−
  switch (op) {
    default: // should never reach here, of course
    case 0: // 0
      xy = (x * 100) + y;
      break;
    case 1: // +
    case 5:
    case 9:
      xy = x + y;
      break;
    case 2: // -
    case 6:
      xy = x - y;
      break;
    case 3: // x
    case 7:
      xy = x * y;
      break;
    case 4: // div
    case 8:
      // scale both xy and z by 100 for a little fixed-point math
      xy = (100 * x) / y;
      z *= 100;
      break;
  }
  // 0=>=<=>=<=>=<=
  switch (eq) {
    default: // should never reach here, of course
    case 0: // 0
      return ((xy == 0) && (z == 0)) ? 1 : 0;
    case 1: // =
    case 3:
    case 5:
    case 7:
    case 9:
      return (xy == z) ? 1 : 0;
    case 2: // >
    case 6:
      return (xy > z) ? 1 : 0;
    case 4: // <
    case 8:
      return (xy < z) ? 1 : 0;
  }
}

void update_ring_states() {
  if (!seen_alignment) {
    digitalWrite(ALIGN_OUT, HIGH); // turn alignment LED on
    for (uint8_t i = 0; i < NUM_RINGS; i++) {
      ring_state[i] = 0;
    }
    if (digitalRead(ALIGN_IN) == HIGH) {
      return; // not aligned yet
    }
    // we're aligned!
    seen_alignment = true;
    // fall through to tweak state, since encoder might be offset slightly from
    // state 0 (use the fact that new_state will jump forward two spots if we
    // see a=0 b=0).
  }
  digitalWrite(ALIGN_OUT, LOW); // turn alignment LED off
  ring_state_changed = false;
  for (uint8_t i = 0; i < NUM_RINGS; i++) {
    ring_state[i] = new_state(i, ring_state[i]);
  }
  if (ring_state_changed) {
    last_changed_time = millis();
    power_saving = false;
  }
}

void update_led_states() {
  // slight hack to avoid calling strip.show() unnecessarily
  uint8_t old_pixels[3*NUM_PIXELS];
  memcpy(old_pixels, strip.getPixels(), sizeof(old_pixels));
  
  if (!seen_alignment) {
    // borrowed from "rainbowCycle" in LEDTEST
    uint16_t j = (millis() / 20) & 255; // animate w/ 20ms for each frame
    for (uint16_t i = 0; i < NUM_PIXELS; i++) {
      strip.setPixelColor(i, Wheel(((i * 256 / NUM_PIXELS) + j) & 255));
    }
  } else if (power_saving || (millis() - last_changed_time) > IDLE_TIMEOUT_MS) {
    power_saving = true;
    strip.clear(); // turn off LEDS to save power
    // XXX some sort of reminder blink?
  } else {
    uint8_t z2 = 0;
    uint8_t z1 = add_ringval(quad_table[ring_state[4]].value, z2);
    uint8_t eq = add_ringval(quad_table[ring_state[3]].value, z1);
    uint8_t y  = add_ringval(quad_table[ring_state[2]].value, eq);
    uint8_t op = add_ringval(quad_table[ring_state[1]].value, y);
    uint8_t x  = add_ringval(quad_table[ring_state[0]].value, op);

    for (uint8_t i = 0; i < NUM_PIXELS; i++) {
      uint8_t st = compute_result(x, op, y, eq, z1, z2);
      uint32_t color = (st == BAD) ? COLOR_BAD : st ? COLOR_RIGHT : COLOR_WRONG;
      strip.setPixelColor(i, color);
      x  = add_ringval(x, 1);
      op = add_ringval(op, 1);
      y  = add_ringval(y, 1);
      eq = add_ringval(eq, 1);
      z1 = add_ringval(z1, 1);
      z2 = add_ringval(z2, 1);
    }
  }
  // strip.show() takes approx 10*3*8/800kHz = 0.3ms of interrupt-disabled non-sleep time
  // so try to avoid calling it if nothing has changed.
  if (memcmp(old_pixels, strip.getPixels(), sizeof(old_pixels)) != 0) {
    strip.show();
  }
}

void run_spinner() {
  update_ring_states();
  update_led_states();
}

void testOneRing(uint8_t ring, uint16_t pixel) {
  const struct ring2pin *r = &ring2pin[ring];
  uint8_t val = (digitalRead(r->a_pin) ? 1 : 0) + (digitalRead(r->b_pin) ? 2 : 0);
  uint32_t color = strip.Color(255, 255, 255);
  switch (val) {
    case 0: color = strip.Color(0, 0, 0); break;
    case 1: color = strip.Color(255, 0, 0); break;
    case 2: color = strip.Color(0, 255, 0); break;
    case 3: color = strip.Color(0, 0, 255); break;
    default: break;
  }
  strip.setPixelColor(pixel, color);
}

void selfTest() {
  digitalWrite(ALIGN_OUT, HIGH); // turn alignment LED on
  for (uint8_t i = 0; i < NUM_RINGS; i++) {
    testOneRing(i, i);
  }
  strip.setPixelColor(5, digitalRead(ALIGN_IN) ? strip.Color(0, 255, 0) : strip.Color(255, 0, 0));
  uint32_t color = Wheel((uint8_t)(millis() / 10));
  for (uint8_t i=6; i < NUM_PIXELS; i++) {
    strip.setPixelColor(i, color);
  }
  strip.show();
}

void setup() {
  // Power-savings:
  // Default to INPUT_PULLUP for all pins, to minimize power consumption
  DDRB = DDRC = DDRD = 0;
  PORTB = PORTC = PORTD = 0xFF;

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);   // Indicate we are starting initialization.
  
  // Ring switch inputs
  for (uint8_t i = 0; i < NUM_RINGS; i++) {
    pinMode(ring2pin[i].a_pin, INPUT_PULLUP);
    pinMode(ring2pin[i].b_pin, INPUT_PULLUP);
  }

  // Alignment detection
  pinMode(ALIGN_OUT, OUTPUT);
  pinMode(ALIGN_IN, INPUT_PULLUP);

  pinMode(SELFTEST_PIN, INPUT_PULLUP);

  strip.setBrightness(50);
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'

  seen_alignment = false;
  digitalWrite(ALIGN_OUT, HIGH); // turn alignment LED on

  digitalWrite(LED_BUILTIN, LOW);   // Initialization is complete.

  while (digitalRead(SELFTEST_PIN) == LOW) {
    selfTest();
  }
}

void loop() {
  // XXX this should be triggered on pin change interrupt, and sleep otherwise
  // (there's also the 1ms timer-overflow interrupt in arduino core, have to figure out
  // how/whether to handle that)
  run_spinner();
}

