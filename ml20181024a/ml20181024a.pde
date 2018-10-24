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
import java.nio.IntBuffer;

final int W = 640, H = 480;
Context context;
Pipeline pipeline;
PImage img;

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
  config.enableStream(Stream.RS2_STREAM_COLOR, 
    0, W, H, Format.RS2_FORMAT_BGRA8, fps);
  pipeline.startWithConfig(config);
  img = createImage(W, H, ARGB);
  frameRate(fps);
}

public void draw() {
  background(0);
  FrameList frames = pipeline.waitForFrames(5000);
  for (int i=0; i<frames.frameCount(); i++) {
    Frame frame = frames.frame(i);
    IntBuffer iBuf = frame.getFrameData().asIntBuffer();
    iBuf.get(img.pixels);
    frame.release();
  }
  img.updatePixels();
  image(img, 0, 0);
  frames.release();
}
