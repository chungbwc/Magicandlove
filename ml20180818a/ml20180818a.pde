// Detect face of 2 images with 
// Haarcascade file.
import cvimage.*;
import org.opencv.core.*;
import org.opencv.core.Core;
import org.opencv.face.Face;

final int W = 300, H = 300;

PImage img1, img2;
String faceFile;
PVector offset;

public void settings() {
  size(W*2, H);
}

public void setup() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img1 = loadImage("george.jpg");
  img2 = loadImage("daniel.jpg");
  faceFile = "haarcascade_frontalface_default.xml";
  offset = new PVector(img1.width, 0);
  noLoop();
}

public void draw() {
  background(0);
  image(img1, 0, 0);
  MatOfRect faces = detectFace(img1);
  drawFaceRect(faces, new PVector(0, 0));
  image(img2, offset.x, offset.y);
  faces = detectFace(img2);
  drawFaceRect(faces, offset);
  faces.release();
}

private MatOfRect detectFace(PImage i) {
  CVImage im = new CVImage(i.width, i.height);
  im.copyTo(i);
  MatOfRect faces = new MatOfRect();
  Face.getFacesHAAR(im.getBGR(), faces, dataPath(faceFile)); 
  return faces;
}

private void drawFaceRect(MatOfRect f, PVector o) {
  Rect [] rArray = f.toArray();
  pushStyle();
  noFill();
  stroke(255);
  for (Rect r : rArray) {
    rect((float)r.x+o.x, (float)r.y+o.y, (float)r.width, (float)r.height);
  }
  popStyle();
}
