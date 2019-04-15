import javax.sound.midi.MidiSystem;
import javax.sound.midi.Sequence;
import javax.sound.midi.Sequencer;
import java.io.File;

Sequencer player;
String midiFile;
long duration;
PFont font;

public void settings() {
  size(640, 480);
}

public void setup() {
  background(0);
  font = loadFont("SansSerif-36.vlw");
  textFont(font, 36);
  midiFile = "Internationale.mid";
  midiPlay();
  duration = floor(player.getMicrosecondLength()/1000);
}

public void draw() {
  background(0);
  String msg = floor(player.getMicrosecondPosition()/1000) + " of " + duration + " ms";
  text(msg, 100, 150);
  msg = player.isRunning() ? "playing" : "stopped";
  text("Status: " + msg, 100, 250);
}

public void midiPlay() {
  try {
    File midi = new File(dataPath(midiFile));
    player = MidiSystem.getSequencer();
    player.open();
    Sequence music = MidiSystem.getSequence(midi);
    player.setSequence(music);
    player.start();
  } 
  catch (Exception e) {
    println(e.getMessage());
  }
}
