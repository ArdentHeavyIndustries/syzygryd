import syzygryd.*;
import processing.serial.*;
import processing.core.*;
import guicomponents.*;

DMX DMXManager;
ArrayList fixtures;
int huetemp=0;
color colortemp, colortemp2; 
Fixture test, test2;

void setup(){
  
  /* example code*/
  colorMode(RGB);
  background(0);
  frameRate(30);
  
  //create new DMX manager object with a refresh rate of 40Hz
  DMXManager = new DMX(this, 40);
  
  //add three controllers to manager
  DMXManager.addController("COM5");
  DMXManager.addController("COM4");
  DMXManager.addController("COM3");


  //create fixtures via fixture factory
  try {
    setupFixtures();
  } catch (DataFormatException e) {
    print("An error occurred while parsing fixtures: " + e.getMessage() + "\n");
    exit();
  }
  
  //manually create two test fixtures on controller 0
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
  
  // create controller displays
  displayControllers(24);
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
 }



