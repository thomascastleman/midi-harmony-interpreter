
/*
  midi_chord_interpreter.pde :: Basic MIDI listeners and Processing setup
*/

import themidibus.*;

MidiBus bus;  // midibus interface

static final int CHANNEL = 0;  // channel constant
int[] activeTones = new int[12];  // vector containing counts of tones currently being played
String[] noteNames = {"A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"};  // note names in the order in which they occur in the activeTones vector

void setup() {
  size(500, 500);
  MidiBus.list();  // list available midi devices
  println("");
  bus = new MidiBus(this, 0, 1);  // init bus
  
  textSize(25);
  
  //int[] active = {
  //  1,  // A
  //  1,  // Bb
  //  1,  // B
  //  1,  // C
  //  1,  // Db
  //  1,  // D
  //  1,  // Eb
  //  1,  // E
  //  1,  // F
  //  1,  // F#
  //  1,   // G
  //  1  // Ab
  //};
  
  //Interpretation inter = new Interpretation("C", 3, active);
  //inter.logInterpretation();
  //println(inter.getMusicalName());
  
  background(10);
}

void draw() {
  //updateInterpretationDisplay();
}

// log the currently active tones vector
void printActiveTones() {
  for (int i = 0; i < activeTones.length; i++) {
    println(noteNames[i] + ": " + activeTones[i]);
  }
  println("");
}

// update the on-screen display of current harmonic interpretations
void updateInterpretationDisplay() {
  // interpret the active tones into chord names
  String[] chordNames = interpret(activeTones);
  
  background(50);
  println("Changed background");
  
  // for now, log names
  for (int i = 0; i < chordNames.length; i++) {
    // working on making this text appear 
    text(chordNames[i], 50, (i + 1) * 35);
  }
}

// convert a MIDI pitch number to its tone index (A --> 0, A# --> 1, ...)
int midiPitchToTone(int midiPitch) {
  // 21 is A0; mod by 12 to map all of the tones separated by octaves on to the same tone
  return (midiPitch - 21) % 12;
}

// Receive a noteOn
void noteOn(int channel, int pitch, int velocity) {
  //println();
  //println("Note On:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
  
  int toneIndex = midiPitchToTone(pitch);  // find tone based on MIDI pitch
  
  // if valid tone, increment count of this tone
  if (toneIndex >= 0) {
    activeTones[toneIndex]++;
  }

  // update the interpretation to reflect new note
  updateInterpretationDisplay();
}

// Receive a noteOff
void noteOff(int channel, int pitch, int velocity) {
  //println();
  //println("Note Off:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
  
  int toneIndex = midiPitchToTone(pitch);  // find tone based on MIDI pitch
  
  // if valid tone with nonzero frequency, decrement count of this tone
  if (toneIndex >= 0 && activeTones[toneIndex] > 0) {
    activeTones[toneIndex]--;
  }
  
  // update the interpretation to reflect removed note
  updateInterpretationDisplay();
}
