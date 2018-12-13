
/*
  harmony_analyzer.pde :: Abstract functions generating interpretations based on active tones, then ordering them
    and converting them to human-readable format
*/

// fully interpret a set of tones, returning a list of chord names ordered by confidence
String[] interpret(int[] tones) {
  String[] orderedNames = new String[12];  // array to hold ordered string names of interpretations
  Interpretation[] interpretations = new Interpretation[12];
  ArrayList<Interpretation> orderedInter = new ArrayList<Interpretation>();  // alloc new list for sorting interpretations
  
  // generate the interpretation vectors for each key
  for (int i = 0; i < interpretations.length; i++) {
    interpretations[i] = new Interpretation(noteNames[i], i, tones);  // construct new interpretation from this key center
    interpretations[i].getScore();  // calculate interpretation score
    orderedInsert(orderedInter, interpretations[i]);  // insert into list of interpretations, maintaining order
  }
  
  // convert into ordered list of human-readable chord names
  for (int i = 0; i < orderedInter.size(); i++) {
    orderedNames[i] = orderedInter.get(i).score + " " + orderedInter.get(i).getMusicalName();
  }
  
  return orderedNames;
}

// insert an interpretation into an ordered list, maintaining order by score
void orderedInsert(ArrayList<Interpretation> a, Interpretation inter) {
  int k;
  // locate index at which to insert
  for (k = 0; k < a.size(); k++) {
    if (a.get(k).score < inter.score) {
      break;
    }
  }
  
  a.add(k, inter);  // make insertion
}
