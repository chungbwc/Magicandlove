public class Note {

  private final String[] NOTES = {
    "C", 
    "C#", 
    "D", 
    "D#", 
    "E", 
    "F", 
    "F#", 
    "G", 
    "G#", 
    "A", 
    "A#", 
    "B"
  };
  private String name;
  private int note;
  private int channel;
  private int octave;

  public Note(int c, int k) {
    channel = c;
    note = k;
    octave = (note / 12) - 1;
    int n = note % 12;
    name = NOTES[n];
  }

  public int getOctave() {
    return octave;
  }

  public String getNote() {
    return name;
  }

  public int getChannel() {
    return channel;
  }
}
