
/*
  harmony_analyzer.pde :: Abstract functions generating interpretations based on active tones, then ordering them
    and converting them to human-readable format
*/

// interpret given set of tones in all 12 keys, return list of interpretation objects
Interpretation[] getInterpretations(int[] tones) {
  Interpretation[] interpretations = new Interpretation[12];  // one for each key
  
  // generate the actual interpretations
  for (int i = 0; i < interpretations.length; i++) {
    interpretations[i] = new Interpretation(noteNames[i], i, tones);
  }
  
  return interpretations;
}

// fully interpret a set of tones, returning a list of chord names ordered by confidence
String[] interpret(int[] tones) {
  return new String[12];
}
