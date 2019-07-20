import CommonsMath3.*;
boolean isDown = false;
boolean never = true;
ArrayList<int[]> coords = new ArrayList<int[]>();
int[] currentCoords = new int[2];
int maxx = 1366;
int[] xs;
int[] ys;
void setup() {
  size(1366, 768);
  background(240, 240, 240);
  frameRate(60);
}
void draw() {
  if (isDown) {
    println("lo");
    if (coords.size() > 0) {
      line(currentCoords[0], currentCoords[1], mouseX, mouseY);
    }
    currentCoords[0] = mouseX;
    currentCoords[1] = mouseY;
    coords.add(currentCoords);
  }
}
void mousePressed() {
  if (!isDown) {
    if (never) {
      isDown = true;
    }
  } else {
    never = false;
    isDown = false;
    getXY();
  }
}
void getXY() {
  xs = new int[coords.size()];
  ys = new int[coords.size()];
  for (int i = 0; i < coords.size(); i++) {
    xs[i] = coords.get(i)[0];
    ys[i] = coords.get(i)[1];
  }
}
