
import java.util.Arrays;

/*

  interpretation.pde :: Class to store the basic information encoded by an interpretation of a given set of notes

--> the letter of the root (i.e. "D", "Ab", ...)
--> a 17-dimensional vector containing the frequencies of various intervals

Scheme of intervals vector is as follows: [1, 3, b3, 7, b7, 5, b5, #5, bb7, b9, 9, #9, 11, #11, b13, 13, #13]
Some of these intervals are restricted in their interpretation as follows:
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

It is because of these restrictions that the intervals are counted in this specific order.

*/

String[] intervalNames = {"1", "3", "b3", "7", "b7", "5", "b5", "#5", "bb7", "(b9)", "9", "(#9)", "11", "(#11)", "(b13)", "13", "(#13)"};

// the actual intervals themselves, in semitones (i.e. 4 semitones above root is expected position of major 3rd)
static final int[] intervalOffsets = {0, 4, 3, 11, 10, 7, 6, 8, 9, 1, 2, 3, 5, 6, 8, 9, 10};

/*
  The constraints encode the logical implications of choosing to interpret a certain pitch a given way
  (i.e. interpreting a pitch as a 3 implies there is no b3 -- this would have to be interpreted as a #9)
  
  Here, each subarray represents the constraints for a given interval. The contents of the subarray are indices of previous intervals, whose 
  values have an effect on the interpretation of this note. 
  
  Negative indices indicate that this interval should not be used in the interpretation if any of the intervals at the listed negative indices have been
  included in the interpretation. (i.e. do not include a b7 in the interpretation if a maj 7 has already been identified--there can only be one 7)
  
  Positive indices indicate that this interval should not be used in the interpretation if any of the intervals at the listed positive indices have NOT been
  included in the interpretation. (i.e. a bb7 requires the full rest of the diminished chord (b3 and b5) to be interpreted as such and not otherwise as a 13)
*/
static final int[][] constraints = {
  {},                // for 1
  {},                // for 3
  {-1},              // for b3
  {},                // for 7
  {-3},              // for b7
  {},                // for 5
  {-1, -3, -5, 2},   // for b5
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

// encodes the indices of extensions that are unlikely to occur over each chord quality (used to rank interpretations)
int[][] unlikelyExtensions = {
  {9, 11, 12, 14, 16},  // maj / maj7: b9, #9, 11, b13, #13
  {9, 13, 14, 15},      // min / min7: b9, #11, b13, 13
  {},                   // dominant 7: none
  {9, 10, 15},          // -7b5: b9, 9, 13
  {9, 10, 12, 14},      // dim: b9, 9, 11, b13
  {9, 12, 15},          // aug: b9, 11, 13
  {9, 13, 14, 16},      // minmaj7: b9, #11, b13, #13
  {9, 11, 12, 15, 16}   // augmaj7: b9, #9, 11, 13, #13
};

// This is how scoring works.
// INTERVAL_WEIGHTS assigns weights to the relative importance of each interval's presence in an interpretation
float[] INTERVAL_WEIGHTS = {
  -0.25,    // root weight
  1,    // third weight
  0.25,    // fifth weight
  1,    // seventh weight
  0.5,    // ninth weight
  0.5,    // eleventh weight
  0.5     // thirteenth weight
};

// convert an index in this.intervals to an index in {1, 3, 5, ...}
int convertIntervalIndex(int i) {
  // third
  if (i == 1 || i == 2) {
    return 1;
    
  // fifth
  } else if (i >= 5 && i <= 7) {
    return 2;
    
  // seventh
  } else if (i == 3 || i == 4 || i == 8) {
    return 3;
  
  // ninth
  } else if (i >= 9 && i <= 11) {
    return 4;
  
  // eleventh
  } else if (i == 12 || i == 13) {
    return 5;
    
  // thirteenth
  } else if (i >= 14 && i <= 16) {
    return 6;
    
  // root
  } else {
    return 0;
  }
}

class Interpretation {
  
  String root;  // letter of the root
  int[] intervals = new int[17];  // various intervals and their frequencies
  String chordQuality;  // i.e. "maj7", "dim"
  float score;  // metric used to rank interpretations against each other
  
  // construct a new interpretation
  Interpretation(String _root, int rootIndex, int[] tones) {
    // record root letter
    this.root = _root;
    
    // interpret the chord here
    this.generateInterVec(rootIndex, tones);
  }
  
  // fill out the interpretation vector for given tones based on the root this interpretation is using (modifies this.intervals)
  void generateInterVec(int rootIndex, int[] tones) {
    // for each possible degree
    for (int i = 0; i < this.intervals.length; i++) {
      int j = (rootIndex + intervalOffsets[i]) % 12;  // find what tone corresponds with this degree
      
      // if this is an active tone
      if (tones[j] > 0) {
        boolean violates = false;
        
        // for each constraint on this degree
        for (int c : constraints[i]) {
          // if fails positive or negative constraint
          if ((c < 0 && this.intervals[Math.abs(c)] != 0) || (c > 0 && this.intervals[c] == 0)) {
            violates = true;
            break;
          }
        }
        
        // if passed all constraints, accept interpretation
        if (!violates) {
          this.intervals[i] = tones[j];
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
      if (this.intervals[i] > 0) {
        ext += " " + intervalNames[i];
      }
    }

    return name + ext;
  }
  
  // get the basic chord quality of this interpretation
  String getChordQuality() {
    if (this.chordQuality == null) {
      // if has b7
      if (this.intervals[4] > 0) {
        // if has b3
        if (this.intervals[2] > 0) {
          // if has b5
          if (this.intervals[6] > 0) {
            this.chordQuality = "-7b5";  // half diminished
          } else {
            this.chordQuality = "-7";  // minor seventh
          }
        } else {
          this.chordQuality = "7";  // dominant seventh
        }
        
      // otherwise if has maj7
      } else if (this.intervals[3] > 0) {
        // if has b3
        if (this.intervals[2] > 0) {
          this.chordQuality = "-Δ7";  // minor major seventh
        } else if (this.intervals[7] > 0) {
          this.chordQuality = "+Δ7";  // augmented major seventh
        } else {
          this.chordQuality = "Δ7";  // major seventh
        }
        
      // otherwise if has b5
      } else if (this.intervals[6] > 0) {
        this.chordQuality = "dim";  // diminished
      
      // otherwise if has #5
      } else if (this.intervals[7] > 0) {
        this.chordQuality = "+";  // augmented
        
      // otherwise if has b3
      } else if (this.intervals[2] > 0) {
        this.chordQuality = "-";  // minor
      
      // if none of these features are identified, we can't say anything specific about chord quality
      } else {
        this.chordQuality = "";
      }
    }
    
    return this.chordQuality;
  }
  
  // return the score of this interpretation
  float getScore() {
    this.score = 0;
    
    // start determining interval presences by assuming all intervals are absent (represented by -1)
    int[] intervalPresences = new int[7];
    Arrays.fill(intervalPresences, -1);
    
    // determine whether or not each interval is present
    for (int i = 0; i < this.intervals.length; i++) {
      if (this.intervals[i] > 0) {
        intervalPresences[convertIntervalIndex(i)] = 1;
      }
    }
    
    // take weighted sum of interval presences as score
    for (int i = 0; i < intervalPresences.length; i++) {
      this.score += INTERVAL_WEIGHTS[i] * intervalPresences[i];
    }
    
    // get the index to find out which extensions are unlikely to occur on this chord
    int qualityIndex = 0;
    switch (this.getChordQuality()) {
      case "":      qualityIndex = 0; break;
      case "Δ7":    qualityIndex = 0; break;
      case "-":     qualityIndex = 1; break;
      case "-7":    qualityIndex = 1; break; 
      case "7":     qualityIndex = 2; break;
      case "-7b5":  qualityIndex = 3; break;
      case "dim":   qualityIndex = 4; break;
      case "+":     qualityIndex = 5; break;
      case "-Δ7":   qualityIndex = 6; break;
      case "+Δ7":   qualityIndex = 7; break;
    }
    
    int[] ext = unlikelyExtensions[qualityIndex];  // get the unlikely extensions for this chord quality
    
    // subtract one for every unlikely extension that appears in this interpretation
    for (int i = 0; i < ext.length; i++) {
      if (this.intervals[ext[i]] > 0) {
        this.score--;
      }
    }
    
    return this.score;
  }

}
