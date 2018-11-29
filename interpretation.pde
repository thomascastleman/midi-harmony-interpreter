
/*

  interpretation.pde :: Class to store the basic information encoded by an interpretation of a given set of notes

--> the letter of the root (i.e. "D", "Ab", ...)
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

// the required shift from the root to get to the corresponding degree (i.e. 4 semitones above root is expected position of major 3rd)
static final int[] degreeOffsets = {0, 4, 3, 11, 10, 7, 6, 8, 9, 1, 2, 3, 5, 6, 8, 9, 10};

/*
  The constraints encode the logical implications of choosing to interpret a certain pitch a given way
  (i.e. interpreting a pitch as a 3 implies there is no b3 -- this would have to be interpreted as a #9)
  
  Here, each subarray represents the constraints for a given degree. The contents of the subarray are indices of previous degrees, whose 
  values have an effect on the interpretation of this degree. 
  
  Negative indices indicate that this degree should not be used in the interpretation if any of the degrees at the listed negative indices have been
  included in the interpretation. (i.e. do not include a b7 in the interpretation if a maj 7 has already been identified--there can only be one 7)
  
  Positive indices indicate that this degree should not be used in the interpretation if any of the degrees at the listed positive indices have NOT been
  included in the interpretation. (i.e. a bb7 requires the full rest of the diminished chord (b3 and b5) to be interpreted as such and not otherwise as a 13)
*/
static final int[][] constraints = {
  {},
  {},
  {-1},
  {},
  {-3},
  {},
  {-1, -3, -5},
  {-2, -4, -5, -6},
  {-3, -4, 2, 6},
  {},
  {},
  {-1},
  {},
  {-6},
  {-7},
  {},
  {-4},
};

class Interpretation {
  
  String root;  // letter of the root
  int[] degrees = new int[17];  // various scale degrees and their frequencies
  float score;  // metric used to rank interpretations against each other
  
  // construct a new interpretation
  Interpretation(String _root, int rootIndex, int[] tones) {
    // record root letter
    this.root = _root;
    
    // interpret the chord here
    this.generateInterVec(rootIndex, tones);
  }
  
  // fill out the interpretation vector for this root (modifies self.degrees)
  void generateInterVec(int rootIndex, int[] tones) {
    
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
