import syzygryd.*;
import processing.serial.*;
import processing.core.*;

DMX DMXManager;
int huetemp=0;
color colortemp; 
Fixture test;

void setup(){
  
  /* example code*/
  size(257,449);
  colorMode(RGB);
  background(0);
  frameRate(30);
  
  //create new DMX manager object with a refresh rate of 44Hz
  DMXManager = new DMX(this, 44);
  
  //add three controllers to manager
  DMXManager.addController("COM1");
  DMXManager.addController("COM3");
  DMXManager.addController("COM4");

  //set DMX channels directly 
  DMXManager.setChannel(0,0,(byte)255);
  DMXManager.setChannel(0,17,(byte)189);
  DMXManager.setChannel(1,511,(byte)128);
  DMXManager.setChannel(1,1,(byte)128);
  
  //create a test fixture on controller 0
  test = new Fixture(DMXManager, 0, "cube");
  
  //add red and green channels, allowing DMX manager to assign addresses 
  int redAddress = test.addChannel("red");
  print("Assigned red address = " + redAddress + "\n");
  int greenAddress = test.addChannel("green");
  print("Assigned green address = " + greenAddress + "\n");
  
  //add blue channel
  int blueAddress = test.addChannel("blue");
  print("Assigned blue address = " + blueAddress + "\n");
    
  //set values for green and blue fixture channels directly
  test.setChannel("green",200);
  test.setChannel("blue",255);

  test.addTrait("RGBColor", new RGBColorTrait(test));
  ((RGBColorTrait)test.trait("RGBColor")).setColorRGB(#FEDCBA);

}


/* example of a simple hue rotation on a single fixture */

void draw(){
  colorMode(HSB);
  colortemp = color(huetemp,255,255);  
  ((RGBColorTrait)test.trait("RGBColor")).setColorRGB(colortemp); 
  huetemp++;
  huetemp %= 256;
  drawChannelGrid();
}


/* simple DMX visualization - displays grid of controller channels, values represented as grayscale levels */

void drawChannelGrid(){
  colorMode(RGB);
  for (int ctrlr = 0; ctrlr < DMXManager.controllers.size(); ctrlr++) {
    DMX.Controller ctrl = (DMX.Controller)DMXManager.controllers.get(ctrlr);
    int univSize = ctrl.universeSize();
    for (int row = 0; row <= ceil(univSize / 32); row++){
      for (int col = 0; (col < 32) && (row * 32 + col < univSize); col++){
        int val = ctrl.getChannelUnsigned(row * 32 + col);
        fill(val, 0, 0);
        stroke(255);
        rect((col*8),(row*8)+ctrlr*160,8,8);
      }
    }
  }
}
