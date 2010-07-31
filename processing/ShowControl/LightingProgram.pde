class LightingProgram {

  LightingProgram(){
  }
  
  void initialize() {
    ((RGBColorMixingTrait)test.trait("RGBColorMixing")).setColorRGB(color(0,255,0));  //set start color   
    ((RGBColorMixingTrait)test2.trait("RGBColorMixing")).setColorRGB(color(128,64,256));  //set start color   
    
    new FadeBehavior(test, 0, now()+10000, 10000, color(#ffffff)).blendMode = BLEND;  // wait 10 secs, then fade to white over 10 secs
    new FadeBehavior(test, 0, now()+20000, 10000, color(#000000));  // wait 10 secs, then fade to black over 10 secs
    new HueRotateBehavior(test, 10); // color cycling    
  }
  
  void drawFrame() {
  }
}

