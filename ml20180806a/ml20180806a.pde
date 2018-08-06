import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
import org.opencv.dnn.*;
import java.util.*;

final int CAPW = 640, CAPH = 360;
final int W = 300, H = 300;
final int MAX_LABEL = 100;
private Net net;
private Capture cap;
private CVImage cv;
private String [] labels;

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
  loadTensorflow();
}

private void loadTensorflow() {
  net = Dnn.readNetFromTensorflow(dataPath("frozen_inference_graph.pb"), 
    dataPath("ssd_inception_v2_coco_2017_11_17.pbtxt"));
  //ArrayList<String> layers = (ArrayList)net.getLayerNames();
  //printArray(layers);
  //net.setPreferableBackend(Dnn.DNN_BACKEND_DEFAULT);
  //net.setPreferableTarget(Dnn.DNN_TARGET_OPENCL);
  String [] labelFile = loadStrings("mscoco_label_map.pbtxt");
  labels = new String[MAX_LABEL];
  for (int i=0; i<labelFile.length; i+=5) {
    String s1 = trim(split(labelFile[i+2], ':')[1]);
    String s2 = trim(split(labelFile[i+3], ':')[1]);
    s2 = s2.substring(1, s2.length()-1);
    int idx = parseInt(s1);
    labels[idx] = s2;
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
  Mat blob = Dnn.blobFromImage(cv.getBGR(), 1.0/127.5, 
    new Size(cv.width, cv.height), 
    new Scalar(127.5, 127.5, 127.5), true, false);
  net.setInput(blob);
  Mat tmp = net.forward().reshape(1, 1).row(0);
  Size sz = tmp.size();
  if (sz.width < 700) // 100 rows x 7
    return;
  Mat result = tmp.reshape(1, 100);

  pushStyle();
  noFill();
  stroke(255, 0, 0);
  double maxValue = Double.MIN_VALUE;
  int maxIdx = -1;
  for (int i=0; i<result.rows(); i++) {
    double [] tt = result.row(i).reshape(7, 1).get(0, 0);
    if (tt[2] > maxValue) {
      maxValue = tt[2];
      maxIdx = i;
    }
  }
  displayObject(result.row(maxIdx).reshape(7, 1).get(0, 0));

  pushStyle();
  fill(0);
  noStroke();
  text(nf(frameRate, 2, 1), 10, 20);
  popStyle();
  blob.release();
  tmp.release();
  result.release();
}

private void displayObject(double [] o) {
  pushStyle();
  int classId = (int)o[1];
  String label = labels[classId];
  float left = (float)o[3]*cap.width;
  float top = (float)o[4]*cap.height;
  float right = (float)o[5]*cap.width;
  float bottom = (float)o[6]*cap.height;
  noFill();
  stroke(255, 0, 0);
  rect(left, top, right-left, bottom-top);
  noStroke();
  fill(255, 0, 0);
  text(label, left+5, top+15);
  popStyle();
}
