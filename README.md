# midi-harmony-interpreter


This harmony interpreter works with MIDI input via [the Midibus library](http://www.smallbutdigital.com/projects/themidibus/) to generate interpretations for the chord quality, extensions, and root of the musical notes being played live.

## How it works
Any notes that are played into the connected MIDI instrument are recorded in a array of the twelve possible tones. This array of "active tones" records the frequency at which each note is currently being played. For instance, an active tone array of

```java
[ 
  0,  // A
  1,  // Bb
  0,  // B
  0,  // C
  1,  // Db
  0,  // D
  2,  // Eb
  0,  // E
  0,  // F
  0,  // Gb
  1,  // G
  0,  // Ab
]
```
would indicate that 2 Eb's, 1 Bb, 1 Db, and 1 G are currently being played on the MIDI instrument.

From here, this set of notes is interpreted with all 12 possible tones as the root. To do this, we assume a note is the root of this chord, and then identify the intervals between this root and the tones that are active. The intervals themselves are essentially an "interpretation" of the chord being played, and can be easily converted into a musical name (i.e. "min7").

#### Identifying Intervals

If we assumed Eb to be the root in the above example, we would get intervals of 1 (Eb), 3 (G), 5 (Bb), and b7 (Db). Should we assume another root, the intervals would be different, and thus the interpretation different.

Intervals are identified in the following specific order which gives precedence to certain intervals:
```java
1, 3, b3, 7, b7, 5, b5, #5, bb7, b9, 9, #9, 11, #11, b13, 13, #13
```

There are also certain logical constraints on which intervals can exist in the presence of other intervals, as follows:

<p align="center">
<img src="http://tcastleman.com/imgs/harmony-interpreter-constraints.png" width=50%>
</p>

When the algorithm interprets each interval, these constraints are never violated. For instance, if there is already a 3 in the interpretation, the algorithm will never interpret the note 1 semitone below this as a b3, but will instead treat it as a #9 (so as to avoid two 3rds).


#### Naming Chord Qualities

Once sets of intervals relative to each possible root have been identified, their musical names can be determined using the following tree.

<p align="center">
<img src="http://tcastleman.com/imgs/chord-quality-tree.png" width=80%>
</p>

The tree is traversed by starting at the root and proceeding to the child node whose value is an interval that is present in this interpretation, returning the current node's musical name if it is impossible to traverse to a child node. For instance, if a b7 was present, the leftmost path would be traversed, but if there were no b3 in the interpretation, then "7" would be returned as the proper chord quality.

#### Ranking Interpretations

In order to rank order the interpretations (for the purpose of determining a *most* likely interpretation), each interpretation is given a score based on the presence and absence of each interval class (e.g. all ninths, instead of distinguishing between 9, b9, and #9) as well as the presence of what are deemed to be "unlikely" extensions based on the determined chord quality. 

##### Weights
To get the initial score, a weighted sum is taken: the presence (denoted 1) or absence (denoted -1) of each interval class in the interpretation is multiplied by its weight (a parameter to the scoring system), and this is added to the sum. 

The weights themselves can be tuned to meet the specific needs of the user. For instance, if an interpreter that tends towards interpreting the input as simple, vanilla voicings is needed, the weights can be adjusted to favor chord tones (1, 3, 5, 7) and disfavor extensions. For an interpreter that tends towards rootless, extended voicings, the weights might be adjusted to favor extensions and disfavor chord tones.

These weights are defined in the `INTERVAL_WEIGHTS[]` array in `interpretation.pde`.

##### Unlikely Extensions
One point is then subtracted from the score for each extension present that is deemed "unlikely" to fit with this chord quality. These extensions are defined as follows:

```
Maj / Maj7: b9, #9, 11, b13, #13
Min / Min7: b9, #11, b13, 13
Dom 7: none
Half Dim: b9, 9, 13
Dim: b9, 9, 11, b13
Aug: b9, 11, 13
Minmaj7: b9, #11, b13, #13
Augmaj7: b9, #9, 11, 13, #13
```

### Further Reading

For a more in-depth, mathematical perspective on this algorithm, check out [An Algorithm for the Interpretation of Jazz Harmony.](http://tcastleman.com/portfolio/An_Algorithm_for_the_Interpretation_of_Jazz_Harmony.pdf)
