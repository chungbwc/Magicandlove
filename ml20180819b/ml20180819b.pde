import cvimage.*;
import org.opencv.core.*;
import org.opencv.core.Core;
import org.opencv.imgproc.*;
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
  Rect rect1 = new Rect(0, 0, img1.width, img1.height);
  Rect rect2 = new Rect(0, 0, img2.width, img2.height);
  ArrayList<MatOfPoint2f> shapes = detectFacemarks(img1);
  PVector origin = new PVector(0, 0);
  for (MatOfPoint2f sh : shapes) {
    Point [] pts = sh.toArray();
    ArrayList<Point> hull = findBoundary(pts);
    ArrayList<int []> triangles = findTriangles(rect1, hull);
    drawTriangles(triangles, hull, origin);
  }
  image(img2, offset.x, offset.y);
  shapes.clear();
  shapes = detectFacemarks(img2);
  for (MatOfPoint2f sh : shapes) {
    Point [] pts = sh.toArray();
    ArrayList<Point> hull = findBoundary(pts);
    ArrayList<int []> triangles = findTriangles(rect2, hull);
    drawTriangles(triangles, hull, offset);
  }
  saveFrame("face####.png");
}

private void drawTriangles(ArrayList<int []> t, ArrayList<Point> p, PVector o) {
  pushStyle();
  noFill();
  stroke(255);
  for (int [] tri : t) {
    beginShape();
    for (int i=0; i<3; i++) {
      Point pt = p.get(tri[i]);
      vertex((float)pt.x+o.x, (float)pt.y+o.y);
    }
    endShape(CLOSE);
  }
  popStyle();
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

private ArrayList<int []> findTriangles(Rect r, ArrayList<Point> p) {
  ArrayList<int []> tri = new ArrayList<int []>();
  Subdiv2D subdiv = new Subdiv2D(r);
  for (Point pt : p) {
    if (r.contains(pt)) 
      subdiv.insert(pt);
  }
  MatOfFloat6 triangleList = new MatOfFloat6();
  subdiv.getTriangleList(triangleList);
  float [] triangleArray = triangleList.toArray();

  for (int i=0; i<triangleArray.length; i+=6) {
    Point [] pt = new Point[3];
    int [] ind = new int[3];
    pt[0] = new Point(triangleArray[i], triangleArray[i+1]);
    pt[1] = new Point(triangleArray[i+2], triangleArray[i+3]);
    pt[2] = new Point(triangleArray[i+4], triangleArray[i+5]);
    if (r.contains(pt[0]) &&
      r.contains(pt[1]) &&
      r.contains(pt[2])) {
      for (int j=0; j<3; j++) 
        for (int k=0; k<p.size(); k++) 
          if (abs((float)(pt[j].x - p.get(k).x)) < 1.0 &&
            abs((float)(pt[j].y - p.get(k).y)) < 1.0)
            ind[j] = (int) k;
      tri.add(ind);
    }
  }
  triangleList.release();
  return tri;
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
