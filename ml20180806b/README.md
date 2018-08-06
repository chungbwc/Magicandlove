To run this Processing program, please download the following files from the Caffe model into the **data** folder.

[openpose_pose_coco.prototxt](https://raw.githubusercontent.com/opencv/opencv_extra/master/testdata/dnn/openpose_pose_coco.prototxt)

[pose_iter_440000.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/coco/pose_iter_440000.caffemodel)


The program will not have real time performance in pure CPU implementation. It also assumes the default webcam size is 640 x 360. Modify it if the webcam setting is not the same. Please also download [CVImage](http://www.magicandlove.com/blog/2018/07/20/opencv-3-4-2-java-build/) for OpenCV 3.4.2 for use. You can install it properly as Processing library or put the files into the **code** folder for temporary testing.