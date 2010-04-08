import syzygryd.*;
import processing.serial.*;
import processing.core.*;


void setup(){
  

  /* testing code*/
  DMX DMXManager = new DMX(this, 44);
  DMXManager.addController("foo");
  DMXManager.addController("bar",512);
  DMXManager.addController("buff",9600,512);
  DMXManager.setChannel(0,1,255);
  
  Fixture test = new Fixture("cube");
  test.addProp("StrobeRate");
  print("Fixture type: " + test.type + "\n");
  print("Red Component: " + red(test.lightColor)+"\n");
  
  Iterator i = test.props.keySet().iterator();
  while (i.hasNext()) {
    print(i.next()+"\n");
  }
}

void draw(){
}



