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

    new SetColor(arm[0], 10, color(#00ff00));  //set start color on base layer

    new HueRotate(arm[0], 10); // begin color cycling on base layer
    
    new FadeTo(arm[0], 9, now()+10000, 10000, color(#ffffff));  // wait 10 secs, then fade to white over 10 secs
    new FadeTo(arm[0], 8, now()+20000, 10000, color(#000000));  // wait 20 secs, then fade to black over 10 secs
    new FadeTo(arm[0], 7, now()+30000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 30 secs, then fade up underlying animation over 30 secs
  }
}

class TestProgram2 extends LightingProgram{
 
  void initialize() {
    
    new SetColor(arm[0], 10, color(#ff0000));  //set start color
     
    new FadeTo(arm[0], 9, 10000, color(#ffffff));  // fade to white over 10 secs
    new FadeTo(arm[0], 8, now()+10000, 10000, color(#000000));  // wait 10 secs, then fade to black over 10 secs
    new FadeTo(arm[0], 7, now()+20000, 30000, color(#ffffff)).blendMode=MULTIPLY;  // wait 20 secs, then fade up underlying animation over 30 secs
  }
  
  void drawFrame(){
    ((RGBColorMixingTrait)arm[0].trait("RGBColorMixing")).setColorRGB(color(255,0,0));  //set start color   
  }
}

