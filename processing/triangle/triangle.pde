import oscP5.*;
import java.util.*;

OscP5 oscP5;
ArrayList<OscMessage> oscMessages = new ArrayList<OscMessage>();


void setup() {
  size(400, 400);
  background(0);
  oscP5 = new OscP5(this, 12000);
}

void draw() {
  fill(0, 10);
  rect(0, 0, 400, 400);
  synchronized(oscMessages) {
    Iterator<OscMessage> it = oscMessages.iterator();
    while (it.hasNext()) {
      OscMessage msg = it.next();
      String pattern = msg.addrPattern(); 
      switch(pattern) {
      case "/triangle":
        triangle();
        break;

      default:
        println("Did not recognise OSC message  pattern " + pattern);
      }
      it.remove();
    }
  }
}

void triangle() {
  fill(random(255), random(255), random(255));
  triangle( random(400), random(400), random(400), random(400), random(400), random(400));
}

void oscEvent(OscMessage theOscMessage) {
  synchronized(oscMessages){
    oscMessages.add(theOscMessage);
  }
}