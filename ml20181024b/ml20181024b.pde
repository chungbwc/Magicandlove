import org.librealsense.Context;
import org.librealsense.DeviceList;
import org.librealsense.Device;
import org.librealsense.Pipeline;
import org.librealsense.Config;
import org.librealsense.Native.Stream;
import org.librealsense.Native.Format;
import org.librealsense.Frame;
import org.librealsense.FrameList;

import java.util.List;
import java.nio.ShortBuffer;

final int W = 640, H = 480;
Context context;
Pipeline pipeline;
PImage img;
short [] sArray;

public void settings() {
  size(W, H);
}

public void setup() {
  int fps = 30;
  context = Context.create();
  DeviceList deviceList = context.queryDevices();
  List<Device> devices = deviceList.getDevices();
  Device device = devices.get(0);
  println(device.name());
  pipeline = context.createPipeline();
  Config config = Config.create();
  config.enableDevice(device);
  config.enableStream(Stream.RS2_STREAM_DEPTH, 
    0, W, H, Format.RS2_FORMAT_Z16, fps);
  pipeline.startWithConfig(config);
  img = createImage(W, H, ARGB);
  frameRate(fps);
  sArray = new short[W*H];
}

public void draw() {
  background(0);
  FrameList frames = pipeline.waitForFrames(5000);
  for (int i=0; i<frames.frameCount(); i++) {
    Frame frame = frames.frame(i);
    frame.getFrameData().asShortBuffer().get(sArray);
    for (int j=0; j<sArray.length; j++) {
      img.pixels[j] = 0xFF000000 | sArray[j];
    }
    frame.release();
  }
  img.updatePixels();
  image(img, 0, 0);
  frames.release();
}
