import org.apache.commons.math3.complex.*;
import org.apache.commons.math3.transform.*;

boolean isDown, circles, writeFormula;
float size, totalDistance, averageDistance, maxTime, time;
float[] xpoints, ypoints;
double[] xsa, ysa, mxs, mys, pxs, pys, xdxs, ydxs;
Complex[] fxs, fys;
FastFourierTransformer transformer;
ArrayList<Integer> xs, ys;
ArrayList<ArrayList<Integer>> xss, yss;
ArrayList<CircleSet> csa;
ArrayList<Float> currentLastX, currentLastY;
PrintWriter sw;

void setup() {
  noFill();
  size(1366, 768); // change this to match size that is most convenient for your screen
  background(240, 240, 240);
  frameRate(60); // change this to adjust frame rate WHILE YOU ARE DRAWING
  isDown = false;
  circles = false;
  sw = createWriter("formula.txt");
  xs = new ArrayList<Integer>();
  ys = new ArrayList<Integer>();
  csa = new ArrayList<CircleSet>();
  writeFormula = false; // change this to decide whether to put formulas on text file or not;
}

void draw() {
  if (circles) {
    clear();
    for (CircleSet a : csa) {
      a.drawCircles();
    }
  } else {
    if (isDown) {
      if (xs.size() > 0) {
        line(xs.get(xs.size() - 1) + width / 2, ys.get(ys.size() - 1) + height / 2, mouseX, mouseY);
      }
      xs.add(mouseX - width / 2);
      ys.add(mouseY - height / 2);
    }
  }
}

void mousePressed() {
  if (!circles) {
    if (isDown) {
      isDown = false;
      ArrayList<Integer> xss = new ArrayList<Integer>();
      ArrayList<Integer> yss = new ArrayList<Integer>();
      for (int i = 0; i < xs.size(); i++) {
        xss.add(xs.get(i));
        yss.add(ys.get(i));
      }
      CircleSet cs = new CircleSet(xss, yss, 180, true, writeFormula); // the third and fourth values can be changed to alter level of detail or whether circles are drawn or rotating vectors respectively
      csa.add(cs);
    } else {
      isDown = true;
      xs.clear();
      ys.clear();
    }
  }
}

void keyPressed() {
  if ((key == ' ') && (!circles)) {
    circles = true;
    isDown = false;
    for (CircleSet a : csa) {
      sw.print(a.splitDrawing());
    }
    if (!writeFormula) {
      sw.println("This is the text file that will be overwritten with the formula for the drawing every time * PI / maxTime the program runs. The formula is in the form (x(t), y(t)) and is the kind of thing you can copy/paste into Desmos or some other graphing calculator (make sure the bounds for t are at least 2pi apart else you won't get the full graph of the drawing).");
    }
    sw.flush();
    sw.close();
  }
}
