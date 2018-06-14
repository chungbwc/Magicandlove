static class GraphBuilder {
  private Graph g;

  GraphBuilder(Graph g) {
    this.g = g;
  }

  Output<Float> div(Output<Float> x, Output<Float> y) {
    return binaryOp("Div", x, y);
  }

  <T> Output<T> sub(Output<T> x, Output<T> y) {
    return binaryOp("Sub", x, y);
  }

  <T> Output<Float> resizeBilinear(Output<T> images, Output<Integer> size) {
    return binaryOp3("ResizeBilinear", images, size);
  }

  <T> Output<T> expandDims(Output<T> input, Output<Integer> dim) {
    return binaryOp3("ExpandDims", input, dim);
  }

  <T, U> Output<U> cast(Output<T> value, Class<U> type) {
    DataType dtype = DataType.fromClass(type);
    return g.opBuilder("Cast", "Cast").addInput(value).setAttr("DstT", dtype).build().<U>output(0);
  }

  Output<UInt8> decodeJpeg(Output<String> contents, long channels) {
    return g.opBuilder("DecodeJpeg", "DecodeJpeg").addInput(contents).setAttr("channels", channels).build()
      .<UInt8>output(0);
  }

  <T> Output<T> constant(String name, Object value, Class<T> type) {
    Tensor<T> t = null;
    try {
      t = Tensor.create(value, type);
    } 
    catch (Exception e) {
      println(e.getMessage());
      return null;
    }
    return g.opBuilder("Const", name).setAttr("dtype", DataType.fromClass(type)).setAttr("value", t).build()
      .<T>output(0);

    //   try (Tensor<T> t = Tensor.<T>create(value, type)) {
    //     return g.opBuilder("Const", name).setAttr("dtype", DataType.fromClass(type)).setAttr("value", t).build()
    //       .<T>output(0);
    //   }
  }

  Output<String> constant(String name, byte[] value) {
    return this.constant(name, value, String.class);
  }

  Output<Integer> constant(String name, int value) {
    return this.constant(name, value, Integer.class);
  }

  Output<Integer> constant(String name, int[] value) {
    return this.constant(name, value, Integer.class);
  }

  Output<Float> constant(String name, float value) {
    return this.constant(name, value, Float.class);
  }

  private <T> Output<T> binaryOp(String type, Output<T> in1, Output<T> in2) {
    return g.opBuilder(type, type).addInput(in1).addInput(in2).build().<T>output(0);
  }

  private <T, U, V> Output<T> binaryOp3(String type, Output<U> in1, Output<V> in2) {
    return g.opBuilder(type, type).addInput(in1).addInput(in2).build().<T>output(0);
  }
}
