
/*
  midi_chord_interpreter.pde :: Basic MIDI listeners and Processing setup
*/

import themidibus.*;

MidiBus bus;  // midibus interface

static final int CHANNEL = 0;  // channel constant
int[] activeTones = new int[12];  // vector containing counts of tones currently being played
static final String[] noteNames = {"A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"};  // note names in the order in which they occur in the activeTones vector

String[] interpretations = noteNames;  // initialize interpretations as just note names

void setup() {
  size(500, 500);
  MidiBus.list();  // list available midi devices
  println("");
  bus = new MidiBus(this, 0, 1);  // init bus
  
  textSize(25);
  background(10);
  fill(255);
  stroke(255);
}

void draw() {
  background(50);
  
  // output all current interpretations to screen
  for (int i = 0; i < interpretations.length; i++) {
    text(interpretations[i], 30, (i + 1) * 30);
  }
}

//// log the currently active tones vector
//void printActiveTones() {
//  for (int i = 0; i < activeTones.length; i++) {
//    println(noteNames[i] + ": " + activeTones[i]);
//  }
//  println("");
//}

// update the interpretation of the current set of notes
void updateInterpretation() {
  // interpret the active tones into chord names
  interpretations = interpret(activeTones);
}

// convert a MIDI pitch number to its tone index (A --> 0, A# --> 1, ...)
int midiPitchToTone(int midiPitch) {
  // 21 is A0; mod by 12 to map all of the tones separated by octaves on to the same tone
  return (midiPitch - 21) % 12;
}

// Receive a noteOn
void noteOn(int channel, int pitch, int velocity) {
  // find tone based on MIDI pitch
  int toneIndex = midiPitchToTone(pitch);
  
  // if valid tone, increment count of this tone
  if (toneIndex >= 0) {
    activeTones[toneIndex]++;
    
    // update the interpretation to reflect new note
    updateInterpretation();
  }
}

// Receive a noteOff
void noteOff(int channel, int pitch, int velocity) {
  // find tone based on MIDI pitch
  int toneIndex = midiPitchToTone(pitch);
  
  // if valid tone with nonzero frequency, decrement count of this tone
  if (toneIndex >= 0 && activeTones[toneIndex] > 0) {
    activeTones[toneIndex]--;
    
    // update the interpretation to reflect removed note
    updateInterpretation();
  }
}
