import cvimage.*;
import org.opencv.core.*;
import org.opencv.core.Core;
import org.opencv.face.Face;
import org.opencv.face.Facemark;
//import org.opencv.face.EigenFaceRecognizer;

final int W = 300, H = 300;

PImage img1, img2;
String faceFile, modelFile;
//EigenFaceRecognizer fr;
Facemark fm;
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
  modelFile = "face_landmark_model.dat";
  fm = Face.createFacemarkKazemi();
  fm.loadModel(dataPath(modelFile));
  offset = new PVector(img1.width, 0);
  noLoop();
}

public void draw() {
  background(0);
  image(img1, 0, 0);
  ArrayList<MatOfPoint2f> shapes = detectFacemarks(img1);
  PVector origin = new PVector(0, 0);
  for (MatOfPoint2f sh : shapes) {
    Point [] pts = sh.toArray();
    ArrayList<Point> hull = findBoundary(pts);
    drawBoundary(hull, origin);
  }
  image(img2, offset.x, offset.y);
  shapes.clear();
  shapes = detectFacemarks(img2);
  for (MatOfPoint2f sh : shapes) {
    Point [] pts = sh.toArray();
    ArrayList<Point> hull = findBoundary(pts);
    drawBoundary(hull, offset);
  }
  saveFrame("face####.png");
}

private ArrayList<Point> findBoundary(Point [] p) {
  ArrayList<Point> boundary = new ArrayList<Point>();
  MatOfInt index = new MatOfInt();
  Imgproc.convexHull(new MatOfPoint(p), index, false);
  int [] idx = index.toArray();
  for (int i=0; i<idx.length; i++) {
    boundary.add(p[idx[i]]);
  }
  index.release();
  return boundary;
}

private void drawBoundary(ArrayList<Point> p, PVector o) {
  pushStyle();
  noFill();
  stroke(255);
  beginShape();
  for (int i=0; i<p.size(); i++) {
    Point pt = p.get(i);
    vertex((float)pt.x + o.x, (float)pt.y + o.y);
  }
  endShape(CLOSE);
  popStyle();
}

private ArrayList<MatOfPoint2f> detectFacemarks(PImage i) {
  ArrayList<MatOfPoint2f> shapes = new ArrayList<MatOfPoint2f>();
  CVImage im = new CVImage(i.width, i.height);
  im.copyTo(i);
  MatOfRect faces = new MatOfRect();
  Face.getFacesHAAR(im.getBGR(), faces, dataPath(faceFile)); 
  if (!faces.empty()) {
    fm.fit(im.getBGR(), faces, shapes);
  }
  faces.release();
  return shapes;
}
