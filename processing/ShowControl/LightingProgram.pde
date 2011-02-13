abstract class LightingProgram {
  
  LightingProgram(){
    print("Adding program.\n");
    programList.add(this);
  }
  
  void initialize() {
  }
  
  void drawFrame(){
  }
  
  void advance(float elapsedTime) {
  }
  
  void render(LightingState state) {
  }
}

// ----------------------------------------------------- Test Lighting Program -------------------------------------------------------- 

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
  int cubeNum = 0;
  int frameCount = 0;
  
 void drawFrame(){
   frameCount++;
   if (frameCount > FRAMERATE*3) {
     frameCount = 0;
     
//     new SetColor(arm[0].members.get(0), 10, color(#ff0000));  //set start color on base layer
//     new FadeTo(arm[0].members.get(0), 9, now(), 3000, color(#880000));    

     // Three seconds have passed...

     new SetColor(arm[0].members.get(cubeNum), 10, color(#000000));  //set start color on base layer
     new FadeTo(arm[0].members.get(cubeNum), 10, now(), 1000, color(#ff0000));
     new FadeTo(arm[0].members.get(cubeNum), 10, now()+1000, 1000, color(#00ff00));     
     new FadeTo(arm[0].members.get(cubeNum), 10, now()+2000, 1000, color(#0000ff));
     
     println("called frame");
     
     // Only go to 10
     cubeNum++;
     if (cubeNum > 9) {
       cubeNum = 0;
     }
   }
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

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 3
**   tab-width: 3
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=3 tabstop=3 expandtab cindent shiftwidth=3
**
*/
