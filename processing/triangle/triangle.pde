import oscP5.*;

OscP5 oscP5;
PGraphics layer1;
int width = 1200, height = 900;

void setup() {
  size(1200, 900);
  background(0);
  oscP5 = new OscP5(this, 12000);
  oscP5.plug(this, "triangle", "/triangle");
  oscP5.plug(this, "circle", "/circle");
  layer1 = createGraphics(width, height);
}

void draw() {
  layer1.beginDraw();
  layer1.fill(0, 2);
  layer1.rect(0, 0, width, height);
  layer1.endDraw();
  image(layer1, 0, 0);

}

void triangle() {
  println("Drawing triangle");
  layer1.beginDraw();

  layer1.fill(random(255), random(255), random(255), 100);
  layer1.triangle( random(width), random(height), random(width), random(height), random(width), random(height));
  layer1.endDraw();
}

void circle() {
  println("Drawing circle");
  layer1.beginDraw();
  float radius = random(height)/2;
  layer1.fill(210,100);
  layer1.ellipse(width/2, height/2, radius, radius );
  layer1.endDraw();
}