import org.apache.commons.math3.complex.*;
import org.apache.commons.math3.transform.*;
import java.io.*;

boolean isDown;
boolean never;
boolean circles;
ArrayList<Integer> xs;
ArrayList<Integer> ys;
float size;
float totalDistance;
float averageDistance;
double[] xsa;
double[] ysa;
FastFourierTransformer transformer;
Complex[] fxs;
Complex[] fys;
double[] mxs;
double[] mys;
double[] pxs;
double[] pys;
float time;
float[] xpoints;
float[] ypoints;
ArrayList<Float> currentLastX;
ArrayList<Float> currentLastY;

void setup() {
  noFill();
  size(1366, 768);
  background(240, 240, 240);
  frameRate(60);
  isDown = false;
  never = true;
  circles = false;
  xs = new ArrayList<Integer>();
  ys = new ArrayList<Integer>();
  totalDistance = 0;
  transformer = new FastFourierTransformer(DftNormalization.STANDARD);
  time = 0;
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
    if (time == 0) {
      clear();
      stroke(240);
      time += PI / 360;
    } else {
      clear();
      for (int i = 0; i < 2 * size; i++) {
        int index = i / 4;
        if (i % 4 < 2) {
          if (i % 4 == 0) {
            if (i == 0) {
              xpoints[i] = width / 2 + (float) mxs[index] / 2 * cos((float) (index * time - pxs[index]));
              ypoints[i] = height / 2 + (float) mxs[index] / 2 * sin((float) (index * time - pxs[index]));
            } else {
              xpoints[i] = xpoints[i - 1] + (float) mxs[index] / 2 * cos((float) (index * time - pxs[index]));
              ypoints[i] = ypoints[i - 1] + (float) mxs[index] / 2 * sin((float) (index * time - pxs[index]));
              if (index > 0) {
                line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
                ellipse(xpoints[i - 1], ypoints[i - 1], (float) mxs[index] / 2, (float) mxs[index] / 2);
              }
            }
          } else {
            xpoints[i] = xpoints[i - 1] + (float) mxs[index] / 2 * cos((float) (index * time - pxs[index]));
            ypoints[i] = ypoints[i - 1] + (float) mxs[index] / -2 * sin((float) (index * time - pxs[index]));
            if (index > 0) {
              line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
              ellipse(xpoints[i - 1], ypoints[i - 1], (float) mxs[index] / 2, (float) mxs[index] / 2);
            }
          }
        } else {
          if (i % 4 == 2) {         
            xpoints[i] = xpoints[i - 1] + (float) mys[index] / 2 * sin((float) (index * time - pys[index]));
            ypoints[i] = ypoints[i - 1] + (float) mys[index] / 2 * cos((float) (index * time - pys[index]));
            if (index > 0) {
              line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
              ellipse(xpoints[i - 1], ypoints[i - 1], (float) mys[index] / 2, (float) mys[index] / 2);
            }
          } else {
            xpoints[i] = xpoints[i - 1] + (float) mys[index] / -2 * sin((float) (index * time - pys[index]));
            ypoints[i] = ypoints[i - 1] + (float) mys[index] / 2 * cos((float) (index * time - pys[index]));
            if (index > 0) {
              line(xpoints[i - 1], ypoints[i - 1], xpoints[i], ypoints[i]);
              ellipse(xpoints[i - 1], ypoints[i - 1], (float) mys[index] / 2, (float) mys[index] / 2);
            }
          }
        }
      }
      currentLastX.add(xpoints[xpoints.length - 1]);
      currentLastY.add(ypoints[ypoints.length - 1]);
      for (int i = 0; i < currentLastX.size() - 1; i++) {
        line(currentLastX.get(i), currentLastY.get(i), currentLastX.get(i + 1), currentLastY.get(i + 1));
      }
      time += PI / 60;
    }
  }
}

void mousePressed() {
  if (!isDown) {
    if (never) {
      isDown = true;
    } else {
      circles = true;
    }
  } else {
    never = false;
    isDown = false;
    println(splitDrawing() + "\n");
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
    mxs[i] = fxs[i].abs() / size;
    mys[i] = fys[i].abs() / size;
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
  String formula = "";
  formula += "(";
  for (int i = 0; i < size / 2; i++) {
    if (mxs[i] != 0) {
      formula += mxs[i] + "cos(" + i + "t - " + pxs[i] + ") + ";
    }
  }
  formula += "0, -(";
  for (int i = 0; i < size / 2; i++) {
    if (mys[i] != 0) {
      formula += mys[i] + "cos(" + i + "t - " + pys[i] + ") + ";
    }
  }
  formula += "0))";
  return formula;
}
