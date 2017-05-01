class Reed{
  private float x, y;
  private float height;
  private float width;
  private float bend;
  private float k = PI/2; // the angle when bend = 1;
  private color colour;;
  
  public Reed(float x, float y, float height, float width, color colour){
     this.x = x;
     this.y = y;
     this.height = height;
     this.width = constrain(width, 1, 10);
     this.colour = colour;
     this.bend = 0;
  }
  
  public void bend(){
    bend = 1 - (1-bend)*0.9;  
  }
  
  public void unbend(){
      bend = (1-width/100)*bend;
  }  
  
  public void draw(){
  
    float theta = bend * k / width;
    strokeWeight(width);
    stroke(colour);
    noFill();
    if(theta == 0){
        line(x, y, x, y-height);
        return;
    }
    theta = constrain(theta,0.001, PI/2);
    float r = height/theta;
    float cx = x + r;
    float cy = y;
    arc(cx, y, 2*r, 2*r, PI, PI +theta);
  }
  
  
}