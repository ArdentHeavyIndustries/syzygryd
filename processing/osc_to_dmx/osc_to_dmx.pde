/* DMX Business */
import codeanticode.prodmx.*;
import processing.serial.*;

/* Osc business */
import oscP5.*;
import netP5.*;
import processing.opengl.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

DMX dmx;

void setup(){
  
  //dmx stuff
   String portName = Serial.list()[0];
  dmx = new DMX(this, "/dev/cu.usbserial-FTSK5W77", 115200, 32);
  dmx.setDMXChannel(1, 255);  
  
    /* start oscP5, listening for incoming messages at port 8001
   * this isn't the port from touchosc, it's a port out of max.
   * max needs to  be set up to send out to this patch with a 
   * port different from the listen port for the controllers
   * if you're running it on the same machine. */
  oscP5 = new OscP5(this,8002);
  

}


void draw() {
  //this gets the current master color, and converts it from hsb to three rgb values
  color currentColor = Color.HSBtoRGB(map(buttons[0].getHue(),0,100,0,1),1,1);
  int redColor = (int)red(currentColor);
  println(redColor);
  int greenColor = (int)green(currentColor);
  println(greenColor);
  int blueColor = (int)blue(currentColor);
  println(blueColor);
  println(masterHue);
  
  dmx.setDMXChannel(2, redColor); 
    dmx.setDMXChannel(3, greenColor); 
    dmx.setDMXChannel(4, blueColor); 
    
}

class MasterHue
{
  int masterHue = 1;

  int getValue() {
    return masterHue;
  }

  void setValue(int _masterHue) {
    masterHue = _masterHue;
  }

}
