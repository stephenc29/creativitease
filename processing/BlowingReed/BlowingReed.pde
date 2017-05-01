ArrayList<Reed> reedBed;
int numReeds = 100;
int maxHeight = 300;
int maxWidth = 7;

int width = 1200;
int height = 900;

void setup() {
  reedBed = new ArrayList<Reed>();
  size(1200, 900);
  background(0);
  for (int i = 0; i<numReeds; i++) {
    reedBed.add( new Reed(maxHeight+ random(width - 2*maxHeight),
    maxHeight +random(height - 2*maxHeight), 
    50 + random(maxHeight -50), 
    1+random(maxWidth-1),
    color(random(255))
    ));
  }
  frameRate(25);
}

void draw() {
  fill(0, 10);
  rect(0, 0, width, height);
  for (Reed r : reedBed) {
    r.draw();

    if (mousePressed) {
      r.bend();
    } else {
      r.unbend();
    }
  }
}