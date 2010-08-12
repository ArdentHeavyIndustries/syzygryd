abstract class LightingProgram {
  
  LightingProgram(){
    print("Adding program.\n");
    programList.add(this);
  }
  
  void initialize() {
  }
  
  void drawFrame() {
  }
}

/* ----------------------------------------------------- Lighting Programs -------------------------------------------------------- */

class TestProgram extends LightingProgram{
 
  void initialize() {

    new SetColor(arm[0], 10, color(#ff0000));  //set start color on base layer
    new SetColor(arm[1], 10, color(#00ff00));  //set start color on base layer
    new SetColor(arm[2], 10, color(#0000ff));  //set start color on base layer

    new HueRotate(arm[0], 10); // begin color cycling on base layer
    new HueRotate(arm[1], 10); // begin color cycling on base layer
    new HueRotate(arm[2], 10); // begin color cycling on base layer
    
    new FadeTo(arm[0], 9, now()+10000, 10000, color(#ffffff));  // wait 10 secs, then fade to white over 10 secs
    new FadeTo(arm[0], 8, now()+20000, 10000, color(#000000));  // wait 20 secs, then fade to black over 10 secs
    new FadeTo(arm[0], 7, now()+30000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 30 secs, then fade up underlying animation over 30 secs
    new FadeTo(arm[1], 9, now()+10000, 10000, color(#ffffff));  // wait 10 secs, then fade to white over 10 secs
    new FadeTo(arm[1], 8, now()+20000, 10000, color(#000000));  // wait 20 secs, then fade to black over 10 secs
    new FadeTo(arm[1], 7, now()+30000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 30 secs, then fade up underlying animation over 30 secs
    new FadeTo(arm[2], 9, now()+10000, 10000, color(#ffffff));  // wait 10 secs, then fade to white over 10 secs
    new FadeTo(arm[2], 8, now()+20000, 10000, color(#000000));  // wait 20 secs, then fade to black over 10 secs
    new FadeTo(arm[2], 7, now()+30000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 30 secs, then fade up underlying animation over 30 secs
  }
}

class TestProgram2 extends LightingProgram{
 
  void initialize() {
    
    new SetColor(arm[0], 10, color(#ff0000));  //set start color
     
    new FadeTo(arm[0], 9, 10000, color(#ffffff));  // fade to white over 10 secs
    new FadeTo(arm[0], 8, now()+10000, 10000, color(#000000));  // wait 10 secs, then fade to black over 10 secs
    new FadeTo(arm[0], 7, now()+20000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 20 secs, then fade up underlying animation over 30 secs
  } 
}

class PlayheadChaseProgram extends LightingProgram{
  LinkedList<Integer>[] chaseQueue = new LinkedList[3];
  
  void initialize(){
    for (int i = 0; i < 3; i++) {
      chaseQueue[i] = new LinkedList();
    }
    chaseQueue[0].addFirst(color(#ffffff));
  }
  
}
