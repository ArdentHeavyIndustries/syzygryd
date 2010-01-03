import codeanticode.prodmx.*;
import processing.serial.*;

DMX dmx;

void setup() {
  size(200, 200);
  String portName = Serial.list()[0];
  dmx = new DMX(this, portName, 115200, 32);
}

void draw() {
  dmx.setDMXChannel(0, (int)map(mouseX, 0, width, 0, 255));  
}


