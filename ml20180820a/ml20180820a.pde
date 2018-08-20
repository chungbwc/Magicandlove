// Face swap example from OpenCV
import cvimage.*;
import org.opencv.core.*;
import org.opencv.core.Core;
import org.opencv.imgproc.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.face.Face;
import org.opencv.face.Facemark;
import java.util.ArrayList;

// Image size is 300 x 300.
final int W = 300, H = 300;
final float DIST = 1.0;
PImage img1, img2;
String faceFile, modelFile;
Facemark fm;
PVector offset1, offset2, origin;

public void settings() {
  size(W*3, H);
}

public void setup() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img1 = loadImage("daniel.jpg");
  img2 = loadImage("george.jpg");
  faceFile = "haarcascade_frontalface_default.xml";
  modelFile = "face_landmark_model.dat";
  fm = Face.createFacemarkKazemi();
  fm.loadModel(dataPath(modelFile));
  // Offset for display of the 3 images.
  origin = new PVector(0, 0);
  offset1 = new PVector(img1.width, 0);
  offset2 = new PVector(img1.width+img2.width, 0);
  noLoop();
}

public void draw() {
  background(0);
  swapFaces();
  saveFrame("faceswap####.png");
}

private void swapFaces() {
  CVImage cv1 = new CVImage(img1.width, img1.height);
  CVImage cv2 = new CVImage(img2.width, img2.height);
  cv1.copyTo(img1);
  cv2.copyTo(img2);
  image(img1, origin.x, origin.y);
  image(img2, offset1.x, offset1.y);

  Mat im1 = cv1.getBGR();
  Mat im2 = cv2.getBGR();

  // Source and target images with higher precision.
  Mat im1s = new Mat(im1.rows(), im1.cols(), CvType.CV_32F);
  im1.convertTo(im1s, CvType.CV_32F);
  Mat warp = im2.clone();
  warp.convertTo(warp, CvType.CV_32F);
  Rect rect = new Rect(0, 0, warp.cols(), warp.rows());

  // Face landmark of the 2 images.
  ArrayList<MatOfPoint2f> shape1 = detectFacemarks(im1);
  ArrayList<MatOfPoint2f> shape2 = detectFacemarks(im2);

  int num = min(shape1.size(), shape2.size());
  // Only 1 face in test sample
  for (int z=0; z<num; z++) {
    Point [] points1 = shape1.get(z).toArray();
    Point [] points2 = shape2.get(z).toArray();
    // Find convex hull contour of the 2nd image and obtain
    // the same points from the 1st image.
    ArrayList<Point> boundary_image1 = new ArrayList<Point>();
    ArrayList<Point> boundary_image2 = new ArrayList<Point>();
    MatOfInt index = new MatOfInt();
    Imgproc.convexHull(new MatOfPoint(points2), index, false);
    int [] idx = index.toArray();
    for (int i=0; i<idx.length; i++) {
      boundary_image1.add(points1[idx[i]]);
      boundary_image2.add(points2[idx[i]]);
    }
    // Find the Delaunay triangulation from the 2nd image and
    // corresponding triangles from the 1st image.
    ArrayList<int []> triangles = getTriangles(rect, boundary_image2);
    for (int i=0; i<triangles.size(); i++) {
      ArrayList<Point> triangle1 = new ArrayList<Point>();
      ArrayList<Point> triangle2 = new ArrayList<Point>();
      int [] triangle = triangles.get(i);
      for (int j=0; j<3; j++) {
        triangle1.add(boundary_image1.get(triangle[j]));
        triangle2.add(boundary_image2.get(triangle[j]));
      }
      // Draw the triangle for the 1st image.
      pushStyle();
      noFill();
      stroke(255);
      beginShape();
      for (Point p : triangle1) {
        vertex((float)p.x, (float)p.y);
      }
      endShape(CLOSE);
      // Draw the triangle for the 2nd image.
      beginShape();
      for (Point p : triangle2) {
        vertex((float)p.x+offset1.x, (float)p.y+offset1.y);
      }
      endShape(CLOSE);
      popStyle();
      // Warp each triangle from source image to target image.
      warp = warpTriangle(im1s, warp, triangle1, triangle2);
    }
    warp.convertTo(warp, CvType.CV_8UC3);
    CVImage last = new CVImage(warp.cols(), warp.rows());
    last.copyTo(warp);
    image(last, offset2.x, offset2.y);
  }
  im1.release();
  im2.release();
  warp.release();
  im1s.release();
}

private Mat warpTriangle(Mat i, Mat o, ArrayList<Point> t1, ArrayList<Point> t2) {
  MatOfPoint m1 = new MatOfPoint();
  MatOfPoint m2 = new MatOfPoint();
  m1.fromList(t1);
  m2.fromList(t2);
  Rect rect1 = Imgproc.boundingRect(m1);
  Rect rect2 = Imgproc.boundingRect(m2);
  ArrayList<Point> triangle1Rect = new ArrayList<Point>();
  ArrayList<Point> triangle2Rect = new ArrayList<Point>();
  ArrayList<Point> triangle2RectInt = new ArrayList<Point>();
  for (int j=0; j<3; j++) {
    triangle1Rect.add(new Point(t1.get(j).x - rect1.x, 
      t1.get(j).y - rect1.y));
    triangle2Rect.add(new Point(t2.get(j).x - rect2.x, 
      t2.get(j).y - rect2.y));
    triangle2RectInt.add(new Point((int)(t2.get(j).x - rect2.x), 
      (int)(t2.get(j).y - rect2.y)));
  }
  Mat mask = Mat.zeros(rect2.height, rect2.width, CvType.CV_32FC3);
  MatOfPoint tmp = new MatOfPoint();
  tmp.fromList(triangle2RectInt);
  Imgproc.fillConvexPoly(mask, tmp, new Scalar(1.0, 1.0, 1.0), 16, 0);
  Mat img1Rect = i.submat(rect1);
  Mat img2Rect = Mat.zeros(rect2.height, rect2.width, img1Rect.type());
  MatOfPoint mm1 = new MatOfPoint();
  MatOfPoint mm2 = new MatOfPoint();
  mm1.fromList(triangle1Rect);
  mm2.fromList(triangle2Rect);
  Mat warp_mat = Imgproc.getAffineTransform(new MatOfPoint2f(mm1.toArray()), 
    new MatOfPoint2f(mm2.toArray()));
  Imgproc.warpAffine(img1Rect, img2Rect, warp_mat, img2Rect.size(), 
    Imgproc.INTER_LINEAR, Core.BORDER_REFLECT_101, Scalar.all(0));
  Core.multiply(img2Rect, mask, img2Rect);
  Mat tmp1 = new Mat(mask.size(), mask.type(), Scalar.all(1.0));
  Core.subtract(tmp1, mask, tmp1);
  Mat tOut = o.clone();
  Mat tmp2 = tOut.submat(rect2);
  Core.multiply(tmp2, tmp1, tmp2);
  Core.add(tmp2, img2Rect, tmp2);
  m1.release();
  m2.release();
  mm1.release();
  mm2.release();
  warp_mat.release();
  tmp.release();
  tmp1.release();
  tmp2.release();
  img1Rect.release();
  img2Rect.release();
  return tOut;
}

private ArrayList<int []> getTriangles(Rect r, ArrayList<Point> pts) {
  // Construct the Delaunay triangles from the list of Point in pts.
  // Result is in the list of 3 indices of the vertex.
  ArrayList<int []> tri = new ArrayList<int []>();
  Subdiv2D subdiv = new Subdiv2D(r);
  for (Point p : pts) {
    if (r.contains(p)) 
      subdiv.insert(p);
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
        for (int k=0; k<pts.size(); k++) 
          if (abs((float)(pt[j].x - pts.get(k).x)) < DIST &&
            abs((float)(pt[j].y - pts.get(k).y)) < DIST)
            ind[j] = (int) k;
      tri.add(ind);
    }
  }
  return tri;
}

private ArrayList<MatOfPoint2f> detectFacemarks(Mat i) {
  // Detect face landmark from an Mat image.
  ArrayList<MatOfPoint2f> shapes = new ArrayList<MatOfPoint2f>();
  MatOfRect faces = new MatOfRect();
  Face.getFacesHAAR(i, faces, dataPath(faceFile)); 
  if (!faces.empty()) {
    fm.fit(i, faces, shapes);
  }
  faces.release();
  return shapes;
}
