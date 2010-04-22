import syzygryd.*;
import processing.serial.*;
import processing.core.*;

DMX DMXManager;
int huetemp=0;
color colortemp, colortemp2; 
Fixture test, test2;

void setup(){
  
  /* example code*/
  size(513,789);
  colorMode(RGB);
  background(0);
  frameRate(30);
  
  //create new DMX manager object with a refresh rate of 44Hz
  DMXManager = new DMX(this, 44);
  
  //add three controllers to manager
  DMXManager.addController("COM3");
  //DMXManager.addController("COM4");
  //DMXManager.addController("COM2");

  //create a test fixture on controller 0
  test = new Fixture(DMXManager, 0, "cube");
  test2 = new Fixture(DMXManager, 0, "cube");
  
  //add RGB channels, allowing DMX manager to assign addresses 
  test.addChannel("red");
  test.addChannel("green");
  test.addChannel("blue");
  //add RGB channels with fixed address assignments 
  test2.addChannel("red", 32);
  test2.addChannel("green", 33);
  test2.addChannel("blue", 34);
  

    
  //set values for green and blue fixture channels directly
  test2.setChannel("green",200);
  test2.setChannel("blue",255);

  test.addTrait("RGBColorMixing", new RGBColorMixingTrait(test));
  test2.addTrait("RGBColorMixing", new RGBColorMixingTrait(test2));
}


/* example of a simple hue rotation on a single fixture */

void draw(){
  colorMode(HSB);
  colortemp = color(huetemp,255,255); 
  colortemp2  = color((huetemp+128)%256,255,255);
  ((RGBColorMixingTrait)test.trait("RGBColorMixing")).setColorRGB(colortemp); 
  ((RGBColorMixingTrait)test2.trait("RGBColorMixing")).setColorRGB(colortemp2); 
  huetemp++;
  huetemp %= 256;
  drawChannelGrid();
}


/* simple DMX visualization - displays grid of controller channels, values represented as grayscale levels */

void drawChannelGrid(){
  colorMode(RGB);
  textFont(createFont("arial", 8));
  for (int ctrlr = 0; ctrlr < DMXManager.controllers.size(); ctrlr++) {
    DMX.Controller ctrl = (DMX.Controller)DMXManager.controllers.get(ctrlr);
    int univSize = ctrl.universeSize();
    for (int row = 0; row <= ceil(univSize / 32); row++){
      for (int col = 0; (col < 32) && (row * 32 + col < univSize); col++){
        int val = ctrl.getChannelUnsigned(row * 32 + col);
        fill(val, 0, 0);
        stroke(255);
        rect((col*16),(row*16)+ctrlr*266,16,16);
        fill(#ffffff);
        stroke(#000000);
        textAlign(CENTER,CENTER);
        text(str(row*32+col), (col*16),(row*16)+ctrlr*266,16,16);
      }
    }
  }
}
