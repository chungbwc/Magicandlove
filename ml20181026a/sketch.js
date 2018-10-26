const con = require('electron').remote.getGlobal('console');
const cv = require('../libs/opencv')

var canvas;
var capture;
var pg;

function setup() {
    canvas = createCanvas(window.innerWidth, window.innerHeight);
    canvas.canvas.style.display = "block";
    pg = createGraphics(width, height);
    background(0);
 
    capture = createCapture(VIDEO);
    capture.size(width, height);
    capture.hide();
}

function draw() {
    background(0);
    pg.image(capture, 0, 0);
    var mat = cv.imread(pg.canvas);
    cv.cvtColor(mat, mat, cv.COLOR_RGBA2GRAY);
    cv.blur(mat, mat, new cv.Size(3,3), new cv.Point(-1,-1), cv.BORDER_DEFAULT);
    cv.Canny(mat, mat, 50, 100, 3, false);
    cv.imshow(canvas.canvas, mat);
    mat.delete();
}

function println(s) {
    con.log(s);
}
