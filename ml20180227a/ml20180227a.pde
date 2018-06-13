import javafx.scene.canvas.Canvas;
import javafx.scene.Scene;
//import javafx.stage.Stage;
import javafx.scene.layout.StackPane;
import javafx.collections.ObservableList;
import javafx.collections.FXCollections;
import javafx.scene.chart.*;
import javafx.geometry.Side;

void setup() {
  size(640, 480, FX2D);
  background(255);
  noLoop();
}

void draw() {
  pieChart();
}

void pieChart() {
  Canvas canvas = (Canvas) this.getSurface().getNative();
  Scene scene = canvas.getScene();
  //  Stage st = (Stage) s.getWindow();
  StackPane pane = (StackPane) scene.getRoot();

  ObservableList<PieChart.Data> pieChartData =
    FXCollections.observableArrayList(
    new PieChart.Data("Fat Bear", 10), 
    new PieChart.Data("Pooh San", 20), 
    new PieChart.Data("Pig", 8), 
    new PieChart.Data("Rabbit", 15), 
    new PieChart.Data("Chicken", 2));
  PieChart chart = new PieChart(pieChartData);
  chart.setTitle("Animals");
  chart.setLegendSide(Side.RIGHT);

  pane.getChildren().add(chart);
}
