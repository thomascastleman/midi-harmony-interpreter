
/*

  interpretation.pde :: Class to store the basic information encoded by an interpretation of a given set of notes

--> the index of the root note being used (A --> 0, A# --> 1, ...)
--> the letter of the root itself (i.e. "D", "Ab", ...)
--> a 17-dimensional vector containing the frequencies of various scale degrees

Scheme of degrees vector is as follows: [1, 3, b3, 7, b7, 5, b5, #5, bb7, b9, 9, #9, 11, #11, b13, 13, #13]
Some of these degrees are restricted as follows:
  --> b3 only if NOT 3
  --> b7 only if NOT 7
  --> b5 only if NOT 3 and NOT 5 and NOT 7
  --> #5 only if NOT b3 and NOT b5 and NOT 5 and NOT b7
  --> bb7 only if b3 and b5 and NOT b7 and NOT 7
  --> #9 only if NOT b3
  --> #11 only if NOT b5
  --> b13 only if NOT #5
  --> #13 only if NOT b7
  
It is because of these restrictions that the degrees are counted in this specific order.

*/

class Interpretation {
  
  int rootIndex;  // index of the root this interpretation is based upon
  String root;  // letter of the root
  int[] degrees = new int[17];  // various scale degrees and their frequencies
  float score;  // metric used to rank interpretations against each other
  
  // construct a new interpretation
  Interpretation(int _rootIndex, String _root, int[] tones) {
    // record root index and letter
    this.rootIndex = _rootIndex;
    this.root = _root;
    
    
    // -------- interpret the chord here -------------
  }
  
  // return the score of this interpretation
  float getScore() {
    return 0.0;
  }
  
  // convert a chord interpretation to its corresponding musical name
  String getMusicalName() {
    return "";
  }
  
}
