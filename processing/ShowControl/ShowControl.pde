import syzygryd.*;
import processing.serial.*;
import processing.core.*;


void setup(){
  

  /* testing code*/
  DMX DMXManager = new DMX(this, 44);
  DMXManager.addController("COM1");

  DMXManager.setChannel(0,1,255);
  
  Fixture test = new Fixture(DMXManager, "cube");

}

void draw(){
}



