~some random ultralight hackup with more pink~
Supported Version(s): StepMania 5 Beta 3
Last Update: July 5th 2014
====================================

Known Issues:

When outright missing a hold/freeze note (no NG), the total number of holds that have been played so far will not match the actual number of holds played, 
resulting in score discrepancies with the average score and the actual score.
- The number of holds played will be forced to update to the number displayed in the groove radar as a temporary solution. 
(However, this causes the average score to drop for a moment if the last note happens to be a hold note, but the ending score should be the same.)
- This will be fixed in the next stepmania release as HMS_Missed lua bindings have been added after beta3.

The final score shows up as a AAA anyway after hitting a mine while the scoregraph shows otherwise:
- Stepmania 5 (for some reason) unlike 3.9, awards AAA score even when mines are hit. The DP score however, will still drop (by 8 on default) resulting in the discrepancy.

BPM Display ingame does not accout for haste mods:
- Will be fixed in the next stepmania release when GetTrueBPS() function becomes available.

2P and other game modes don't work
- oop. (it might run but 2P support is the last thing on my todo list atm)



FAQ:

How to setup ingame speed change:
The speed up/down are each mapped to <EffectUp> and <EffectDown> respectively. Map those keys in config key/joy mappings.

Speedmods do not load from speedmods.txt:
The speedmods are no longer loaded from that file as it is replaced by jousway's speedmod system.



more to be added later o/~