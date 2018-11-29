
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
  --> 13 only if NOT bb7
  --> #13 only if NOT b7
  
It is because of these restrictions that the degrees are counted in this specific order.

*/

String[] degreeNames = {"1", "3", "b3", "7", "b7", "5", "b5", "#5", "bb7", "b9", "9", "#9", "11", "#11", "b13", "13", "#13"};

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
  {},                // for 1
  {},                // for 3
  {-1},              // for b3
  {},                // for 7
  {-3},              // for b7
  {},                // for 5
  {-1, -3, -5},      // for b5
  {-2, -4, -5, -6},  // for #5
  {-3, -4, 2, 6},    // for bb7
  {},                // for b9
  {},                // for 9
  {-2},              // for #9
  {},                // for 11
  {-6},              // for #11
  {-7},              // for b13
  {-8},              // for 13
  {-4},              // for #13
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
  
  // fill out the interpretation vector for given tones based on the root this interpretation is using (modifies this.degrees)
  void generateInterVec(int rootIndex, int[] tones) {
    // for each possible degree
    for (int i = 0; i < this.degrees.length; i++) {
      int j = (rootIndex + degreeOffsets[i]) % 12;  // find what tone corresponds with this degree
      
      // if this is an active tone
      if (tones[j] > 0) {
        boolean violates = false;
        
        // for each constraint on this degree
        for (int c : constraints[i]) {
          // if fails positive or negative constraint
          if ((c < 0 && this.degrees[Math.abs(c)] != 0) || (c > 0 && this.degrees[c] == 0)) {
            violates = true;
            break;
          }
        }
        
        // if passed all constraints, accept interpretation
        if (!violates) {
          this.degrees[i] = tones[j];
        }
      }
    }
  }
  
  // convert a chord interpretation to its corresponding musical name
  String getMusicalName() {
    String name = this.root + this.getChordQuality();  // combine root with basic chord quality
    String ext = "";  // prepare to gather extensions
    
    // for the remaining extensions, simply add their degree names
    for (int i = 9; i < 17; i++) {
      if (this.degrees[i] > 0) {
        ext += " " + degreeNames[i];
      }
    }
    
    return name + ext;
  }
  
  // get the basic chord quality of this interpretation
  String getChordQuality() {
    // if has b7
    if (this.degrees[4] > 0) {
      // if has b3
      if (this.degrees[2] > 0) {
        // if has b5
        if (this.degrees[6] > 0) {
          return "-7b5";  // half diminished
        } else {
          return "-7";  // minor seventh
        }
      } else {
        return "7";  // dominant seventh
      }
      
    // otherwise if has maj7
    } else if (this.degrees[3] > 0) {
      // if has b3
      if (this.degrees[2] > 0) {
        return "-Δ7";  // minor major seventh
      } else if (this.degrees[7] > 0) {
        return "+Δ7";  // augmented major seventh
      } else {
        return "Δ7";  // major seventh
      }
      
    // otherwise if has b5
    } else if (this.degrees[6] > 0) {
      return "dim";  // diminished
    
    // otherwise if has #5
    } else if (this.degrees[7] > 0) {
      return "+";  // augmented
      
    // otherwise if has b3
    } else if (this.degrees[2] > 0) {
      return "-";  // minor
    
    // if none of these features are identified, we can't say anything specific about chord quality
    } else {
      return "";
    }
  }
  
  // return the score of this interpretation
  float getScore() {
    return 0.0;
  }
  
  
  
  
  
  // ------------- debug ----------
  
  // log interpretation vector in human-readable format
  void logInterpretation() {
    for (int i = 0; i < this.degrees.length; i++) {
      println(degreeNames[i] + ": " + this.degrees[i]);
    }
    println("");
  }
  
}
