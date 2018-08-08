To run this Processing program, please download the following files from the Darknet YOLO v3 model into the **data** folder.

[yolov3.cfg (YOLOv3-416)](https://github.com/pjreddie/darknet/blob/master/cfg/yolov3.cfg)

[yolov3.weights (YOLOv3-416)](https://pjreddie.com/media/files/yolov3.weights)

[object_detection_classes_yolov3.txt](https://github.com/opencv/opencv/blob/3.4.2/samples/data/dnn/object_detection_classes_yolov3.txt)


The program will not have real time performance in pure CPU implementation. It also assumes the default webcam size is 640 x 360. Modify it if the webcam setting is not the same. Please also download [CVImage](http://www.magicandlove.com/blog/2018/07/20/opencv-3-4-2-java-build/) for OpenCV 3.4.2 for use. You can install it properly as Processing library or put the files into the **code** folder for temporary testing.