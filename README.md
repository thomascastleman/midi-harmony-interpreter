# midi-harmony-interpreter


This harmony interpreter works with MIDI input via [the Midibus library](http://www.smallbutdigital.com/projects/themidibus/) for Processing.

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
