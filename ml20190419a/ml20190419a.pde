import javax.sound.midi.MidiSystem;
import javax.sound.midi.Sequence;
import javax.sound.midi.Sequencer;
import javax.sound.midi.Soundbank;
import javax.sound.midi.Synthesizer;
import java.io.File;
import java.io.FilenameFilter;

Sequencer player;
String sbFile;
long duration;
PFont font;
File [] files;
int idx;

public void settings() {
  size(640, 480);
}

public void setup() {
  background(0);
  font = loadFont("SansSerif-24.vlw");
  textFont(font, 24);
  sbFile = "MuseScore_General.sf3";
  File dir = new File(dataPath(""));
  files = dir.listFiles(new FilenameFilter() {
    @Override
      public boolean accept(File f, String n) {
      return n.endsWith(".mid");
    }
  }
  );
  printArray(files);
  idx = 0;
  setupMidi();
  midiPlay(files[idx]);
}

private void setupMidi() {
  try {
    File sb = new File(dataPath(sbFile));
    Soundbank soundbank = MidiSystem.getSoundbank(sb);
    Synthesizer synth = MidiSystem.getSynthesizer();
    synth.loadAllInstruments(soundbank);
    synth.open();

    player = MidiSystem.getSequencer();
    player.open();
  } 
  catch (Exception e) {
    println(e.getMessage());
  }
}

public void draw() {
  background(0);
  String msg = floor(player.getMicrosecondPosition()/1000000) + " of " + duration + " s";
  text(msg, 100, 100);
  msg = player.isRunning() ? "playing" : "stopped";
  text("Status: " + msg, 100, 150);
  text(files[idx].getName(), 100, 200);
  if (!player.isRunning()) {
    idx++;
    idx %= files.length;
    midiPlay(files[idx]);
  }
}

public void midiPlay(File f) {
  try {
    Sequence music = MidiSystem.getSequence(f);
    player.setSequence(music);
    player.start();
  } 
  catch (Exception e) {
    println(e.getMessage());
  }
  duration = floor(player.getMicrosecondLength()/1000000);
}
