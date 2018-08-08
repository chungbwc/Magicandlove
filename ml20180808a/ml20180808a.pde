import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
//import org.opencv.core.Core;
import org.opencv.core.Core.MinMaxLocResult;
import org.opencv.dnn.*;
import org.opencv.core.MatOfDouble;
import java.util.*;

final int CAPW = 640, CAPH = 360;
final int W = 416, H = 416;
final float THRESH = 0.85;
private Net net;
private Capture cap;
private CVImage cv;
private String [] labels;
private ArrayList<String> names;

public void settings() {
  size(CAPW, CAPH);
}

public void setup() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  //  printArray(Capture.list());
  cap = new Capture(this, CAPW, CAPH);
  cap.start();
  cv = new CVImage(W, H);
  loadYOLO();
  getOutputsNames(net);
}

private void getOutputsNames(Net n) {
  int [] outLayers = n.getUnconnectedOutLayers().toArray();
  ArrayList<String> layers = (ArrayList)n.getLayerNames();
  names = new ArrayList<String>(outLayers.length);
  for (int i=0; i<outLayers.length; i++) {
    names.add(layers.get(outLayers[i]-1));
  }
  for (String s : names) {
    println(s);
  }
}

private void loadYOLO() {
  net = Dnn.readNetFromDarknet(dataPath("yolov3.cfg"), 
    dataPath("yolov3.weights"));

  //net.setPreferableBackend(Dnn.DNN_BACKEND_DEFAULT);
  //net.setPreferableTarget(Dnn.DNN_TARGET_OPENCL);
  String [] labelFile = loadStrings("object_detection_classes_yolov3.txt");
  labels = new String[labelFile.length];
  println("Class size: " + labelFile.length);
  for (int i=0; i<labelFile.length; i++) {
    labels[i] = trim(labelFile[i]);
    println(labels[i]);
  }
}

public void draw() {
  if (!cap.available()) 
    return;
  cap.read();
  background(0);
  cv.copy(cap, 0, 0, cap.width, cap.height, 
    0, 0, cv.width, cv.height);
  cv.copyTo();
  image(cap, 0, 0);
  Mat blob = Dnn.blobFromImage(cv.getBGR(), 1.0f/255.0f, 
    new Size(cv.width, cv.height), 
    new Scalar(0, 0, 0), true, false);
  net.setInput(blob);

  Mat result = net.forward(names.get(0));

  pushStyle();
  for (int i=0; i<result.rows(); i++) {
    Mat scores = result.row(i).colRange(5, result.cols());
    MinMaxLocResult mm = Core.minMaxLoc(scores);
    Point classIdPoint = mm.maxLoc;
    double confidence = mm.maxVal;
    if (confidence > THRESH) {
      int idx = (int)classIdPoint.x;
      int x = (int)(result.get(i, 0)[0]*cap.width);
      int y = (int)(result.get(i, 1)[0]*cap.height);
      int w = (int)(result.get(i, 2)[0]*cap.width);
      int h = (int)(result.get(i, 3)[0]*cap.height);
      noFill();
      stroke(255, 0, 0);
      rect(x-w/2.0, y-h/2.0, w, h);
      noStroke();
      fill(255, 0, 0, 200);
      rect(x-w/2.0, y-h/2.0, w, 18);
      fill(255, 255, 255);
      text(labels[idx], x+5-w/2.0, y+12-h/2.0);
    }
  }
  popStyle();
}
