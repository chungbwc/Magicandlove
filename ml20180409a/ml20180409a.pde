import processing.video.*;
import java.awt.image.BufferedImage;
import org.jcodec.api.awt.AWTSequenceEncoder;

Capture cap;
AWTSequenceEncoder enc;

public void settings() {
  size(640, 480);
}

public void setup() {
  cap = new Capture(this, width, height);
  cap.start();
  String fName = "recording.mp4";
  enc = null;
  try {
    enc = AWTSequenceEncoder.createSequenceEncoder(new File(dataPath(fName)), 25);
  } 
  catch (IOException e) {
    println(e.getMessage());
  }
}

public void draw() {
  image(cap, 0, 0);
}

public void captureEvent(Capture c) {
  c.read();
}

private void saveVideo(BufferedImage i) {
  try {
    enc.encodeImage(i);
  } 
  catch (IOException e) {
    println(e.getMessage());
  }
}

public void mousePressed() {
  saveVideo((BufferedImage) this.getGraphics().getImage());
}

public void exit() {
  try {
    enc.finish();
  } 
  catch (IOException e) {
    println(e.getMessage());
  }
  super.exit();
}
