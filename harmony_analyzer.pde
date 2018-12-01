
/*
  harmony_analyzer.pde :: Abstract functions generating interpretations based on active tones, then ordering them
    and converting them to human-readable format
*/

// fully interpret a set of tones, returning a list of chord names ordered by confidence
String[] interpret(int[] tones) {
  String[] orderedNames = new String[12];
  Interpretation[] interpretations = new Interpretation[12];
  
  // generate the interpretation vectors for each key
  for (int i = 0; i < interpretations.length; i++) {
    interpretations[i] = new Interpretation(noteNames[i], i, tones);
    
    // -- debug: for the moment, just add the names to ordered names in whatever order
    orderedNames[i] = interpretations[i].getMusicalName();
    
    // ----- calculate score here ----------
  }
  
  interpretations[8].logInterpretation();
  
  return orderedNames;
}
