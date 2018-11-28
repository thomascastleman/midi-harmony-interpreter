
import themidibus.*;

MidiBus bus;  // midibus interface

static final int CHANNEL = 0;  // channel constant
int[] activeTones = new int[12];  // vector containing counts of tones currently being played
String[] noteNames = {"A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"};  // note names in the order in which they occur in the activeTones vector

void setup() {
  size(500, 500);
  MidiBus.list();  // list available midi devices
  println("");
  bus = new MidiBus(this, 0, 1);    // init bus
}

void draw() {
  background(50);
}

// log the currently active tones vector
void printActiveTones() {
  for (int i = 0; i < activeTones.length; i++) {
    println(noteNames[i] + ": " + activeTones[i]);
  }
}

// convert a MIDI pitch number to its tone index (A --> 0, A# --> 1, ...)
int midiPitchToTone(int midiPitch) {
  // 21 is A0; mod by 12 to map all of the tones separated by octaves on to the same tone
  return (midiPitch - 21) % 12;
}

// Receive a noteOn
void noteOn(int channel, int pitch, int velocity) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  
  int tone = midiPitchToTone(pitch);  // find tone based on MIDI pitch
  
  // if valid tone, increment count of this tone
  if (tone > 0) {
    activeTones[tone]++;
  }
}

// Receive a noteOff
void noteOff(int channel, int pitch, int velocity) {
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  
  int tone = midiPitchToTone(pitch);  // find tone based on MIDI pitch
  
  // if valid tone, decrement count of this tone
  if (tone > 0 && activeTones[tone] > 0) {
    activeTones[tone]--;
  }
}
