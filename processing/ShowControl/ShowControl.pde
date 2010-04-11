import syzygryd.*;
import processing.serial.*;
import processing.core.*;

DMX DMXManager;

void setup(){
  
  /* testing code*/
  size(257,449);
  background(0);
  colorMode(RGB);
  
  //create new DMX manager object with a refresh rate of 44Hz
  DMXManager = new DMX(this, 44);
  
  //add three controllers to manager
  DMXManager.addController("COM1");
  DMXManager.addController("COM3");
  DMXManager.addController("COM4");

  //set DMX channels directly 
  DMXManager.setChannel(0,0,(byte)255);
  DMXManager.setChannel(0,3,(byte)189);
  DMXManager.setChannel(1,511,(byte)128);
  DMXManager.setChannel(1,34,(byte)128);
  
  //create a test fixture on controller 0
  Fixture test = new Fixture(DMXManager, 0, "cube");
  
  //add red and green channels, allowing DMX manager to assign addresses 
  int redAddress = test.addChannel("red");
  print("Assigned red address = " + redAddress + "\n");
  int greenAddress = test.addChannel("green");
  print("Assigned green address = " + greenAddress + "\n");
  
  //add blue channel at DMX address 256
  int blueAddress = test.addChannel("blue", 256);
  print("Assigned blue address = " + blueAddress + "\n");
  
  //set values for green and blue channels
  test.setChannel("green",200);
  test.setChannel("blue",255);

}

void draw(){
  
  //display grid of controller channels, values represnted as grayscale levels
  for (int ctrlr = 0; ctrlr < DMXManager.controllers.size(); ctrlr++) {
    DMX.Controller ctrl = (DMX.Controller)DMXManager.controllers.get(ctrlr);
    int univSize = ctrl.universeSize();
    for (int row = 0; row < ceil(univSize / 32); row++){
      for (int col = 0; col < 32; col++){
        int val = ctrl.getChannelUnsigned(row * 32 + col);
        fill(val);
        stroke(255);
        rect((col*8),(row*8)+ctrlr*160,8,8);
      }
    }
  }
  
}



