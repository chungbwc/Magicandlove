import javax.sound.midi.Receiver;
import javax.sound.midi.Sequencer;
import javax.sound.midi.Transmitter;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.MidiMessage;
import java.lang.reflect.Method;

public class GetMidi implements Receiver {
  private Transmitter tx;
  private PApplet parent;
  private Method setNote;

  public GetMidi(PApplet p, Sequencer s) {
    parent = p;
    try {
      setNote = parent.getClass().getMethod("setNote", 
        int.class, int.class);
      tx = s.getTransmitter();
      tx.setReceiver(this);
    } 
    catch (Exception e) {
      println(e.getMessage());
    }
  }

  @Override
    public void send(MidiMessage m, long t) {
    if (m instanceof ShortMessage) {
      ShortMessage sm = (ShortMessage) m;
      int ch = sm.getChannel();
      int cmd = sm.getCommand();
      switch (cmd) {
      case ShortMessage.NOTE_ON:
        int key = sm.getData1();
        //int vel = sm.getData2();
        setNote(ch, key);
        break;
      case ShortMessage.NOTE_OFF:
        break;
      default:
        // println("Command " + cmd);
        break;
      }
    }
  }

  public void close() {
  }
}
