import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import org.tensorflow.DataType;
import org.tensorflow.Graph;
import org.tensorflow.Output;
import org.tensorflow.Session;
import org.tensorflow.Tensor;
import org.tensorflow.TensorFlow;
import org.tensorflow.types.UInt8;

PImage img;

public void settings() {
  size(640, 480);
}

public void setup() {
  img = loadImage("FatBear.jpg");
  noLoop();
}

public void draw() {
  background(0);
  tFlow();
  image(img, 50, 50);
}

private void tFlow() {
  String modelDir = dataPath("");
  String imageFile = dataPath("FatBear.jpg");

  byte[] graphDef = readAllBytesOrExit(Paths.get(modelDir, "tensorflow_inception_graph.pb"));
  List<String> labels = readAllLinesOrExit(Paths.get(modelDir, "imagenet_comp_graph_label_strings.txt"));
  byte[] imageBytes = readAllBytesOrExit(Paths.get(imageFile));

  Tensor<Float> image = null;
  try {
    image = constructAndExecuteGraphToNormalizeImage(imageBytes);
  } 
  catch (Exception e) {
    println(e.getMessage());
    exit();
  }
  float[] labelProbabilities = executeInceptionGraph(graphDef, image);
  int bestLabelIdx = maxIndex(labelProbabilities);
  println(String.format("BEST MATCH: %s (%.2f%% likely)", labels.get(bestLabelIdx), 
    labelProbabilities[bestLabelIdx] * 100f));
  text("Best match: " + labels.get(bestLabelIdx) + " " + 
    nfc(labelProbabilities[bestLabelIdx]*100f, 2) + "%", 
    320, 60);
}

private static Tensor<Float> constructAndExecuteGraphToNormalizeImage(byte[] imageBytes) {
  Graph g = null;
  try {
    g = new Graph();
  } 
  catch (Exception e) {
    println(e.getMessage());
    return null;
  }
  GraphBuilder b = new GraphBuilder(g);
  final int H = 224;
  final int W = 224;
  final float mean = 117f;
  final float scale = 1f;

  final Output<String> input = b.constant("input", imageBytes);
  final Output<Float> output = b
    .div(b.sub(
    b.resizeBilinear(b.expandDims(b.cast(b.decodeJpeg(input, 3), Float.class), 
    b.constant("make_batch", 0)), b.constant("size", new int[] { H, W })), 
    b.constant("mean", mean)), b.constant("scale", scale));
  Session s = null;
  try {
    s = new Session(g);
  } 
  catch (Exception e) {
    println(e.getMessage());
    return null;
  }
  return s.runner().fetch(output.op().name()).run().get(0).expect(Float.class);
}

private static float[] executeInceptionGraph(byte[] graphDef, Tensor<Float> image) {
  Graph g = null;
  try {
    g = new Graph();
  } 
  catch (Exception e) {
    println(e.getMessage());
    return null;
  }
  g.importGraphDef(graphDef);
  Session s = null;
  Tensor<Float> result = null;
  try {
    s = new Session(g);
    result = s.runner().feed("input", image).fetch("output").run().get(0)
      .expect(Float.class);
  } 
  catch (Exception e) {
    println(e.getMessage());
    return null;
  }

  final long[] rshape = result.shape();
  if (result.numDimensions() != 2 || rshape[0] != 1) {
    throw new RuntimeException(String.format(
      "Expected model to produce a [1 N] shaped tensor where N is the number of labels, instead it produced one with shape %s", 
      Arrays.toString(rshape)));
  }
  int nlabels = (int) rshape[1];
  return result.copyTo(new float[1][nlabels])[0];
}

private static int maxIndex(float[] probabilities) {
  int best = 0;
  for (int i = 1; i < probabilities.length; ++i) {
    if (probabilities[i] > probabilities[best]) {
      best = i;
    }
  }
  return best;
}

private static byte[] readAllBytesOrExit(Path path) {
  try {
    return Files.readAllBytes(path);
  } 
  catch (IOException e) {
    System.err.println("Failed to read [" + path + "]: " + e.getMessage());
    System.exit(1);
  }
  return null;
}

private static List<String> readAllLinesOrExit(Path path) {
  try {
    return Files.readAllLines(path, Charset.forName("UTF-8"));
  } 
  catch (IOException e) {
    System.err.println("Failed to read [" + path + "]: " + e.getMessage());
    System.exit(0);
  }
  return null;
}
