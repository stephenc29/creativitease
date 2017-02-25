import oscP5.*;

OscP5 oscP5;
float x,y;
boolean toDraw;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  oscP5.plug(this,"bleep","/bleep");
   background(128); 

  x=200;
  y=200;
  toDraw=true;
}

void draw(){
  if(toDraw){
   fill(255);  
   ellipse(x, y, 55, 55);
   toDraw=false;
  }
 fill(0,20);
 rect(0,0,400,400);
}
void bleep(){
   println("Bleep"); 
   x= 100+random(200);
   y= 100+random(200);
   toDraw = true;

}