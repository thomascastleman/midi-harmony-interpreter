
import themidibus.*;

MidiBus bus;  // midibus interface

static final int CHANNEL = 0;  // channel constant

void setup() {
  size(500, 500);
  MidiBus.list();  // list available midi devices
  println("");
  bus = new MidiBus(this, 0, 1);    // init bus
}

void draw() {
  background(50);
}

// Receive a noteOn
void noteOn(int channel, int pitch, int velocity) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

// Receive a noteOff
void noteOff(int channel, int pitch, int velocity) {
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}
