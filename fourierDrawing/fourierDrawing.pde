import org.apache.commons.math3.complex.*;
import org.apache.commons.math3.transform.*;

boolean isDown, never, circles, writeFormula;
float size, totalDistance, averageDistance, maxTime, time;
float[] xpoints, ypoints;
double[] xsa, ysa, mxs, mys, pxs, pys;
Complex[] fxs, fys;
FastFourierTransformer transformer;
ArrayList<Integer> xs, ys;
ArrayList<Float> currentLastX, currentLastY;
PrintWriter sw;

void setup() {
  noFill();
  size(1366, 768);
  background(240, 240, 240);
  frameRate(60); // change this to adjust frame rate WHILE YOU ARE DRAWING
  isDown = false;
  never = true;
  circles = false;
  xs = new ArrayList<Integer>();
  ys = new ArrayList<Integer>();
  totalDistance = 0;
  transformer = new FastFourierTransformer(DftNormalization.STANDARD);
  writeFormula = false; //change this to true if you want to have the parametric formula for what you frew in the the formula.txt file
  sw = createWriter("formula.txt");
  maxTime = 180; // change this to adjust level of detail of CIRCLES DRAWING
  time = 2 * maxTime;
  currentLastX = new ArrayList<Float>();
  currentLastY = new ArrayList<Float>();
}

void draw() {
  if (isDown) {
    if (xs.size() > 0) {
      line(xs.get(xs.size() - 1) + width / 2, ys.get(ys.size() - 1) + height / 2, mouseX, mouseY);
    }
    xs.add(mouseX - width / 2);
    ys.add(mouseY - height / 2);
  } else if (circles) {
    drawCircles();
  }
}

void mousePressed() {
  if (!isDown) {
    if (never) {
      isDown = true;
    } else {
      circles = true;
      frameRate(60); // change this to adjust frame rate WHILE CIRCLES ARE DRAWING (this is the speed at which circles draw, NOT the level of detail)
    }
  } else {
    never = false;
    isDown = false;
    sw.println(splitDrawing());
    sw.flush();
    sw.close();
  }
}

String splitDrawing() {
  xs.add(xs.get(0));
  ys.add(ys.get(0));
  line(xs.get(xs.size() - 2) + width / 2, ys.get(ys.size() - 2) + height / 2, xs.get(xs.size() - 1) + width / 2, ys.get(ys.size() - 1) + height / 2);
  size = pow(2, 1 + floor(log(xs.size()) / (log(2) + 1e-10)));
  xsa = new double[(int) size];
  ysa = new double[(int) size];
  mxs = new double[(int) size / 2];
  mys = new double[(int) size / 2];
  pxs = new double[(int) size / 2];
  pys = new double[(int) size / 2];
  xpoints = new float[(int) size * 2];
  ypoints = new float[(int) size * 2];
  for (int i = 0; i < xs.size() - 1; i++) {
    totalDistance += dist(xs.get(i), ys.get(i), xs.get(i + 1), ys.get(i + 1));
  }
  averageDistance = totalDistance / (size - 1);
  xsa[0] = xs.get(0);
  ysa[0] = ys.get(0);
  int lastPoint = 0;
  for (int i = 0; i < size - 1; i++) {
    float left = averageDistance;
    if (left >= dist((float) xsa[i], (float) ysa[i], xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())))) {
      left -= dist((float) xsa[i], (float) ysa[i], xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
      lastPoint++;
      while (left >= dist(xs.get((int) (lastPoint % xs.size())), ys.get((int) (lastPoint % xs.size())), xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())))) {
        left -= dist(xs.get((int) (lastPoint % xs.size())), ys.get((int) (lastPoint % xs.size())), xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
        lastPoint++;
      }
      xsa[i + 1] = xs.get((int) (lastPoint % xs.size())) + (xs.get((int) ((lastPoint + 1) % xs.size())) - xs.get((int) (lastPoint % xs.size()))) * left / dist(xs.get((int) (lastPoint % xs.size())), ys.get((int) (lastPoint % xs.size())), xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
      ysa[i + 1] = ys.get((int) (lastPoint % xs.size())) + (ys.get((int) ((lastPoint + 1) % xs.size())) - ys.get((int) (lastPoint % xs.size()))) * left / dist(xs.get((int) (lastPoint % xs.size())), ys.get((int) (lastPoint % xs.size())), xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
    } else {
      xsa[i + 1] = xsa[i] + (xs.get((int) ((lastPoint + 1) % xs.size())) - xsa[i]) * left / dist((float) xsa[i], (float) ysa[i], xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
      ysa[i + 1] = ysa[i] + (ys.get((int) ((lastPoint + 1) % xs.size())) - ysa[i]) * left / dist((float) xsa[i], (float) ysa[i], xs.get((int) ((lastPoint + 1) % xs.size())), ys.get((int) ((lastPoint + 1) % xs.size())));
    }
  }
  fxs = transformer.transform(xsa, TransformType.FORWARD);
  fys = transformer.transform(ysa, TransformType.FORWARD);
  double maxx = 0;
  double maxy = 0;
  for (int i = 0; i < size / 2; i++) {
    if (i == 0) {
      mxs[i] = fxs[i].abs() / size;
      mys[i] = fys[i].abs() / size;
    } else {
      mxs[i] = 2 * fxs[i].abs() / size;
      mys[i] = 2 * fys[i].abs() / size;
    }
    maxx = Math.max(mxs[i], maxx);
    maxy = Math.max(mys[i], maxy);
    pxs[i] = mxs[i] < 1e-4 ? 0 : atan2((float) fxs[i].getImaginary(), (float) fxs[i].getReal());
    pys[i] = mys[i] < 1e-4 ? 0 : atan2((float) fys[i].getImaginary(), (float) fys[i].getReal());
  }
  for (int i = 0; i < size / 2; i++) {
    if (mxs[i] < maxx / 1000) {
      mxs[i] = 0;
    }
    if (mys[i] < maxy / 1000) {
      mys[i] = 0;
    }
  }
  if (writeFormula) {
    String formula = "Copy and paste the following into a graphing calculator such as Desmos:\n";
    formula += "(";
    for (int i = 1; i < size / 2; i++) {
      if (mxs[i] != 0) {
        formula += mxs[i] / 100 + "cos(" + i + "t - " + pxs[i] + ") + ";
      }
    }
    formula += "0, -(";
    for (int i = 1; i < size / 2; i++) {
      if (mys[i] != 0) {
        formula += mys[i] / 100 + "cos(" + i + "t - " + pys[i] + ") + ";
      }
    }
    formula += "0))";
    return formula;
  } else {
    return "This is the text file that will be overwritten with the formula for the drawing every time * PI / maxTime the program runs. The formula is in the form (x(t), y(t)) and is the kind of thing you can copy/paste into Desmos or some other graphing calculator (make sure the bounds for t are at least 2pi apart else you won't get the full graph of the drawing).";
  }
  
}

void drawCircles() {
  clear();
  for (int i = 0; i < 2 * size; i++) {
    int index = i / 4;
    if (i % 4 == 0) {
      if (i == 0) {
        xpoints[i] = width / 2 + (float) mxs[index] / 2 * cos((float) (index * time * PI / maxTime - pxs[index]));
        ypoints[i] = height / 2 + (float) mxs[index] / 2 * sin((float) (index * time * PI / maxTime - pxs[index]));
      } else {
        xpoints[i] = xpoints[i - 1] + (float) mxs[index] / 2 * cos((float) (index * time * PI / maxTime - pxs[index]));
        ypoints[i] = ypoints[i - 1] + (float) mxs[index] / 2 * sin((float) (index * time * PI / maxTime - pxs[index]));
        if (index > 0) {
          stroke(120);
          line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
          ellipse(xpoints[i - 1], ypoints[i - 1], (float) mxs[index], (float) mxs[index]);
        }
      }
    } else if (i % 4 == 1) {
      xpoints[i] = xpoints[i - 1] + (float) mxs[index] / 2 * cos((float) (index * time * PI / maxTime - pxs[index]));
      ypoints[i] = ypoints[i - 1] + (float) mxs[index] / -2 * sin((float) (index * time * PI / maxTime - pxs[index]));
      if (index > 0) {
        stroke(120);
        line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
        ellipse(xpoints[i - 1], ypoints[i - 1], (float) mxs[index], (float) mxs[index]);
      }
    } else if (i % 4 == 2) {         
        xpoints[i] = xpoints[i - 1] + (float) mys[index] / 2 * sin((float) (index * time * PI / maxTime - pys[index]));
        ypoints[i] = ypoints[i - 1] + (float) mys[index] / 2 * cos((float) (index * time * PI / maxTime - pys[index]));
        if (index > 0) {
          stroke(120);
          line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
          ellipse(xpoints[i - 1], ypoints[i - 1], (float) mys[index], (float) mys[index]);
        }
    } else {
      xpoints[i] = xpoints[i - 1] + (float) mys[index] / -2 * sin((float) (index * time * PI / maxTime - pys[index]));
      ypoints[i] = ypoints[i - 1] + (float) mys[index] / 2 * cos((float) (index * time * PI / maxTime - pys[index]));
      if (index > 0) {
        stroke(120);
        line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
        ellipse(xpoints[i - 1], ypoints[i - 1], (float) mys[index], (float) mys[index]);
      }
    }
  }
  currentLastX.add(xpoints[xpoints.length - 1]);
  currentLastY.add(ypoints[ypoints.length - 1]);
  for (int i = 0; i < min(currentLastX.size() - 1, maxTime * 2); i++) {
    stroke(240);
    line(currentLastX.get(i), currentLastY.get(i), currentLastX.get(i + 1), currentLastY.get(i + 1));
  }
  time--;
}
